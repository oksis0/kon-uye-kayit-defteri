import 'package:freezed_annotation/freezed_annotation.dart';

import '../enum/kuyruk_durumu.dart';

part 'ice_aktarma_isi.freezed.dart';

/// Toplu içe aktarma kuyruğundaki tek bir dosya (PLAN.md §4.3, §8).
///
/// ★ Sadece yerel Drift'te var, Firestore'a hiç gitmez — bu tamamen bu
/// cihaza özgü bir çalışma listesi. Dosya taşınmaz/silinmez; hangi dosyanın
/// işlendiği bu kayıttaki [islendi] alanıyla takip edilir, uygulama çökse
/// bile kaldığı yerden devam edebilsin diye.
@freezed
abstract class IceAktarmaIsi with _$IceAktarmaIsi {
  const factory IceAktarmaIsi({
    required String id,
    required String dosyaYolu,
    required String dosyaAdi,
    required String dosyaHash,
    required KuyrukDurumu durum,
    @Default(false) bool islendi,
    String? hataMesaji,
    @Default(0) int denemeSayisi,
    String? olusanOrtakId,

    /// Azure'un ham cevabı. Uygulama inceleme formundayken çökerse, açılışta
    /// OCR'ı tekrarlamadan (kota israfı olmadan) forma dönebilmek için.
    String? ocrHamJson,

    /// `ocrYapiliyor` durumundayken hangi Azure işleminin sorgulanacağı.
    String? azureOperationId,
    required DateTime eklenmeTarihi,
  }) = _IceAktarmaIsi;
}
