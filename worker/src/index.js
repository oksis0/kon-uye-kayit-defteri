// ============================================================================
// Ortak Pay Defteri — Cloudflare Worker
// ----------------------------------------------------------------------------
// Bu Worker, Flutter uygulaması ile Azure Document Intelligence (OCR) ve
// Cloudflare R2 (dosya deposu) arasında bir kapı bekçisi (gatekeeper) görevi
// görür. Amaç: Azure API anahtarının hiçbir zaman istemci uygulamasına
// (derlenmiş .exe/.apk) gömülmemesi — anahtar sadece burada, Worker Secret
// olarak duruyor.
//
// R2 erişimi "binding" üzerinden yapılıyor (env.BELGELER) — bu yüzden R2 için
// ayrıca bir access key/secret oluşturmaya gerek yok.
//
// Beklenen Worker Secrets (wrangler secret put ile ayrı ayrı set edilir):
//   AZURE_ENDPOINT      -> örn. https://xxx.cognitiveservices.azure.com
//   AZURE_ANAHTAR       -> Azure Document Intelligence API anahtarı
//   FIREBASE_PROJECT_ID -> Firebase proje kimliği (JWT "aud" doğrulaması için)
//   YETKILI_UID         -> Tek yetkili Firebase kullanıcısının UID'si
// ============================================================================

// Azure Document Intelligence REST API sürümü (prebuilt-layout modeli).
const AZURE_API_SURUMU = "2024-11-30";

// Firebase ID token'larını imzalayan Google servis hesabının JWKS adresi.
const FIREBASE_JWKS_URL =
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";

// JWKS önbelleği için Cache API'de kullanılacak sahte istek anahtarı.
const JWKS_CACHE_ANAHTARI = new Request(
  "https://ortak-defteri-worker.internal/firebase-jwks-onbellek"
);

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const { pathname } = url;
    const yontem = request.method;

    try {
      // ---- /saglik: auth gerektirmeyen tek uç nokta ----
      if (pathname === "/saglik") {
        if (yontem !== "GET") {
          return jsonYanit({ hata: "Desteklenmeyen HTTP metodu" }, 405);
        }
        return jsonYanit({ durum: "ok" });
      }

      // ---- Bu noktadan sonraki her uç nokta yetkilendirme ister ----
      const yetkiHatasi = await yetkiKontroluYap(request, env);
      if (yetkiHatasi) {
        return yetkiHatasi;
      }

      // ---- OCR: Azure analiz işlemini başlat ----
      if (pathname === "/ocr/basla") {
        if (yontem !== "POST") {
          return jsonYanit({ hata: "Desteklenmeyen HTTP metodu" }, 405);
        }
        return await ocrBaslat(request, env);
      }

      // ---- OCR: Tek seferlik durum sorgusu (poll döngüsü istemcide) ----
      if (pathname.startsWith("/ocr/durum/")) {
        if (yontem !== "GET") {
          return jsonYanit({ hata: "Desteklenmeyen HTTP metodu" }, 405);
        }
        const operationId = decodeURIComponent(
          pathname.slice("/ocr/durum/".length)
        );
        if (!operationId) {
          return jsonYanit({ hata: "operationId eksik" }, 400);
        }
        return await ocrDurumSorgula(operationId, env);
      }

      // ---- Belge: R2 üzerinde CRUD (create/read/delete) ----
      if (pathname.startsWith("/belge/")) {
        const anahtar = decodeURIComponent(pathname.slice("/belge/".length));
        if (!anahtar) {
          return jsonYanit({ hata: "Belge anahtarı eksik" }, 400);
        }

        if (yontem === "PUT") {
          return await belgeYukle(anahtar, request, env);
        }
        if (yontem === "GET") {
          return await belgeGetir(anahtar, env);
        }
        if (yontem === "DELETE") {
          return await belgeSil(anahtar, env);
        }
        return jsonYanit({ hata: "Desteklenmeyen HTTP metodu" }, 405);
      }

      // ---- Bilinmeyen rota ----
      return jsonYanit({ hata: "Bulunamadı" }, 404);
    } catch (err) {
      // Beklenmedik her hata için genel bir güvenlik ağı.
      return jsonYanit(
        { hata: `Beklenmeyen sunucu hatası: ${err.message}` },
        500
      );
    }
  },
};

