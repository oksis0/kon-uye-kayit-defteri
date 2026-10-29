import 'dart:math' as math;

import '../../core/util/para_bicim.dart';
import '../../domain/enum/satir_turu.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ocr_sonucu.dart';

/// Azure Document Intelligence (`prebuilt-layout`) ham JSON'unu
/// [OcrSonucu]'na çevirir — "Aşama 1: Etiket Eşleyici" (PLAN.md §7.2).
///
/// Akıllı ayrıştırma stratejisi:
/// 1. Tablolar içeriğine göre sınıflandırılır (Kimlik Izgarası, Sermaye Tablosu, Ödemeler Tablosu).
/// 2. Kimlik Izgarası tablosu varsa (Baba Adı, Doğum Yeri, Tarihi vb.) değerler doğrudan hücrelerden çekilir.
/// 3. Metin satırları açı/eğim toleranslı geometrik eşleme ile etiketlere bağlanır.
/// 4. Ad Soyad, damga/mühür nedeniyle "Adı," olarak kalsa dahi sağındaki el yazısı ismi tespit edilir.
/// 5. Ortak No bulunamazsa veya boşsa "Sayfa No" yedeği kullanılır.
/// 6. Sermaye ve Ödeme tabloları 6 sütunlu veya 10 sütunlu başlık yapısına göre dinamik eşlenir.
OcrSonucu azureSonucunuAyristir(Map<String, dynamic> azureYaniti) {
  final Map<String, dynamic>? analiz = azureYaniti['analyzeResult'] as Map<String, dynamic>?;
  if (analiz == null) return const OcrSonucu();

  final List<_Satir> satirlar = _satirlariCikar(analiz);
  final List<_KelimeGuveni> kelimeler = _kelimeleriCikar(analiz);

  // Tabloları sınıflandır
  final List<dynamic> hamTablolar = (analiz['tables'] as List?) ?? const <dynamic>[];
  Map<String, dynamic>? kimlikTablosu;
  Map<String, dynamic>? sermayeTablosu;
  Map<String, dynamic>? odemeTablosu;
  final List<Map<String, dynamic>> digerTablolar = <Map<String, dynamic>>[];

  for (final Object? t in hamTablolar) {
    if (t is! Map<String, dynamic>) continue;
    if (_tabloKimlikMi(t)) {
      kimlikTablosu ??= t;
    } else if (_tabloSermayeMi(t)) {
      sermayeTablosu ??= t;
    } else if (_tabloOdemeMi(t)) {
      odemeTablosu ??= t;
    } else {
      digerTablolar.add(t);
    }
  }

  // Geriye dönük uyumluluk: Eğer sermaye/ödeme tabloları başlık anahtar kelimeleriyle
  // tespit edilemediyse (örn. sentetik testler), sırasıyla ata.
  if (sermayeTablosu == null && digerTablolar.isNotEmpty) {
    sermayeTablosu = digerTablolar.removeAt(0);
  }
  if (odemeTablosu == null && digerTablolar.isNotEmpty) {
    odemeTablosu = digerTablolar.removeAt(0);
  }

  // 1) Kimlik tablosundan alanları çıkar (varsa)
  final _KimlikTabloCikti kimlikCikti = kimlikTablosu != null
      ? _kimlikTablosundanCikar(kimlikTablosu, kelimeler)
      : const _KimlikTabloCikti(<String, OcrAlan>{}, <String>{});
  final Map<String, OcrAlan> kimlikHucresiAlanlari = kimlikCikti.alanlar;
  final Set<String> gorulenKimlikAlanlari = kimlikCikti.gorulenAlanlar;

  // 2) Satırlardan etiket eşleyici ile alanları bul
  OcrAlan? satirdaBul(
    List<String> etiketVaryasyonlari, {
    bool sadeceSayi = false,
  }) =>
      _alanBul(
        satirlar,
        kelimeler,
        etiketVaryasyonlari,
        sadeceSayi: sadeceSayi,
      );

  // Akıllı alan çözümleyici:
  // Kimlik tablosu varsa hücre değerini alır. Tabloda yer almayan veya
  // tablosuz belgelerde doğrudan esnek satır eşleyicisi devreye girer.
  OcrAlan? alanCoz(
    String alanAdi,
    List<String> etiketVaryasyonlari, {
    bool sadeceSayi = false,
  }) {
    if (gorulenKimlikAlanlari.contains(alanAdi)) {
      return kimlikHucresiAlanlari[alanAdi];
    }
    return kimlikHucresiAlanlari[alanAdi] ??
        satirdaBul(etiketVaryasyonlari, sadeceSayi: sadeceSayi);
  }

  // Ortak No
  final OcrAlan? ortakNo = alanCoz('ortakNo', _ortakNoVaryasyonlari, sadeceSayi: true);

  // Sayfa No
  final OcrAlan? sayfaNo = alanCoz('sayfaNo', _sayfaNoVaryasyonlari, sadeceSayi: true);

  // TC Kimlik No
  final OcrAlan? tcKimlikNo = _tcKimlikNoBul(satirlar, kelimeler, kimlikHucresiAlanlari);

  // Ad Soyad
  final OcrAlan? adSoyad = alanCoz('adSoyad', _adSoyadVaryasyonlari);

  // Baba Adı
  final OcrAlan? babaAdi = alanCoz('babaAdi', _babaAdiVaryasyonlari);

  // Doğum Yeri
  OcrAlan? dogumYeri = alanCoz('dogumYeri', _dogumYeriVaryasyonlari);

  // Doğum Tarihi
  OcrAlan? dogumTarihi = alanCoz('dogumTarihi', _dogumTarihiVaryasyonlari);

  // Eğer Doğum Yeri içinde hem yer hem tarih varsa (örn. "ULUS 1965" veya "ANKARA 15.04.1974")
  if (dogumYeri != null && (dogumTarihi == null || dogumTarihi.metin.trim().isEmpty)) {
    final RegExp tarihRegex =
        RegExp(r'(\d{1,2}[./\-]\d{1,2}[./\-]\d{2,4}|\b(?:19\d{2}|20\d{2})\b)');
    final Match? eslesme = tarihRegex.firstMatch(dogumYeri.metin);
    if (eslesme != null) {
      final String bulunanTarih = eslesme.group(0)!;
      final String temizYeri = dogumYeri.metin
          .replaceFirst(bulunanTarih, '')
          .replaceAll(RegExp(r'[:\-–—/,\s]+'), ' ')
          .trim();
      dogumTarihi = OcrAlan(metin: bulunanTarih, guven: dogumYeri.guven);
      if (temizYeri.isNotEmpty) {
        dogumYeri = OcrAlan(metin: temizYeri, guven: dogumYeri.guven);
      }
    }
  }

  // Giriş Tarihi
  final OcrAlan? girisTarihi = alanCoz('girisTarihi', _girisTarihiVaryasyonlari);

  // Çıkış Tarihi
  final OcrAlan? cikisTarihi = alanCoz('cikisTarihi', _cikisTarihiVaryasyonlari);

  // İkamet Adresi
  final OcrAlan? ikametAdresi = alanCoz('ikametAdresi', _ikametAdresiVaryasyonlari);

  // Nüfusa Kayıtlı Olduğu Yer
  final OcrAlan? nufusKayitYeri = alanCoz('nufusKayitYeri', _nufusKayitYeriVaryasyonlari);

  // Tablo satırlarını dinamik sütun eşleme ile çıkar
  final List<DefterSatiri> sermayeSatirlari = sermayeTablosu != null
      ? _tabloSatirlariniCikar(sermayeTablosu, SatirTuru.sermaye)
      : const <DefterSatiri>[];

  final List<DefterSatiri> odemeSatirlari = odemeTablosu != null
      ? _tabloSatirlariniCikar(odemeTablosu, SatirTuru.odeme)
      : const <DefterSatiri>[];

  return OcrSonucu(
    ortakNo: ortakNo,
    sayfaNo: sayfaNo,
    tcKimlikNo: tcKimlikNo,
    adSoyad: adSoyad,
    babaAdi: babaAdi,
    dogumYeri: dogumYeri,
    dogumTarihi: dogumTarihi,
    girisTarihi: girisTarihi,
    cikisTarihi: cikisTarihi,
    ikametAdresi: ikametAdresi,
    nufusKayitYeri: nufusKayitYeri,
    sermayeSatirlari: sermayeSatirlari,
    odemeSatirlari: odemeSatirlari,
  );
}

