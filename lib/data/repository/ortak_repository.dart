import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/util/turkce_normalize.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ortak.dart';
import '../yerel/veritabani.dart';
import '../yerel/veritabani_provider.dart';

part 'ortak_repository.g.dart';

const Uuid _uuid = Uuid();

/// UI'nin ortaklar üzerindeki **tek** veri kapısı — Drift'i doğrudan
/// hiçbir ekran bilmez (PLAN.md §3, katman kuralı).
///
/// ★ Firestore senkronu henüz yok (Faz 4'te eklenecek). Bu bilinçli:
/// Faz 1'de veritabanı, arama ve arayüz sağlam otururken ağ hataları işin
/// içine karışmasın (PLAN.md §15, Faz 1).
class OrtakRepository {
  OrtakRepository(this._db);

  final AppVeritabani _db;

  Stream<List<Ortak>> ara(String sorgu, {bool pasifleriDeGoster = false}) {
    final String normalize = turkceNormalize(sorgu);
    return _db.ortakDao
        .ara(normalize, pasifleriDeGoster: pasifleriDeGoster)
        .map((List<OrtakSatiri> satirlar) => satirlar.map(_ortagaDonustur).toList());
  }

  Stream<List<Ortak>> tumunuIzle({bool pasifleriDeGoster = false}) {
    return _db.ortakDao
        .tumunuIzle(pasifleriDeGoster: pasifleriDeGoster)
        .map((List<OrtakSatiri> satirlar) => satirlar.map(_ortagaDonustur).toList());
  }

  Future<Ortak?> idIleGetir(String id) async {
    final OrtakSatiri? satir = await _db.ortakDao.idIleBul(id);
    return satir == null ? null : _ortagaDonustur(satir);
  }

  Stream<Ortak?> ortakIzle(String id) {
    return _db.ortakDao.tekIzle(id).map((OrtakSatiri? satir) {
      return satir == null ? null : _ortagaDonustur(satir);
    });
  }

  /// Yinelenen Ortak No kontrolü için (PLAN.md §7.4).
  Future<Ortak?> ortakNoIleKontrolEt(String ortakNo) async {
    final OrtakSatiri? satir = await _db.ortakDao.ortakNoIleBul(ortakNo);
    return satir == null ? null : _ortagaDonustur(satir);
  }

  Stream<List<DefterSatiri>> satirlariIzle(String ortakId) {
    return _db.defterSatiriDao
        .ortaginSatirlariniIzle(ortakId)
        .map((List<DefterSatiriSatiri> satirlar) => satirlar.map(_satiraDonustur).toList());
  }

  /// Yeni ortak ekler. `aramaAnahtari` burada hesaplanır — çağıran taraf
  /// (form/ekran) Türkçe normalizasyonu bilmek zorunda değil.
  Future<Ortak> ekle(Ortak ortak) async {
    final String id = ortak.id.isEmpty ? _uuid.v4() : ortak.id;
    final DateTime simdi = DateTime.now();

    final Ortak yeniOrtak = ortak.copyWith(
      id: id,
      aramaAnahtari: _aramaAnahtariHesapla(ortak),
      olusturmaTarihi: simdi,
      guncellemeTarihi: simdi,
    );

    await _db.ortakDao.ekle(_companionaDonustur(yeniOrtak));
    return yeniOrtak;
  }

  Future<Ortak> guncelle(Ortak ortak) async {
    final Ortak guncelOrtak = ortak.copyWith(
      aramaAnahtari: _aramaAnahtariHesapla(ortak),
      guncellemeTarihi: DateTime.now(),
    );
    await _db.ortakDao.guncelle(_companionaDonustur(guncelOrtak));
    return guncelOrtak;
  }

  /// Soft delete (PLAN.md §10.1) — kalıcı silme Faz 7'de eklenecek.
  Future<void> pasifYap(String id, String neden) {
    return _db.ortakDao.pasifYap(id, neden);
  }

  Future<DefterSatiri> satirEkle(DefterSatiri satir) async {
    final String id = satir.id.isEmpty ? _uuid.v4() : satir.id;
    final DefterSatiri yeniSatir = satir.copyWith(id: id);
    await _db.defterSatiriDao.ekle(_satirCompanionaDonustur(yeniSatir));
    return yeniSatir;
  }

  Future<void> satirGuncelle(DefterSatiri satir) {
    return _db.defterSatiriDao.guncelle(_satirCompanionaDonustur(satir));
  }

