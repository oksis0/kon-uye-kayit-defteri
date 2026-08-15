# Ortak Pay Defteri — Dijitalleştirme Uygulaması / Uygulama Planı

> Sürüm: **2.0** · Tarih: 2026-08-15 · Durum: **Onay bekliyor**
> Flutter 3.44.8 · Dart 3.12.2

---

## 0. Özet

El yazısı "Ortak Pay Defteri" sayfalarını tarayıp OCR ile dijitalleştiren, ortak
bilgileri üzerinde hızlı arama yapan işletme içi masaüstü/mobil uygulama.

**Karar özeti:**

| Konu | Karar | Neden |
|---|---|---|
| Yerel DB | **Drift** (sqlite3) | Windows dahil tüm platformlarda sağlam; tam SQL → arama motorumuz bu |
| Bulut DB | **Firestore** | Kullanıcı tercihi. Arama zayıflığı "yerel-öncelikli arama" ile telafi edildi |
| Giriş | **Firebase Auth — tek ortak hesap** | Tek kullanıcı adı/şifre. Kayıt ol ekranı yok, UID kurala sabitlenmiş |
| Dosya deposu | **Cloudflare R2** | 10 GB ücretsiz, egress ücretsiz |
| Gizli anahtarlar | **Cloudflare Worker + R2 binding** | ★ R2 anahtarı hiç var olmuyor. Tek sır Azure anahtarı, o da sunucuda. **$0** |
| OCR | **Azure DI — `prebuilt-layout`** | `prebuilt-read`'in aksine **tabloları satır/sütun olarak** çıkarır. Aynı ücretsiz katman |
| State management | **Riverpod** (kod üretimli) | Async veri akışları için en az kalıp kod, derleme zamanı güvenlik |
| Navigasyon | **go_router** | Bildirimsel, masaüstü + mobil aynı kod |
| Model sınıfları | **Freezed** | Immutable model + `copyWith` + JSON, elle yazmaya gerek yok |

**Toplam maliyet: $0/ay.** Hiçbir serviste kredi kartı gerekmiyor. (Kota tablosu §9)

