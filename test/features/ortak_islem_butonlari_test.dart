import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ortak_defteri/app/theme/app_theme.dart';
import 'package:ortak_defteri/domain/model/ortak.dart';
import 'package:ortak_defteri/features/ortak_detay/ortak_detay_ekrani.dart';
import 'package:ortak_defteri/features/ortak_detay/widget/kimlik_bilgi_karti.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  final Ortak aktifOrtak = Ortak(
    id: 'test-1',
    ortakNo: '1001',
    sayfaNo: '10',
    tcKimlikNo: '12345678901',
    adSoyad: 'Ahmet Yılmaz',
    aktif: true,
    aramaAnahtari: '1001 ahmet yilmaz',
    olusturmaTarihi: DateTime.now(),
    guncellemeTarihi: DateTime.now(),
  );

  final Ortak pasifOrtak = Ortak(
    id: 'test-2',
    ortakNo: '1002',
    sayfaNo: '12',
    tcKimlikNo: '98765432109',
    adSoyad: 'Mehmet Demir',
    aktif: false,
    pasifNedeni: 'İstifa',
    aramaAnahtari: '1002 mehmet demir',
    olusturmaTarihi: DateTime.now(),
    guncellemeTarihi: DateTime.now(),
  );

  testWidgets('Aktif ortak için sarı Pasif butonu ve kırmızı Kalıcı Sil butonu görünür', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: IslemButonlari(ortak: aktifOrtak),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Üyeliği Sona Erdir (Pasif Yap)'), findsOneWidget);
    expect(find.text('Ortağı Kalıcı Sil'), findsOneWidget);
  });

  testWidgets('Pasif ortak için sarı Aktif Yap butonu ve kırmızı Kalıcı Sil butonu görünür', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: IslemButonlari(ortak: pasifOrtak),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Ortağı Yeniden Aktif Yap'), findsOneWidget);
    expect(find.text('Ortağı Kalıcı Sil'), findsOneWidget);
  });

  testWidgets('KimlikBilgiKarti pasif ortak için Aktif Et butonu ve uyarı şeridi gösterir', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool aktifEdildi = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: KimlikBilgiKarti(
              ortak: pasifOrtak,
              onAktifEt: () => aktifEdildi = true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Aktif Et'), findsOneWidget);
    expect(find.text('Bu üye pasif durumdadır (Neden: İstifa).'), findsOneWidget);

    await tester.tap(find.text('Aktif Et'));
    await tester.pump();
    expect(aktifEdildi, isTrue);
  });

  testWidgets('KimlikBilgiKarti aktif ortak için Aktif Et butonu ve uyarı şeridi GÖSTERMEZ', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: KimlikBilgiKarti(
              ortak: aktifOrtak,
              onAktifEt: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Aktif Et'), findsNothing);
    expect(find.textContaining('Bu üye pasif durumdadır'), findsNothing);
  });
}
