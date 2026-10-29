import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/env.dart';
import '../../core/util/turkce_normalize.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ortak.dart';
import '../goruntu/goruntu_hazirlayici.dart';
import '../uzak/firestore_servisi.dart';
import '../yerel/dao/meta_dao.dart';
import '../yerel/tablolar/ortaklar_tablosu.dart';
import '../yerel/veritabani.dart';
import '../yerel/veritabani_provider.dart';
import 'belge_repository.dart';

part 'ortak_repository.g.dart';

const Uuid _uuid = Uuid();

/// UI'nin ortaklar üzerindeki **tek** veri kapısı — Drift'i doğrudan
/// hiçbir ekran bilmez (PLAN.md §3, katman kuralı).
///
/// ★ Firestore senkronu **koşullu**: [_firestore] `null` ise (bulut
/// yapılandırılmamışsa) tüm yazma/okuma tamamen yerel — Faz 1-2 davranışı
/// birebir korunur. Dolu ise her yazma sonrası arka planda (beklenmeden)
/// Firestore'a itilir; ağ hatası olursa kayıt yerelde zaten güvende olduğu
/// için kullanıcı akışı hiç kesilmez (PLAN.md §2.5, yerel-öncelikli mimari).
///
/// ★ Bilinen basitleştirme: alan-bazlı çakışma çözümü YOK — tüm kayıt
/// `guncellemeTarihi`'ye göre "son yazan kazanır" ile değiştirilir
/// (PLAN.md §15 Faz 4 notu). 2 kişilik ekip ölçeğinde bu yeterli; başarısız
/// push'lar için otomatik yeniden deneme kuyruğu da yok (ileride eklenebilir).
class OrtakRepository {
  OrtakRepository(this._db, this._firestore, this._belgeRepo);

  final AppVeritabani _db;
  final FirestoreServisi? _firestore;
  final BelgeRepository? _belgeRepo;

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

