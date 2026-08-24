import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enum/satir_turu.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ortak.dart';

part 'firestore_servisi.g.dart';

const Uuid _uuid = Uuid();

/// Ortak kayıtlarının Firestore ile senkronu (PLAN.md §2.5, §4.4).
///
/// ★ Satırlar alt koleksiyon DEĞİL, `ortaklar/{id}` belgesine gömülü bir
/// dizi — 2.000 ortak × ~20 satır alt koleksiyon olsaydı 42.000 okuma
/// olurdu (günlük 50.000 limitine çok yakın); gömülü dizide 2.000 okuma,
/// 20× tasarruf (PLAN.md §4.4).
///
/// ★ Firestore burada ARAMA MOTORU DEĞİL — sadece senkron/yedek deposu.
/// Tüm aramalar yerel Drift üzerinde SQL ile (PLAN.md §2.5).
class FirestoreServisi {
  FirestoreServisi(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _ortaklarKoleksiyonu =>
      _db.collection('ortaklar');

  CollectionReference<Map<String, dynamic>> get _silmeTalepleriKoleksiyonu =>
      _db.collection('silmeTalepleri');

  Future<void> ortakYaz(Ortak ortak, List<DefterSatiri> satirlar) {
    return _ortaklarKoleksiyonu.doc(ortak.id).set(_ortagiDocaCevir(ortak, satirlar));
  }

  Future<void> ortakSil(String ortakId) => _ortaklarKoleksiyonu.doc(ortakId).delete();

  // ---------------------------------------------------------------------
  // Azure OCR kota sayacı (PLAN.md §9) — `sistem/kota_{yyyy-MM}`.
  // ★ Bu, uygulamanın kendi TAHMİNİ sayacı. Gerçek kaynak Azure paneli;
  // senkronizasyon kayması ihtimaline karşı ayda bir orada doğrulanmalı.
  // ---------------------------------------------------------------------

  Future<int> kotaOku(String ay) async {
    final DocumentSnapshot<Map<String, dynamic>> anlik =
        await _db.collection('sistem').doc('kota_$ay').get();
    return (anlik.data()?['ocrSayfaSayisi'] as num?)?.toInt() ?? 0;
  }

  /// Atomik artırma — `FieldValue.increment` sayesinde iki OCR isteği aynı
  /// anda gelse bile sayaç kaybolmaz (transaction'a gerek yok).
  Future<void> kotaArtir(String ay) {
    return _db.collection('sistem').doc('kota_$ay').set(
      <String, dynamic>{
        'ocrSayfaSayisi': FieldValue.increment(1),
        'sonGuncelleme': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ---------------------------------------------------------------------
  // Kalıcı silme — mezar taşı (PLAN.md §10.2). Adım adım silme sırasında
  // elektrik kesilirse, açılışta [silmeTalepleriGetir] ile yarım kalan
  // işlemler bulunup tamamlanabilir.
  // ---------------------------------------------------------------------

  Future<void> silmeTalebiYaz(String ortakId, {String? r2Anahtari, required String adim}) {
    return _silmeTalepleriKoleksiyonu.doc(ortakId).set(<String, dynamic>{
      'ortakId': ortakId,
      'r2Anahtari': r2Anahtari,
      'adim': adim,
      'olusturmaTarihi': FieldValue.serverTimestamp(),
    });
  }

  Future<void> silmeTalebiGuncelle(String ortakId, {required String adim}) {
    return _silmeTalepleriKoleksiyonu.doc(ortakId).update(<String, dynamic>{'adim': adim});
  }

  Future<void> silmeTalebiSil(String ortakId) => _silmeTalepleriKoleksiyonu.doc(ortakId).delete();

  /// Açılışta çağrılır — yarım kalan kalıcı silmeleri bulur (PLAN.md §10.2).
  Future<List<SilmeTalebi>> silmeTalepleriGetir() async {
    final QuerySnapshot<Map<String, dynamic>> anlik = await _silmeTalepleriKoleksiyonu.get();
    return anlik.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> veri = doc.data();
      return SilmeTalebi(
        ortakId: veri['ortakId'] as String? ?? doc.id,
        r2Anahtari: veri['r2Anahtari'] as String?,
        adim: veri['adim'] as String? ?? 'r2',
      );
    }).toList();
  }

  /// [sonSenkron]'dan sonra güncellenen kayıtları çeker (delta senkron —
  /// PLAN.md §2.5). İlk senkronda [sonSenkron] çok eski bir tarih verilerek
  /// tüm kayıtlar çekilir.
  Future<List<(Ortak, List<DefterSatiri>)>> degisiklikleriGetir(DateTime sonSenkron) async {
    final QuerySnapshot<Map<String, dynamic>> anlik = await _ortaklarKoleksiyonu
        .where('guncellemeTarihi', isGreaterThan: Timestamp.fromDate(sonSenkron))
        .get();

    return anlik.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      return _docuOrtagaCevir(doc.id, doc.data());
    }).toList();
  }

