import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/core/util/para_bicim.dart';

void main() {
  group('paraMetniniKurusaCevir', () {
    test('Türkçe biçim: binlik nokta, ondalık virgül', () {
      expect(paraMetniniKurusaCevir('1.250,50'), 125050);
    });

    test('binlik ayıracı olmadan, ondalık virgül', () {
      expect(paraMetniniKurusaCevir('1250,50'), 125050);
    });

    test('ondalık nokta (OCR bazen böyle okuyabilir)', () {
      expect(paraMetniniKurusaCevir('1250.50'), 125050);
    });

    test('sadece tam sayı, ondalık yok', () {
      expect(paraMetniniKurusaCevir('1250'), 125000);
    });

    test('₺ işareti ve boşluklarla', () {
      expect(paraMetniniKurusaCevir(' 1.250,50 ₺ '), 125050);
    });

    test('tek haneli kuruş "5,5" → 5 lira 50 kuruş', () {
      expect(paraMetniniKurusaCevir('5,5'), 550);
    });

    test('null girdi null döner', () {
      expect(paraMetniniKurusaCevir(null), isNull);
    });

    test('boş string null döner', () {
      expect(paraMetniniKurusaCevir(''), isNull);
      expect(paraMetniniKurusaCevir('   '), isNull);
    });

    test('rakam içermeyen metin null döner', () {
      expect(paraMetniniKurusaCevir('okunamadı'), isNull);
    });

    test('büyük binlik ayraçlı sayı', () {
      expect(paraMetniniKurusaCevir('12.345.678,90'), 1234567890);
    });
  });

  group('kurusuBicimlendir', () {
    test('kuruşu Türkçe para birimine çevirir', () {
      expect(kurusuBicimlendir(125050), contains('1.250,50'));
      expect(kurusuBicimlendir(125050), contains('₺'));
    });

    test('sıfır', () {
      expect(kurusuBicimlendir(0), contains('0,00'));
    });
  });
}