// ---------------------------------------------------------------------
// Etiket varyasyonları
// ---------------------------------------------------------------------

const List<String> _ortakNoVaryasyonlari = <String>[
  'Ortak No',
  'ORTAK NO',
  'Ortak Numarası',
  'Ortak Numarasi',
  'Ortak No.',
  'ORTAK NO.',
  'Üye No',
  'Üye No.',
  'Uye No',
];

const List<String> _sayfaNoVaryasyonlari = <String>[
  'Sayfa No',
  'SAYFA NO',
  'Sayfa No.',
  'Sayfa:',
  'Sayfa',
];

const List<String> _adSoyadVaryasyonlari = <String>[
  'Adı Soyadı',
  'ADI SOYADI',
  'Adı ve Soyadı',
  'Ad ve Soyadı',
  'Ad Soyad',
  'AD SOYAD',
  'Adı, Soyadı',
  'Adı,',
  'Adı:',
  'Adı',
  'ADI',
];

const List<String> _babaAdiVaryasyonlari = <String>[
  'Baba Adı',
  'BABA ADI',
  'Baba Adi',
  'Baba Adı:',
  'Baba:',
];

const List<String> _dogumYeriVaryasyonlari = <String>[
  'Doğum Yeri ve Tarihi',
  'Doğum Yeri / Tarihi',
  'Doğum Yeri ve Yılı',
  'Doğum Yeri, Tarihi',
  'D. Yeri ve Tarihi',
  'D.Yeri ve Tarihi',
  'Doğum Yeri',
  'DOĞUM YERİ',
  'Dogum Yeri',
  'Doğum Yeri:',
  'D. Yeri',
  'D.Yeri',
];

const List<String> _dogumTarihiVaryasyonlari = <String>[
  'Doğum Tarihi',
  'DOĞUM TARİHİ',
  'Dogum Tarihi',
  'Doğum Tarihi:',
  'Doğum Yılı',
  'Doğum Günü',
  'D. Tarihi',
  'D.Tarihi',
  'D. Tarih',
  'D.Tarih',
];

