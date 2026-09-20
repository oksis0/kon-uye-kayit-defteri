import 'package:drift/drift.dart';

import '../../../domain/enum/kuyruk_durumu.dart';
import '../tablolar/ice_aktarma_kuyrugu_tablosu.dart';
import '../veritabani.dart';

part 'kuyruk_dao.g.dart';

@DriftAccessor(tables: [IceAktarmaKuyrugu])
class KuyrukDao extends DatabaseAccessor<AppVeritabani> with _$KuyrukDaoMixin {
  KuyrukDao(super.db);

  /// Kuyruk ekranı için tam liste, ekleme sırasına göre.
  Stream<List<IceAktarmaIsiSatiri>> tumunuIzle() {
    return (select(iceAktarmaKuyrugu)
          ..orderBy([(t) => OrderingTerm.asc(t.eklenmeTarihi)]))
        .watch();
  }

  /// [durumlar] içindeki durumlardan herhangi birinde olan, en eski işi
  /// getirir. "Sıradaki işi seç" mantığı (öncelik sırası) repository
  /// katmanında (PLAN.md §8) — DAO sadece ham sorgu sağlar.
  Future<IceAktarmaIsiSatiri?> durumaGoreEnEskiIsi(List<KuyrukDurumu> durumlar) {
    return (select(iceAktarmaKuyrugu)
          ..where((t) => t.durum.isInValues(durumlar))
          ..orderBy([(t) => OrderingTerm.asc(t.eklenmeTarihi)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<IceAktarmaIsiSatiri?> idIleBul(String id) {
    return (select(iceAktarmaKuyrugu)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<IceAktarmaIsiSatiri?> ortakIdIleBul(String ortakId) {
    return (select(iceAktarmaKuyrugu)
          ..where((t) => t.olusanOrtakId.equals(ortakId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<bool> hashVarMi(String hash) async {
    final IceAktarmaIsiSatiri? bulunan = await (select(iceAktarmaKuyrugu)
          ..where((t) => t.dosyaHash.equals(hash)))
        .getSingleOrNull();
    return bulunan != null;
  }

  Future<int> ekle(IceAktarmaKuyruguCompanion is_) => into(iceAktarmaKuyrugu).insert(is_);

  Future<bool> guncelle(IceAktarmaKuyruguCompanion is_) async {
    final int etkilenen = await (update(iceAktarmaKuyrugu)
          ..where((t) => t.id.equals(is_.id.value)))
        .write(is_);
    return etkilenen > 0;
  }

  /// Bu ay kalan Azure kotasını (500 sayfa) planlamak için — kuyrukta
  /// henüz OCR yapılmamış kaç iş kaldığını sayar.
  Future<int> bekleyenSayisi() async {
    final int? sayi = await (selectOnly(iceAktarmaKuyrugu)
          ..addColumns([iceAktarmaKuyrugu.id.count()])
          ..where(iceAktarmaKuyrugu.islendi.equals(false)))
        .map((row) => row.read(iceAktarmaKuyrugu.id.count()))
        .getSingleOrNull();
    return sayi ?? 0;
  }

  /// Kuyruktaki tüm kayıtları temizler.
  Future<int> tumunuSil() => delete(iceAktarmaKuyrugu).go();
}
