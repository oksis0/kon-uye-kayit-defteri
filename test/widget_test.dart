import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ortak_defteri/app/app.dart';

void main() {
  testWidgets('Uygulama açılışta Arama ekranını gösterir', (WidgetTester tester) async {
    await initializeDateFormatting('tr_TR');

    await tester.pumpWidget(const ProviderScope(child: OrtakDefteriUygulamasi()));
    // ★ pumpAndSettle KULLANILMIYOR — arama sonuçları akışı (Drift .watch())
    // hiç tamamlanmayan bir Stream olduğu için "yükleniyor" animasyonu sürekli
    // yeni kare talep eder ve pumpAndSettle asla durmaz. Sabit sayıda pump
    // yeterli; test zaten yalnızca statik AppBar öğelerini doğruluyor.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ortak Pay Defteri'), findsOneWidget);
    expect(find.text('Yeni Ortak'), findsOneWidget);
  });
}
