import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/data/rapor/uye_listesi_pdf_servisi.dart';
import 'package:ortak_defteri/domain/model/ortak.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UyeListesiPdfServisi Testleri', () {
    const UyeListesiPdfServisi servis = UyeListesiPdfServisi();

    final List<Ortak> testOrtaklar = <Ortak>[
      Ortak(
        id: '1',
        ortakNo: '101',
        sayfaNo: '12',
        tcKimlikNo: '12345678901',
        adSoyad: 'Şükrü YILMAZOĞLU',
        babaAdi: 'İsmail',
        dogumYeri: 'Eskişehir',
        dogumTarihiHam: '15.03.1975',
        dogumTarihi: DateTime(1975, 3, 15),
        girisTarihiHam: '01.01.2020',
        girisTarihi: DateTime(2020, 1, 1),
        ikametAdresi: 'Çamlıca Mah. Gül Sok. No:5 Odunpazarı/Eskişehir',
        nufusKayitYeri: 'Eskişehir / Odunpazarı',
        aramaAnahtari: 'sukru yilmazoglu',
        aktif: true,
        olusturmaTarihi: DateTime(2020, 1, 1),
        guncellemeTarihi: DateTime(2020, 1, 1),
      ),
      Ortak(
        id: '2',
        ortakNo: '102',
        sayfaNo: '13',
        tcKimlikNo: '98765432109',
        adSoyad: 'Ömer Faruk ÇELİK',
        babaAdi: 'Şaban',
        dogumYeri: 'İzmir',
        dogumTarihiHam: '20.08.1982',
        dogumTarihi: DateTime(1982, 8, 20),
        girisTarihiHam: '10.05.2021',
        girisTarihi: DateTime(2021, 5, 10),
        cikisTarihiHam: '15.12.2024',
        cikisTarihi: DateTime(2024, 12, 15),
        ikametAdresi: 'Alsancak Mah. Atatürk Cad. No:12 Konak/İzmir',
        nufusKayitYeri: 'İzmir / Konak',
        aramaAnahtari: 'omer faruk celik',
        aktif: false,
        pasifNedeni: 'İstifa',
        olusturmaTarihi: DateTime(2021, 5, 10),
        guncellemeTarihi: DateTime(2024, 12, 15),
      ),
      Ortak(
        id: '3',
        ortakNo: '103',
        tcKimlikNo: '11223344556',
        adSoyad: 'Işıl GÜNEY',
        babaAdi: 'Ahmet',
        dogumYeri: 'Ağrı',
        girisTarihiHam: '05.06.2022',
        aramaAnahtari: 'isil guney',
        aktif: true,
        olusturmaTarihi: DateTime(2022, 6, 5),
        guncellemeTarihi: DateTime(2022, 6, 5),
      ),
    ];

    test('Türkçe karakterli ortaklar listesini geçerli bir PDF bayt dizisine dönüştürür', () async {
      final Uint8List pdfBytes = await servis.raporOlustur(
        ortaklar: testOrtaklar,
        baslik: 'TEST KOOPERATİFİ ORTAK LİSTESİ',
        altAciklama: 'Denetim amaçlı resmi test raporu',
      );

      // PDF baytları boş olmamalı
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));

      // PDF dosya formatı her zaman '%PDF-' magic baytları ile başlar (0x25, 0x50, 0x44, 0x46, 0x2D)
      final String baslik = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(baslik, equals('%PDF-'));
    });

    test('Boş ortak listesinde de çökmeden geçerli bir PDF tablosu oluşturur', () async {
      final Uint8List pdfBytes = await servis.raporOlustur(
        ortaklar: <Ortak>[],
        baslik: 'BOŞ LİSTE RAPORU',
      );

      expect(pdfBytes, isNotEmpty);
      final String baslik = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(baslik, equals('%PDF-'));
    });
  });
}