### Sürüm geçmişi
- **v1.0** — İlk plan (Worker'lı)
- **v1.1** — Anahtarlar cihaza alındı (kullanıcı kararı)
- **v2.0** — ★ Anahtarlar Worker'a geri alındı + **R2 binding** ile R2 anahtarı
  tamamen ortadan kaldırıldı; giriş **tek ortak hesaba** indirildi

---

## 1. Geliştirme ve Derleme Ortamı

**Karar:** Geliştirme **macOS'ta**, Windows `.exe` üretimi **GitHub Actions** ile.

```
macOS (geliştirme)          GitHub Actions (derleme)
  flutter run -d macos   →    windows-latest runner
  günlük test                  flutter build windows
                               → .exe artefaktı indirilebilir
```

**Neden çalışıyor:** Flutter'ın masaüstü kod yollarının ~%95'i macOS ve Windows'ta
aynıdır. Drift, Riverpod, go_router, dio, file_picker — hepsi ikisinde de
özdeş davranır. Gün içindeki geliştirmeyi macOS'ta yapıp, çıktıyı CI'dan alacağız.

### 1.1 Bu kararın gerektirdikleri

| Gereklilik | Ne zaman | Not |
|---|---|---|
| **Git deposu** | Faz 1, ilk iş | Klasör şu an git deposu değil — `git init` + GitHub'a push gerekiyor. CI olmazsa olmazı |
| macOS masaüstü desteği | Faz 1 | `flutter config --enable-macos-desktop` |
| CI iş akışı | Faz 1 sonunda (erken!) | `.github/workflows/windows-build.yml` |
| **Windows PC'de gerçek test** | Faz 1 sonu, Faz 4, Faz 8 | ✅ Ayrı Windows PC'n var — bu, CI'ın en zayıf noktasını kapatıyor |

> ⚠️ **CI derler, test etmez.** GitHub Actions `.exe`'yi üretir ama *çalıştırıp
> denemez*. Kod ~%95 ortak olsa da geri kalan %5'te sürprizler saklanır:
> - `flutter_secure_storage` → Windows Credential Manager vs macOS Keychain
>   (farklı arka uç, farklı hata davranışı)
> - Dosya yolu ayıracı → `path` paketi çözüyor ama elle string birleştirirsek patlar
> - `window_manager`, MSIX paketleme, taranan klasöre erişim izinleri
>
> **Ama senin ayrı Windows PC'n var** → bu boşluk kapanıyor. İki katmanlı yaklaşım:
> - **CI (her push):** derleniyor mu? `analyze` ve `test` geçiyor mu? → hızlı erken uyarı
> - **Windows PC (faz sonlarında):** `.exe`'yi gerçekten aç, çalıştır, dene
>
> Windows PC'de doğrudan `flutter build windows` de çalıştırabilirsin — CI'ın yerine
> değil, **yanına**. CI'ın asıl değeri "unutmayı imkânsız kılması".

### 1.2 CI kurulumu (Faz 1)

```yaml
# .github/workflows/windows-build.yml (özet)
on: [push, workflow_dispatch]
jobs:
  windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: {flutter-version: '3.44.8', channel: stable}
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test
      - run: flutter build windows --release --dart-define-from-file=env.json
      - uses: actions/upload-artifact@v4     # indirilebilir .exe
```

- `env.json` gizli değerler içermiyor (§12.1) ama yine de **GitHub Secret** olarak
  tutup adımda dosyaya yazacağız — repoya asla girmeyecek
- Repo **private** olacak → 2.000 dk/ay ücretsiz CI. Bu iş akışı ~4 dk sürer,
  ayda 500 push'a kadar rahat

---

## 2. Mimari

```
┌───────────────────────────────────────────────────────────┐
│                    FLUTTER UYGULAMASI                     │
│                                                           │
│   UI (features/) → Riverpod → Repository → Drift (yerel)  │
│                                   │                       │
│              ⚿ HİÇBİR GİZLİ ANAHTAR YOK                   │
└───────────────────┬───────────────┴───────────────────────┘
                    │
        ┌───────────┼───────────────┐
        ▼           ▼               ▼
┌──────────────┐ ┌────────────┐ ┌──────────────────────────┐
│  Firebase    │ │  Firebase  │ │   CLOUDFLARE WORKER      │
│  Auth        │ │  Firestore │ │   (kapı bekçisi)         │
│ (tek hesap)  │ │ (metadata) │ │                          │
└──────────────┘ └────────────┘ │  • Firebase token doğrula│
       │                        │  • UID sabit eşleşme     │
       └── ID Token ────────────▶│                         │
                                └────┬──────────────┬──────┘
                                     │ binding      │ secret
                                     ▼              ▼
                              ┌─────────────┐ ┌────────────┐
                              │Cloudflare R2│ │ Azure Doc  │
                              │ (görseller) │ │Intelligence│
                              │ ⚿ anahtar   │ │            │
                              │   YOK        │ │            │
                              └─────────────┘ └────────────┘
```

### 2.1 Neden Cloudflare Worker? (Bu planın en önemli kararı)

**Problem:** Azure OCR anahtarı uygulamaya gömülemez. `.exe` içindeki string'ler
`strings` komutuyla okunur; `--dart-define` de derlenmiş ikiliye gömülür,
**gizli değildir.**

**Klasik çözüm:** Firebase Cloud Functions.
**Engel:** Cloud Functions artık **Blaze planı = kredi kartı** zorunlu kılıyor.

**Bizim çözüm:** Cloudflare Worker.
- **Ücretsiz:** 100.000 istek/gün, **kredi kartı istemiyor**
- ~200 satır JavaScript, tek komutla deploy (`wrangler deploy`)
- R2 zaten Cloudflare'de → doğal entegrasyon

### 2.2 ★ R2 Binding: Sızacak anahtarın hiç var olmaması

Worker'a R2'yi iki şekilde bağlayabiliriz:

| Yöntem | R2 anahtarı | Flutter'da gereken |
|---|---|---|
| S3 API + erişim anahtarı | Worker Secret'ta durur (sızabilir bir sır **vardır**) | SigV4 imzalama kodu (~80 satır kripto) |
| **Binding** ✅ | ★ **Hiç oluşturulmaz** | Sadece `Bearer` başlıklı düz HTTP |

Binding'de bucket, Worker'ın çalışma ortamında `env.BELGELER` gibi bir **nesne**
olarak durur. Kimlik doğrulama Cloudflare altyapısı içinde yapılır — ortada
paylaşılan bir sır yoktur.

**Sonuç: Tüm sistemde tek bir gizli anahtar var — Azure anahtarı, o da sunucuda.**
Uygulamanın içinde sıfır sır. Bu, bütçe $0 iken ulaşılabilecek en iyi durum.

**Yan fayda:** Flutter tarafı belirgin sadeleşiyor — SigV4 imzalayıcı, `minio`
benzeri S3 bağımlılığı, imza hata ayıklaması… hiçbiri yok.

### 2.3 Worker uç noktaları

| Uç nokta | İş | Not |
|---|---|---|
| `POST /ocr/basla` | Görsel byte'larını alır → Azure'a iletir → `operationId` döner | Hemen döner, beklemez |
| `GET /ocr/durum/:id` | Azure'a tek bir durum sorgusu yapar → `bekliyor` \| `bitti` + JSON | ★ Bekleme döngüsü **uygulamada** — Worker süre limitine hiç yaklaşmıyor, ayrıca ilerleme gösterebiliyoruz |
| `PUT /belge/:anahtar` | Byte'ları R2'ye yazar (binding, streaming) | |
| `GET /belge/:anahtar` | R2'den okur, görseli döner | Uygulama yerel önbelleğe alır |
| `DELETE /belge/:anahtar` | R2'den siler | |
| `GET /saglik` | Ayarlar ekranındaki bağlantı testi | |

### 2.4 Worker'ın güvenlik kontrolü

Her istekte `Authorization: Bearer <Firebase ID Token>` başlığı beklenir:

1. JWT imzası Google'ın açık anahtarlarıyla doğrulanır
   *(anahtarlar Cache API ile önbelleklenir — her istekte indirilmez)*
2. `aud` alanı Firebase proje kimliğine eşit mi?
3. `exp` süresi geçmemiş mi?
4. ★ `sub` (UID) **sabit tek hesabın UID'sine** eşit mi?

Dördü de geçmezse **401**. Worker URL'i herkese açık olsa bile, geçerli token
olmadan tek byte veri çıkmaz.

### 2.5 Yerel-Öncelikli Arama (Firestore'un arama zayıflığının çözümü)

Firestore `LIKE '%yılmaz%'` yapamaz — sadece "ile başlayan" sorgusu destekler.
Ama veri hacmi küçük (≈2.000 ortak × ~1 KB):

```
Uygulama açılışı → Firestore'dan DELTA senkron (guncellemeTarihi > sonSenkron)
                 → Drift'e yaz
                 → TÜM ARAMALAR Drift üzerinde SQL ile
```

**Kazançlar:**
- Kısmi arama, çok alanlı arama, sıralama — hepsi SQL ile serbest
- Arama anlık (milisaniye), internet gerekmez
- Firestore okuma kotası korunur: ilk senkron 2.000 okuma, sonraki açılışlar ~5
  (günlük limit 50.000)
- **Çevrimdışı çalışır**

**Bedeli:** Her yeni cihaz ilk kurulumda tam senkron yapar (tek seferlik).

---

## 3. Klasör Yapısı

Katmanlı + özellik-öncelikli hibrit. Paylaşılan altyapı `core`/`data`'da,
ekranlar `features` altında kendi klasöründe.

```
lib/
├── main.dart                        # Firebase init, ProviderScope, runApp
│
├── app/
│   ├── app.dart                     # MaterialApp.router
│   ├── router.dart                  # go_router rotaları + giriş koruması
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart          # renk sabitleri (magic number YOK)
│       ├── app_typography.dart      # Display/Headline/Title/Body/Caption
│       └── app_spacing.dart         # 4/8/16/24/32/48/64
│
├── core/
│   ├── config/
│   │   ├── env.dart                 # --dart-define okuyucu (Worker URL, Firebase)
│   │   └── sabitler.dart
│   ├── hata/
│   │   ├── failure.dart             # sealed: AgHatasi, KotaDoldu, OcrHatasi...
│   │   └── sonuc.dart               # Result<T>
│   ├── util/
│   │   ├── turkce_normalize.dart    # ★ Türkçe arama normalizasyonu
│   │   ├── tarih_ayikla.dart        # el yazısı tarih formatları
│   │   ├── para_bicim.dart          # kuruş ↔ "1.250,50 ₺"
│   │   └── dosya_hash.dart          # sha256
│   └── widget/
│       ├── bos_durum.dart
│       ├── yukleniyor.dart
│       └── hata_gosterge.dart
│
├── data/
│   ├── yerel/
│   │   ├── veritabani.dart          # Drift AppDatabase
│   │   ├── tablolar/
│   │   │   ├── ortaklar_tablosu.dart
│   │   │   ├── defter_satirlari_tablosu.dart
│   │   │   ├── ice_aktarma_kuyrugu_tablosu.dart
│   │   │   └── uygulama_meta_tablosu.dart
│   │   ├── dao/
│   │   │   ├── ortak_dao.dart
│   │   │   └── kuyruk_dao.dart
│   │   └── gorsel_onbellek.dart     # R2'den çekilen görseller diskte
│   ├── uzak/
│   │   ├── auth_servisi.dart        # Firebase Auth sarmalayıcı
│   │   ├── firestore_servisi.dart   # Firestore CRUD
│   │   └── worker_istemcisi.dart    # ★ Worker'a tüm HTTP çağrıları (tek dosya)
│   ├── goruntu/
│   │   ├── goruntu_hazirlayici.dart # HEIC→JPEG, boyut küçültme, sıkıştırma
│   │   └── netlik_kontrol.dart      # Laplacian variance (Faz 8)
│   └── repository/
│       ├── ortak_repository.dart    # ★ Tek gerçek kaynak: Drift + Firestore
│       ├── belge_repository.dart    # Worker üzerinden R2 yükle/getir/sil
│       ├── ocr_repository.dart       # Worker → Azure → alan ayrıştırma
│       ├── kuyruk_repository.dart
│       └── yedek_repository.dart
│
├── domain/
│   ├── model/                       # Freezed — saf iş nesneleri
│   │   ├── ortak.dart
│   │   ├── defter_satiri.dart
│   │   ├── ice_aktarma_isi.dart
│   │   └── ocr_sonucu.dart
│   └── enum/
│       ├── kuyruk_durumu.dart
│       └── satir_turu.dart
│
└── features/
    ├── auth/
    │   ├── giris_ekrani.dart
    │   └── auth_provider.dart
    ├── arama/                       # ★ ANA EKRAN
    │   ├── arama_ekrani.dart
    │   ├── arama_provider.dart
    │   └── widget/
    │       ├── arama_cubugu.dart
    │       ├── ortak_kart.dart
    │       └── filtre_paneli.dart
    ├── ortak_detay/
    │   ├── ortak_detay_ekrani.dart
    │   ├── ortak_duzenle_ekrani.dart
    │   └── widget/
    │       ├── kimlik_bilgi_karti.dart
    │       ├── defter_tablosu.dart
    │       └── belge_onizleme.dart
    ├── ice_aktarma/
    │   ├── klasor_sec_ekrani.dart
    │   ├── kuyruk_ekrani.dart        # X/Y ilerleme
    │   ├── inceleme_ekrani.dart      # ★ OCR düzenleme formu
    │   ├── kuyruk_provider.dart
    │   └── widget/
    │       ├── ilerleme_cubugu.dart
    │       ├── alan_giris.dart       # güven skoruna göre renkli
    │       └── tablo_duzenleyici.dart
    ├── yedek/
    │   └── yedek_ekrani.dart
    └── ayarlar/
        ├── ayarlar_ekrani.dart
        └── kota_gosterge.dart

worker/                              # ★ Flutter dışı — Cloudflare Worker
├── src/index.js                     # ~200 satır
├── wrangler.toml                    # R2 binding tanımı
└── README.md                        # deploy adımları
```

**Katman kuralı (öğrenme notu):**
- `features` → sadece `domain` ve `repository`'yi bilir. Firestore'u, Drift'i **bilmez**
- `repository` → veri kaynaklarını gizler. UI "veri nereden geldi" bilmez
- `domain/model` → hiçbir şeyi bilmez, saf Dart. Test etmesi en kolay katman

Bu ayrım sayesinde ileride Firestore'dan başka bir servise geçmek istersen
sadece `data/uzak/` klasörünü değiştirirsin, 30+ ekran dosyasına dokunmazsın.

---

## 4. Veri Modeli

### 4.1 `Ortak`

| Alan | Tip | Not |
|---|---|---|
| `id` | String (uuid) | Birincil anahtar |
| `ortakNo` | String | **Benzersiz varsayılmıyor** — uyarı gösterilip kullanıcıya soruluyor |
| `adSoyad` | String | Tek zorunlu alan |
| `babaAdi` | String? | |
| `dogumYeri` | String? | |
| `dogumTarihiHam` / `dogumTarihi` | String? / DateTime? | Ham metin **her zaman** saklanır |
| `girisTarihiHam` / `girisTarihi` | String? / DateTime? | |
| `cikisTarihiHam` / `cikisTarihi` | String? / DateTime? | Boşsa ortak hâlâ aktif |
| `ikametAdresi` | String? | |
| `nufusKayitYeri` | String? | |
| `aramaAnahtari` | String | ★ Normalize edilmiş tüm metin alanları birleşik |
| `belgeR2Anahtari` | String | `belgeler/2026/08/uuid.jpg` |
| `ocrGuvenOrtalama` | double? | 0-1. Düşükse kartta uyarı rozeti |
| `aktif` | bool | ★ Soft delete |
| `pasifNedeni` / `pasifTarihi` | String? / DateTime? | |
| `olusturmaTarihi` / `guncellemeTarihi` | DateTime | Delta senkron bunu kullanır |
| `senkronDurumu` | enum | *sadece Drift'te*: `senkron` / `beklemede` / `hata` |

### 4.2 `DefterSatiri` (Sermaye Yüklenmeleri **ve** Ödemeler)

Sütun yapıları aynı olduğu için **tek model + `tur` alanı**. İki ayrı sınıf
yazmak kod tekrarı olurdu.

| Alan | Tip | Not |
|---|---|---|
| `id` | String | |
| `ortakId` | String | FK |
| `tur` | enum | `sermaye` \| `odeme` |
| `siraNo` | int | Tablodaki satır sırası |
| `tarihHam` / `tarih` | String? / DateTime? | |
| `no` | String? | |
| `madde` | String? | Defterdeki "Mad." sütunu |
| `aciklama` | String? | |
| **`miktarKurus`** | **int** | ★ aşağıdaki not |
| **`yekunKurus`** | **int** | |
| `miktarHam` / `yekunHam` | String? | OCR ham metni — denetim için |

> **★ Para neden `double` değil `int`?**
> `double` ikili kayan nokta kullanır: `0.1 + 0.2 == 0.30000000000000004`.
> Bir muhasebe defterinde bu kabul edilemez — toplamlar tutmaz.
> Tüm para değerleri **kuruş cinsinden tam sayı** (1.250,50 ₺ → `125050`).
> Ekranda `intl` ile biçimlendiriyoruz. Finansal yazılımın standart kuralı.

### 4.3 `IceAktarmaIsi` (kuyruk — sadece yerel)

| Alan | Tip | Not |
|---|---|---|
| `id` | String | |
| `dosyaYolu` / `dosyaAdi` | String | |
| `dosyaHash` | String | ★ sha256 — aynı dosya iki kez kuyruğa girmesin |
| `durum` | enum | `bekliyor`→`hazirlaniyor`→`ocrYapiliyor`→`onayBekliyor`→`tamamlandi` / `hata` / `atlandi` |
| `islendi` | bool | ★ İstenen `processed` alanı |
| `hataMesaji` | String? | |
| `denemeSayisi` | int | 3 denemeden sonra `hata` |
| `olusanOrtakId` | String? | |
| `ocrHamJson` | String? | ★ Azure'un ham cevabı — çökme sonrası OCR tekrar edilmesin (kota!) |
| `eklenmeTarihi` | DateTime | |

> **Neden dosya taşımıyoruz?** Çökme dayanıklılığı için — ama daha önemlisi:
> dosya taşımak/silmek geri alınamaz, veritabanı alanı geri alınabilir.
> `ocrHamJson`'ı saklamak da kota israfını önler: uygulama inceleme formundayken
> çökerse, açılışta OCR'ı tekrarlamadan forma döneriz.

### 4.4 Firestore Şeması

```
ortaklar/{ortakId}
  ├─ (Ortak'ın tüm alanları)
  └─ satirlar: [ {tur, siraNo, tarih, no, madde, aciklama, miktarKurus, yekunKurus}, ... ]
       ★ Alt koleksiyon DEĞİL, GÖMÜLÜ dizi

sistem/kota/{2026-08}
  ├─ ocrSayfaSayisi: 187
  └─ sonGuncelleme

silmeTalepleri/{id}        ← "hayalet veri" önleyici (§10.2)
  ├─ ortakId, r2Anahtari, adim: "r2" | "firestore" | "yerel"
  └─ olusturmaTarihi
```

> **Neden gömülü dizi?** Firestore'da alt koleksiyondaki her belge **ayrı okuma**
> sayılır. 20 satırlık ortak = 21 okuma → 2.000 ortak = **42.000 okuma**, günlük
> 50.000 limitini neredeyse doldurur. Gömülü dizide **2.000 okuma**. 20× tasarruf.
> Belge limiti 1 MiB, bizim en büyük kayıt ~15 KB.

> **Neden yerelde ayrı tablo, bulutta gömülü?** Yerelde SQL'in gücünü istiyoruz
> (JOIN, toplam, sıralama); bulutta okuma kotasını. Repository katmanı çeviriyi
> yapar, UI hiçbirini bilmez. **Repository deseninin tam olarak var olma nedeni budur.**

---

## 5. Türkçe Arama Normalizasyonu

```dart
// core/util/turkce_normalize.dart
const _harfHaritasi = {
  'ı':'i', 'İ':'i', 'I':'i',
  'ş':'s', 'Ş':'s',
  'ğ':'g', 'Ğ':'g',
  'ü':'u', 'Ü':'u',
  'ö':'o', 'Ö':'o',
  'ç':'c', 'Ç':'c',
  'â':'a', 'î':'i', 'û':'u',   // eski imla
};
String turkceNormalize(String girdi) { ... }
```

1. Küçük harfe çevir *(Türkçe I/ı tuzağı — bu yüzden manuel harf haritası)*
2. Aksanlı/özel harfleri katla
3. Noktalama temizle, çoklu boşluğu teke indir
4. Baş/son boşluk kırp

**Örnek:** `"Şükrü YILMAZOĞLU"` → `"sukru yilmazoglu"` · `"İSMAİL Çağrı"` → `"ismail cagri"`

- **Yazarken:** `aramaAnahtari = normalize("$adSoyad $babaAdi $ortakNo $dogumYeri $ikametAdresi $nufusKayitYeri")`
- **Ararken:** `WHERE aramaAnahtari LIKE '%' || :normalizeSorgu || '%'`

Sonuç: kullanıcı `sukru` yazar, `ŞÜKRÜ` bulunur. Klavye düzeni sorunu biter.

> **İleride (şimdi gerek yok):** SQLite FTS5. 2.000 kayıtta `LIKE` taraması <5ms.
> 50.000 kaydı geçersen geçeriz. **Erken optimizasyon yapmıyoruz** — bilinçli karar.

---

## 6. Görüntü Yakalama ve Hazırlama

### 6.1 Windows akışı

```
NAPS2 ile tara → klasöre kaydet → uygulamada "Klasör Seç" → kuyruk
```

**NAPS2 ayarları (tek seferlik — OCR doğruluğunu en çok bu etkiler):**

| Ayar | Değer | Neden |
|---|---|---|
| Format | **JPEG** | ★ PDF **seçme** — rasterize etmek fazladan iş ve hata kaynağı |
| Çözünürlük | **300 DPI** | El yazısı OCR'ın tatlı noktası. 600 DPI dosyayı büyütür, doğruluğu artırmaz |
| Renk | **Gri tonlama** | Renk bilgisi işe yaramıyor, dosya 3× küçülüyor |
| Kalite | %85 | 300 DPI A4 gri ≈ 1-2 MB → 4 MB limitinin altında |
| Dosya adı | `defter_$(nnnn)` | Sıralı isim → kuyruk sırası doğal |

### 6.2 Mobil akışı

`image_picker` (kamera + galeri). `camera` paketi şimdilik **gereksiz** — özel
canlı önizleme/kırpma arayüzü Faz 9'a ertelendi; `image_picker` sistem kamerasını
kullanıyor ve çok daha az kod.

### 6.3 Görüntü hazırlama hattı

```
Dosya → [1] Format → [2] Boyut → [3] Netlik → Azure
```

**[1] HEIC → JPEG**
Sadece iOS'ta karşımıza çıkar (tarayıcılar HEIC üretmez). `image_picker` iOS'ta
çoğunlukla otomatik JPEG'e çevirir ama **garanti değil** — dosyanın ilk
byte'larından (magic bytes) format tespiti yapıp gerekirse
`flutter_image_compress` ile dönüştüreceğiz (iOS'ta native ImageIO HEIC'i çözer).

**[2] Boyut kontrolü — 4 MB kuralı**
```
boyut <= 4MB  → HİÇ DOKUNMA (kaliteyi koru)
boyut >  4MB  → kademeli: q90 → kontrol → q75 → kontrol → q60 → kontrol
                hâlâ büyükse: en uzun kenar 2400px'e küçült, q75 ile tekrar
```

> ⚠️ **Plandaki bir düzeltme:** `flutter_image_compress`'in **Windows desteği
> güvenilir değil** (native eklenti Android/iOS/macOS odaklı). Windows birincil
> hedefimiz olduğu için:
> - **Masaüstünde:** saf Dart `image` paketi (decode → resize → `encodeJpg`).
>   Her platformda garantili. Yavaş olduğu için `Isolate.run()` içinde çalışacak,
>   arayüz donmayacak
> - **Mobilde:** `flutter_image_compress` (native, çok daha hızlı ve az bellek)
>
> Tek arayüz (`GoruntuHazirlayici`), iki uygulama. "Platform-özel strateji"
> deseninin ders kitabı örneği.

**[3] Netlik kontrolü (Faz 8 — öneriyorum ama zorunlu değil)**
- 640px'e küçült → gri tonla → Laplacian çekirdeği → varyans hesapla
- Eşik altındaysa: **"Bu belge bulanık görünüyor. Yine de gönderilsin mi?"**
- **Neden değerli:** ayda 500 sayfa kotan var; 20 bulanık sayfa kotanın %4'ü.
  Ayrıca kullanıcı 3 hafta sonra değil **o an** yeniden tarayabilir
- **Neden Faz 8:** eşiği gerçek örneklerle kalibre etmeden iyi belgeleri reddeder

---

## 7. OCR ve Onay Akışı

### 7.1 Azure model seçimi — ✅ `prebuilt-layout` (karar verildi)

| | `prebuilt-read` | `prebuilt-layout` |
|---|---|---|
| El yazısı | ✅ | ✅ |
| Ücretsiz katman | 500 sayfa/ay | 500 sayfa/ay (aynı) |
| Döndürdüğü | Düz metin satırları + koordinat | Satırlar + **`tables[]` (satır/sütun indeksli hücreler)** |
| Bizim tablolar | ❌ Koordinattan elle gruplamak gerekir | ✅ Hazır geliyor |

Sermaye/Ödemeler tabloların olduğu için **`prebuilt-layout` belirgin şekilde
daha uygun** — aynı fiyat, "hangi hücre hangi sütunda" problemini Azure çözüyor.
`read` ile bunu yazmak yüzlerce satır kırılgan koordinat matematiği demek.

> `read` tercih edersen mimari değişmez, sadece `ocr_repository.dart` içindeki
> ayrıştırıcı farklı olur.

### 7.2 Alan çıkarma stratejisi

Azure hiçbir hazır modelde "Baba Adı = Mehmet" diye vermez (o, eğitilmiş özel
model işi). İki aşama:

**Aşama 1 — Etiket eşleyici (Faz 5)**
- Sayfadaki **matbu etiketleri** ara (`"Ortak No"`, `"Adı Soyadı"`, `"Baba Adı"`…) —
  bunlar el yazısı değil, OCR'ları çok doğru
- Etiketin **sağındaki/altındaki** el yazısını koordinat yakınlığına göre eşle
- Tabloları `layout`'un `tables[]` çıktısından doğrudan al
- Türkçe etiket varyasyonlarına tolerans (`"Adı Soyadı"` / `"Ad Soyad"` / `"Adı ve Soyadı"`)

**Aşama 2 — Özel model (Faz 10, ancak gerekirse)**
Sayfa düzeni sabit şablon olduğu için Azure "custom extraction" modeli 5 etiketli
örnekle eğitilebilir. **Ama önce Aşama 1'in doğruluğunu gerçek 20 sayfada ölçelim** —
yeterliyse buraya hiç gelmeyiz.

> **Beklenti yönetimi (dürüst olmam gereken kısım):** El yazısı OCR mükemmel
> değildir. Türkçe el yazısında `ı/i`, `ş/s`, rakamlarda `1/7`, `0/6` karışır.
> **Bu yüzden onay formu bir "lüks" değil, sistemin ana parçası.**
> Uygulamayı "OCR yazar, insan onaylar" değil,
> **"insan yazar, OCR ön-doldurur"** zihniyetiyle tasarlıyoruz.
> Bu bakış arayüz tasarımını da belirliyor.

### 7.3 İnceleme (onay) ekranı

```
┌──────────────────────────┬──────────────────────────────────┐
│                          │  Ortak No    [ 147          ] ✓  │
│                          │  Adı Soyadı  [ Ahmet Yılmaz ] ✓  │
│    BELGE GÖRSELİ         │  Baba Adı    [ Mehmet       ] ⚠  │
│    (yakınlaştırılabilir) │  Doğum Yeri  [ Konya        ] ✓  │
│                          │  ...                             │
│    Alana tıklayınca      ├──────────────────────────────────┤
│    görselde ilgili       │  SERMAYE YÜKLENMELERİ            │
│    bölge vurgulanır ★    │  ┌─────┬──┬────┬───────┬───────┐ │
│                          │  │Tarih│No│Mad.│Açıkla.│Miktar │ │
│                          │  ├─────┼──┼────┼───────┼───────┤ │
│                          │  │ ... │..│ .. │  ...  │  ...  │ │
│                          │  └─────┴──┴────┴───────┴───────┘ │
│                          │  [+ Satır Ekle]                  │
│                          ├──────────────────────────────────┤
│                          │  [Atla]  [Kaydet ve Sıradaki →]  │
└──────────────────────────┴──────────────────────────────────┘
```

**Tasarım kararları:**
- ★ **Görsel ve form yan yana** — göz ekranlar arasında gezmez. Kullanıcı bu
  ekranda yüzlerce saat geçirecek; **en çok yatırım yapılacak ekran bu**
- ★ **Alan → görsel vurgusu:** Azure her alanın `boundingBox`'ını döndürüyor.
  Alana tıklayınca görselde o bölge çerçevelenip otomatik kaydırılıyor.
  Doğrulama hızını ciddi artırır
- **Güven skoru renklendirmesi:** `>0.9` nötr · `0.7–0.9` sarı kenarlık ·
  `<0.7` turuncu + otomatik odak. Kullanıcı önce riskli alanlara bakar
- **Klavye öncelikli:** `Tab` sonraki alan, `Ctrl+Enter` kaydet+sıradaki.
  Toplu işte fare yavaştır — masaüstünün avantajı bu
- **Boş bırakılabilir:** Tek zorunlu alan `adSoyad`. Defterde boş hücreler var

### 7.4 Yinelenen Ortak No kontrolü

Kaydet'e basınca `ortakNo` yerel Drift'te aranır. Bulunursa:

```
┌─────────────────────────────────────────────────┐
│  ⚠ Bu ortak no zaten kayıtlı                    │
│                                                 │
│  Kayıtlı: #147 · Ahmet Yılmaz                   │
│           12.03.2026 · Emirhan                  │
│           [mevcut kaydın küçük görseli]         │
│                                                 │
│  Yeni:    #147 · Ahmet Yılmaz                   │
│           [yeni belgenin küçük görseli]         │
│                                                 │
│  [ İptal ]  [ Yeni Kayıt Ekle ]  [ Üzerine Yaz ]│
└─────────────────────────────────────────────────┘
```

★ **İki görseli yan yana göstermek kritik** — "aynı sayfayı iki kez mi taradım,
yoksa gerçekten iki farklı kayıt mı?" sorusu ancak böyle yanıtlanır.
Metin karşılaştırması yetmez.

"Üzerine Yaz" seçilirse eski kayıt silinmez; `aktif: false` +
`pasifNedeni: "üzerine yazıldı"` olarak arşivlenir.
**Hiçbir yol veri kaybına çıkmıyor.**

---

## 8. Toplu İçe Aktarma Kuyruğu

```
1. "Klasör Seç"  → file_picker.getDirectoryPath()
2. Klasörü tara  → *.jpg, *.jpeg, *.png
3. Her dosya için sha256
     └─ Bu hash zaten kuyrukta mı? → "atlandi", kullanıcıya bildir
4. Kuyruğa yaz (durum: bekliyor)
5. DÖNGÜ (her seferinde 1 dosya):
     a. Görüntü hazırla (format / boyut / netlik)
     b. Worker POST /ocr/basla  → operationId
     c. Worker GET /ocr/durum/:id  (2 sn aralıkla, üstel geri çekilme)
        → sonuç → ocrHamJson'a kaydet
     d. İnceleme ekranı → kullanıcı düzeltir
     e. Kaydet:
          e1. Worker PUT /belge/:anahtar  (görseli R2'ye)
          e2. Firestore'a yaz
          e3. Drift'e yaz
          e4. durum "tamamlandi", islendi = true
     f. Sıradaki dosya
```

★ **Görsel neden onaydan sonra yükleniyor?** Atlanan/reddedilen belgeler R2'de
yer kaplamasın. Güvenle yapabiliyoruz çünkü kaynak dosya taranan klasörde duruyor,
hiç taşınmıyor. *(Mobilde istisna: kamera dosyası geçici olduğu için hemen
yüklenir — `BelgeRepository` bu farkı içeride halleder, UI bilmez.)*

### Kritik davranışlar

| Durum | Davranış |
|---|---|
| Uygulama çöktü | Açılışta `islendi = false` olan ilk işten devam. `ocrHamJson` doluysa **OCR tekrar yapılmaz** |
| İnternet gitti | İş `hata` olur, kuyrukta kalır, "Yeniden Dene" ile devam |
| Azure kotası doldu | Kuyruk **duraklatılır**: "Bu ayki 500 sayfa doldu. Kalan X belge gelecek ay işlenecek." |
| Kullanıcı "Atla" dedi | `durum: atlandi`, `islendi: true` — bir daha çıkmaz ama kayıtta kalır |
| Aynı klasör tekrar seçildi | Hash eşleşenler atlanır, sadece yeniler eklenir |

### İlerleme göstergesi

```
┌────────────────────────────────────────────────────┐
│  İçe Aktarma                                       │
│  ████████████████░░░░░░░░░░░░░  187 / 342          │
│                                                    │
│  ✓ 184 tamamlandı   ⊘ 2 atlandı   ✕ 1 hata         │
│  Bu ay OCR: 187 / 500 sayfa                        │
│                                                    │
│  Şu an: defter_0188.jpg  ·  OCR yapılıyor...       │
│                                                    │
│  [ Duraklat ]           [ Hatalıları Yeniden Dene ]│
└────────────────────────────────────────────────────┘
```

★ Kota sayacını **burada** göstermek önemli — kullanıcı sınıra çarpmadan görür.

---

## 9. Kota ve Maliyet (2.000 sayfa senaryosu)

| Servis | Ücretsiz limit | Kullanım | Durum |
|---|---|---|---|
| **Azure DI (F0)** | 500 sayfa/ay | 2.000 sayfa → **4 ay** | ⚠️ Tek darboğaz |
| | 4 MB/dosya | 300 DPI gri JPEG ≈ 1–2 MB | ✅ |
| | 2 sayfa/istek | Biz 1 sayfa/istek | ✅ |
| | 20 istek/dk | Kuyruk sıralı | ✅ |
| **Cloudflare R2** | 10 GB · egress ücretsiz | 2.000 × 1,5 MB ≈ **3 GB** | ✅ |
| | Class A 1M/ay | ~4.000 yazma | ✅ |
| **Cloudflare Workers** | 100.000 istek/gün | ~12.000 toplam | ✅ Kredi kartı yok |
| **Firestore** | 1 GiB | 2.000 × 15 KB ≈ **30 MB** | ✅ |
| | 50.000 okuma/gün | İlk senkron 2.000, sonrası ~5 | ✅ |
| | 20.000 yazma/gün | Günde ~100 belge = 100 yazma | ✅ |
| **Firebase Auth** | Spark'ta ücretsiz | 1 hesap | ✅ |

**Sonuç: $0/ay, hiçbir yerde kredi kartı yok.**

**Hızlandırma seçeneği:** Azure S0 katmanı `prebuilt-layout` için
≈ **$10 / 1.000 sayfa** (bölgeye göre değişir, panelden teyit et).
2.000 sayfa ≈ **$20 tek seferlik** → 4 ay yerine 1 haftada biter.
Varsayılan ücretsiz katman, ama seçenek dursun.

**Uygulamadaki kota koruması:**
- `sistem/kota/{yyyy-MM}` sayacı, her OCR'da transaction ile +1
- 450'de sarı uyarı, 500'de kuyruk otomatik duraklar
- Ayarlar ekranında kalan kota her zaman görünür
- ⚠️ Bu **bizim tahmini sayacımız**. Gerçek kaynak Azure paneli — ayda bir teyit et

---

## 10. Silme Davranışı

### 10.1 Soft delete (varsayılan)

`aktif = false` + `pasifNedeni` + `pasifTarihi`. Veri **silinmez**, görsel R2'de
kalır. Arama sonuçlarında varsayılan gizli; "Pasif kayıtları da göster" onay
kutusuyla görünür.

> ⚖️ **Yasal not — bunu bir varsayım olarak dayatmıyorum:**
> Ortak Pay Defteri, TTK kapsamında resmi bir ticari defter olabilir ve ticari
> defterlerin belirli süre saklanması yasal zorunluluk taşıyabilir. Dijital
> kopyanın hukuki geçerliliği ayrı bir konu.
> **Mali müşavirine iki soru sor:** (1) Bu defterin saklama süresi nedir?
> (2) Dijital kopya aslın yerine geçer mi, fiziksel defter yine saklanmalı mı?
> Cevap gelene kadar **en korumacı** varsayımla gidiyoruz: hiçbir şey silinmez.

### 10.2 Kalıcı Sil — "hayalet veri" önleyici

Üç yerde veri var (R2, Firestore, Drift). Sıra **kasıtlı**:

```
0. Firestore'a MEZAR TAŞI:  silmeTalepleri/{id} = {ortakId, r2Anahtari, adim:"r2"}
1. Worker DELETE /belge/:anahtar   → mezar taşı: adim = "firestore"
2. Firestore ortaklar/{id} sil     → mezar taşı: adim = "yerel"
3. Drift'ten sil (satırlar cascade) → mezar taşını sil
```

**Neden önce mezar taşı?** Adım 1–2 arasında elektrik keserse mezar taşı
`adim: "firestore"`da kalır. Uygulama açılışında `silmeTalepleri` kontrol edilir
ve **yarım kalan silme kaldığı yerden tamamlanır.** Mezar taşı olmasa R2'de
yetim bir dosya kalır, kimse fark etmezdi.

**Neden R2 önce?** Ters sırada (önce Firestore) hata olursa R2'de **görünmez**
yetim dosya kalır. Bu sırada hata olursa DB kaydı var ama görsel yok —
ekranda "görsel bulunamadı" çıkar, **fark edilebilir** bir hata.
Sessiz hatadansa gürültülü hata iyidir.

**Arayüz — çift onay:**
1. `[Kalıcı Sil]` sadece **detay ekranı → ⋯ menüsünde** (yanlışlıkla basılmaz)
2. Diyalog silinecek her şeyi listeler + **ortak numarasını yazmanı ister**
   (`"Onaylamak için 147 yazın"`) — GitHub'ın repo silme deseni.
   Refleksle onaylanamaz.

---

## 11. Yedekleme

Bulut mimarisi tek-nokta-arıza riskini kaldırıyor ama **hesap kaybı / yanlış
silme / servis kapanması** risklerini kaldırmıyor.

### Uygulama içi "Yedek Al"

Kullanıcı hedef klasör seçer (OneDrive/Drive klasörünü gösterir):

```
yedek_2026-08-15_143022/
├── ortaklar.json          # tam veri, geri yükleme için makine-okunur
├── ortaklar.csv           # Excel'de açılır, insan-okunur
├── defter_satirlari.csv   # sermaye + ödeme satırları
├── gorsel_listesi.csv     # R2 anahtarı ↔ ortak eşleşmesi
└── OZET.txt               # kaç kayıt, tarih, uygulama sürümü
```

★ **JSON + CSV birlikte:** JSON tam ve geri yüklenebilir; CSV ise uygulama
tamamen yok olsa bile veriyi Excel'de okumanı sağlar. Bir arşiv sisteminde
"yazılım öldüğünde veri hâlâ okunabilir mi?" sorusunun cevabı **evet** olmalı.

**Görseller neden dahil değil?** 3 GB'ı haftalık kopyalamak pratik değil:
- Haftalık yedek: sadece metin veri (birkaç MB) + görsel listesi
- Ayrı **"Tüm Görselleri İndir"** butonu (tek seferlik/aylık, arka planda)
- R2'nin kendi dayanıklılığı yüksek; asıl korunması gereken metin veri

**Hatırlatma:** `sonYedekTarihi` meta tablosunda. 7 günü geçtiyse ana ekranda
dikkat çekici ama **engellemeyen** bir şerit.
*(Otomatik zamanlanmış yedek Faz 11 — Windows Task Scheduler entegrasyonu
gerektirir; önce manuel butonla başlıyoruz.)*

---

## 12. Güvenlik ve Anahtar Yönetimi

### 12.1 Sırlar nerede duruyor?

| Sır | Nerede | Uygulamada var mı? |
|---|---|---|
| **Azure DI anahtarı** | Cloudflare Worker Secret | ❌ Hayır |
| **R2 erişim anahtarı** | ★ **Hiç oluşturulmuyor** (binding) | ❌ Diye bir şey yok |
| Firebase yapılandırma | Uygulama içinde | ✅ ama **zaten gizli değil** — tasarımı gereği istemci tarafı. Güvenlik Security Rules ile |
| Worker URL | `--dart-define` | ✅ Gizli değil, sadece yapılandırma |
| Kullanıcı oturum token'ı | `flutter_secure_storage` | Windows Credential Manager / iOS Keychain / Android Keystore |

**Uygulamanın içinde tek bir gizli anahtar yok.** `.exe` ele geçse bile
çıkarılacak bir sır bulunmuyor.

### 12.2 Tek Kullanıcı Girişi

**Karar:** Tek kullanıcı adı, tek şifre. Herkes aynı hesapla girer.
Uygulamada **kayıt ol / şifre sıfırla ekranı yok.**

**Kurulum:**
1. Firebase Konsolu → Authentication → Sign-in method → **Email/Password** aç
2. Users → **Add user** → tek hesabı elle oluştur
   (örn. `defter@sirketadi.com` + güçlü şifre)
3. Oluşan **UID'yi kopyala** → hem güvenlik kurallarına hem Worker secret'ına
4. Uygulama `createUserWithEmailAndPassword` çağrısını **hiç içermez** →
   kayıt olma yolu kodda mevcut değil

**Deneyim:** Firebase Auth oturumu cihazda kalıcı → giriş ekranı pratikte
**kurulumda bir kez** görünür. "Çıkış Yap" ayarlardadır.

> **Kullanıcı izi alanı eklenmedi (karar: 2026-08-15).** Kayıtları yalnızca 2 kişi
> ve çoğunlukla birlikte giriyor → "bu kaydı kim girdi?" sorusunun pratik karşılığı
> yok. Model bir alan hafifledi, form bir kutu azaldı.
> *(İleride gerekirse `olusturanKisi` alanı eklenebilir — Drift şema migrasyonu
> ve Firestore'da opsiyonel alan, ikisi de geriye dönük uyumlu.)*

### 12.3 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ★ Tek hesabın UID'si SABİT.
    // Firebase Konsolu > Authentication > Users'tan kopyalanacak.
    function tekYetkiliKullanici() {
      return request.auth != null
          && request.auth.uid == 'BURAYA_UID_YAPISTIR';
    }

    match /ortaklar/{ortakId}   { allow read, write: if tekYetkiliKullanici(); }
    match /sistem/{belge=**}    { allow read, write: if tekYetkiliKullanici(); }
    match /silmeTalepleri/{id}  { allow read, write: if tekYetkiliKullanici(); }

    match /{document=**}        { allow read, write: if false; }  // geri kalan kapalı
  }
}
```

★ **UID'yi sabitlemek neden önemli?** `request.auth != null` yazsaydık, projende
herhangi bir yolla hesap açan biri veriye erişirdi. UID sabit olunca **sadece o
tek hesap** okuyup yazabilir — beyaz liste koleksiyonuna bile gerek kalmıyor
(ve her sorguda fazladan bir okuma harcamıyoruz).

### 12.4 Worker güvenliği

Aynı UID kontrolü Worker'da da yapılır (§2.4). Yani üç katman:
1. Firebase Auth — geçerli oturum olmadan token yok
2. Firestore Rules — UID eşleşmezse veri yok
3. Worker — UID eşleşmezse R2 ve Azure'a erişim yok

### 12.5 Yapılandırma dosyaları

```
env.json            ← .gitignore'da! Worker URL + Firebase config
env.ornek.json      ← repoda, boş şablon
worker/.dev.vars    ← .gitignore'da! Azure anahtarı (yerel test için)
```
Çalıştırma: `flutter run --dart-define-from-file=env.json -d windows`
Worker deploy: `wrangler secret put AZURE_ANAHTARI`

---

## 13. Paket Listesi

```yaml
dependencies:
  flutter: {sdk: flutter}

  # State management
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

  # Navigasyon
  go_router: ^16.0.0

  # Yerel veritabanı
  drift: ^2.28.0
  drift_flutter: ^0.2.0          # sqlite3 native, tüm platformlar
  path_provider: ^2.1.5
  path: ^1.9.0

  # Model üretimi
  freezed_annotation: ^3.0.0
  json_annotation: ^4.9.0

  # Firebase
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.0
  cloud_firestore: ^6.0.0

  # Ağ
  dio: ^5.7.0                    # Worker çağrıları, yükleme ilerlemesi, retry

  # Dosya & görüntü
  file_picker: ^10.0.0           # klasör/dosya seçimi — Windows ✓
  image: ^4.3.0                  # saf Dart görüntü işleme (masaüstü yolu)
  flutter_image_compress: ^2.3.0 # native sıkıştırma (mobil yolu)
  image_picker: ^1.1.2           # mobil kamera/galeri
  crypto: ^3.0.6                 # sha256 dosya hash

  # Yardımcı
  flutter_secure_storage: ^9.2.4
  intl: ^0.20.0                  # tr_TR tarih/para biçimi
  uuid: ^4.5.1
  csv: ^6.0.0
  google_fonts: ^6.2.1
  window_manager: ^0.4.3         # Windows pencere min boyutu/başlık

