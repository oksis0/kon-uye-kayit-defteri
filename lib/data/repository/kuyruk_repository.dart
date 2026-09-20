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
import 'ocr_repository.dart';

part 'kuyruk_repository.g.dart';

const Uuid _uuid = Uuid();
const Set<String> _desteklenenUzantilar = <String>{'.jpg', '.jpeg', '.png'};

/// Toplu içe aktarma kuyruğunu yönetir (PLAN.md §8).
///
/// ★ OCR **koşullu**: bulut yapılandırılmışsa (`ocrRepo` verilmişse) görüntü
/// hazırlama sonrası Azure OCR başlatılır; yapılandırılmamışsa (Faz 1-2'deki
/// gibi, env.json boşsa) doğrudan `onayBekliyor`'a geçilir ve kullanıcı
/// formu tamamen elle doldurur. `onayBekliyor` durumu her iki yolda da
/// aynı — İnceleme ekranı `ocrHamJson` doluysa ön-doldurur, boşsa boş form
/// gösterir. "İnsan yazar, OCR ön-doldurur" (PLAN.md §7.2).
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

      final bool eklendiMi = await dosyaEkle(girdi.path);
      if (eklendiMi) {
        eklenen++;
      } else {
        atlanan++;
      }
    }

    return KlasorTaramaSonucu(eklenen: eklenen, atlanan: atlanan);
  }

  /// Tek bir dosyayı kuyruğa ekler — mobilde kamera/galeriden gelen tek
  /// fotoğraf için (PLAN.md §6.2). Masaüstündeki [klasordenIceAktar] da
  /// aynı hash-kontrolü için bunu kullanır. Zaten kuyrukta olan bir dosya
  /// (aynı hash) sessizce atlanır, `false` döner.
  Future<bool> dosyaEkle(String dosyaYolu) async {
    final String hash = await dosyaHashHesapla(dosyaYolu);
    final bool zatenVar = await _db.kuyrukDao.hashVarMi(hash);
    if (zatenVar) return false;

    final IceAktarmaIsi is_ = IceAktarmaIsi(
      id: _uuid.v4(),
      dosyaYolu: dosyaYolu,
      dosyaAdi: Uri.file(dosyaYolu).pathSegments.last,
      dosyaHash: hash,
      durum: KuyrukDurumu.bekliyor,
      eklenmeTarihi: DateTime.now(),
    );
    await _db.kuyrukDao.ekle(_companionaDonustur(is_));
    return true;
  }

  /// Bir işin görüntüsünü hazırlar (format/boyut kontrolü), ardından
  /// [ocrRepo] verilmişse Azure OCR'ı BAŞLATIR (beklemez — durum
  /// `ocrYapiliyor`'a geçer, sonucu [ocrDurumunuKontrolEt] alır).
  /// [ocrRepo] `null` ise (bulut yapılandırılmamışsa) doğrudan
  /// `onayBekliyor`'a geçer — Faz 2'deki elle akış (PLAN.md §8).
  Future<void> hazirla(String isId, {OcrRepository? ocrRepo}) async {
    final IceAktarmaIsiSatiri? satir = await _db.kuyrukDao.idIleBul(isId);
    if (satir == null) return;

    await _db.kuyrukDao.guncelle(
      IceAktarmaKuyruguCompanion(
        id: Value(isId),
        durum: const Value(KuyrukDurumu.hazirlaniyor),
      ),
    );

    try {
      final HazirlanmisGorsel hazir = await _goruntuHazirlayici.hazirla(satir.dosyaYolu);

      if (ocrRepo == null) {
        await _db.kuyrukDao.guncelle(
          IceAktarmaKuyruguCompanion(
            id: Value(isId),
            durum: const Value(KuyrukDurumu.onayBekliyor),
          ),
        );
        return;
      }

      final String operationId = await ocrRepo.baslat(hazir.veriler);
      await _db.kuyrukDao.guncelle(
        IceAktarmaKuyruguCompanion(
          id: Value(isId),
          durum: const Value(KuyrukDurumu.ocrYapiliyor),
          azureOperationId: Value(operationId),
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

  /// `ocrYapiliyor` durumundaki bir işin Azure sonucunu tek seferlik
  /// sorgular (bekleme döngüsü çağıran tarafta — PLAN.md §2.3). "Bekliyor"
  /// yanıtında durum değişmez, bir sonraki pollde tekrar denenir.
  Future<OcrIslemSonucu?> ocrDurumunuKontrolEt(String isId, OcrRepository ocrRepo) async {
    final IceAktarmaIsiSatiri? satir = await _db.kuyrukDao.idIleBul(isId);
    if (satir == null || satir.azureOperationId == null) return null;

    final OcrIslemSonucu sonuc = await ocrRepo.durumSorgula(satir.azureOperationId!);

    switch (sonuc) {
      case OcrIslemSonucuBekliyor():
        return sonuc;
      case OcrIslemSonucuHizSiniri():
        return sonuc;
      case OcrIslemSonucuBitti(:final String hamJson):
        await _db.kuyrukDao.guncelle(
          IceAktarmaKuyruguCompanion(
            id: Value(isId),
            durum: const Value(KuyrukDurumu.onayBekliyor),
            ocrHamJson: Value(hamJson),
          ),
        );
        return sonuc;
      case OcrIslemSonucuHata(:final String mesaj):
        await _db.kuyrukDao.guncelle(
          IceAktarmaKuyruguCompanion(
            id: Value(isId),
            durum: const Value(KuyrukDurumu.hata),
            hataMesaji: Value(mesaj),
            denemeSayisi: Value(satir.denemeSayisi + 1),
          ),
        );
        return sonuc;
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

  /// Kuyruktaki tüm kayıtları temizler.
  Future<void> kuyruguTemizle() async {
    await _db.kuyrukDao.tumunuSil();
  }

  /// Bir ortağın içe aktarıldığı orijinal dosyanın yerel yolunu döner (varsa).
  Future<String?> ortaginDosyaYolunuBul(String ortakId) async {
    final IceAktarmaIsiSatiri? satir = await _db.kuyrukDao.ortakIdIleBul(ortakId);
    return satir?.dosyaYolu;
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
        azureOperationId: satir.azureOperationId,
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