const List<String> _girisTarihiVaryasyonlari = <String>[
  'Ortaklığa Giriş Tarihi',
  'Ortaklığa Giriş',
  'Ortaklığa Kabul Tarihi',
  'Kayıt Tarihi',
  'Kaydolduğu Tarih',
  'Giriş Tarihi',
  'GİRİŞ TARİHİ',
  'Giris Tarihi',
  'Giriş Tarihi:',
  'Kabul Tarihi',
  'Giriş',
  'Üyelik Tarihi',
];

const List<String> _cikisTarihiVaryasyonlari = <String>[
  'Ortaklıktan Çıkış Tarihi',
  'Ortaklıktan Çıkış',
  'Ortaklıktan Ayrılış Tarihi',
  'Ayrılma Tarihi',
  'Çıkış Tarihi',
  'ÇIKIŞ TARİHİ',
  'Cikis Tarihi',
  'Çıkış Tarihi:',
  'Ayrılış Tarihi',
  'İstifa Tarihi',
  'Çıkış',
];

const List<String> _ikametAdresiVaryasyonlari = <String>[
  'İkametgah ve Adresi',
  'İkametgâhı ve Adresi',
  'İkametgahı ve Adresi',
  'İkametgahı',
  'İkametgâhı',
  'İkametgâh',
  'İkamet Adresi',
  'İKAMET ADRESİ',
  'Ikamet Adresi',
  'İkametgah Adresi',
  'İkametgah',
  'Ikametgah',
  'İkamet',
  'Ikamet',
  'Adresi',
  'ADRESİ',
  'Adres',
  'ADRES',
  'Adresi:',
  'Adres:',
  'Ev Adresi',
  'Tebligat Adresi',
];

const List<String> _nufusKayitYeriVaryasyonlari = <String>[
  'Nüfusa Kayıtlı Olduğu Yer',
  'NÜFUSA KAYITLI OLDUĞU YER',
  'Nüfusta Kayıtlı Olduğu Yer',
  'NÜFUSTA KAYITLI OLDUĞU YER',
  'Nufusa Kayitli Oldugu Yer',
  'Nufusta Kayitli Oldugu Yer',
  'Nüfus Kayıt Yeri',
  'Nüfusa Kayıtlı',
  'Nüfusta Kayıtlı',
  'Nüfusa',
  'Nüfusta',
];

const List<String> _tumEtiketler = <String>[
  'ortak no', 'adı', 'adi', 'soyadı', 'soyadi', 'ad soyad',
  'baba adı', 'baba adi', 'doğum yeri', 'dogum yeri',
  'doğum tarihi', 'dogum tarihi', 'giriş tarihi', 'giris tarihi',
  'çıkış tarihi', 'cikis tarihi', 'ikamet adresi', 'ikamet', 'ikametgah',
  'adresi', 'adres', 'nüfusa', 'nufusa', 'nüfusta', 'nufusta', 'nüfus', 'nufus',
  't.c.', 'tc', 'kimlik', 'imza yeri', 'sayfa no',
  'yönetim', 'yonetim', 'kurulu', 'karar', 'dilekçe', 'dilekce',
  'makbuz', 'yevmiye', 'açıklama', 'aciklama', 'miktarı', 'miktari', 'yekün', 'yekun',
  'sermaye', 'ödeme', 'odeme', 'fotoğraf', 'fotograf', 'lira', 'kr.',
];

const double _varsayilanGuven = 0.75;

// ---------------------------------------------------------------------
// Geometri yardımcıları
// ---------------------------------------------------------------------

class _Kutu {
  const _Kutu(this.minX, this.minY, this.maxX, this.maxY);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get merkezX => (minX + maxX) / 2;
  double get merkezY => (minY + maxY) / 2;
  double get genislik => maxX - minX;
  double get yukseklik => maxY - minY;

  static _Kutu? poligondenOlustur(Object? poligon) {
    if (poligon is! List) return null;
    final List<double> sayilar =
        poligon.whereType<num>().map((num n) => n.toDouble()).toList();
    if (sayilar.length < 8) return null;

    final List<double> xler = <double>[
      for (int i = 0; i < sayilar.length; i += 2) sayilar[i],
    ];
    final List<double> yler = <double>[
      for (int i = 1; i < sayilar.length; i += 2) sayilar[i],
    ];

    return _Kutu(
      xler.reduce((double a, double b) => a < b ? a : b),
      yler.reduce((double a, double b) => a < b ? a : b),
      xler.reduce((double a, double b) => a > b ? a : b),
      yler.reduce((double a, double b) => a > b ? a : b),
    );
  }
}

class _Satir {
  const _Satir(this.metin, this.kutu);
  final String metin;
  final _Kutu kutu;
}

class _KelimeGuveni {
  const _KelimeGuveni(this.kutu, this.guven);
  final _Kutu kutu;
  final double guven;
}

List<_Satir> _satirlariCikar(Map<String, dynamic> analiz) {
  final List<dynamic> sayfalar = (analiz['pages'] as List?) ?? const <dynamic>[];
  final List<_Satir> sonuc = <_Satir>[];

  for (final Object? sayfa in sayfalar) {
    if (sayfa is! Map) continue;
    final List<dynamic> satirlar = (sayfa['lines'] as List?) ?? const <dynamic>[];
    for (final Object? satir in satirlar) {
      if (satir is! Map) continue;
      final String? metin = satir['content'] as String?;
      final _Kutu? kutu = _Kutu.poligondenOlustur(satir['polygon']);
      if (metin != null && metin.trim().isNotEmpty && kutu != null) {
        sonuc.add(_Satir(metin.trim(), kutu));
      }
    }
  }
  return sonuc;
}

