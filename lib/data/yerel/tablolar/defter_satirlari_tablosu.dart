import 'package:drift/drift.dart';

import '../../../domain/enum/satir_turu.dart';
import 'ortaklar_tablosu.dart';

/// PLAN.md §4.2 — Sermaye Yüklenmeleri ve Ödemeler, tek ortak yapı + [tur].
@DataClassName('DefterSatiriSatiri')
class DefterSatirlari extends Table {
  TextColumn get id => text()();
  TextColumn get ortakId => text().references(Ortaklar, #id)();
  TextColumn get tur => textEnum<SatirTuru>()();
  IntColumn get siraNo => integer()();

  TextColumn get tarihHam => text().nullable()();
  DateTimeColumn get tarih => dateTime().nullable()();
  TextColumn get no => text().nullable()();
  TextColumn get madde => text().nullable()();
  TextColumn get aciklama => text().nullable()();

  /// ★ Kuruş cinsinden tam sayı — `double` kullanılmıyor.
  /// Bkz. `defter_satiri.dart` içindeki gerekçe (PLAN.md §4.2).
  IntColumn get miktarKurus => integer().withDefault(const Constant(0))();
  IntColumn get yekunKurus => integer().withDefault(const Constant(0))();
  TextColumn get miktarHam => text().nullable()();
  TextColumn get yekunHam => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
