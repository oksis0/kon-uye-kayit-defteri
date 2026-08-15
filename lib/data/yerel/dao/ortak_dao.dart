import 'package:drift/drift.dart';

import '../tablolar/ortaklar_tablosu.dart';
import '../veritabani.dart';

part 'ortak_dao.g.dart';

/// Ortaklar tablosu üzerindeki tüm sorgular tek yerde.
/// ★ Türkçe kısmi arama burada — `aramaAnahtari` normalize edilmiş metin
/// üzerinde `LIKE` ile çalışır (PLAN.md §5).
@DriftAccessor(tables: [Ortaklar])
class OrtakDao extends DatabaseAccessor<AppVeritabani> with _$OrtakDaoMixin {
  OrtakDao(super.db);

  /// [normalizeSorgu] çağıran tarafça zaten `turkceNormalize` ile
  /// işlenmiş olmalı — DAO bunu bilmez, sadece string eşleştirir.
  Stream<List<OrtakSatiri>> ara(
    String normalizeSorgu, {
    bool pasifleriDeGoster = false,
  }) {
    final sorgu = select(ortaklar)
      ..where((o) => o.aramaAnahtari.like('%$normalizeSorgu%'));
    if (!pasifleriDeGoster) {
      sorgu.where((o) => o.aktif.equals(true));
    }
    sorgu.orderBy([(o) => OrderingTerm.asc(o.adSoyad)]);
    return sorgu.watch();
  }

  Stream<List<OrtakSatiri>> tumunuIzle({bool pasifleriDeGoster = false}) {
    final sorgu = select(ortaklar);
    if (!pasifleriDeGoster) {
      sorgu.where((o) => o.aktif.equals(true));
    }
    sorgu.orderBy([(o) => OrderingTerm.asc(o.adSoyad)]);
    return sorgu.watch();
  }

  Future<OrtakSatiri?> idIleBul(String id) {
    return (select(ortaklar)..where((o) => o.id.equals(id))).getSingleOrNull();
  }

  /// Detay ekranı için reaktif tekil izleme — satır düzenlemeleri sonrası
  /// ekran elle yenilenmeden güncellenir.
  Stream<OrtakSatiri?> tekIzle(String id) {
    return (select(ortaklar)..where((o) => o.id.equals(id))).watchSingleOrNull();
  }

  /// Yinelenen Ortak No kontrolü için (PLAN.md §7.4).
  Future<OrtakSatiri?> ortakNoIleBul(String ortakNo) {
    return (select(ortaklar)..where((o) => o.ortakNo.equals(ortakNo)))
        .getSingleOrNull();
  }

  Future<int> ekle(OrtaklarCompanion satir) => into(ortaklar).insert(satir);

  Future<bool> guncelle(OrtaklarCompanion satir) =>
      update(ortaklar).replace(satir);

  /// Soft delete — veri silinmez, `aktif: false` yapılır (PLAN.md §10.1).
  Future<void> pasifYap(String id, String neden) {
    return (update(ortaklar)..where((o) => o.id.equals(id))).write(
      OrtaklarCompanion(
        aktif: const Value(false),
        pasifNedeni: Value(neden),
        pasifTarihi: Value(DateTime.now()),
        guncellemeTarihi: Value(DateTime.now()),
      ),
    );
  }

  /// Kalıcı silme — sadece §10.2'deki çift onaylı akışta kullanılır.
  Future<int> kaliciSil(String id) {
    return (delete(ortaklar)..where((o) => o.id.equals(id))).go();
  }
}