List<_KelimeGuveni> _kelimeleriCikar(Map<String, dynamic> analiz) {
  final List<dynamic> sayfalar = (analiz['pages'] as List?) ?? const <dynamic>[];
  final List<_KelimeGuveni> sonuc = <_KelimeGuveni>[];

  for (final Object? sayfa in sayfalar) {
    if (sayfa is! Map) continue;
    final List<dynamic> kelimeler = (sayfa['words'] as List?) ?? const <dynamic>[];
    for (final Object? kelime in kelimeler) {
      if (kelime is! Map) continue;
      final _Kutu? kutu = _Kutu.poligondenOlustur(kelime['polygon']);
      final num? guven = kelime['confidence'] as num?;
      if (kutu != null && guven != null) {
        sonuc.add(_KelimeGuveni(kutu, guven.toDouble()));
      }
    }
  }
  return sonuc;
}

// ---------------------------------------------------------------------
// Tablo Sınıflandırma
// ---------------------------------------------------------------------

bool _tabloKimlikMi(Map<String, dynamic> tablo) {
  final List<dynamic> hucreler = (tablo['cells'] as List?) ?? const <dynamic>[];
  final String hepsi = hucreler
      .map((dynamic h) => (h is Map ? h['content'] as String? : null) ?? '')
      .join(' ')
      .toLowerCase();
  int eslesme = 0;
  if (hepsi.contains('baba ad') || hepsi.contains('baba adı')) eslesme++;
  if (hepsi.contains('dogum') || hepsi.contains('doğum')) eslesme++;
  if (hepsi.contains('nufus') || hepsi.contains('nüfus')) eslesme++;
  if (hepsi.contains('giris') || hepsi.contains('giriş')) eslesme++;
  if (hepsi.contains('ikamet')) eslesme++;
  return eslesme >= 2;
}

bool _tabloSermayeMi(Map<String, dynamic> tablo) {
  final List<dynamic> hucreler = (tablo['cells'] as List?) ?? const <dynamic>[];
  final String hepsi = hucreler
      .map((dynamic h) => (h is Map ? h['content'] as String? : null) ?? '')
      .join(' ')
      .toLowerCase();
  return hepsi.contains('sermaye') ||
      hepsi.contains('yüklenme') ||
      hepsi.contains('yuklenme') ||
      hepsi.contains('pay taahh');
}

bool _tabloOdemeMi(Map<String, dynamic> tablo) {
  final List<dynamic> hucreler = (tablo['cells'] as List?) ?? const <dynamic>[];
  final String hepsi = hucreler
      .map((dynamic h) => (h is Map ? h['content'] as String? : null) ?? '')
      .join(' ')
      .toLowerCase();
  return hepsi.contains('ödeme') ||
      hepsi.contains('odeme') ||
      hepsi.contains('makbuz') ||
      hepsi.contains('tahsilat');
}

// ---------------------------------------------------------------------
// Kimlik Tablosu Ayrıştırma
// ---------------------------------------------------------------------

class _KimlikTabloCikti {
  const _KimlikTabloCikti(this.alanlar, this.gorulenAlanlar);
  final Map<String, OcrAlan> alanlar;
  final Set<String> gorulenAlanlar;
}

