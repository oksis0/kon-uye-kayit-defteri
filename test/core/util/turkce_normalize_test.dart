import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/core/util/turkce_normalize.dart';

void main() {
  group('turkceNormalize — harf katlaması', () {
    test('ı/İ/I hepsi i olur (Türkçe I/ı tuzağı)', () {
      expect(turkceNormalize('ıİI'), 'iii');
    });

    test('ş/Ş → s', () {
      expect(turkceNormalize('Şişli'), 'sisli');
    });

    test('ğ/Ğ → g', () {
      expect(turkceNormalize('Ağrı Dağ'), 'agri dag');
    });

    test('ü/Ü → u', () {
      expect(turkceNormalize('Ürün'), 'urun');
    });

    test('ö/Ö → o', () {
      expect(turkceNormalize('Ömer Göz'), 'omer goz');
    });

    test('ç/Ç → c', () {
      expect(turkceNormalize('Çağrı'), 'cagri');
    });

    test('eski imla â/î/û katlanır', () {
      expect(turkceNormalize('kâğıt'), 'kagit');
    });
  });

  group('turkceNormalize — PLAN.md §5 örnekleri', () {
    test('Şükrü YILMAZOĞLU → sukru yilmazoglu', () {
      expect(turkceNormalize('Şükrü YILMAZOĞLU'), 'sukru yilmazoglu');
    });

    test('İSMAİL Çağrı → ismail cagri', () {
      expect(turkceNormalize('İSMAİL Çağrı'), 'ismail cagri');
    });
  });

  group('turkceNormalize — boşluk ve noktalama', () {
    test('çoklu boşluk teke iner', () {
      expect(turkceNormalize('Ahmet    Yılmaz'), 'ahmet yilmaz');
    });

    test('baş ve son boşluk kırpılır', () {
      expect(turkceNormalize('  Ahmet  '), 'ahmet');
    });

    test('noktalama temizlenir', () {
      expect(turkceNormalize('Yılmaz, Ahmet.'), 'yilmaz ahmet');
    });

    test('rakamlar korunur (ortak no, tarih gibi alanlar için)', () {
      expect(turkceNormalize('Ortak No: 147'), 'ortak no 147');
    });

    test('boş string boş kalır', () {
      expect(turkceNormalize(''), '');
    });

    test('sadece boşluktan oluşan string boş kalır', () {
      expect(turkceNormalize('   '), '');
    });
  });

  group('turkceNormalize — arama senaryosu', () {
    test('kullanıcı düz "sukru" yazınca "ŞÜKRÜ" ile eşleşir', () {
      final String kayit = turkceNormalize('ŞÜKRÜ YILMAZ');
      final String sorgu = turkceNormalize('sukru');
      expect(kayit.contains(sorgu), isTrue);
    });

    test('idempotent — iki kez normalize etmek sonucu değiştirmez', () {
      final String birKez = turkceNormalize('Çağrı Öztürk');
      expect(turkceNormalize(birKez), birKez);
    });
  });

  group('aramaAnahtariUret', () {
    test('birden çok alanı boşlukla birleştirir', () {
      final String sonuc = aramaAnahtariUret(<String?>['Ahmet Yılmaz', 'Konya', '147']);
      expect(sonuc, 'ahmet yilmaz konya 147');
    });

    test('null alanları atlar', () {
      final String sonuc = aramaAnahtariUret(<String?>['Ahmet', null, 'Konya']);
      expect(sonuc, 'ahmet konya');
    });

    test('boş string alanları atlar', () {
      final String sonuc = aramaAnahtariUret(<String?>['Ahmet', '', '   ', 'Konya']);
      expect(sonuc, 'ahmet konya');
    });

    test('tüm alanlar null/boşsa boş sonuç döner', () {
      final String sonuc = aramaAnahtariUret(<String?>[null, '', '  ']);
      expect(sonuc, '');
    });
  });
}