  Map<String, dynamic> _ortagiDocaCevir(Ortak ortak, List<DefterSatiri> satirlar) {
    Timestamp? zaman(DateTime? t) => t == null ? null : Timestamp.fromDate(t);

    return <String, dynamic>{
      'ortakNo': ortak.ortakNo,
      'adSoyad': ortak.adSoyad,
      'babaAdi': ortak.babaAdi,
      'dogumYeri': ortak.dogumYeri,
      'dogumTarihiHam': ortak.dogumTarihiHam,
      'dogumTarihi': zaman(ortak.dogumTarihi),
      'girisTarihiHam': ortak.girisTarihiHam,
      'girisTarihi': zaman(ortak.girisTarihi),
      'cikisTarihiHam': ortak.cikisTarihiHam,
      'cikisTarihi': zaman(ortak.cikisTarihi),
      'ikametAdresi': ortak.ikametAdresi,
      'nufusKayitYeri': ortak.nufusKayitYeri,
      'aramaAnahtari': ortak.aramaAnahtari,
      'belgeR2Anahtari': ortak.belgeR2Anahtari,
      'ocrGuvenOrtalama': ortak.ocrGuvenOrtalama,
      'aktif': ortak.aktif,
      'pasifNedeni': ortak.pasifNedeni,
      'pasifTarihi': zaman(ortak.pasifTarihi),
      'olusturmaTarihi': Timestamp.fromDate(ortak.olusturmaTarihi),
      'guncellemeTarihi': Timestamp.fromDate(ortak.guncellemeTarihi),
      'satirlar': satirlar.map(_satiriMapaCevir).toList(),
    };
  }

  Map<String, dynamic> _satiriMapaCevir(DefterSatiri satir) {
    return <String, dynamic>{
      // ★ Satır id'si de yazılıyor — pull sırasında aynı satırı tanıyıp
      // güncelleyebilelim diye (yoksa her pull'da satırlar çoğalırdı).
      'id': satir.id,
      'tur': satir.tur.name,
      'siraNo': satir.siraNo,
      'tarihHam': satir.tarihHam,
      'tarih': satir.tarih == null ? null : Timestamp.fromDate(satir.tarih!),
      'no': satir.no,
      'madde': satir.madde,
      'aciklama': satir.aciklama,
      'miktarKurus': satir.miktarKurus,
      'yekunKurus': satir.yekunKurus,
      'miktarHam': satir.miktarHam,
      'yekunHam': satir.yekunHam,
    };
  }

  (Ortak, List<DefterSatiri>) _docuOrtagaCevir(String id, Map<String, dynamic> veri) {
    DateTime? zamanCoz(Object? deger) => deger is Timestamp ? deger.toDate() : null;

    final Ortak ortak = Ortak(
      id: id,
      ortakNo: veri['ortakNo'] as String? ?? '',
      adSoyad: veri['adSoyad'] as String? ?? '',
      babaAdi: veri['babaAdi'] as String?,
      dogumYeri: veri['dogumYeri'] as String?,
      dogumTarihiHam: veri['dogumTarihiHam'] as String?,
      dogumTarihi: zamanCoz(veri['dogumTarihi']),
      girisTarihiHam: veri['girisTarihiHam'] as String?,
      girisTarihi: zamanCoz(veri['girisTarihi']),
      cikisTarihiHam: veri['cikisTarihiHam'] as String?,
      cikisTarihi: zamanCoz(veri['cikisTarihi']),
      ikametAdresi: veri['ikametAdresi'] as String?,
      nufusKayitYeri: veri['nufusKayitYeri'] as String?,
      aramaAnahtari: veri['aramaAnahtari'] as String? ?? '',
      belgeR2Anahtari: veri['belgeR2Anahtari'] as String?,
      ocrGuvenOrtalama: (veri['ocrGuvenOrtalama'] as num?)?.toDouble(),
      aktif: veri['aktif'] as bool? ?? true,
      pasifNedeni: veri['pasifNedeni'] as String?,
      pasifTarihi: zamanCoz(veri['pasifTarihi']),
      olusturmaTarihi: zamanCoz(veri['olusturmaTarihi']) ?? DateTime.now(),
      guncellemeTarihi: zamanCoz(veri['guncellemeTarihi']) ?? DateTime.now(),
    );

    final List<dynamic> hamSatirlar = veri['satirlar'] as List<dynamic>? ?? const <dynamic>[];
    final List<DefterSatiri> satirlar = hamSatirlar.map((Object? s) {
      final Map<String, dynamic> m = s as Map<String, dynamic>;
      return DefterSatiri(
        id: (m['id'] as String?) ?? _uuid.v4(),
        ortakId: id,
        tur: (m['tur'] as String?) == 'odeme' ? SatirTuru.odeme : SatirTuru.sermaye,
        siraNo: m['siraNo'] as int? ?? 0,
        tarihHam: m['tarihHam'] as String?,
        tarih: zamanCoz(m['tarih']),
        no: m['no'] as String?,
        madde: m['madde'] as String?,
        aciklama: m['aciklama'] as String?,
        miktarKurus: m['miktarKurus'] as int? ?? 0,
        yekunKurus: m['yekunKurus'] as int? ?? 0,
        miktarHam: m['miktarHam'] as String?,
        yekunHam: m['yekunHam'] as String?,
      );
    }).toList();

    return (ortak, satirlar);
  }
}

/// Kalıcı silme mezar taşı (PLAN.md §10.2). [adim] hangi aşamada
/// kalındığını gösterir: `"r2"` → R2 henüz silinmedi, `"firestore"` →
/// R2 silindi ama Firestore kaydı duruyor, `"yerel"` → ikisi de silindi,
/// sadece yerel Drift kaydı kaldı.
class SilmeTalebi {
  const SilmeTalebi({required this.ortakId, this.r2Anahtari, required this.adim});
  final String ortakId;
  final String? r2Anahtari;
  final String adim;
}

/// ★ Sadece `Env.bulutYapilandirmasiTamam == true` iken okunmalı —
/// `FirebaseFirestore.instance` Firebase başlatılmadan çağrılırsa hata
/// fırlatır. Riverpod tembel (lazy) olduğu için bu provider hiç
/// `watch`/`read` edilmezse `FirebaseFirestore.instance`'a hiç dokunulmaz.
@Riverpod(keepAlive: true)
FirestoreServisi firestoreServisi(Ref ref) => FirestoreServisi(FirebaseFirestore.instance);