_KimlikTabloCikti _kimlikTablosundanCikar(
  Map<String, dynamic> tablo,
  List<_KelimeGuveni> kelimeler,
) {
  final List<dynamic> hucreler = (tablo['cells'] as List?) ?? const <dynamic>[];
  final Map<String, OcrAlan> sonuc = <String, OcrAlan>{};
  final Set<String> gorulenAlanlar = <String>{};

  final Map<int, Map<int, Map<String, dynamic>>> hucreGrid =
      <int, Map<int, Map<String, dynamic>>>{};
  int maxSatir = 0;
  int maxSutun = 0;

  for (final Object? h in hucreler) {
    if (h is! Map<String, dynamic>) continue;
    final int? r = h['rowIndex'] as int?;
    final int? c = h['columnIndex'] as int?;
    if (r == null || c == null) continue;
    if (r > maxSatir) maxSatir = r;
    if (c > maxSutun) maxSutun = c;
    (hucreGrid[r] ??= <int, Map<String, dynamic>>{})[c] = h;
  }

  for (int r = 0; r <= maxSatir; r++) {
    for (int c = 0; c <= maxSutun; c++) {
      final Map<String, dynamic>? hucre = hucreGrid[r]?[c];
      if (hucre == null) continue;
      final String icerik = (hucre['content'] as String?)?.trim() ?? '';
      final String lower =
          icerik.toLowerCase().replaceAll(RegExp(r'[:\-–—"„.\s]+'), ' ').trim();
      if (lower.isEmpty) continue;

      // Değer hücresi: aynı satırdaki sağ hücreler (c+1 veya c+2).
      // Eğer aynı satırda sağ hücre varsa (boş olsa bile), bu hücre o satırın değer alanıdır;
      // alt satırdan veri çalınmamalıdır. Sadece yatay başlık tablosunda (örn. 2 satırlı:
      // r=0 başlıklar, r=1 değerler) alt hücreye bakılır.
      Map<String, dynamic>? degerHucre;
      String deger = '';
      if (hucreGrid[r]?.containsKey(c + 1) ?? false) {
        degerHucre = hucreGrid[r]?[c + 1];
        deger = (degerHucre?['content'] as String?)?.trim() ?? '';
        if (deger.isEmpty && (hucreGrid[r]?.containsKey(c + 2) ?? false)) {
          degerHucre = hucreGrid[r]?[c + 2];
          deger = (degerHucre?['content'] as String?)?.trim() ?? '';
        }
      } else if (hucreGrid[r + 1]?[c] != null) {
        // Sağda hücre yoksa, alt satırdaki hücreye bak (eğer başka bir etiket değilse)
        final String altIcerik = (hucreGrid[r + 1]![c]!['content'] as String?)?.trim() ?? '';
        if (altIcerik.isNotEmpty && !_baskaEtiketMi(altIcerik)) {
          degerHucre = hucreGrid[r + 1]?[c];
          deger = altIcerik;
        }
      }

      // Eğer sağ veya alt hücrelerde değer yoksa ama hücrenin kendi içinde etiket+değer
      // birleşmişse (örn: "Nüfusa Kayıtlı Olduğu Yer KONAK" veya "Ortak No: 1011")
      if (deger.isEmpty) {
        final String? kendiDegeri = _etiketSonrasiniAl(icerik, <String>[
          'nüfusa kayıtlı olduğu yer', 'nüfusta kayıtlı olduğu yer',
          'nüfusa kayıtlı', 'nüfusta kayıtlı',
          'ortak no', 'adı soyadı', 'adı', 'adi', 'baba adı', 'baba adi', 'doğum yeri', 'dogum yeri',
          'doğum tarihi', 'dogum tarihi', 'giriş tarihi', 'giris tarihi',
          'çıkış tarihi', 'cikis tarihi', 'ikamet adresi', 'ikametgah adresi', 'ikamet', 'ikametgah',
          'nüfus kayıt yeri', 'nüfusa', 'nüfusta', 'nüfus',
          'nufusa kayitli oldugu yer', 'nufusta kayitli oldugu yer', 'nufusa', 'nufusta',
          'sayfa no', 't.c.', 'tc',
        ]);
        if (kendiDegeri != null && kendiDegeri.isNotEmpty) {
          deger = kendiDegeri;
          degerHucre = hucre;
        }
      }

      // Değer başındaki iki nokta, çizgi, tırnak vb. temizliği
      deger = deger.replaceFirst(RegExp(r'^[:\-–—"„“”\/\.\\\s]+'), '').trim();

      String? alanTuru;
      if (lower.contains('baba ad') || lower == 'baba') {
        alanTuru = 'babaAdi';
      } else if (lower.contains('dogum yer') || lower.contains('doğum yer')) {
        alanTuru = 'dogumYeri';
      } else if (lower.contains('dogum tarih') ||
          lower.contains('doğum tarih') ||
          (lower.contains('tarih') &&
              !lower.contains('giris') &&
              !lower.contains('giriş') &&
              !lower.contains('cikis') &&
              !lower.contains('çıkış'))) {
        alanTuru = 'dogumTarihi';
      } else if (lower.contains('giris') || lower.contains('giriş')) {
        alanTuru = 'girisTarihi';
      } else if (lower.contains('cikis') || lower.contains('çıkış')) {
        alanTuru = 'cikisTarihi';
      } else if (lower.contains('nufus') || lower.contains('nüfus')) {
        alanTuru = 'nufusKayitYeri';
      } else if (lower.contains('ikamet') || lower.contains('adres')) {
        alanTuru = 'ikametAdresi';
      } else if (lower.contains('ad') || lower.contains('soyad')) {
        alanTuru = 'adSoyad';
      } else if (lower.contains('sayfa no') || lower.contains('sayfa')) {
        alanTuru = 'sayfaNo';
      } else if (lower.contains('t.c') || lower.contains('kimlik no') || lower == 'tc') {
        alanTuru = 'tcKimlikNo';
      } else if (lower.contains('ortak no') || lower == 'no' || lower.contains('üye no') || lower.contains('sıra no')) {
        alanTuru = 'ortakNo';
      }

      if (alanTuru != null) {
        gorulenAlanlar.add(alanTuru);
        if (deger.isNotEmpty) {
          final _Kutu? kutu = _Kutu.poligondenOlustur(degerHucre?['polygon']);
          final double guven = kutu != null ? _guvenHesapla(kutu, kelimeler) : 0.85;
          sonuc[alanTuru] ??= OcrAlan(metin: deger, guven: guven);
        }
      }
    }
  }

  return _KimlikTabloCikti(sonuc, gorulenAlanlar);
}

