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

  // Sayfa boyutları — çapa tabanlı fallback için gerekli
  final List<dynamic> sayfaListesi = (analiz['pages'] as List?) ?? const <dynamic>[];
  final double sayfaW = sayfaListesi.isNotEmpty
      ? ((sayfaListesi[0] as Map<String, dynamic>?)?['width'] as num?)?.toDouble() ?? 1.0
      : 1.0;
  final double sayfaH = sayfaListesi.isNotEmpty
      ? ((sayfaListesi[0] as Map<String, dynamic>?)?['height'] as num?)?.toDouble() ?? 1.0
      : 1.0;

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
  final Map<String, OcrAlan> kimlikHucresiAlanlari = kimlikTablosu != null
      ? _kimlikTablosundanCikar(kimlikTablosu, kelimeler)
      : const <String, OcrAlan>{};

  // 2) Satırlardan etiket eşleyici ile alanları bul
  OcrAlan? satirdaBul(
    List<String> etiketVaryasyonlari, {
    bool sadeceMetin = false,
    bool sadeceSayi = false,
  }) =>
      _alanBul(
        satirlar,
        kelimeler,
        etiketVaryasyonlari,
        sadeceMetin: sadeceMetin,
        sadeceSayi: sadeceSayi,
      );

  bool etiketSayfadaVarMi(List<String> etiketVaryasyonlari) {
    if (kimlikTablosu != null) {
      final List<dynamic> hucreler = (kimlikTablosu['cells'] as List?) ?? const <dynamic>[];
      for (final Object? h in hucreler) {
        if (h is! Map) continue;
        final String c = (h['content'] as String?)?.toLowerCase() ?? '';
        for (final String e in etiketVaryasyonlari) {
          if (c.contains(e.toLowerCase())) return true;
        }
      }
    }
    return satirlar.any((_Satir s) => _satirEtiketMi(s.metin, etiketVaryasyonlari));
  }

  // 3) Çapa tabanlı fallback yardımcısı — etiket/tablo bulamazsa koordinat bölgesinden ara
  OcrAlan? capaIleBul(
    String alanAdi,
    List<String> etiketVaryasyonlari, {
    bool sadeceMetin = false,
    bool sadeceSayi = false,
  }) {
    // Eğer etiket sayfada/tabloda zaten MEVCUTSA ve değeri bulunamadıysa,
    // bu alan belgede boş bırakılmıştır. Asla komşu satırların değerini çalma!
    if (etiketSayfadaVarMi(etiketVaryasyonlari)) return null;

    return _capaBolgeSindeBul(
      satirlar,
      kelimeler,
      sayfaW,
      sayfaH,
      alanAdi,
      sadeceMetin: sadeceMetin,
      sadeceSayi: sadeceSayi,
    );
  }

  // Ortak No
  final OcrAlan? ortakNo = kimlikHucresiAlanlari['ortakNo'] ??
      satirdaBul(_ortakNoVaryasyonlari, sadeceSayi: true) ??
      capaIleBul('ortakNo', _ortakNoVaryasyonlari, sadeceSayi: true);

  // Sayfa No
  final OcrAlan? sayfaNo = kimlikHucresiAlanlari['sayfaNo'] ??
      satirdaBul(_sayfaNoVaryasyonlari, sadeceSayi: true) ??
      capaIleBul('sayfaNo', _sayfaNoVaryasyonlari, sadeceSayi: true);

  // TC Kimlik No
  final OcrAlan? tcKimlikNo = _tcKimlikNoBul(satirlar, kelimeler, kimlikHucresiAlanlari);

  // Ad Soyad
  final OcrAlan? adSoyad = kimlikHucresiAlanlari['adSoyad'] ??
      satirdaBul(_adSoyadVaryasyonlari, sadeceMetin: true) ??
      capaIleBul('adSoyad', _adSoyadVaryasyonlari, sadeceMetin: true);

  // Baba Adı
  final OcrAlan? babaAdi = kimlikHucresiAlanlari['babaAdi'] ??
      satirdaBul(_babaAdiVaryasyonlari, sadeceMetin: true) ??
      capaIleBul('babaAdi', _babaAdiVaryasyonlari, sadeceMetin: true);

  // Doğum Yeri
  final OcrAlan? dogumYeri = kimlikHucresiAlanlari['dogumYeri'] ??
      satirdaBul(_dogumYeriVaryasyonlari, sadeceMetin: true) ??
      capaIleBul('dogumYeri', _dogumYeriVaryasyonlari, sadeceMetin: true);

  // Doğum Tarihi
  final OcrAlan? dogumTarihi = kimlikHucresiAlanlari['dogumTarihi'] ??
      satirdaBul(_dogumTarihiVaryasyonlari) ??
      capaIleBul('dogumTarihi', _dogumTarihiVaryasyonlari);

  // Giriş Tarihi
  final OcrAlan? girisTarihi = kimlikHucresiAlanlari['girisTarihi'] ??
      satirdaBul(_girisTarihiVaryasyonlari) ??
      capaIleBul('girisTarihi', _girisTarihiVaryasyonlari);

  // Çıkış Tarihi
  final OcrAlan? cikisTarihi = kimlikHucresiAlanlari['cikisTarihi'] ??
      satirdaBul(_cikisTarihiVaryasyonlari) ??
      capaIleBul('cikisTarihi', _cikisTarihiVaryasyonlari);

  // İkamet Adresi
  final OcrAlan? ikametAdresi = kimlikHucresiAlanlari['ikametAdresi'] ??
      satirdaBul(_ikametAdresiVaryasyonlari) ??
      capaIleBul('ikametAdresi', _ikametAdresiVaryasyonlari, sadeceMetin: true);

  // Nüfusa Kayıtlı Olduğu Yer
  final OcrAlan? nufusKayitYeri = kimlikHucresiAlanlari['nufusKayitYeri'] ??
      satirdaBul(_nufusKayitYeriVaryasyonlari) ??
      capaIleBul('nufusKayitYeri', _nufusKayitYeriVaryasyonlari, sadeceMetin: true);

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
  'Doğum Yeri',
  'DOĞUM YERİ',
  'Dogum Yeri',
  'Doğum Yeri:',
];

