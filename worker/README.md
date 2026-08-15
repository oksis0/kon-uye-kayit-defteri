# Ortak Pay Defteri — Cloudflare Worker

Bu Worker, Flutter uygulaması ile Azure Document Intelligence (OCR) ve
Cloudflare R2 (dosya deposu) arasında bir kapı bekçisi (gatekeeper) görevi
görür. Azure API anahtarı ve R2 erişimi hiçbir zaman istemci uygulamasına
(derlenmiş .exe/.apk) gömülmez — sadece burada, Worker Secret olarak durur.

## Uç noktalar

| Metod  | Yol                        | Auth | Açıklama                                   |
|--------|----------------------------|------|---------------------------------------------|
| GET    | `/saglik`                  | Hayır| Bağlantı testi — `{"durum":"ok"}` döner    |
| POST   | `/ocr/basla`                | Evet | Görseli Azure'a gönderir, `operationId` döner |
| GET    | `/ocr/durum/:operationId`   | Evet | Azure'dan tek seferlik durum sorgusu       |
| PUT    | `/belge/:anahtar`           | Evet | Görseli R2'ye yazar                        |
| GET    | `/belge/:anahtar`           | Evet | Görseli R2'den okur                        |
| DELETE | `/belge/:anahtar`           | Evet | Görseli R2'den siler                       |

`/saglik` hariç tüm uç noktalar `Authorization: Bearer <Firebase ID Token>`
header'ı ister ve token'ın `sub` (UID) alanının `YETKILI_UID` secret'ına
tam olarak eşit olmasını zorunlu kılar.

## Ön koşullar

- Bir Cloudflare hesabı
- Bir Azure Document Intelligence kaynağı (endpoint + API anahtarı)
- Firebase projesinin proje kimliği ve tek yetkili kullanıcının UID'si
- Node.js (wrangler için)

## Kurulum ve ilk deploy

```bash
# 1) Bu klasöre gir
cd worker

# 2) Bağımlılıkları kur (sadece wrangler)
npm install

# 3) Wrangler'a global olarak da kurmak istersen (opsiyonel)
npm install -g wrangler

# 4) Cloudflare hesabınla giriş yap (tarayıcı açılır)
npx wrangler login

# 5) R2 bucket'ını oluştur (bir kereye mahsus)
npx wrangler r2 bucket create ortak-defteri-belgeler

# 6) Secret'ları TEK TEK yükle — her komut sonrası değeri terminale
#    yapıştırman istenecek (kodun içine YAZILMAZ)
npx wrangler secret put AZURE_ENDPOINT
npx wrangler secret put AZURE_ANAHTAR
npx wrangler secret put FIREBASE_PROJECT_ID
npx wrangler secret put YETKILI_UID

# 7) Deploy et
npx wrangler deploy
```

Deploy sonrası Wrangler sana bir URL verir
(örn. `https://ortak-defteri-worker.<hesap-adi>.workers.dev`). Bu URL'yi
Flutter uygulamasının ayarlar ekranına Worker adresi olarak gireceksin.

## Secret'ları güncelleme / kontrol etme

```bash
# Bir secret'ı güncellemek için aynı komutu tekrar çalıştır (üzerine yazar)
npx wrangler secret put AZURE_ANAHTAR

# Hangi secret'ların tanımlı olduğunu görmek için (değerler gösterilmez)
npx wrangler secret list
```

## Yerel geliştirme (`wrangler dev`)

Yerel testte gerçek secret'ları Cloudflare'e yüklemeden, `.dev.vars` adlı
bir dosyayla çalışabilirsin. Bu dosya **asla git'e girmez**
(`worker/.dev.vars` zaten proje kökündeki `.gitignore`'da tanımlı).

```bash
cd worker

# Örnek dosyayı kopyala ve gerçek değerlerini gir
cp .dev.vars.example .dev.vars
# .dev.vars dosyasını aç, AZURE_ENDPOINT / AZURE_ANAHTAR /
# FIREBASE_PROJECT_ID / YETKILI_UID değerlerini gerçek değerlerle doldur

# Yerel sunucuyu başlat (varsayılan olarak http://localhost:8787)
npx wrangler dev
```

`wrangler dev` çalışırken R2 binding'i de yerel bir simülasyon
(miniflare) üzerinden çalışır; gerçek bucket'a dokunmak istersen
`wrangler dev --remote` kullanabilirsin.

### Örnek test isteği

```bash
# Sağlık kontrolü (auth gerekmez)
curl http://localhost:8787/saglik

# Belge yükleme (Firebase ID token'ını Flutter tarafında al)
curl -X PUT "http://localhost:8787/belge/belgeler%2F2026%2F08%2Ftest.jpg" \
  -H "Authorization: Bearer <ID_TOKEN>" \
  -H "Content-Type: image/jpeg" \
  --data-binary @ornek.jpg
```

## Canlı logları izleme

```bash
npx wrangler tail
```

## Dosya yapısı

- `src/index.js` — Worker'ın tüm mantığı (routing, Azure proxy, R2 CRUD,
  Firebase JWT doğrulaması)
- `wrangler.toml` — Worker adı, R2 binding, compatibility_date
- `package.json` — wrangler devDependency olarak tanımlı
- `.dev.vars.example` — yerel geliştirme için örnek değişken şablonu
  (gerçek `.dev.vars` git'e girmez)