dev_dependencies:
  build_runner: ^2.4.13
  drift_dev: ^2.28.0
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.0.0
  custom_lint: ^0.7.0
  freezed: ^3.0.0
  json_serializable: ^6.9.0
  flutter_lints: ^6.0.0
  mocktail: ^1.0.4
```
*(Sürümler kurulumda `pub get` ile güncel karşılıklarına sabitlenecek.)*

> ★ **Binding kararının kazancı burada görünüyor:** S3 istemcisi (`minio` vb.)
> ve elle SigV4 imzalama kodu listede **yok**. Bir bağımlılık ve ~80 satır
> kripto kodu eksildi.

### Neden bu seçimler? (öğrenme notu)

**Riverpod, Provider/BLoC yerine:**
Bu uygulama ağırlıklı **asenkron veri akışı** (DB sorgusu, HTTP, senkron).
Riverpod'un `AsyncValue` tipi yükleniyor/veri/hata üç durumunu tek tipte tutar —
`switch` ile üçünü ele almayı unutamazsın (derleyici zorlar).
BLoC aynı işi yapar ama her ekran için Event + State + Bloc sınıfı gerekir;
bu boyutta gereksiz tören. Provider ise derleme zamanı güvenlik vermez
(`context.read<X>()` yanlış tipte **çalışma anında** patlar).

**Drift, Isar yerine:**
- Isar 3 uzun süredir güncellenmiyor, 4 hâlâ olgunlaşma aşamasında — ilk projende
  bakımı belirsiz bir bağımlılığa güvenmek risk
- Drift SQLite üzerinde: dünyanın en çok test edilmiş veritabanı motoru
- **Asıl neden:** arama motorumuz SQL. `LIKE`, `ORDER BY`, `JOIN`, ileride FTS5 —
  hepsi hazır. Isar'ın sorgu API'si bu esnekliği vermiyor
- Windows/macOS/Linux/Android/iOS desteği `drift_flutter` ile tek satır

**Dio, http yerine:** Yükleme ilerlemesi (`onSendProgress`), yeniden deneme
interceptor'ı, timeout yönetimi hazır. Kuyruk mantığı için gerekli.

---

## 14. Tasarım Sistemi

*(CLAUDE.md kurallarına uygun — UI kodu yazmadan önce `mobile-design` skill'i
aktive edilecek ve bu bölüm detaylandırılacak.)*

**Tipografi**
- Arayüz/gövde: **Plus Jakarta Sans** *(Inter yasak)*
- Sayısal/tablo: **IBM Plex Mono** — ★ sabit genişlikli rakamlar sayesinde para
  sütunlarında haneler alt alta hizalanır. Muhasebe tablosunda okunabilirlik farkı
- Hiyerarşi: Display 32 / Headline 24 / Title 18 / Body 15 / Caption 13

**Renk** — monokromatik + tek accent
- Zemin: sıcak nötr griler (defter kâğıdı hissi, soğuk mavi-gri değil)
- Accent: derin mürekkep mavisi — arşiv/kayıt işine uygun ciddi ton
- Durum renkleri (başarı/uyarı/hata) accent'ten bağımsız, sadece işlevsel
- Toplam ≤5 ton. Hepsi `app_colors.dart`'ta, kodda ham renk kodu yok

**Boşluk** — 4 tabanlı: 4 / 8 / 16 / 24 / 32 / 48 / 64
- Kart içi padding minimum 16, tercihen 24
- Ekran kenar boşluğu 24 (masaüstü 32)

**Hareket**
- Süre ≤ 240ms, `Curves.easeOut` / `Curves.fastOutSlowIn`
- Liste öğeleri 40ms stagger
- Overshoot/bounce **yok**; anlam katmayan animasyon eklenmez

**Duyarlılık**
- `< 600px` → mobil: alt navigasyon, tam ekran detay
- `600–900px` → tablet: NavigationRail
- `> 900px` → masaüstü: NavigationRail + **ana-detay yan yana** (arama solda,
  seçili ortak sağda). İnceleme ekranı zaten iki panelli

---

## 15. Geliştirme Sırası

Her faz sonunda **çalışan bir uygulama** var. İlk projende bu önemli: her adımda
somut ilerleme görürsün, hata ayıklama kolay kalır.

### Faz 0 — Hazırlık *(kod yok)*
- [ ] Geliştirme makinesi kararı (§1)
- [ ] NAPS2 kurulumu + ayarları (§6.1)
- [ ] ★ **Pilot: 20 gerçek sayfa tara** — 300 DPI gri JPEG
- [ ] Hesaplar: Cloudflare, Firebase, Azure (kredi kartı istemeyen katmanlar)
- [ ] Mali müşavire yasal soru (§10.1) — cevap beklerken geliştirme sürer

> ★ **20 sayfa neden şart:** OCR ayrıştırıcısını hayali bir düzen üzerine
> yazamayız. Gerçek sayfayı görmeden yazılan etiket eşleyici kesin baştan yazılır.

### Faz 1 — İskelet + Yerel CRUD  🎯 *ilk çalışan uygulama*
- [ ] `flutter create` + **`git init`** + private GitHub reposu + `.gitignore`
- [ ] Klasör yapısı (§3), `analysis_options.yaml` (strict)
- [ ] Tema sistemi (§14) — *önce `mobile-design` skill'i aktive edilecek*
- [ ] Drift şeması + DAO'lar
- [ ] Riverpod + go_router kurulumu
- [ ] Türkçe normalizasyon + **birim testleri** (ilk test dosyan)
- [ ] Arama ekranı + ortak detay + **elle** ortak ekleme formu
- [ ] ★ **GitHub Actions CI** (§1.2) — Windows derlemesi ilk günden yeşil kalsın
- [ ] ★ Üretilen `.exe`'yi **Windows PC'de bir kez aç** — erken doğrulama
- **Sonunda:** Elle ortak ekleyip Türkçe arama yapabilen, tamamen çevrimdışı,
  bulutsuz bir masaüstü uygulaması. *Buluttan hiçbir şey yok — bilinçli.*

### Faz 2 — Görsel içe aktarma *(OCR yok)*
- [ ] Klasör seçimi + dosya tarama + sha256
- [ ] Kuyruk tablosu + kuyruk ekranı + ilerleme
- [ ] Görüntü hazırlama hattı (platform-özel, §6.3) + testleri
- [ ] Görsel önizleme (yakınlaştırma/kaydırma)
- **Sonunda:** Klasörden görselleri sıraya koyan, boyutlandıran, yanına elle veri
  girilebilen uygulama. **OCR olmasa bile işe yarıyor.**

### Faz 3 — Cloudflare Worker + R2  *(~200 satır JS)*
- [ ] R2 bucket + `wrangler` projesi + binding
- [ ] `PUT/GET/DELETE /belge/:anahtar` uçları
- [ ] `GET /saglik`
- [ ] Flutter: `worker_istemcisi.dart` + görsel yerel önbelleği
- **Sonunda:** Görseller buluta çıkıyor, herhangi bir cihazdan görülebiliyor
- ⚠️ *Token doğrulaması Faz 4'te ekleniyor — bu fazda Worker geçici olarak
  paylaşılan basit bir sırla korunur, bucket henüz boş*

### Faz 4 — Giriş + Firestore senkron
- [ ] Firebase projesi + Auth, tek hesap oluştur, UID'yi al
- [ ] Security Rules (§12.3)
- [ ] Giriş ekranı ("Adınız" alanı dahil) + rota koruması
- [ ] Worker'a Firebase token + UID doğrulaması ekle (§2.4)
- [ ] Firestore yazma + delta senkron + çakışma politikası
      (son yazan kazanır, `guncellemeTarihi` karşılaştırmalı)
- **Sonunda:** Güvenli, senkron, çok cihazlı uygulama. **OCR hâlâ yok** ama sistem
  tam çalışıyor — bu noktada ekibe dağıtılabilir

### Faz 5 — Azure OCR  🎯 *ana özellik*
- [ ] Worker `/ocr/basla` + `/ocr/durum/:id`
- [ ] Flutter'da bekleme döngüsü (üstel geri çekilme)
- [ ] Alan ayrıştırıcı (etiket eşleyici + tablo çıkarımı, §7.2)
- [ ] ★ **Pilot 20 sayfada doğruluk ölçümü** → ayrıştırıcıyı iyileştir
- [ ] Kota sayacı + otomatik duraklatma
- **Sonunda:** OCR ön-dolduruyor

### Faz 6 — İnceleme ekranı  🎯 *en çok kullanılacak ekran → v1.0*
- [ ] İki panelli düzen (§7.3)
- [ ] Alan→görsel vurgulama (boundingBox)
- [ ] Güven skoru renklendirmesi
- [ ] Tablo satırı ekle/sil/düzenle
- [ ] Klavye kısayolları
- [ ] Yinelenen Ortak No diyaloğu (§7.4)
- **Sonunda:** Uçtan uca tam akış. **Bu, v1.0.**

### Faz 7 — Silme + Yedekleme
- [ ] Soft delete + pasif kayıt filtresi
- [ ] Mezar taşlı kalıcı silme + açılışta yarım-kalan temizliği (§10.2)
- [ ] Yedek Al (JSON+CSV) + 7 gün hatırlatıcı

### Faz 8 — Cilalama + dağıtım
- [ ] Netlik kontrolü (Laplacian, §6.3)
- [ ] Boş/hata/yükleniyor durumları gözden geçir
- [ ] Klavye kısayolları tam tur
- [ ] Widget + entegrasyon testleri
- [ ] Windows paketleme (MSIX veya Inno Setup) — CI'a eklenir
- [ ] ★ Windows PC'de tam tur elden geçirme (tarama klasörü, secure storage, pencere)

### Faz 9 — Mobil
- [ ] Android build + `image_picker` + duyarlı düzenler
- [ ] iOS build (Mac gerekir — sende var) + HEIC yolu testi

### Faz 10+ — Gerekirse
- [ ] Azure özel model (doğruluk yetmezse)
- [ ] FTS5 (kayıt 50.000'i geçerse)
- [ ] Otomatik zamanlanmış yedek

---

## 16. Kabul Ettiğim Varsayımlar

Yanlışsa söyle, plan güncellenir:

1. **Her ortak tam olarak 1 defter sayfası.** Veri modeli yine de
   `belgeR2Anahtari`'nı ileride diziye çevirmeye izin verecek şekilde kurgulandı
2. `ortakNo` **benzersiz olmayabilir** → veritabanı kısıtı yok, uygulama
   seviyesinde uyarı
3. Sermaye/ödeme satırları **sabit 6 sütun** (Tarih, No, Mad., Açıklama, Miktar, Yekün)
4. Defter **Türkçe** ve **tek şablon** — sayfa düzeni tüm sayfalarda aynı
5. Tarihler `gg.aa.yyyy`, okunamayanlar için ham metin saklanıyor
6. Tek ortak hesap, **veri paylaşımlı** — kişi bazlı erişim kısıtı yok
7. Uygulama **Türkçe arayüz**, çoklu dil yok

---

## 17. Kararını Beklediğim Konular

### ✅ Karara bağlananlar (2026-08-15)

| Konu | Karar |
|---|---|
| Bulut DB | **Firestore** + yerel-öncelikli arama (§2.5) |
| Anahtar barındırma | **Cloudflare Worker + R2 binding** — uygulamada sıfır sır (§2.2) |
| Giriş | **Tek hesap**, UID kurala sabit, kayıt ol ekranı yok (§12.2) |
| Kullanıcı izi alanı | **Eklenmiyor** — 2 kişi birlikte giriyor |
| Geliştirme ortamı | **macOS + GitHub Actions CI**, doğrulama ayrı Windows PC'de (§1) |
| Azure modeli | **`prebuilt-layout`** (§7.1) |
| Belge yapısı | Her ortak = 1 sayfa |
| Ekip | 2 kişi |

### ⏳ Sonraya bırakılanlar (varsayılanla ilerliyorum)

| Konu | Varsayılan | Ne zaman kesinleşir |
|---|---|---|
| Netlik kontrolü (§6.3) | Dahil, **Faz 8'de** | Eşik gerçek taramalarla kalibre edilecek |
| 4 ay ücretsiz vs $20 (§9) | **Ücretsiz katman** | Faz 5'te hız canını sıkarsa geç — mimari değişmiyor |
| Yasal saklama süresi (§10.1) | **En korumacı**: hiçbir şey silinmez | Mali müşavir cevabı geldiğinde |

### 📋 Senin yapman gerekenler

| # | İş | Ne zaman | Neden |
|---|---|---|---|
| 1 | **20 gerçek sayfa tara** (300 DPI, gri, JPEG) | Faz 5'ten önce | ★ OCR ayrıştırıcısı hayali sayfa üzerine yazılamaz |
| 2 | Cloudflare + Firebase + Azure hesapları | Faz 3'ten önce | Hepsi ücretsiz katman, kredi kartı yok |
| 3 | GitHub'da **private** repo aç | Faz 1'de | CI ve yedek geçmişi için |
| 4 | Mali müşavire 2 soru (§10.1) | Ne zaman olursa | Cevap beklerken geliştirme sürüyor |

> Faz 1 ve 2 bu maddelerin **hiçbirini beklemiyor** — hemen başlanabilir.
