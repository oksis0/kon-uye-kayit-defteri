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
    // Kullanıcı bir isim/numara/TC arıyorsa pasif de olsa sonucu görsün,
    // genel listede gezinirken pasifler filtreye bağlı kalsın.
    if (!pasifleriDeGoster && normalizeSorgu.isEmpty) {
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

  Future<List<OrtakSatiri>> tumunuGetir({bool pasifleriDeGoster = true}) {
    final sorgu = select(ortaklar);
    if (!pasifleriDeGoster) {
      sorgu.where((o) => o.aktif.equals(true));
    }
    return sorgu.get();
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
  Future<OrtakSatiri?> ortakNoIleBul(String ortakNo, {String? haricId}) {
    final query = select(ortaklar)..where((o) => o.ortakNo.equals(ortakNo));
    if (haricId != null) {
      query.where((o) => o.id.equals(haricId).not());
    }
    return query.getSingleOrNull();
  }

  /// Yinelenen T.C. Kimlik No kontrolü için.
  Future<OrtakSatiri?> tcKimlikNoIleBul(String tcKimlikNo, {String? haricId}) {
    final query = select(ortaklar)..where((o) => o.tcKimlikNo.equals(tcKimlikNo));
    if (haricId != null) {
      query.where((o) => o.id.equals(haricId).not());
    }
    return query.getSingleOrNull();
  }

  /// Belge dosya yolu ile kayıtlı ortak var mı kontrol eder.
  Future<OrtakSatiri?> dosyaYoluIleBul(String dosyaYolu) {
    return (select(ortaklar)..where((o) => o.yerelDosyaYolu.equals(dosyaYolu)))
        .getSingleOrNull();
  }

  /// Bir dosyanın (tam yol veya dosya adı ile) zaten bir ortağa kayıtlı olup olmadığını denetler.
  Future<bool> dosyaKayitliMi(String dosyaYolu) async {
    final OrtakSatiri? tamEslesme = await dosyaYoluIleBul(dosyaYolu);
    if (tamEslesme != null) return true;

    final String dosyaAdi = Uri.file(dosyaYolu).pathSegments.last;
    if (dosyaAdi.isEmpty) return false;
    final List<OrtakSatiri> adaylar = await (select(ortaklar)
          ..where((o) => o.yerelDosyaYolu.like('%$dosyaAdi')))
        .get();
    return adaylar.isNotEmpty;
  }

  Future<int> ekle(OrtaklarCompanion satir) => into(ortaklar).insert(satir);

  /// Firestore'dan pull edilen kayıtlar için — yerelde zaten varsa
  /// üzerine yazar, yoksa ekler (PLAN.md §2.5, delta senkron).
  Future<void> upsert(OrtaklarCompanion satir) =>
      into(ortaklar).insertOnConflictUpdate(satir);

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

  /// Pasif ortağı yeniden aktif yapar.
  Future<void> aktifYap(String id) {
    return (update(ortaklar)..where((o) => o.id.equals(id))).write(
      OrtaklarCompanion(
        aktif: const Value(true),
        pasifNedeni: const Value(null),
        pasifTarihi: const Value(null),
        guncellemeTarihi: Value(DateTime.now()),
      ),
    );
  }

  Future<void> senkronDurumuGuncelle(String id, SenkronDurumu durum) {
    return (update(ortaklar)..where((o) => o.id.equals(id))).write(
      OrtaklarCompanion(
        senkronDurumu: Value(durum),
      ),
    );
  }

  /// Kalıcı silme — sadece §10.2'deki çift onaylı akışta kullanılır.
  Future<int> kaliciSil(String id) {
    return (delete(ortaklar)..where((o) => o.id.equals(id))).go();
  }
}
