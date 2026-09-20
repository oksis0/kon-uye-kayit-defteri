import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ortak_defteri/app/theme/app_theme.dart';
import 'package:ortak_defteri/domain/enum/satir_turu.dart';
import 'package:ortak_defteri/domain/model/defter_satiri.dart';
import 'package:ortak_defteri/domain/model/ortak.dart';
import 'package:ortak_defteri/features/ortak_detay/widget/defter_tablosu.dart';
import 'package:ortak_defteri/features/ortak_detay/widget/kimlik_bilgi_karti.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  final Ortak ornekOrtak = Ortak(
    id: 'test-1',
    ortakNo: '1024',
    sayfaNo: '45',
    tcKimlikNo: '12345678901',
    adSoyad: 'Emirhan Testoğlu Çok Uzun İsimli Ortak Kaydı',
    babaAdi: 'Mehmet Ali',
    dogumYeri: 'Kadıköy / İstanbul',
    dogumTarihi: DateTime(1985, 4, 12),
    girisTarihi: DateTime(2010, 1, 1),
    ikametAdresi: 'Atatürk Mahallesi Cumhuriyet Caddesi No: 42 Daire: 7 Ataşehir / İstanbul',
    nufusKayitYeri: 'İstanbul / Üsküdar / Selimiye Mah. Cilt: 12 Aile: 34 Sıra: 56',
    aramaAnahtari: '1024 emirhan testoglu',
    yerelDosyaYolu: '/test/yol/belge.jpg',
    olusturmaTarihi: DateTime.now(),
    guncellemeTarihi: DateTime.now(),
  );

  testWidgets('KimlikBilgiKarti dar mobil ekranda (360px) taşma olmadan render olur', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: KimlikBilgiKarti(ortak: ornekOrtak),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Emirhan Testoğlu Çok Uzun İsimli Ortak Kaydı'), findsOneWidget);
    expect(find.text('Taranmış Belgeyi Gör'), findsOneWidget);
  });

  testWidgets('DefterTablosu dar mobil ekranda (360px) yatay kaydırma ile taşmasız render olur', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final List<DefterSatiri> satirlar = <DefterSatiri>[
      DefterSatiri(
        id: 'satir-1',
        ortakId: 'test-1',
        tur: SatirTuru.sermaye,
        siraNo: 1,
        tarih: DateTime(2020, 1, 1),
        no: '2020/01',
        miktarKurus: 15000000,
        yekunKurus: 15000000,
        aciklama: 'İlk taahhüt edilen sermaye payı',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: DefterTablosu(
              tur: SatirTuru.sermaye,
              satirlar: satirlar,
              onSatirKaydet: (_) {},
              onSatirSil: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Sermaye Yüklenmesi'), findsOneWidget);
  });
}