const List<String> _dogumTarihiVaryasyonlari = <String>[
  'Doğum Tarihi',
  'DOĞUM TARİHİ',
  'Dogum Tarihi',
  'Doğum Tarihi:',
  'Doğum Yılı',
];

const List<String> _girisTarihiVaryasyonlari = <String>[
  'Giriş Tarihi',
  'GİRİŞ TARİHİ',
  'Giris Tarihi',
  'Giriş Tarihi:',
  'Ortaklığa Giriş',
];

const List<String> _cikisTarihiVaryasyonlari = <String>[
  'Çıkış Tarihi',
  'ÇIKIŞ TARİHİ',
  'Cikis Tarihi',
  'Çıkış Tarihi:',
  'Ortaklıktan Çıkış',
];

const List<String> _ikametAdresiVaryasyonlari = <String>[
  'İkamet Adresi',
  'İKAMET ADRESİ',
  'Ikamet Adresi',
  'İkametgah Adresi',
  'İkametgah',
  'Ikametgah',
  'İkamet',
  'Ikamet',
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
  'nüfusa', 'nufusa', 'nüfusta', 'nufusta', 'nüfus', 'nufus',
  't.c.', 'tc', 'kimlik', 'imza yeri', 'sayfa no', 'karar', 'yevmiye',
  'sermaye', 'ödeme', 'odeme', 'fotoğraf', 'fotograf',
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

Map<String, OcrAlan> _kimlikTablosundanCikar(
  Map<String, dynamic> tablo,
  List<_KelimeGuveni> kelimeler,
) {
  final List<dynamic> hucreler = (tablo['cells'] as List?) ?? const <dynamic>[];
  final Map<String, OcrAlan> sonuc = <String, OcrAlan>{};

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
      // Asla alt satırdan (r+1) değer çekilmez — her satır bağımsız bir alandır!
      Map<String, dynamic>? degerHucre = hucreGrid[r]?[c + 1];
      String deger = (degerHucre?['content'] as String?)?.trim() ?? '';
      if (deger.isEmpty && hucreGrid[r]?[c + 2] != null) {
        degerHucre = hucreGrid[r]?[c + 2];
        deger = (degerHucre?['content'] as String?)?.trim() ?? '';
      }

      // Eğer sağ hücrelerde değer yoksa ama hücrenin kendi içinde etiket+değer
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
      if (deger.isEmpty) continue;

      final _Kutu? kutu = _Kutu.poligondenOlustur(degerHucre?['polygon']);
      final double guven = kutu != null ? _guvenHesapla(kutu, kelimeler) : 0.85;
      final OcrAlan alan = OcrAlan(metin: deger, guven: guven);

      if (lower.contains('baba ad') || lower == 'baba') {
        sonuc['babaAdi'] ??= alan;
      } else if (lower.contains('dogum yer') || lower.contains('doğum yer')) {
        sonuc['dogumYeri'] ??= alan;
      } else if (lower.contains('dogum tarih') ||
          lower.contains('doğum tarih') ||
          (lower.contains('tarih') &&
              !lower.contains('giris') &&
              !lower.contains('giriş') &&
              !lower.contains('cikis') &&
              !lower.contains('çıkış'))) {
        sonuc['dogumTarihi'] ??= alan;
      } else if (lower.contains('giris') || lower.contains('giriş')) {
        sonuc['girisTarihi'] ??= alan;
      } else if (lower.contains('cikis') || lower.contains('çıkış')) {
        sonuc['cikisTarihi'] ??= alan;
      } else if (lower.contains('nufus') || lower.contains('nüfus')) {
        sonuc['nufusKayitYeri'] ??= alan;
      } else if (lower.contains('ikamet') || lower.contains('adres')) {
        sonuc['ikametAdresi'] ??= alan;
      } else if (lower.contains('ad') && lower.contains('soyad')) {
        sonuc['adSoyad'] ??= alan;
      } else if (lower.contains('sayfa no') || lower.contains('sayfa')) {
        sonuc['sayfaNo'] ??= alan;
      } else if (lower.contains('t.c') || lower.contains('kimlik no') || lower == 'tc') {
        sonuc['tcKimlikNo'] ??= alan;
      } else if (lower.contains('ortak no') || lower == 'no') {
        sonuc['ortakNo'] ??= alan;
      }
    }
  }

  return sonuc;
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
  return _tumEtiketler.any((String e) => temiz.startsWith(e));
}

