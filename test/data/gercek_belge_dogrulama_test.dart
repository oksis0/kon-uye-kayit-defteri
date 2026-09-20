import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/core/util/tarih_ayikla.dart';
import 'package:ortak_defteri/data/repository/ocr_ayristirici.dart';
import 'package:ortak_defteri/domain/model/ocr_sonucu.dart';

void main() {
  test('Kullanıcının gerçek Ortak Pay Defteri (ŞABAN EKİNCİ, Sayfa 50) verisini eksiksiz ayrıştırır', () {
    final File fixtureFile = File('test/fixtures/gercek_ocr_ornek.json');
    if (!fixtureFile.existsSync()) {
      return;
    }

    final String hamJson = fixtureFile.readAsStringSync();
    final Map<String, dynamic> azureYaniti = jsonDecode(hamJson) as Map<String, dynamic>;

    final OcrSonucu sonuc = azureSonucunuAyristir(azureYaniti);

    // 1) Ad Soyad
    expect(sonuc.adSoyad?.metin, 'SABAN EKINCI');

    // 2) Sayfa No ve TC Kimlik No
    expect(sonuc.sayfaNo?.metin, '50');
    expect(sonuc.tcKimlikNo?.metin, '52876743710');

    // Ortak No bu belgede boş bırakıldığı için null olmalıdır (Sayfa No ile karışmaz)
    expect(sonuc.ortakNo, isNull);

    // 3) Kimlik Tablosu Alanları
    expect(sonuc.babaAdi?.metin, 'MUHARREM');
    expect(sonuc.dogumYeri?.metin, 'ULUS');
    expect(sonuc.dogumTarihi?.metin, '1974');
    expect(sonuc.girisTarihi?.metin, '1995');
    expect(sonuc.nufusKayitYeri?.metin, 'KONAK');

    // İkamet Adresi belgede boş bırakıldığı için kesinlikle null olmalı (alttaki KONAK'ı çalmamalı)
    expect(sonuc.ikametAdresi, isNull);

    // 4) Tarih ayrıştırma doğrulaması
    final DateTime? dtDogum = tarihiAyristir(sonuc.dogumTarihi?.metin);
    expect(dtDogum, isNotNull);
    expect(dtDogum!.year, 1974);

    final DateTime? dtGiris = tarihiAyristir(sonuc.girisTarihi?.metin);
    expect(dtGiris, isNotNull);
    expect(dtGiris!.year, 1995);

    // 5) Sermaye Tablosu (Top. Sermaye, 100.00 TL)
    expect(sonuc.sermayeSatirlari, hasLength(1));
    expect(sonuc.sermayeSatirlari.first.aciklama, 'Top. Sermaye');
    expect(sonuc.sermayeSatirlari.first.miktarKurus, 10000);
    expect(sonuc.sermayeSatirlari.first.yekunKurus, 10000);

    // 6) Ödeme Tablosu
    expect(sonuc.odemeSatirlari, isEmpty);
  });

  test('Kullanıcının ikinci gerçek Ortak Pay Defteri (OĞUZHAN, Sayfa 360, No 1011) verisini eksiksiz ayrıştırır', () {
    final File fixtureFile = File('test/fixtures/gercek_ocr_ornek_2.json');
    if (!fixtureFile.existsSync()) {
      return;
    }

    final String hamJson = fixtureFile.readAsStringSync();
    final Map<String, dynamic> azureYaniti = jsonDecode(hamJson) as Map<String, dynamic>;

    final OcrSonucu sonuc = azureSonucunuAyristir(azureYaniti);

    // 1) Ad Soyad, Ortak No, Sayfa No, TC Kimlik No
    expect(sonuc.adSoyad?.metin, 'Oğuzhan');
    expect(sonuc.ortakNo?.metin, '1011');
    expect(sonuc.sayfaNo?.metin, '360');
    expect(sonuc.tcKimlikNo?.metin, '50194833250');

    // 2) Kimlik Alanları
    expect(sonuc.babaAdi?.metin, 'Saban');
    expect(sonuc.dogumTarihi?.metin, '20.10.2001'); // Başındaki ":" temizlenmiş olmalı
    expect(sonuc.girisTarihi?.metin, '28.02.2024');
    expect(sonuc.nufusKayitYeri?.metin, 'KONAK');

    // İkamet Adresi bu belgede de boş bırakıldığı için null olmalı (Nüfusa Kayıtlı Olduğu Yer'i çalmamalı!)
    expect(sonuc.ikametAdresi, isNull);
  });
}
