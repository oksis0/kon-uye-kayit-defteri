import 'dart:io';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/util/dosya_hash.dart';
import '../../domain/enum/kuyruk_durumu.dart';
import '../../domain/model/ice_aktarma_isi.dart';
import '../goruntu/goruntu_hazirlayici.dart';
import '../yerel/veritabani.dart';
import '../yerel/veritabani_provider.dart';

part 'kuyruk_repository.g.dart';

const Uuid _uuid = Uuid();
const Set<String> _desteklenenUzantilar = <String>{'.jpg', '.jpeg', '.png'};

/// Toplu içe aktarma kuyruğunu yönetir (PLAN.md §8).
///
/// ★ Faz 2 kapsamı: **OCR YOK.** Kuyruk, taranmış dosyaları hazırlayıp
/// (format/boyut) `onayBekliyor` durumuna getirir; kullanıcı formu elle
/// doldurup ortağa bağlar. `onayBekliyor` durumu bilinçli olarak genel
/// tutuldu — Faz 3+'ta Azure OCR devreye girdiğinde aynı durum, formu
/// önceden doldurulmuş olarak karşılamak için kullanılacak. Mimari değişmez,
/// sadece `ocrHamJson` dolu gelir.
class KuyrukRepository {
  KuyrukRepository(this._db);

  final AppVeritabani _db;
  final GoruntuHazirlayici _goruntuHazirlayici = GoruntuHazirlayici();

  Stream<List<IceAktarmaIsi>> tumunuIzle() {
    return _db.kuyrukDao
        .tumunuIzle()
        .map((List<IceAktarmaIsiSatiri> satirlar) => satirlar.map(_iseDonustur).toList());
  }

  Future<IceAktarmaIsi?> idIleGetir(String id) async {
    final IceAktarmaIsiSatiri? satir = await _db.kuyrukDao.idIleBul(id);
    return satir == null ? null : _iseDonustur(satir);
  }

  /// Klasördeki desteklenen görselleri tarar, her biri için sha256 hesaplar,
  /// zaten kuyrukta olanları (aynı hash) atlar — yinelenen tarama
  /// hatalarını önlemek için (PLAN.md §8).
  Future<KlasorTaramaSonucu> klasordenIceAktar(String klasorYolu) async {
    final Directory klasor = Directory(klasorYolu);
    if (!klasor.existsSync()) {
      throw KuyrukHatasi('Klasör bulunamadı: $klasorYolu');
    }

    final List<FileSystemEntity> girdiler = klasor.listSync()
      ..sort((FileSystemEntity a, FileSystemEntity b) => a.path.compareTo(b.path));

    int eklenen = 0;
    int atlanan = 0;

    for (final FileSystemEntity girdi in girdiler) {
      if (girdi is! File) continue;
      if (!_desteklenenUzantilar.contains(_uzanti(girdi.path))) continue;

      final String hash = await dosyaHashHesapla(girdi.path);
      final bool zatenVar = await _db.kuyrukDao.hashVarMi(hash);
      if (zatenVar) {
        atlanan++;
        continue;
      }

      final IceAktarmaIsi is_ = IceAktarmaIsi(
        id: _uuid.v4(),
        dosyaYolu: girdi.path,
        dosyaAdi: girdi.uri.pathSegments.last,
        dosyaHash: hash,
        durum: KuyrukDurumu.bekliyor,
        eklenmeTarihi: DateTime.now(),
      );
      await _db.kuyrukDao.ekle(_companionaDonustur(is_));
      eklenen++;
    }

    return KlasorTaramaSonucu(eklenen: eklenen, atlanan: atlanan);
  }

