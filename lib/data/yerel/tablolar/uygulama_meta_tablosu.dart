import 'package:drift/drift.dart';

/// Uygulama genelinde tek değerli ayarlar için basit anahtar-değer deposu
/// (PLAN.md §3) — örn. son Firestore senkron zamanı, son yedek tarihi.
///
/// ★ Üretilen satır sınıfı `UygulamaMetaSatiri` — tablo adıyla aynı isimde
/// olmasın diye (Türkçe çoğul eki olmadığı için Drift'in otomatik isim
/// türetmesi burada devreye girmiyor, bkz. `ortaklar_tablosu.dart`daki not).
@DataClassName('UygulamaMetaSatiri')
class UygulamaMeta extends Table {
  TextColumn get anahtar => text()();
  TextColumn get deger => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{anahtar};
}