OcrAlan? _tcKimlikNoBul(
  List<_Satir> satirlar,
  List<_KelimeGuveni> kelimeler,
  Map<String, OcrAlan> kimlikHucresiAlanlari,
) {
  // 1) Tablo hücresinde varsa
  if (kimlikHucresiAlanlari['tcKimlikNo'] != null) {
    return kimlikHucresiAlanlari['tcKimlikNo'];
  }

  final RegExp tcRegex = RegExp(r'\b([1-9]\d{10})\b');

  // 2) T.C. etiketi geçen satırlarda aynı satırda veya hemen takip eden satırda 11 haneli sayı
  for (int i = 0; i < satirlar.length; i++) {
    final _Satir s = satirlar[i];
    final String temiz = s.metin.trim().toLowerCase();
    final bool tcEtiketiVar = temiz.startsWith('t.c') ||
        temiz.startsWith('tc') ||
        temiz.contains('t.c.') ||
        temiz.contains('kimlik no');

    if (tcEtiketiVar) {
      // Aynı satırda 11 haneli sayı var mı?
      final Match? eslesme = tcRegex.firstMatch(s.metin);
      if (eslesme != null) {
        final String tc = eslesme.group(1)!;
        return OcrAlan(metin: tc, guven: _guvenHesapla(s.kutu, kelimeler));
      }

      // Takip eden 1-3 satıra bak (örn. Line 3: "T.C." -> Line 4: "52876743710")
      for (int j = i + 1; j < math.min(i + 4, satirlar.length); j++) {
        final _Satir sonrasi = satirlar[j];
        final Match? sonrasiEslesme = tcRegex.firstMatch(sonrasi.metin);
        if (sonrasiEslesme != null) {
          final String tc = sonrasiEslesme.group(1)!;
          return OcrAlan(metin: tc, guven: _guvenHesapla(sonrasi.kutu, kelimeler));
        }
      }
    }
  }

  // 3) Etiket olmasa bile, kimlik bölümündeki (ilk 25 satır veya tablolardan önceki satırlarda) 11 haneli sayı
  for (final _Satir s in satirlar.take(25)) {
    final String l = s.metin.toLowerCase();
    if (l.contains('sermaye') || l.contains('ödeme') || l.contains('odeme')) break;

    final Match? eslesme = tcRegex.firstMatch(s.metin);
    if (eslesme != null) {
      final String tc = eslesme.group(1)!;
      return OcrAlan(metin: tc, guven: _guvenHesapla(s.kutu, kelimeler));
    }
  }

  return null;
}

// ---------------------------------------------------------------------
// Etiket eşleyici & Geometrik Arama
// ---------------------------------------------------------------------

String _temizleEtiket(String s) =>
    s.trim().replaceFirst(RegExp(r'^[:\-–—"„“”\/\.\\\s]+'), '').trim();

bool _baskaEtiketMi(String metin) {
  final String temiz = _temizleEtiket(metin).toLowerCase();
  for (final String e in _tumEtiketler) {
    if (e.length <= 4) {
      if (temiz == e ||
          temiz == '$e:' ||
          temiz == '$e.' ||
          temiz.startsWith('$e :') ||
          temiz.startsWith('$e:') ||
          temiz.startsWith('$e-') ||
          temiz.startsWith('$e -') ||
          temiz.startsWith('$e ')) {
        return true;
      }
    } else {
      if (temiz.startsWith(e)) {
        return true;
      }
    }
  }
  return false;
}

OcrAlan? _alanBul(
  List<_Satir> satirlar,
  List<_KelimeGuveni> kelimeler,
  List<String> etiketVaryasyonlari, {
  bool sadeceSayi = false,
}) {
  for (final _Satir etiketSatiri in satirlar) {
    if (!_satirEtiketMi(etiketSatiri.metin, etiketVaryasyonlari)) continue;

    // 1) Aynı satırda etiketten sonra metin var mı? ("Ortak No: 147")
    final String? ayniSatirdakiDeger = _etiketSonrasiniAl(etiketSatiri.metin, etiketVaryasyonlari);
    if (ayniSatirdakiDeger != null && ayniSatirdakiDeger.trim().isNotEmpty) {
      if (!sadeceSayi) {
        return OcrAlan(
          metin: ayniSatirdakiDeger.trim(),
          guven: _guvenHesapla(etiketSatiri.kutu, kelimeler),
        );
      } else {
        final String sadeceRakam = ayniSatirdakiDeger.replaceAll(RegExp(r'\D'), '');
        // Ortak No / Sayfa No: 1-8 basamaklıdır, 11 haneli TC No olamaz
        if (sadeceRakam.isNotEmpty && sadeceRakam.length <= 8 && sadeceRakam.length != 11) {
          return OcrAlan(
            metin: ayniSatirdakiDeger.trim(),
            guven: _guvenHesapla(etiketSatiri.kutu, kelimeler),
          );
        }
      }
    }

    // 2) Aynı yatay bantta sağdaki veya alttaki en yakın satırı bul
    final _Satir? degerSatiri = _yakinDegerSatiriniBul(
      etiketSatiri,
      satirlar,
      sadeceSayi: sadeceSayi,
    );
    if (degerSatiri != null) {
      final String temizDeger =
          degerSatiri.metin.replaceFirst(RegExp(r'^[:\-–—"„“”\/\.\\\s]+'), '').trim();
      if (temizDeger.isNotEmpty) {
        return OcrAlan(metin: temizDeger, guven: _guvenHesapla(degerSatiri.kutu, kelimeler));
      }
    }
  }
  return null;
}

bool _satirEtiketMi(String satirMetni, List<String> etiketVaryasyonlari) {
  final String temiz = _temizleEtiket(satirMetni).toLowerCase();
  return etiketVaryasyonlari.any((String v) => temiz.startsWith(v.toLowerCase()));
}

