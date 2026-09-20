import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/core/util/csv_guvenlik.dart';

void main() {
  group('csvFormulKorumasi (CWE-1236 Formula Injection Koruması)', () {
    test('null veya boş string güvenle boş döner', () {
      expect(csvFormulKorumasi(null), '');
      expect(csvFormulKorumasi(''), '');
    });

    test('Normal metinleri değiştirmeden döner', () {
      expect(csvFormulKorumasi('Ahmet Yılmaz'), 'Ahmet Yılmaz');
      expect(csvFormulKorumasi('1024'), '1024');
      expect(csvFormulKorumasi('Kadıköy, İstanbul'), 'Kadıköy, İstanbul');
    });

    test('Tehlikeli formül ve DDE başlatıcı karakterleri tek tırnak ile korumaya alır', () {
      // Eşittir (=) ile başlayan formüller
      expect(csvFormulKorumasi('=SUM(A1:A10)'), "'=SUM(A1:A10)");
      expect(csvFormulKorumasi("=cmd|'/C calc'!A0"), "'=cmd|'/C calc'!A0");

      // Artı (+) ve Eksi (-) ile başlayan formüller
      expect(csvFormulKorumasi('+1+2'), "'+1+2");
      expect(csvFormulKorumasi('-5+5'), "'-5+5");

      // Et (@) işareti ile başlayan formüller
      expect(csvFormulKorumasi('@SUM(1,2)'), "'@SUM(1,2)");

      // Tab (\t) ve Satırbaşı (\r)
      expect(csvFormulKorumasi('\tformül'), "'\tformül");
      expect(csvFormulKorumasi('\rformül'), "'\rformül");
    });
  });
}