// ============================================================================
// OCR — Azure Document Intelligence proxy
// ============================================================================

/**
 * Ham görsel byte'larını Azure'un prebuilt-layout modeline gönderip
 * asenkron analizi başlatır. Azure 202 döner ve Operation-Location
 * header'ında sonucun nereden sorgulanacağını belirtir. Worker bu URL'den
 * operationId'yi çıkarıp istemciye döner — SONUCU BEKLEMEZ.
 */
async function ocrBaslat(request, env) {
  const gorselVerisi = await request.arrayBuffer();
  const icerikTuru = request.headers.get("Content-Type") || "image/jpeg";
  const azureUrl = `${env.AZURE_ENDPOINT}/documentintelligence/documentModels/prebuilt-layout:analyze?api-version=${AZURE_API_SURUMU}`;

  let azureYaniti;
  try {
    azureYaniti = await fetch(azureUrl, {
      method: "POST",
      headers: {
        "Content-Type": icerikTuru,
        "Ocp-Apim-Subscription-Key": env.AZURE_ANAHTAR,
      },
      body: gorselVerisi,
    });
  } catch (err) {
    return jsonYanit(
      { hata: `Azure Document Intelligence'a bağlanılamadı: ${err.message}` },
      502
    );
  }

  if (azureYaniti.status !== 202) {
    const hataMetni = await guvenliMetinOku(azureYaniti);
    return jsonYanit(
      {
        hata: `Azure OCR analizi başlatılamadı (durum ${azureYaniti.status}): ${hataMetni}`,
      },
      502
    );
  }

  const operationLocation =
    azureYaniti.headers.get("Operation-Location") ||
    azureYaniti.headers.get("operation-location");

  if (!operationLocation) {
    return jsonYanit(
      { hata: "Azure yanıtında Operation-Location başlığı bulunamadı" },
      502
    );
  }

  // Operation-Location şu formatta gelir:
  //  .../analyzeResults/{operationId}?api-version=...
  // operationId'yi son path segmentinden çıkarıyoruz.
  const opUrl = new URL(operationLocation);
  const parcalar = opUrl.pathname.split("/").filter(Boolean);
  const operationId = parcalar[parcalar.length - 1];

  return jsonYanit({ operationId });
}

/**
 * Azure'un Get Analyze Result uç noktasına TEK bir sorgu yapar ve Azure'un
 * "status" alanını Türkçe bir zarfa (bekliyor/bitti/hata) çevirir.
 * ÖNEMLİ: Burada bekleme/poll döngüsü YOK — istemci periyodik çağırır.
 */
async function ocrDurumSorgula(operationId, env) {
  const azureUrl = `${env.AZURE_ENDPOINT}/documentintelligence/documentModels/prebuilt-layout/analyzeResults/${operationId}?api-version=${AZURE_API_SURUMU}`;

  let azureYaniti;
  try {
    azureYaniti = await fetch(azureUrl, {
      method: "GET",
      headers: { "Ocp-Apim-Subscription-Key": env.AZURE_ANAHTAR },
    });
  } catch (err) {
    return jsonYanit(
      { hata: `Azure Document Intelligence'a bağlanılamadı: ${err.message}` },
      502
    );
  }

  if (!azureYaniti.ok) {
    const hataMetni = await guvenliMetinOku(azureYaniti);
    return jsonYanit(
      {
        hata: `Azure durum sorgusu başarısız (durum ${azureYaniti.status}): ${hataMetni}`,
      },
      502
    );
  }

  let veri;
  try {
    veri = await azureYaniti.json();
  } catch (err) {
    return jsonYanit(
      { hata: `Azure yanıtı JSON olarak ayrıştırılamadı: ${err.message}` },
      502
    );
  }

  const azureDurumu = veri.status; // "notStarted" | "running" | "succeeded" | "failed"

  if (azureDurumu === "succeeded") {
    return jsonYanit({ durum: "bitti", sonuc: veri });
  }

  if (azureDurumu === "failed") {
    const mesaj =
      (veri.error && veri.error.message) || "Bilinmeyen Azure OCR hatası";
    return jsonYanit({ durum: "hata", mesaj });
  }

  // "notStarted", "running" veya beklenmeyen bir durum -> hâlâ bekleniyor.
  return jsonYanit({ durum: "bekliyor" });
}

