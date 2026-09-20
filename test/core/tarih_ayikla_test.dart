import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/core/util/tarih_ayikla.dart';

void main() {
  group('tarihiAyristir', () {
    test('4 haneli tek yıl değerlerini (1974, 1995) 1 Ocak olarak çevirir', () {
      final DateTime? d1 = tarihiAyristir('1974');
      expect(d1, isNotNull);
      expect(d1!.year, 1974);
      expect(d1.month, 1);
      expect(d1.day, 1);

      final DateTime? d2 = tarihiAyristir('1995');
      expect(d2, isNotNull);
      expect(d2!.year, 1995);
    });

    test('Gün.Ay.Yıl biçimlerini (15.04.1974, 1/5/1990) doğru ayrıştırır', () {
      final DateTime? d = tarihiAyristir('15.04.1974');
      expect(d, isNotNull);
      expect(d!.year, 1974);
      expect(d.month, 4);
      expect(d.day, 15);

      final DateTime? dSlash = tarihiAyristir('1/5/1990');
      expect(dSlash, isNotNull);
      expect(dSlash!.year, 1990);
      expect(dSlash.month, 5);
      expect(dSlash.day, 1);
    });

    test('Metin içindeki 4 haneli yılı bulur', () {
      final DateTime? d = tarihiAyristir('Doğum: 1974');
      expect(d, isNotNull);
      expect(d!.year, 1974);
    });

    test('Boş veya geçersiz metinler için null döner', () {
      expect(tarihiAyristir(null), isNull);
      expect(tarihiAyristir(''), isNull);
      expect(tarihiAyristir('   '), isNull);
      expect(tarihiAyristir('geçersiz metin'), isNull);
    });
  });
}