String? _etiketSonrasiniAl(String satirMetni, List<String> etiketVaryasyonlari) {
  final String temiz = _temizleEtiket(satirMetni);
  for (final String v in etiketVaryasyonlari) {
    if (temiz.toLowerCase().startsWith(v.toLowerCase())) {
      final String kalan = temiz.substring(v.length).trim();
      final String ayracsiz = kalan.replaceFirst(RegExp(r'^[:\-–—"„“”\/\.\\\s]+'), '').trim();
      if (ayracsiz.isEmpty || RegExp(r'^[.\-–—:,\s]+$').hasMatch(ayracsiz)) {
        return null;
      }
      return ayracsiz;
    }
  }
  return null;
}

_Satir? _yakinDegerSatiriniBul(
  _Satir etiketSatiri,
  List<_Satir> tumSatirlar, {
  bool sadeceSayi = false,
}) {
  _Satir? enYakinSagdaki;
  double enKisaYatayMesafe = double.infinity;

  for (final _Satir aday in tumSatirlar) {
    if (identical(aday, etiketSatiri)) continue;
    if (_baskaEtiketMi(aday.metin)) continue;
    if (sadeceSayi) {
      final String sadeceRakam = aday.metin.replaceAll(RegExp(r'\D'), '');
      // Ortak No / Sayfa No: 1-8 basamaklıdır, 11 haneli TC No olamaz
      if (sadeceRakam.isEmpty || sadeceRakam.length > 8 || sadeceRakam.length == 11) {
        continue;
      }
    }

    final double yCakisma = math.max(
      0.0,
      math.min(aday.kutu.maxY, etiketSatiri.kutu.maxY) -
          math.max(aday.kutu.minY, etiketSatiri.kutu.minY),
    );
    final double dMerkezY = (aday.kutu.merkezY - etiketSatiri.kutu.merkezY).abs();
    final double minH = math.min(aday.kutu.yukseklik, etiketSatiri.kutu.yukseklik);
    final bool ayniBant = yCakisma > minH * 0.25 || dMerkezY <= minH * 0.55;

    // Sağda olma (küçük açı/eğiklik toleransı ile)
    final bool sagda = aday.kutu.minX >= etiketSatiri.kutu.maxX - minH * 0.4;

    if (ayniBant && sagda) {
      final double mesafe = aday.kutu.minX - etiketSatiri.kutu.maxX;
      if (mesafe < enKisaYatayMesafe) {
        enKisaYatayMesafe = mesafe;
        enYakinSagdaki = aday;
      }
    }
  }

  if (enYakinSagdaki != null) return enYakinSagdaki;

  _Satir? enYakinAltta;
  double enKisaDikeyMesafe = double.infinity;

  for (final _Satir aday in tumSatirlar) {
    if (identical(aday, etiketSatiri)) continue;
    if (_baskaEtiketMi(aday.metin)) continue;
    if (sadeceSayi) {
      final String sadeceRakam = aday.metin.replaceAll(RegExp(r'\D'), '');
      if (sadeceRakam.isEmpty || sadeceRakam.length > 8 || sadeceRakam.length == 11) {
        continue;
      }
    }

    final bool altta = aday.kutu.minY > etiketSatiri.kutu.maxY - 10;
    final bool xHizali =
        (aday.kutu.minX - etiketSatiri.kutu.minX).abs() < etiketSatiri.kutu.yukseklik * 3.0;
    final double mesafe = aday.kutu.minY - etiketSatiri.kutu.maxY;
    if (altta && xHizali && mesafe < enKisaDikeyMesafe && mesafe < etiketSatiri.kutu.yukseklik * 4.0) {
      enKisaDikeyMesafe = mesafe;
      enYakinAltta = aday;
    }
  }
  return enYakinAltta;
}

double _guvenHesapla(_Kutu kutu, List<_KelimeGuveni> kelimeler) {
  final List<double> eslesenGuvenler = <double>[
    for (final _KelimeGuveni k in kelimeler)
      if (_merkeziKutuIcindeMi(k.kutu, kutu)) k.guven,
  ];
  if (eslesenGuvenler.isEmpty) return _varsayilanGuven;
  return eslesenGuvenler.reduce((double a, double b) => a + b) / eslesenGuvenler.length;
}

bool _merkeziKutuIcindeMi(_Kutu kelime, _Kutu satir) {
  const double tolerans = 0.05;
  final double merkezX = (kelime.minX + kelime.maxX) / 2;
  final double merkezY = (kelime.minY + kelime.maxY) / 2;
  return merkezX >= satir.minX - tolerans &&
      merkezX <= satir.maxX + tolerans &&
      merkezY >= satir.minY - tolerans &&
      merkezY <= satir.maxY + tolerans;
}

// ---------------------------------------------------------------------
// Tablo Satırları Çıkarımı (Dinamik Sütun Eşleme)
// ---------------------------------------------------------------------