// ============================================================================
// Belge — R2 CRUD (binding üzerinden, access key YOK)
// ============================================================================

/** Görsel byte'larını R2'ye yazar. */
async function belgeYukle(anahtar, request, env) {
  const icerikTuru = request.headers.get("Content-Type") || "application/octet-stream";

  try {
    await env.BELGELER.put(anahtar, request.body, {
      httpMetadata: { contentType: icerikTuru },
    });
  } catch (err) {
    return jsonYanit({ hata: `R2'ye yazılamadı: ${err.message}` }, 502);
  }

  return jsonYanit({ durum: "ok" });
}

/** R2'den görsel byte'larını okuyup uygun Content-Type ile döner. */
async function belgeGetir(anahtar, env) {
  let nesne;
  try {
    nesne = await env.BELGELER.get(anahtar);
  } catch (err) {
    return jsonYanit({ hata: `R2'den okunamadı: ${err.message}` }, 502);
  }

  if (!nesne) {
    return jsonYanit({ hata: "Belge bulunamadı" }, 404);
  }

  const icerikTuru =
    (nesne.httpMetadata && nesne.httpMetadata.contentType) ||
    "application/octet-stream";

  return new Response(nesne.body, {
    status: 200,
    headers: { "Content-Type": icerikTuru },
  });
}

/** R2'den nesneyi siler. Nesne zaten yoksa da başarı döner (idempotent). */
async function belgeSil(anahtar, env) {
  try {
    await env.BELGELER.delete(anahtar);
  } catch (err) {
    return jsonYanit({ hata: `R2'den silinemedi: ${err.message}` }, 502);
  }
  return jsonYanit({ durum: "ok" });
}

// ============================================================================
// Yetkilendirme — Firebase ID Token (JWT) doğrulaması
// ----------------------------------------------------------------------------
// Harici bir kütüphane KULLANILMIYOR — Workers'ın native Web Crypto API'si
// (crypto.subtle) ile RS256 imza doğrulaması yapılıyor.
// ============================================================================

/**
 * İsteği kontrol eder; sorun varsa doğrudan dönülecek bir Response,
 * sorun yoksa null döner.
 */
async function yetkiKontroluYap(request, env) {
  const authHeader = request.headers.get("Authorization");

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return jsonYanit(
      { hata: "Authorization header eksik veya 'Bearer <token>' formatında değil" },
      401
    );
  }

  const token = authHeader.slice("Bearer ".length).trim();
  if (!token) {
    return jsonYanit({ hata: "Token boş" }, 401);
  }

  try {
    await firebaseTokenDogrula(token, env);
    return null; // her şey yolunda
  } catch (err) {
    return jsonYanit({ hata: `Yetkilendirme başarısız: ${err.message}` }, 401);
  }
}

/**
 * Firebase ID Token'ı uçtan uca doğrular:
 *  1) JWT yapısı ve alg == RS256
 *  2) Google JWKS'ten kid'e uyan açık anahtar bulunur
 *  3) RSASSA-PKCS1-v1_5 / SHA-256 imza doğrulaması (Web Crypto)
 *  4) exp (süre), aud (proje kimliği), iss (issuer), sub (YETKILI_UID)
 *
 * Herhangi bir adım başarısız olursa Error fırlatır.
 */