  Future<void> satirSil(String id) {
    return _db.defterSatiriDao.sil(id);
  }

  String _aramaAnahtariHesapla(Ortak ortak) => aramaAnahtariUret(<String?>[
        ortak.ortakNo,
        ortak.adSoyad,
        ortak.babaAdi,
        ortak.dogumYeri,
        ortak.ikametAdresi,
        ortak.nufusKayitYeri,
      ]);

  Ortak _ortagaDonustur(OrtakSatiri satir) => Ortak(
        id: satir.id,
        ortakNo: satir.ortakNo,
        adSoyad: satir.adSoyad,
        babaAdi: satir.babaAdi,
        dogumYeri: satir.dogumYeri,
        dogumTarihiHam: satir.dogumTarihiHam,
        dogumTarihi: satir.dogumTarihi,
        girisTarihiHam: satir.girisTarihiHam,
        girisTarihi: satir.girisTarihi,
        cikisTarihiHam: satir.cikisTarihiHam,
        cikisTarihi: satir.cikisTarihi,
        ikametAdresi: satir.ikametAdresi,
        nufusKayitYeri: satir.nufusKayitYeri,
        aramaAnahtari: satir.aramaAnahtari,
        belgeR2Anahtari: satir.belgeR2Anahtari,
        ocrGuvenOrtalama: satir.ocrGuvenOrtalama,
        aktif: satir.aktif,
        pasifNedeni: satir.pasifNedeni,
        pasifTarihi: satir.pasifTarihi,
        olusturmaTarihi: satir.olusturmaTarihi,
        guncellemeTarihi: satir.guncellemeTarihi,
      );

  OrtaklarCompanion _companionaDonustur(Ortak ortak) => OrtaklarCompanion.insert(
        id: ortak.id,
        ortakNo: ortak.ortakNo,
        adSoyad: ortak.adSoyad,
        babaAdi: Value(ortak.babaAdi),
        dogumYeri: Value(ortak.dogumYeri),
        dogumTarihiHam: Value(ortak.dogumTarihiHam),
        dogumTarihi: Value(ortak.dogumTarihi),
        girisTarihiHam: Value(ortak.girisTarihiHam),
        girisTarihi: Value(ortak.girisTarihi),
        cikisTarihiHam: Value(ortak.cikisTarihiHam),
        cikisTarihi: Value(ortak.cikisTarihi),
        ikametAdresi: Value(ortak.ikametAdresi),
        nufusKayitYeri: Value(ortak.nufusKayitYeri),
        aramaAnahtari: ortak.aramaAnahtari,
        belgeR2Anahtari: Value(ortak.belgeR2Anahtari),
        ocrGuvenOrtalama: Value(ortak.ocrGuvenOrtalama),
        aktif: Value(ortak.aktif),
        pasifNedeni: Value(ortak.pasifNedeni),
        pasifTarihi: Value(ortak.pasifTarihi),
        olusturmaTarihi: ortak.olusturmaTarihi,
        guncellemeTarihi: ortak.guncellemeTarihi,
      );

  DefterSatiri _satiraDonustur(DefterSatiriSatiri satir) => DefterSatiri(
        id: satir.id,
        ortakId: satir.ortakId,
        tur: satir.tur,
        siraNo: satir.siraNo,
        tarihHam: satir.tarihHam,
        tarih: satir.tarih,
        no: satir.no,
        madde: satir.madde,
        aciklama: satir.aciklama,
        miktarKurus: satir.miktarKurus,
        yekunKurus: satir.yekunKurus,
        miktarHam: satir.miktarHam,
        yekunHam: satir.yekunHam,
      );

  DefterSatirlariCompanion _satirCompanionaDonustur(DefterSatiri satir) =>
      DefterSatirlariCompanion.insert(
        id: satir.id,
        ortakId: satir.ortakId,
        tur: satir.tur,
        siraNo: satir.siraNo,
        tarihHam: Value(satir.tarihHam),
        tarih: Value(satir.tarih),
        no: Value(satir.no),
        madde: Value(satir.madde),
        aciklama: Value(satir.aciklama),
        miktarKurus: Value(satir.miktarKurus),
        yekunKurus: Value(satir.yekunKurus),
        miktarHam: Value(satir.miktarHam),
        yekunHam: Value(satir.yekunHam),
      );
}

@Riverpod(keepAlive: true)
OrtakRepository ortakRepository(Ref ref) {
  final AppVeritabani db = ref.watch(veritabaniProvider);
  return OrtakRepository(db);
}
