import '../../core/util/para_bicim.dart';
import '../../domain/enum/satir_turu.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ocr_sonucu.dart';

/// Azure Document Intelligence (`prebuilt-layout`) ham JSON'unu
/// [OcrSonucu]'na çevirir — "Aşama 1: Etiket Eşleyici" (PLAN.md §7.2).
///
/// ★★★ DÜRÜSTLÜK NOTU (önemli): Bu ayrıştırıcı **gerçek taranmış sayfalarla
/// hiç test edilmedi** — PLAN.md Faz 0'daki 20 sayfalık pilot tarama henüz
/// yapılmadı (Azure hesabı yok). Etiket varyasyonları ve geometrik
/// eşleştirme eşikleri, defterin metinde tarif edilen BEKLENEN düzenine
/// göre yazıldı. Bu şu anlama gelir:
///   - Kod mantığı sağlam ve test edilebilir (synthetic JSON ile test
///     edildi — `test/data/ocr_ayristirici_test.dart`).
///   - Gerçek el yazısı/tarama üzerindeki doğruluğu BİLİNMİYOR.
///   - Faz 0 pilot tamamlanınca `_etiketVaryasyonlari` haritası ve mesafe
///     eşikleri gerçek verilerle kalibre edilmeli.
/// Hiçbir alan bulunamasa bile uygulama çökmez — kullanıcı her zaman elle
/// doldurabilir ("insan yazar, OCR ön-doldurur").
OcrSonucu azureSonucunuAyristir(Map<String, dynamic> azureYaniti) {
  final Map<String, dynamic>? analiz = azureYaniti['analyzeResult'] as Map<String, dynamic>?;
  if (analiz == null) return const OcrSonucu();

  final List<_Satir> satirlar = _satirlariCikar(analiz);
  final List<_KelimeGuveni> kelimeler = _kelimeleriCikar(analiz);
  final List<List<DefterSatiri>> tablolar = _tablolariCikar(analiz);

  OcrAlan? bul(List<String> etiketVaryasyonlari) =>
      _alanBul(satirlar, kelimeler, etiketVaryasyonlari);

  return OcrSonucu(
    ortakNo: bul(_ortakNoVaryasyonlari),
    adSoyad: bul(_adSoyadVaryasyonlari),
    babaAdi: bul(_babaAdiVaryasyonlari),
    dogumYeri: bul(_dogumYeriVaryasyonlari),
    dogumTarihi: bul(_dogumTarihiVaryasyonlari),
    girisTarihi: bul(_girisTarihiVaryasyonlari),
    cikisTarihi: bul(_cikisTarihiVaryasyonlari),
    ikametAdresi: bul(_ikametAdresiVaryasyonlari),
    nufusKayitYeri: bul(_nufusKayitYeriVaryasyonlari),
    sermayeSatirlari: tablolar.isNotEmpty ? tablolar[0] : const <DefterSatiri>[],
    odemeSatirlari: tablolar.length > 1 ? tablolar[1] : const <DefterSatiri>[],
  );
}

// ---------------------------------------------------------------------
// Etiket varyasyonları — Faz 0 pilotundan sonra genişletilecek/düzeltilecek.
// ---------------------------------------------------------------------

