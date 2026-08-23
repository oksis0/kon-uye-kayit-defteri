import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/data/repository/ocr_ayristirici.dart';
import 'package:ortak_defteri/domain/enum/satir_turu.dart';
import 'package:ortak_defteri/domain/model/ocr_sonucu.dart';

// ★ Bu testler synthetic (elle kurgulanmış) Azure JSON'u ile geometri ve
// eşleştirme MANTIĞINI doğruluyor — gerçek el yazısı taraması üzerindeki
// doğruluğu DEĞİL (bkz. ocr_ayristirici.dart başındaki dürüstlük notu).

Map<String, dynamic> _satir(String content, List<double> poligon) {
  return <String, dynamic>{'content': content, 'polygon': poligon};
}

Map<String, dynamic> _kelime(String content, List<double> poligon, double guven) {
  return <String, dynamic>{'content': content, 'polygon': poligon, 'confidence': guven};
}

Map<String, dynamic> _sayfa({List<dynamic>? satirlar, List<dynamic>? kelimeler}) {
  return <String, dynamic>{
    'lines': satirlar ?? const <dynamic>[],
    'words': kelimeler ?? const <dynamic>[],
  };
}

Map<String, dynamic> _yanit({List<dynamic>? sayfalar, List<dynamic>? tablolar}) {
  return <String, dynamic>{
    'analyzeResult': <String, dynamic>{
      'pages': sayfalar ?? const <dynamic>[],
      'tables': tablolar ?? const <dynamic>[],
    },
  };
}

Map<String, dynamic> _hucre(int satir, int sutun, String icerik) {
  return <String, dynamic>{'rowIndex': satir, 'columnIndex': sutun, 'content': icerik};
}