List<DefterSatiri> _tabloSatirlariniCikar(
  Map<String, dynamic> tablo,
  SatirTuru tur,
) {
  final List<dynamic> hucreler = (tablo['cells'] as List?) ?? const <dynamic>[];
  if (hucreler.isEmpty) return const <DefterSatiri>[];

  // Başlık satırlarını belirle
  final Set<int> baslikSatirlari = <int>{};
  for (final Object? hucre in hucreler) {
    if (hucre is! Map) continue;
    if (hucre['kind'] == 'columnHeader') {
      final int? r = hucre['rowIndex'] as int?;
      if (r != null) baslikSatirlari.add(r);
    }
  }
  // Eğer kind verilmemişse en azından satır 0 başlık kabul edilir
  if (baslikSatirlari.isEmpty) {
    baslikSatirlari.add(0);
  }

  // Sütun başlık metinlerini topla
  int maxSutun = 0;
  for (final Object? hucre in hucreler) {
    if (hucre is! Map) continue;
    final int? c = hucre['columnIndex'] as int?;
    final int? span = hucre['columnSpan'] as int?;
    if (c != null) {
      final int sonC = c + (span ?? 1) - 1;
      if (sonC > maxSutun) maxSutun = sonC;
    }
  }

  final Map<int, List<String>> sutunBasliklari = <int, List<String>>{};
  for (final Object? hucre in hucreler) {
    if (hucre is! Map) continue;
    final int? r = hucre['rowIndex'] as int?;
    final int? c = hucre['columnIndex'] as int?;
    final int span = (hucre['columnSpan'] as int?) ?? 1;
    final String icerik = (hucre['content'] as String?)?.trim() ?? '';
    if (r == null || c == null || !baslikSatirlari.contains(r)) continue;

    for (int offset = 0; offset < span; offset++) {
      final int hedefC = c + offset;
      (sutunBasliklari[hedefC] ??= <String>[]).add(icerik);
    }
  }

  // Dinamik sütun haritası
  int? tarihCol;
  int? noCol;
  int? maddeCol;
  int? aciklamaCol;
  int? miktarCol;
  int? yekunCol;

  for (int c = 0; c <= maxSutun; c++) {
    final String bText = (sutunBasliklari[c] ?? const <String>[]).join(' ').toLowerCase();
    if (bText.contains('tarih') && tarihCol == null) {
      tarihCol = c;
    }
    if ((bText.contains('no') || bText.contains('numara')) &&
        !bText.contains('karar') &&
        noCol == null) {
      noCol = c;
    }
    if ((bText.contains('mad') || bText.contains('madde')) && maddeCol == null) {
      maddeCol = c;
    }
    if ((bText.contains('açıklama') || bText.contains('aciklama') || bText.contains('nev')) &&
        aciklamaCol == null) {
      aciklamaCol = c;
    }
    if ((bText.contains('miktar') || bText.contains('tutar')) &&
        !bText.contains('kr') &&
        miktarCol == null) {
      miktarCol = c;
    }
    if ((bText.contains('yekün') || bText.contains('yekun')) &&
        !bText.contains('kr') &&
        yekunCol == null) {
      yekunCol = c;
    }
  }

  // Başlık metniyle eşleşmeyenler için varsayılan indeksler (6 sütunlu standart şablon)
  tarihCol ??= 0;
  noCol ??= 1;
  maddeCol ??= 2;
  aciklamaCol ??= 3;
  miktarCol ??= 4;
  yekunCol ??= 5;

  // Veri satırlarını indeksle
  final Map<int, Map<int, String>> satirlarByIndex = <int, Map<int, String>>{};
  for (final Object? hucre in hucreler) {
    if (hucre is! Map) continue;
    final int? satirNo = hucre['rowIndex'] as int?;
    final int? sutunNo = hucre['columnIndex'] as int?;
    final String icerik = (hucre['content'] as String?)?.trim() ?? '';
    if (satirNo == null || sutunNo == null) continue;
    (satirlarByIndex[satirNo] ??= <int, String>{})[sutunNo] = icerik;
  }

  final List<DefterSatiri> satirlar = <DefterSatiri>[];
  final List<int> satirNolari = satirlarByIndex.keys.toList()..sort();

  for (final int satirNo in satirNolari) {
    if (baslikSatirlari.contains(satirNo)) continue;
    final Map<int, String> sutunlar = satirlarByIndex[satirNo]!;
    if (sutunlar.values.every((String v) => v.trim().isEmpty)) continue;

    final String? miktarHam = _bosIseNull(sutunlar[miktarCol]);
    final String? yekunHam = _bosIseNull(sutunlar[yekunCol]);

    satirlar.add(
      DefterSatiri(
        id: '',
        ortakId: '',
        tur: tur,
        siraNo: satirlar.length,
        tarihHam: _bosIseNull(sutunlar[tarihCol]),
        no: _bosIseNull(sutunlar[noCol]),
        madde: _bosIseNull(sutunlar[maddeCol]),
        aciklama: _bosIseNull(sutunlar[aciklamaCol]),
        miktarKurus: paraMetniniKurusaCevir(miktarHam) ?? 0,
        miktarHam: miktarHam,
        yekunKurus: paraMetniniKurusaCevir(yekunHam) ?? 0,
        yekunHam: yekunHam,
      ),
    );
  }

  return satirlar;
}

String? _bosIseNull(String? metin) {
  if (metin == null) return null;
  final String temiz = metin.trim();
  return temiz.isEmpty ? null : temiz;
}

// ---------------------------------------------------------------------
// Çapa Tabanlı Bölge Arama (Fallback)
// ---------------------------------------------------------------------


