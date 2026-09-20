import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/app/theme/app_theme.dart';
import 'package:ortak_defteri/domain/model/ortak.dart';
import 'package:ortak_defteri/features/arama/widget/ortak_kart.dart';

void main() {
  testWidgets('Pasif ortak kartında kehribar kenarlık ve Pasif rozeti görüntülenir',
      (WidgetTester tester) async {
    final Ortak pasifOrtak = Ortak(
      id: 'pasif-1',
      ortakNo: '101',
      adSoyad: 'Ahmet Pasif',
      aramaAnahtari: 'ahmet pasif',
      aktif: false,
      pasifNedeni: 'Vefat',
      olusturmaTarihi: DateTime.now(),
      guncellemeTarihi: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: OrtakKart(
            ortak: pasifOrtak,
            secili: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Ahmet Pasif'), findsOneWidget);
    expect(find.text('Pasif'), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
  });

  testWidgets('Aktif ortak kartında Pasif rozeti görünmez',
      (WidgetTester tester) async {
    final Ortak aktifOrtak = Ortak(
      id: 'aktif-1',
      ortakNo: '102',
      adSoyad: 'Mehmet Aktif',
      aramaAnahtari: 'mehmet aktif',
      aktif: true,
      olusturmaTarihi: DateTime.now(),
      guncellemeTarihi: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: OrtakKart(
            ortak: aktifOrtak,
            secili: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Mehmet Aktif'), findsOneWidget);
    expect(find.text('Pasif'), findsNothing);
  });
}
