import 'package:drift/drift.dart';

import '../tablolar/defter_satirlari_tablosu.dart';
import '../veritabani.dart';

part 'defter_satiri_dao.g.dart';

/// Bir ortağın Sermaye Yüklenmeleri ve Ödemeler satırları üzerindeki
/// sorgular (PLAN.md §4.2).
@DriftAccessor(tables: [DefterSatirlari])
class DefterSatiriDao extends DatabaseAccessor<AppVeritabani>
    with _$DefterSatiriDaoMixin {
  DefterSatiriDao(super.db);

  Stream<List<DefterSatiriSatiri>> ortaginSatirlariniIzle(String ortakId) {
    return (select(defterSatirlari)
          ..where((s) => s.ortakId.equals(ortakId))
          ..orderBy([(s) => OrderingTerm.asc(s.siraNo)]))
        .watch();
  }

  /// Bir ortağın tüm satırlarını doğrudan listeler (senkronizasyon ve dışa aktarım için).
  Future<List<DefterSatiriSatiri>> ortaginSatirlariniGetir(String ortakId) {
    return (select(defterSatirlari)
          ..where((s) => s.ortakId.equals(ortakId))
          ..orderBy([(s) => OrderingTerm.asc(s.siraNo)]))
        .get();
  }

  /// Yedekleme için — tüm ortakların tüm satırları (PLAN.md §11).
  Future<List<DefterSatiriSatiri>> tumunuGetir() => select(defterSatirlari).get();

  Future<int> ekle(DefterSatirlariCompanion satir) =>
      into(defterSatirlari).insert(satir);

  Future<void> upsert(DefterSatirlariCompanion satir) =>
      into(defterSatirlari).insertOnConflictUpdate(satir);

  Future<bool> guncelle(DefterSatirlariCompanion satir) =>
      update(defterSatirlari).replace(satir);

  Future<int> sil(String id) {
    return (delete(defterSatirlari)..where((s) => s.id.equals(id))).go();
  }

  /// Ortak kalıcı silinirken tüm satırları birlikte temizler
  /// (Drift `references` cascade'i yerine burada elle — PLAN.md §10.2).
  Future<int> ortaginTumSatirlariniSil(String ortakId) {
    return (delete(defterSatirlari)..where((s) => s.ortakId.equals(ortakId)))
        .go();
  }
}