void main() {
  group('azureSonucunuAyristir — kimlik alanları', () {
    test('aynı satırda "Etiket: Değer" biçimini ayrıştırır ve kelime güvenini kullanır', () {
      final Map<String, dynamic> yanit = _yanit(
        sayfalar: <dynamic>[
          _sayfa(
            satirlar: <dynamic>[_satir('Ortak No: 147', <double>[0, 0, 2, 0, 2, 0.3, 0, 0.3])],
            kelimeler: <dynamic>[_kelime('147', <double>[1.2, 0, 2, 0, 2, 0.3, 1.2, 0.3], 0.95)],
          ),
        ],
      );

      final OcrSonucu sonuc = azureSonucunuAyristir(yanit);

      expect(sonuc.ortakNo?.metin, '147');
      expect(sonuc.ortakNo?.guven, closeTo(0.95, 0.001));
    });

    test('etiket ve değer ayrı satırlarda, değer sağdaysa bulunur', () {
      final Map<String, dynamic> yanit = _yanit(
        sayfalar: <dynamic>[
          _sayfa(
            satirlar: <dynamic>[
              _satir('Adı Soyadı', <double>[0, 0, 1.5, 0, 1.5, 0.3, 0, 0.3]),
              _satir('Ahmet Yılmaz', <double>[1.7, 0, 3, 0, 3, 0.3, 1.7, 0.3]),
            ],
          ),
        ],
      );

      final OcrSonucu sonuc = azureSonucunuAyristir(yanit);

      expect(sonuc.adSoyad?.metin, 'Ahmet Yılmaz');
      // Kelime verisi verilmedi -> varsayılan güven kullanılmalı.
      expect(sonuc.adSoyad?.guven, closeTo(0.75, 0.001));
    });

    test('etiket ve değer ayrı satırlarda, değer alttaysa bulunur', () {
      final Map<String, dynamic> yanit = _yanit(
        sayfalar: <dynamic>[
          _sayfa(
            satirlar: <dynamic>[
              _satir('Baba Adı', <double>[0, 1.0, 1.2, 1.0, 1.2, 1.3, 0, 1.3]),
              _satir('Mehmet', <double>[0, 1.4, 1.0, 1.4, 1.0, 1.7, 0, 1.7]),
            ],
          ),
        ],
      );

      final OcrSonucu sonuc = azureSonucunuAyristir(yanit);

      expect(sonuc.babaAdi?.metin, 'Mehmet');
    });

    test('uzak bir satır (aynı bantta değil, hizalı değil) eşleşmez', () {
      final Map<String, dynamic> yanit = _yanit(
        sayfalar: <dynamic>[
          _sayfa(
            satirlar: <dynamic>[
              _satir('Doğum Yeri', <double>[0, 0, 1.2, 0, 1.2, 0.3, 0, 0.3]),
              // Çok uzakta, hizasız bir satır — eşleşmemeli.
              _satir('Alakasız metin', <double>[5, 5, 6, 5, 6, 5.3, 5, 5.3]),
            ],
          ),
        ],
      );

      final OcrSonucu sonuc = azureSonucunuAyristir(yanit);

      expect(sonuc.dogumYeri, isNull);
    });

    test('etiket sayfada hiç yoksa alan null kalır (uygulama çökmez)', () {
      final Map<String, dynamic> yanit = _yanit(sayfalar: <dynamic>[_sayfa()]);

      final OcrSonucu sonuc = azureSonucunuAyristir(yanit);

      expect(sonuc.ortakNo, isNull);
      expect(sonuc.adSoyad, isNull);
      expect(sonuc.babaAdi, isNull);
    });

    test('analyzeResult tamamen eksikse çökmeden boş sonuç döner', () {
      expect(() => azureSonucunuAyristir(<String, dynamic>{}), returnsNormally);
      final OcrSonucu sonuc = azureSonucunuAyristir(<String, dynamic>{});
      expect(sonuc.ortakNo, isNull);
      expect(sonuc.sermayeSatirlari, isEmpty);
    });

    test('polygon eksik/bozuk bir satır sessizce atlanır', () {
      final Map<String, dynamic> yanit = _yanit(
        sayfalar: <dynamic>[
          _sayfa(
            satirlar: <dynamic>[
              <String, dynamic>{'content': 'Ortak No: 5'}, // polygon yok
            ],
          ),
        ],
      );

      expect(() => azureSonucunuAyristir(yanit), returnsNormally);
      expect(azureSonucunuAyristir(yanit).ortakNo, isNull);
    });
  });

  group('azureSonucunuAyristir — tablolar', () {
    test('ilk tablo sermaye, ikincisi ödeme olarak ayrıştırılır', () {
      final Map<String, dynamic> sermayeTablosu = <String, dynamic>{
        'cells': <dynamic>[
          _hucre(0, 0, 'Tarih'), _hucre(0, 1, 'No'), _hucre(0, 2, 'Mad.'),
          _hucre(0, 3, 'Açıklama'), _hucre(0, 4, 'Miktar'), _hucre(0, 5, 'Yekün'),
          _hucre(1, 0, '01.01.2020'), _hucre(1, 1, '1'), _hucre(1, 2, '5'),
          _hucre(1, 3, 'İlk sermaye'), _hucre(1, 4, '1.000,00'), _hucre(1, 5, '1.000,00'),
        ],
      };
      final Map<String, dynamic> odemeTablosu = <String, dynamic>{
        'cells': <dynamic>[
          _hucre(0, 0, 'Tarih'), _hucre(0, 1, 'No'), _hucre(0, 2, 'Mad.'),
          _hucre(0, 3, 'Açıklama'), _hucre(0, 4, 'Miktar'), _hucre(0, 5, 'Yekün'),
          _hucre(1, 0, '15.03.2021'), _hucre(1, 1, '2'), _hucre(1, 2, '7'),
          _hucre(1, 3, 'Ödeme'), _hucre(1, 4, '500,00'), _hucre(1, 5, '500,00'),
        ],
      };

      final Map<String, dynamic> yanit = _yanit(
        sayfalar: <dynamic>[_sayfa()],
        tablolar: <dynamic>[sermayeTablosu, odemeTablosu],
      );

      final OcrSonucu sonuc = azureSonucunuAyristir(yanit);

      expect(sonuc.sermayeSatirlari, hasLength(1));
      expect(sonuc.sermayeSatirlari.first.tur, SatirTuru.sermaye);
      expect(sonuc.sermayeSatirlari.first.tarihHam, '01.01.2020');
      expect(sonuc.sermayeSatirlari.first.aciklama, 'İlk sermaye');
      expect(sonuc.sermayeSatirlari.first.miktarKurus, 100000);

      expect(sonuc.odemeSatirlari, hasLength(1));
      expect(sonuc.odemeSatirlari.first.tur, SatirTuru.odeme);
      expect(sonuc.odemeSatirlari.first.miktarKurus, 50000);
    });

    test('başlık satırı (rowIndex 0) veri satırı olarak alınmaz', () {
      final Map<String, dynamic> tablo = <String, dynamic>{
        'cells': <dynamic>[_hucre(0, 0, 'Tarih'), _hucre(0, 1, 'No')],
      };
      final Map<String, dynamic> yanit = _yanit(
        sayfalar: <dynamic>[_sayfa()],
        tablolar: <dynamic>[tablo],
      );

      expect(azureSonucunuAyristir(yanit).sermayeSatirlari, isEmpty);
    });

    test('tamamen boş içerikli satırlar atlanır', () {
      final Map<String, dynamic> tablo = <String, dynamic>{
        'cells': <dynamic>[_hucre(0, 0, 'Tarih'), _hucre(1, 0, ''), _hucre(1, 1, '')],
      };
      final Map<String, dynamic> yanit = _yanit(
        sayfalar: <dynamic>[_sayfa()],
        tablolar: <dynamic>[tablo],
      );

      expect(azureSonucunuAyristir(yanit).sermayeSatirlari, isEmpty);
    });

    test('tablo hiç yoksa iki liste de boş döner', () {
      final Map<String, dynamic> yanit = _yanit(sayfalar: <dynamic>[_sayfa()]);
      final OcrSonucu sonuc = azureSonucunuAyristir(yanit);

      expect(sonuc.sermayeSatirlari, isEmpty);
      expect(sonuc.odemeSatirlari, isEmpty);
    });
  });
}
