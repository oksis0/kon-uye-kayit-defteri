import 'package:drift/drift.dart';

import '../../../domain/enum/kuyruk_durumu.dart';

/// PLAN.md §4.3, §8 — toplu içe aktarma kuyruğu. Sadece yerel, Firestore'a
/// hiç gönderilmez.
@DataClassName('IceAktarmaIsiSatiri')
class IceAktarmaKuyrugu extends Table {
  TextColumn get id => text()();
  TextColumn get dosyaYolu => text()();
  TextColumn get dosyaAdi => text()();

  /// ★ Aynı dosyanın iki kez kuyruğa girmesini önler (PLAN.md §8).
  TextColumn get dosyaHash => text().unique()();

  TextColumn get durum => textEnum<KuyrukDurumu>()
      .withDefault(Constant(KuyrukDurumu.bekliyor.name))();

  /// İstenen `processed` alanı — dosya taşıma/silme değil, bu alanla takip.
  BoolColumn get islendi => boolean().withDefault(const Constant(false))();

  TextColumn get hataMesaji => text().nullable()();
  IntColumn get denemeSayisi => integer().withDefault(const Constant(0))();
  TextColumn get olusanOrtakId => text().nullable()();
  TextColumn get ocrHamJson => text().nullable()();
  DateTimeColumn get eklenmeTarihi => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