bool _harfIceriyorMu(String metin) => RegExp(r'[a-zA-ZçğıöşüÇĞİÖŞÜ]').hasMatch(metin);

bool _rakamIceriyorMu(String metin) => RegExp(r'\d').hasMatch(metin);

double _rakamOrani(String metin) {
  if (metin.isEmpty) return 0;
  final int rakamSayisi = metin.runes.where((int c) => c >= 48 && c <= 57).length;
  return rakamSayisi / metin.length;
}

OcrAlan? _alanBul(
  List<_Satir> satirlar,
  List<_KelimeGuveni> kelimeler,
  List<String> etiketVaryasyonlari, {
  bool sadeceMetin = false,
  bool sadeceSayi = false,
}) {
  for (final _Satir etiketSatiri in satirlar) {
    if (!_satirEtiketMi(etiketSatiri.metin, etiketVaryasyonlari)) continue;

    // 1) Aynı satırda etiketten sonra metin var mı? ("Ortak No: 147")
    final String? ayniSatirdakiDeger = _etiketSonrasiniAl(etiketSatiri.metin, etiketVaryasyonlari);
    if (ayniSatirdakiDeger != null) {
      bool uygun = true;
      if (sadeceMetin && (!_harfIceriyorMu(ayniSatirdakiDeger) || _rakamOrani(ayniSatirdakiDeger) > 0.3)) {
        uygun = false;
      }
      if (sadeceSayi && (!_rakamIceriyorMu(ayniSatirdakiDeger) || ayniSatirdakiDeger.length > 10)) {
        uygun = false;
      }

      if (uygun) {
        return OcrAlan(
          metin: ayniSatirdakiDeger,
          guven: _guvenHesapla(etiketSatiri.kutu, kelimeler),
        );
      }
    }

    // 2) Aynı yatay bantta sağdaki en yakın satırı bul
    final _Satir? degerSatiri = _yakinDegerSatiriniBul(
      etiketSatiri,
      satirlar,
      sadeceMetin: sadeceMetin,
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
  bool sadeceMetin = false,
  bool sadeceSayi = false,
}) {
  _Satir? enYakinSagdaki;
  double enKisaYatayMesafe = double.infinity;

  for (final _Satir aday in tumSatirlar) {
    if (identical(aday, etiketSatiri)) continue;
    if (_baskaEtiketMi(aday.metin)) continue;

    if (sadeceMetin) {
      if (!_harfIceriyorMu(aday.metin) || _rakamOrani(aday.metin) > 0.3) {
        continue;
      }
    }
    if (sadeceSayi) {
      if (!_rakamIceriyorMu(aday.metin) || aday.metin.length > 10) {
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
    final bool ayniBant = yCakisma > minH * 0.25 || dMerkezY <= minH * 0.5;

    // Sağda olma (küçük açı/eğiklik toleransı ile)
    final bool sagda = aday.kutu.minX >= etiketSatiri.kutu.maxX - minH * 0.3;

    if (ayniBant && sagda) {
      final double mesafe = aday.kutu.minX - etiketSatiri.kutu.maxX;
      if (mesafe < enKisaYatayMesafe && mesafe < 2000) {
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

    if (sadeceMetin) {
      if (!_harfIceriyorMu(aday.metin) || _rakamOrani(aday.metin) > 0.3) {
        continue;
      }
    }
    if (sadeceSayi) {
      if (!_rakamIceriyorMu(aday.metin) || aday.metin.length > 10) {
        continue;
      }
    }

    final bool altta = aday.kutu.minY > etiketSatiri.kutu.maxY - 5;
    final bool xHizali =
        (aday.kutu.minX - etiketSatiri.kutu.minX).abs() < etiketSatiri.kutu.yukseklik * 1.5;
    final double mesafe = aday.kutu.minY - etiketSatiri.kutu.maxY;
    if (altta && xHizali && mesafe < enKisaDikeyMesafe && mesafe < etiketSatiri.kutu.yukseklik * 3.5) {
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

/// "ORTAK PAY DEFTERİ" belgesindeki her alanın değer bölgesini
/// normalize koordinatlarla tanımlar.
///
/// [minX], [maxX] → sayfa genisliginin fraksiyonu (0.0–1.0).
/// [minYOfset], [maxYOfset] → çapa satırının merkez Y'sinden
///   sayfa yüksekliğinin fraksiyonu olarak ofset.
/// Bu yaklaşım, farklı zoom seviyelerinde çekilmiş fotoğraflarda da
/// koordinatların sabit kalmasını sağlar.
class _NormalBolge {
  const _NormalBolge(this.minX, this.minYOfset, this.maxX, this.maxYOfset);
  final double minX;
  final double minYOfset; // basılı çapa satırından ofset (page_height fraksiyonu)
  final double maxX;
  final double maxYOfset;
}

/// Koordinatlar Oğuzhan Ekıncı / Şaban Ekıncı sayfaları ölçülerek kalibre edildi.
/// "ORTAK PAY DEFTERİ" başlığı çapa; ofsetler bu başlığın merkez Y'sinden.
const Map<String, _NormalBolge> _alanBolgeleri = <String, _NormalBolge>{
  // Üst satır: Ortak No ve Sayfa No — başlığın hemen altında
  'ortakNo':        _NormalBolge(0.18, 0.010, 0.50, 0.038),
  'sayfaNo':        _NormalBolge(0.65, 0.010, 0.95, 0.038),
  // Adı Soyadı — ortak no'nun altında, geniş bant
  'adSoyad':        _NormalBolge(0.22, 0.030, 0.72, 0.055),
  // Kimlik tablosu satırları — değerler tablonun sağ sütununda
  'babaAdi':        _NormalBolge(0.50, 0.048, 0.88, 0.065),
  'dogumYeri':      _NormalBolge(0.50, 0.066, 0.88, 0.080),
  'dogumTarihi':    _NormalBolge(0.50, 0.081, 0.88, 0.096),
  'girisTarihi':    _NormalBolge(0.50, 0.097, 0.88, 0.112),
  'cikisTarihi':    _NormalBolge(0.50, 0.113, 0.88, 0.128),
  'ikametAdresi':   _NormalBolge(0.50, 0.129, 0.88, 0.144),
  'nufusKayitYeri': _NormalBolge(0.50, 0.145, 0.88, 0.168),
};

/// "ORTAK PAY DEFTERİ" başlığının merkez Y'sini bulur — koordinat çipası.
double? _baslikYBul(List<_Satir> satirlar) {
  for (final _Satir s in satirlar) {
    final String lower = s.metin.toLowerCase();
    if (lower.contains('pay defteri') || lower.contains('ortak pay')) {
      return s.kutu.merkezY;
    }
  }
  return null;
}

/// Etiket eşleme veya tablo çıkarma başarısız olduğunda devreye girer.
/// Başlık (çapa) konumunu referans alarak satırın nerede olacağını hesaplar
/// ve o bölgede geçerli değerleri toplar.
OcrAlan? _capaBolgeSindeBul(
  List<_Satir> satirlar,
  List<_KelimeGuveni> kelimeler,
  double sayfaW,
  double sayfaH,
  String alanAdi, {
  bool sadeceMetin = false,
  bool sadeceSayi = false,
}) {
  final _NormalBolge? bolge = _alanBolgeleri[alanAdi];
  if (bolge == null || sayfaW <= 0 || sayfaH <= 0) return null;

  // Çipa Y'sini bul; bulunamazsa sayfanın %9'unu varsay
  final double anchorY = _baslikYBul(satirlar) ?? (sayfaH * 0.09);

  final double absMinX = bolge.minX * sayfaW;
  final double absMaxX = bolge.maxX * sayfaW;
  final double absMinY = anchorY + bolge.minYOfset * sayfaH;
  final double absMaxY = anchorY + bolge.maxYOfset * sayfaH;

  final List<_Satir> adaylar = <_Satir>[];
  for (final _Satir s in satirlar) {
    // Bölge dışındaysa atla
    if (s.kutu.merkezX < absMinX || s.kutu.merkezX > absMaxX) continue;
    if (s.kutu.merkezY < absMinY || s.kutu.merkezY > absMaxY) continue;
    // Etiket satırlarını değer olarak alma
    if (_baskaEtiketMi(s.metin)) continue;
    // Tip sınırlamaları
    if (sadeceMetin && (!_harfIceriyorMu(s.metin) || _rakamOrani(s.metin) > 0.3)) continue;
    if (sadeceSayi && (!_rakamIceriyorMu(s.metin) || s.metin.length > 10)) continue;
    adaylar.add(s);
  }

  if (adaylar.isEmpty) return null;

  // X'e göre soldan sağa sırala, birleştir
  adaylar.sort((_Satir a, _Satir b) => a.kutu.minX.compareTo(b.kutu.minX));
  final String birlesmis = adaylar.map((_Satir s) => s.metin).join(' ').trim();
  if (birlesmis.isEmpty) return null;

  final _Kutu genelKutu = _Kutu(
    adaylar.map((_Satir s) => s.kutu.minX).reduce(math.min),
    adaylar.map((_Satir s) => s.kutu.minY).reduce(math.min),
    adaylar.map((_Satir s) => s.kutu.maxX).reduce(math.max),
    adaylar.map((_Satir s) => s.kutu.maxY).reduce(math.max),
  );

  // Koordinat tabanlı bulma güvenini hafif düşür (etiket eşleşmesinden daha az güvenilir)
  return OcrAlan(
    metin: birlesmis,
    guven: _guvenHesapla(genelKutu, kelimeler) * 0.85,
  );
}