async function firebaseTokenDogrula(token, env) {
  const parcalar = token.split(".");
  if (parcalar.length !== 3) {
    throw new Error("Geçersiz token formatı");
  }
  const [headerB64, payloadB64, imzaB64] = parcalar;

  const header = base64UrlToJson(headerB64);
  const payload = base64UrlToJson(payloadB64);

  if (header.alg !== "RS256") {
    throw new Error("Desteklenmeyen imza algoritması");
  }
  if (!header.kid) {
    throw new Error("Token başlığında 'kid' yok");
  }

  const jwkListesi = await firebaseJwksAl();
  const eslesenJwk = jwkListesi.find((k) => k.kid === header.kid);
  if (!eslesenJwk) {
    throw new Error("Token imzasını doğrulayacak açık anahtar bulunamadı");
  }

  const genelAnahtar = await crypto.subtle.importKey(
    "jwk",
    eslesenJwk,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["verify"]
  );

  const imzalananVeri = new TextEncoder().encode(`${headerB64}.${payloadB64}`);
  const imzaBytes = base64UrlToBytes(imzaB64);

  const imzaGecerliMi = await crypto.subtle.verify(
    "RSASSA-PKCS1-v1_5",
    genelAnahtar,
    imzaBytes,
    imzalananVeri
  );
  if (!imzaGecerliMi) {
    throw new Error("Token imzası doğrulanamadı");
  }

  // ---- Payload doğrulamaları ----
  const simdi = Math.floor(Date.now() / 1000);
  if (!payload.exp || payload.exp < simdi) {
    throw new Error("Token süresi dolmuş");
  }

  if (payload.aud !== env.FIREBASE_PROJECT_ID) {
    throw new Error("Geçersiz audience (aud)");
  }

  const beklenenIss = `https://securetoken.google.com/${env.FIREBASE_PROJECT_ID}`;
  if (payload.iss !== beklenenIss) {
    throw new Error("Geçersiz issuer (iss)");
  }

  // ★ En kritik kontrol: tek yetkili ortak hesabın UID'si.
  if (payload.sub !== env.YETKILI_UID) {
    throw new Error("Bu hesap için yetki yok");
  }

  return payload;
}

/**
 * Google'ın Firebase JWKS'ini indirir. Cloudflare Cache API ile önbelleğe
 * alınır ki her istekte tekrar indirilmesin.
 */
async function firebaseJwksAl() {
  const onbellek = caches.default;

  let yanit = await onbellek.match(JWKS_CACHE_ANAHTARI);
  if (!yanit) {
    const googleYaniti = await fetch(FIREBASE_JWKS_URL);
    if (!googleYaniti.ok) {
      throw new Error("Google JWKS uç noktasına ulaşılamadı");
    }

    // Cache API'ye yazabilmek için Cache-Control header'ı gerekiyor;
    // Google'ın döndürdüğü değeri koruyoruz, yoksa 1 saatlik varsayılan.
    yanit = new Response(googleYaniti.body, googleYaniti);
    if (!yanit.headers.has("Cache-Control")) {
      yanit.headers.set("Cache-Control", "max-age=3600");
    }
    await onbellek.put(JWKS_CACHE_ANAHTARI, yanit.clone());
  }

  const govde = await yanit.json();
  return govde.keys;
}

// ============================================================================
// Yardımcı fonksiyonlar
// ============================================================================

/** Standart JSON Response üretir. */
function jsonYanit(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
}

/** Base64url string'i Uint8Array'e çevirir. */
function base64UrlToBytes(base64url) {
  const base64 = base64url.replace(/-/g, "+").replace(/_/g, "/");
  const dolgu = base64 + "=".repeat((4 - (base64.length % 4)) % 4);
  const binaryString = atob(dolgu);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}

/** Base64url string'i JSON nesnesine çevirir (JWT header/payload için). */
function base64UrlToJson(base64url) {
  const bytes = base64UrlToBytes(base64url);
  const text = new TextDecoder().decode(bytes);
  return JSON.parse(text);
}

/** Bir Response'un gövdesini hata mesajı için güvenle metne çevirir. */
async function guvenliMetinOku(response) {
  try {
    return await response.text();
  } catch (err) {
    return "(yanıt gövdesi okunamadı)";
  }
}