const List<String> _ortakNoVaryasyonlari = <String>['Ortak No', 'ORTAK NO', 'Ortak Numarası'];
const List<String> _adSoyadVaryasyonlari = <String>[
  'Adı Soyadı', 'ADI SOYADI', 'Adı ve Soyadı', 'Ad Soyad', 'AD SOYAD',
];
const List<String> _babaAdiVaryasyonlari = <String>['Baba Adı', 'BABA ADI'];
const List<String> _dogumYeriVaryasyonlari = <String>['Doğum Yeri', 'DOĞUM YERİ'];
const List<String> _dogumTarihiVaryasyonlari = <String>['Doğum Tarihi', 'DOĞUM TARİHİ'];
const List<String> _girisTarihiVaryasyonlari = <String>['Giriş Tarihi', 'GİRİŞ TARİHİ'];
const List<String> _cikisTarihiVaryasyonlari = <String>['Çıkış Tarihi', 'ÇIKIŞ TARİHİ'];
const List<String> _ikametAdresiVaryasyonlari = <String>[
  'İkamet Adresi', 'İKAMET ADRESİ', 'Adresi', 'Adres',
];
const List<String> _nufusKayitYeriVaryasyonlari = <String>[
  'Nüfusa Kayıtlı Olduğu Yer', 'NÜFUSA KAYITLI OLDUĞU YER', 'Nüfus Kayıt Yeri',
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

  double get merkezY => (minY + maxY) / 2;
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
// Etiket eşleyici
// ---------------------------------------------------------------------

OcrAlan? _alanBul(
  List<_Satir> satirlar,
  List<_KelimeGuveni> kelimeler,
  List<String> etiketVaryasyonlari,
) {
  for (final _Satir etiketSatiri in satirlar) {
    if (!_satirEtiketMi(etiketSatiri.metin, etiketVaryasyonlari)) continue;

    // 1) Aynı satırda etiketten sonra metin var mı? ("Ortak No: 147")
    final String? ayniSatirdakiDeger = _etiketSonrasiniAl(etiketSatiri.metin, etiketVaryasyonlari);
    if (ayniSatirdakiDeger != null) {
      return OcrAlan(
        metin: ayniSatirdakiDeger,
        guven: _guvenHesapla(etiketSatiri.kutu, kelimeler),
      );
    }

    // 2) Değilse: sağda veya altta en yakın satırı bul.
    final _Satir? degerSatiri = _yakinDegerSatiriniBul(etiketSatiri, satirlar);
    if (degerSatiri != null) {
      return OcrAlan(metin: degerSatiri.metin, guven: _guvenHesapla(degerSatiri.kutu, kelimeler));
    }
  }
  return null;
}

bool _satirEtiketMi(String satirMetni, List<String> etiketVaryasyonlari) {
  final String temiz = satirMetni.trim();
  return etiketVaryasyonlari.any((String v) => temiz.startsWith(v));
}

/// Etiketle aynı satırda, etiketten SONRA metin varsa onu döner
/// (baştaki ':', '-' gibi ayraçlar temizlenmiş olarak). Etiketten sonra
/// hiçbir şey yoksa `null` — bu durumda değer başka bir satırda aranır.
String? _etiketSonrasiniAl(String satirMetni, List<String> etiketVaryasyonlari) {
  final String temiz = satirMetni.trim();
  for (final String v in etiketVaryasyonlari) {
    if (temiz.startsWith(v)) {
      final String kalan = temiz.substring(v.length).trim();
      final String ayracsiz = kalan.replaceFirst(RegExp(r'^[:\-–—]\s*'), '');
      return ayracsiz.isEmpty ? null : ayracsiz;
    }
  }
  return null;
}

/// Etiketin sağında (aynı yatay bantta, en yakın) veya altında (x hizalı,
/// en yakın) bir değer satırı arar. Sağdaki satır önceliklidir çünkü Türk
/// form geleneğinde "Etiket: ____" aynı satırda daha yaygındır.
_Satir? _yakinDegerSatiriniBul(_Satir etiketSatiri, List<_Satir> tumSatirlar) {
  _Satir? enYakinSagdaki;
  double enKisaYatayMesafe = double.infinity;

  for (final _Satir aday in tumSatirlar) {
    if (identical(aday, etiketSatiri)) continue;
    final bool ayniBant =
        (aday.kutu.merkezY - etiketSatiri.kutu.merkezY).abs() < etiketSatiri.kutu.yukseklik * 0.6;
    final bool sagda = aday.kutu.minX > etiketSatiri.kutu.maxX;
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
    final bool altta = aday.kutu.minY > etiketSatiri.kutu.maxY;
    final bool xHizali =
        (aday.kutu.minX - etiketSatiri.kutu.minX).abs() < etiketSatiri.kutu.yukseklik * 3;
    final double mesafe = aday.kutu.minY - etiketSatiri.kutu.maxY;
    if (altta && xHizali && mesafe < enKisaDikeyMesafe && mesafe < etiketSatiri.kutu.yukseklik * 2.5) {
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
// Tablo çıkarımı — Azure'un `tables[]` çıktısı zaten satır/sütun indeksli
// geldiği için (bu yüzden `prebuilt-layout` seçildi, PLAN.md §7.1),
// burada geometrik eşleştirmeye gerek yok.
// ---------------------------------------------------------------------

/// İlk tablo Sermaye Yüklenmeleri, ikincisi Ödemeler kabul edilir (sayfa
/// düzeni sırasına göre). Bu varsayım Faz 0 pilotunda doğrulanmalı.
List<List<DefterSatiri>> _tablolariCikar(Map<String, dynamic> analiz) {
  final List<dynamic> tablolar = (analiz['tables'] as List?) ?? const <dynamic>[];
  final List<List<DefterSatiri>> sonuc = <List<DefterSatiri>>[];

  for (int tabloIndex = 0; tabloIndex < tablolar.length; tabloIndex++) {
    final Object? tablo = tablolar[tabloIndex];
    if (tablo is! Map) continue;
    final List<dynamic> hucreler = (tablo['cells'] as List?) ?? const <dynamic>[];

    final Map<int, Map<int, String>> satirlarByIndex = <int, Map<int, String>>{};
    for (final Object? hucre in hucreler) {
      if (hucre is! Map) continue;
      final int? satirNo = hucre['rowIndex'] as int?;
      final int? sutunNo = hucre['columnIndex'] as int?;
      final String icerik = (hucre['content'] as String?)?.trim() ?? '';
      if (satirNo == null || sutunNo == null) continue;
      (satirlarByIndex[satirNo] ??= <int, String>{})[sutunNo] = icerik;
    }

    final SatirTuru tur = tabloIndex == 0 ? SatirTuru.sermaye : SatirTuru.odeme;
    final List<DefterSatiri> satirlar = <DefterSatiri>[];
    final List<int> satirNolari = satirlarByIndex.keys.toList()..sort();

    for (final int satirNo in satirNolari) {
      if (satirNo == 0) continue; // ★ ilk satır başlık (Tarih/No/Mad./...) kabul edilir
      final Map<int, String> sutunlar = satirlarByIndex[satirNo]!;
      if (sutunlar.values.every((String v) => v.isEmpty)) continue;

      satirlar.add(
        DefterSatiri(
          id: '',
          ortakId: '',
          tur: tur,
          siraNo: satirlar.length,
          tarihHam: _bosIseNull(sutunlar[0]),
          no: _bosIseNull(sutunlar[1]),
          madde: _bosIseNull(sutunlar[2]),
          aciklama: _bosIseNull(sutunlar[3]),
          miktarKurus: paraMetniniKurusaCevir(sutunlar[4]) ?? 0,
          miktarHam: _bosIseNull(sutunlar[4]),
          yekunKurus: paraMetniniKurusaCevir(sutunlar[5]) ?? 0,
          yekunHam: _bosIseNull(sutunlar[5]),
        ),
      );
    }
    sonuc.add(satirlar);
  }

  return sonuc;
}

String? _bosIseNull(String? metin) => (metin == null || metin.isEmpty) ? null : metin;