  Future<List<Ortak>> tumOrtaklariGetir({bool pasifleriDeGoster = true}) async {
    final List<OrtakSatiri> satirlar =
        await _db.ortakDao.tumunuGetir(pasifleriDeGoster: pasifleriDeGoster);
    return satirlar.map(_ortagaDonustur).toList();
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
  Future<Ortak?> ortakNoIleKontrolEt(String ortakNo, {String? haricId}) async {
    final OrtakSatiri? satir = await _db.ortakDao.ortakNoIleBul(ortakNo, haricId: haricId);
    return satir == null ? null : _ortagaDonustur(satir);
  }

  /// Yinelenen T.C. Kimlik No kontrolü için.
  Future<Ortak?> tcKimlikNoIleKontrolEt(String tcKimlikNo, {String? haricId}) async {
    final OrtakSatiri? satir = await _db.ortakDao.tcKimlikNoIleBul(tcKimlikNo, haricId: haricId);
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
    _firestoreyeItGorunmeden(id);
    return yeniOrtak;
  }

  Future<Ortak> guncelle(Ortak ortak) async {
    final Ortak guncelOrtak = ortak.copyWith(
      aramaAnahtari: _aramaAnahtariHesapla(ortak),
      guncellemeTarihi: DateTime.now(),
    );
    await _db.ortakDao.guncelle(_companionaDonustur(guncelOrtak));
    _firestoreyeItGorunmeden(guncelOrtak.id);
    return guncelOrtak;
  }

  /// Soft delete (PLAN.md §10.1) — varsayılan silme davranışı. Veri
  /// silinmez, sadece `aktif: false` yapılır (yasal saklama ihtimaline
  /// karşı — bkz. kullanıcı için ekrandaki uyarı).
  Future<void> pasifYap(String id, String neden) async {
    await _db.ortakDao.pasifYap(id, neden);
    _firestoreyeItGorunmeden(id);
  }

  /// Pasif ortağı yeniden aktif duruma getirir.
  Future<void> aktifYap(String id) async {
    await _db.ortakDao.aktifYap(id);
    _firestoreyeItGorunmeden(id);
  }

  /// ★ Kalıcı silme — mezar taşlı, sıralı akış (PLAN.md §10.2). Sadece
  /// gerçek hatalar için (örn. aynı belge iki kez taranmış). Sıra
  /// KASITLI: önce mezar taşı, sonra R2, sonra Firestore, en son yerel —
  /// böylece yarıda kesilse bile [yarimKalanSilmeleriTamamla] devam
  /// edebilir. Her adım idempotent (R2 silme, Firestore silme, yerel
  /// silme — hepsi zaten-silinmiş durumda hata vermez), bu yüzden
  /// yeniden deneme her zaman baştan güvenle çalıştırılabilir.
  Future<void> kaliciSil(String ortakId) async {
    final Ortak? ortak = await idIleGetir(ortakId);
    if (ortak == null) return;

    final FirestoreServisi? firestore = _firestore;
    if (firestore == null) {
      // Bulut yapılandırılmamış — silinecek uzak bir şey yok.
      await _yereldenTamamenSil(ortakId);
      return;
    }

    await firestore.silmeTalebiYaz(ortakId, r2Anahtari: ortak.belgeR2Anahtari, adim: 'r2');
    await _mezarTasiIzleyerekSil(ortakId, ortak.belgeR2Anahtari, firestore);
  }

  /// Açılışta çağrılır — elektrik kesintisi/çökme yüzünden yarıda kalmış
  /// kalıcı silmeleri tamamlar (PLAN.md §10.2).
  Future<void> yarimKalanSilmeleriTamamla() async {
    final FirestoreServisi? firestore = _firestore;
    if (firestore == null) return;

    final List<SilmeTalebi> talepler = await firestore.silmeTalepleriGetir();
    for (final SilmeTalebi talep in talepler) {
      try {
        await _mezarTasiIzleyerekSil(talep.ortakId, talep.r2Anahtari, firestore);
      } catch (e, s) {
        developer.log(
          'Yarım kalan kalıcı silme tamamlanamadı: ${talep.ortakId}',
          name: 'OrtakRepository',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  Future<void> _mezarTasiIzleyerekSil(
    String ortakId,
    String? r2Anahtari,
    FirestoreServisi firestore,
  ) async {
    if (r2Anahtari != null && _belgeRepo != null) {
      await _belgeRepo.sil(r2Anahtari);
    }
    await firestore.silmeTalebiGuncelle(ortakId, adim: 'firestore');

    await firestore.ortakSil(ortakId);
    await firestore.silmeTalebiGuncelle(ortakId, adim: 'yerel');

    await _yereldenTamamenSil(ortakId);
    await firestore.silmeTalebiSil(ortakId);
  }

  Future<void> _yereldenTamamenSil(String ortakId) async {
    await _db.defterSatiriDao.ortaginTumSatirlariniSil(ortakId);
    await _db.ortakDao.kaliciSil(ortakId);
  }

  Future<DefterSatiri> satirEkle(DefterSatiri satir) async {
    final String id = satir.id.isEmpty ? _uuid.v4() : satir.id;
    final DefterSatiri yeniSatir = satir.copyWith(id: id);
    await _db.defterSatiriDao.ekle(_satirCompanionaDonustur(yeniSatir));
    _firestoreyeItGorunmeden(yeniSatir.ortakId);
    return yeniSatir;
  }

  Future<void> satirGuncelle(DefterSatiri satir) async {
    await _db.defterSatiriDao.guncelle(_satirCompanionaDonustur(satir));
    _firestoreyeItGorunmeden(satir.ortakId);
  }

  Future<void> satirSil(String id, String ortakId) async {
    await _db.defterSatiriDao.sil(id);
    _firestoreyeItGorunmeden(ortakId);
  }

  /// Ortağı (kimlik + tüm satırları) Firestore'a gömülü doküman olarak
  /// yazar — beklenmeden (fire-and-forget). Ağ hatası olursa sessizce
  /// loglanır; yerel kayıt zaten güvende olduğu için kullanıcı akışı
  /// kesilmez (PLAN.md §2.5). Bulut yapılandırılmamışsa hiçbir şey yapmaz.
  void _firestoreyeItGorunmeden(String ortakId) {
    final FirestoreServisi? firestore = _firestore;
    if (firestore == null) return;

    unawaited(() async {
      try {
        final OrtakSatiri? satir = await _db.ortakDao.idIleBul(ortakId);
        if (satir == null) return;
        final Ortak ortak = _ortagaDonustur(satir);
        final List<DefterSatiriSatiri> satirlar =
            await _db.defterSatiriDao.ortaginSatirlariniIzle(ortakId).first;
        await firestore.ortakYaz(ortak, satirlar.map(_satiraDonustur).toList());
      } catch (e, s) {
        developer.log(
          'Firestore senkron başarısız (kayıt yerelde güvende)',
          name: 'OrtakRepository',
          error: e,
          stackTrace: s,
        );
      }
    }());
  }

  /// Firestore'dan bu cihaza son senkrondan sonraki değişiklikleri çeker
  /// ve yerel Drift'e uygular (delta senkron — PLAN.md §2.5).
  ///
  /// Çakışma çözümü: gelen kayıt yerelden daha YENİYSE uygulanır ("son
  /// yazan kazanır", `guncellemeTarihi` karşılaştırmalı). Satırlar için
  /// tam-liste-değiştirme stratejisi kullanılır (PLAN.md §15 Faz 4 notu).
  Future<int> firestoretenSenkronizeEt() async {
    final FirestoreServisi? firestore = _firestore;
    if (firestore == null) return 0;

    final String? sonSenkronMetin = await _db.metaDao.degerAl(anahtarSonSenkron);
    final DateTime sonSenkron = sonSenkronMetin != null
        ? DateTime.parse(sonSenkronMetin)
        : DateTime.fromMillisecondsSinceEpoch(0);

    final List<(Ortak, List<DefterSatiri>)> degisenler =
        await firestore.degisiklikleriGetir(sonSenkron);

    int uygulanan = 0;
    DateTime enYeniGuncelleme = sonSenkron;

    for (final (Ortak uzakOrtak, List<DefterSatiri> uzakSatirlar) in degisenler) {
      if (uzakOrtak.guncellemeTarihi.isAfter(enYeniGuncelleme)) {
        enYeniGuncelleme = uzakOrtak.guncellemeTarihi;
      }

      final OrtakSatiri? yerelSatir = await _db.ortakDao.idIleBul(uzakOrtak.id);
      final bool yereldenYeni =
          yerelSatir == null || uzakOrtak.guncellemeTarihi.isAfter(yerelSatir.guncellemeTarihi);
      if (!yereldenYeni) continue;

      await _db.ortakDao.upsert(_companionaDonustur(uzakOrtak));
      await _db.defterSatiriDao.ortaginTumSatirlariniSil(uzakOrtak.id);
      for (final DefterSatiri satir in uzakSatirlar) {
        await _db.defterSatiriDao.ekle(_satirCompanionaDonustur(satir));
      }
      uygulanan++;
    }

    await _db.metaDao.degerYaz(anahtarSonSenkron, enYeniGuncelleme.toIso8601String());
    return uygulanan;
  }

  /// Yereldeki TÜM ortakları ve satırlarını Firestore'a senkronize eder.
  /// Özellikle uygulama ilk kez buluta bağlandığında veya telefondan erişim için
  /// yereldeki tüm üyelerin eksiksiz bulutta bulunmasını garanti eder.
  Future<int> tumunuFirestoreyeIt() async {
    final FirestoreServisi? firestore = _firestore;
    if (firestore == null) return 0;

    final List<OrtakSatiri> satirlar = await _db.ortakDao.tumunuGetir();
    int basarili = 0;

    for (final OrtakSatiri satir in satirlar) {
      try {
        final Ortak ortak = _ortagaDonustur(satir);
        final List<DefterSatiriSatiri> defterSatirlari =
            await _db.defterSatiriDao.ortaginSatirlariniIzle(ortak.id).first;
        await firestore.ortakYaz(ortak, defterSatirlari.map(_satiraDonustur).toList());
        await _db.ortakDao.senkronDurumuGuncelle(satir.id, SenkronDurumu.senkron);
        basarili++;
      } catch (e, s) {
        developer.log(
          'Toplu Firestore itme hatası (${satir.adSoyad}): $e',
          name: 'OrtakRepository',
          error: e,
          stackTrace: s,
        );
      }
    }
    return basarili;
  }

  /// Yerelde görseli/dosyası olan ancak henüz R2 bulutuna yüklenmemiş
  /// (belgeR2Anahtari boş olan) tüm belgeleri Cloudflare R2'ye yükler
  /// ve ortağın kaydını hem yerelde hem Firestore'da günceller.
  /// Bu sayede telefondan veya başka bir cihazdan tüm taranmış belgelere anında erişilebilir.
  Future<int> eksikBelgeleriR2yeYukle() async {
    if (!Env.bulutYapilandirmasiTamam) return 0;
    final BelgeRepository? belgeRepo = _belgeRepo;
    if (belgeRepo == null) return 0;

    final List<OrtakSatiri> satirlar = await _db.ortakDao.tumunuGetir();
    int basarili = 0;

    for (final OrtakSatiri satir in satirlar) {
      if (satir.belgeR2Anahtari != null && satir.belgeR2Anahtari!.isNotEmpty) {
        continue;
      }

      String? dosyaYolu = satir.yerelDosyaYolu;
      if (dosyaYolu == null || dosyaYolu.isEmpty) {
        dosyaYolu = (await _db.kuyrukDao.ortakIdIleBul(satir.id))?.dosyaYolu;
      }

      if (dosyaYolu == null || dosyaYolu.isEmpty) continue;
      final File dosya = File(dosyaYolu);
      if (!await dosya.exists()) continue;

      try {
        final HazirlanmisGorsel hazir = await GoruntuHazirlayici().hazirla(dosyaYolu);
        final String anahtar = belgeRepo.anahtarUret(satir.id);
        await belgeRepo.yukle(anahtar, hazir.veriler);

        final Ortak guncel = _ortagaDonustur(satir).copyWith(
          belgeR2Anahtari: anahtar,
          yerelDosyaYolu: dosyaYolu,
          guncellemeTarihi: DateTime.now(),
        );

        await _db.ortakDao.guncelle(_companionaDonustur(guncel));
        _firestoreyeItGorunmeden(guncel.id);
        basarili++;
      } catch (e, s) {
        developer.log(
          'Eksik belge R2 yükleme hatası (${satir.adSoyad}): $e',
          name: 'OrtakRepository',
          error: e,
          stackTrace: s,
        );
      }
    }

    return basarili;
  }

  String _aramaAnahtariHesapla(Ortak ortak) => aramaAnahtariUret(<String?>[
        ortak.ortakNo,
        ortak.sayfaNo,
        ortak.tcKimlikNo,
        ortak.adSoyad,
        ortak.babaAdi,
        ortak.dogumYeri,
        ortak.ikametAdresi,
        ortak.nufusKayitYeri,
      ]);

  Ortak _ortagaDonustur(OrtakSatiri satir) => Ortak(
        id: satir.id,
        ortakNo: satir.ortakNo,
        sayfaNo: satir.sayfaNo,
        tcKimlikNo: satir.tcKimlikNo,
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
        yerelDosyaYolu: satir.yerelDosyaYolu,
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
        sayfaNo: Value(ortak.sayfaNo),
        tcKimlikNo: Value(ortak.tcKimlikNo),
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
        yerelDosyaYolu: Value(ortak.yerelDosyaYolu),
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
  // ★ FirestoreServisi sadece bulut yapılandırılmışsa okunuyor — aksi halde
  // `FirebaseFirestore.instance` Firebase hiç başlatılmadan çağrılıp hata
  // fırlatırdı (PLAN.md §12.5).
  final FirestoreServisi? firestore =
      Env.bulutYapilandirmasiTamam ? ref.watch(firestoreServisiProvider) : null;
  final BelgeRepository? belgeRepo =
      Env.bulutYapilandirmasiTamam ? ref.watch(belgeRepositoryProvider) : null;
  return OrtakRepository(db, firestore, belgeRepo);
}

/// Uygulama açılışında BİR KEZ çalışır (app.dart'ta `ref.watch` edilir,
/// `keepAlive` sayesinde tekrar tetiklenmez). Bulut yapılandırılmamışsa
/// hiçbir şey yapmaz.
@Riverpod(keepAlive: true)
Future<void> baslangicSenkronu(Ref ref) async {
  if (!Env.bulutYapilandirmasiTamam) return;
  if (FirebaseAuth.instance.currentUser == null) return;
  final OrtakRepository repo = ref.watch(ortakRepositoryProvider);
  try {
    // ★ Önce yarım kalan kalıcı silmeleri tamamla (PLAN.md §10.2)
    await repo.yarimKalanSilmeleriTamamla();
    // ★ Yereldeki tüm kayıtları Firestore'a ve eksik belgeleri R2'ye yükle (telefonda da görünsün)
    await repo.tumunuFirestoreyeIt();
    await repo.eksikBelgeleriR2yeYukle();
    // ★ Son olarak Firestore'dan yeni güncellemeleri çek
    await repo.firestoretenSenkronizeEt();
  } catch (e) {
    developer.log('Başlangıç senkronu atlandı / hata: $e', name: 'Senkron');
  }
}