  /// Bir işin görüntüsünü hazırlar (format/boyut kontrolü). Başarılıysa
  /// `onayBekliyor`, hata olursa `hata` durumuna geçer (PLAN.md §8,
  /// "Kritik davranışlar" tablosu).
  Future<void> hazirla(String isId) async {
    final IceAktarmaIsiSatiri? satir = await _db.kuyrukDao.idIleBul(isId);
    if (satir == null) return;

    await _db.kuyrukDao.guncelle(
      IceAktarmaKuyruguCompanion(
        id: Value(isId),
        durum: const Value(KuyrukDurumu.hazirlaniyor),
      ),
    );

    try {
      await _goruntuHazirlayici.hazirla(satir.dosyaYolu);
      await _db.kuyrukDao.guncelle(
        IceAktarmaKuyruguCompanion(
          id: Value(isId),
          durum: const Value(KuyrukDurumu.onayBekliyor),
        ),
      );
    } catch (e) {
      await _db.kuyrukDao.guncelle(
        IceAktarmaKuyruguCompanion(
          id: Value(isId),
          durum: const Value(KuyrukDurumu.hata),
          hataMesaji: Value(e.toString()),
          denemeSayisi: Value(satir.denemeSayisi + 1),
        ),
      );
    }
  }

  /// Kullanıcı bu işi bir ortak kaydına bağlayıp formu kaydettiğinde
  /// çağrılır — kuyruk işi tamamlanmış sayılır.
  Future<void> tamamlandiIsaretle(String isId, String olusanOrtakId) {
    return _db.kuyrukDao.guncelle(
      IceAktarmaKuyruguCompanion(
        id: Value(isId),
        durum: const Value(KuyrukDurumu.tamamlandi),
        islendi: const Value(true),
        olusanOrtakId: Value(olusanOrtakId),
      ),
    );
  }

  Future<void> atla(String isId) {
    return _db.kuyrukDao.guncelle(
      IceAktarmaKuyruguCompanion(
        id: Value(isId),
        durum: const Value(KuyrukDurumu.atlandi),
        islendi: const Value(true),
      ),
    );
  }

  /// Hatalı bir işi tekrar kuyruğa alır (§8, "Yeniden Dene").
  Future<void> yenidenDene(String isId) {
    return _db.kuyrukDao.guncelle(
      IceAktarmaKuyruguCompanion(
        id: Value(isId),
        durum: const Value(KuyrukDurumu.bekliyor),
        hataMesaji: const Value(null),
      ),
    );
  }

  IceAktarmaIsi _iseDonustur(IceAktarmaIsiSatiri satir) => IceAktarmaIsi(
        id: satir.id,
        dosyaYolu: satir.dosyaYolu,
        dosyaAdi: satir.dosyaAdi,
        dosyaHash: satir.dosyaHash,
        durum: satir.durum,
        islendi: satir.islendi,
        hataMesaji: satir.hataMesaji,
        denemeSayisi: satir.denemeSayisi,
        olusanOrtakId: satir.olusanOrtakId,
        ocrHamJson: satir.ocrHamJson,
        eklenmeTarihi: satir.eklenmeTarihi,
      );

  IceAktarmaKuyruguCompanion _companionaDonustur(IceAktarmaIsi is_) =>
      IceAktarmaKuyruguCompanion.insert(
        id: is_.id,
        dosyaYolu: is_.dosyaYolu,
        dosyaAdi: is_.dosyaAdi,
        dosyaHash: is_.dosyaHash,
        durum: Value(is_.durum),
        eklenmeTarihi: is_.eklenmeTarihi,
      );

  String _uzanti(String yol) {
    final int nokta = yol.lastIndexOf('.');
    return nokta == -1 ? '' : yol.substring(nokta).toLowerCase();
  }
}

class KlasorTaramaSonucu {
  const KlasorTaramaSonucu({required this.eklenen, required this.atlanan});
  final int eklenen;
  final int atlanan;
}

class KuyrukHatasi implements Exception {
  KuyrukHatasi(this.mesaj);
  final String mesaj;

  @override
  String toString() => mesaj;
}

@Riverpod(keepAlive: true)
KuyrukRepository kuyrukRepository(Ref ref) {
  final AppVeritabani db = ref.watch(veritabaniProvider);
  return KuyrukRepository(db);
}
