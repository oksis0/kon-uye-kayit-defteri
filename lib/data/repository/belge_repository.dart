import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../uzak/worker_istemcisi.dart';

part 'belge_repository.g.dart';

/// R2'deki belge görselleri üzerindeki tüm işlemler — UI, Worker'ı veya
/// R2'yi hiç bilmez, sadece bu repository'yi kullanır (PLAN.md §3).
///
/// ★ Görsel, kullanıcı OCR sonucunu ONAYLADIKTAN SONRA yüklenir — atlanan
/// belgeler R2'de yer kaplamasın diye (PLAN.md §2.2, §8).
class BelgeRepository {
  BelgeRepository(this._worker);

  final WorkerIstemcisi _worker;

  /// `belgeler/2026/08/uuid.jpg` gibi tarih bazlı bir anahtar üretir
  /// (PLAN.md §4.1).
  String anahtarUret(String ortakId) {
    final DateTime simdi = DateTime.now();
    final String yil = simdi.year.toString().padLeft(4, '0');
    final String ay = simdi.month.toString().padLeft(2, '0');
    return 'belgeler/$yil/$ay/$ortakId.jpg';
  }

  Future<void> yukle(String anahtar, Uint8List veriler) {
    return _worker.belgeYukle(anahtar, veriler);
  }

  Future<Uint8List> indir(String anahtar) {
    return _worker.belgeGetir(anahtar);
  }

  /// PLAN.md §10.2 — mezar taşlı kalıcı silme akışının ilk adımı.
  Future<void> sil(String anahtar) {
    return _worker.belgeSil(anahtar);
  }
}

@Riverpod(keepAlive: true)
BelgeRepository belgeRepository(Ref ref) {
  return BelgeRepository(ref.watch(workerIstemcisiProvider));
}
