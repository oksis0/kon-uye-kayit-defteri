import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/env.dart';
import '../../domain/model/ocr_sonucu.dart';
import '../uzak/firestore_servisi.dart';
import '../uzak/worker_istemcisi.dart';
import 'ocr_ayristirici.dart';

part 'ocr_repository.g.dart';

/// Azure Document Intelligence ücretsiz katmanının aylık sayfa limiti
/// (PLAN.md §9).
const int aylikUcretsizOcrLimiti = 500;

/// OCR başlatma + bekleme + ayrıştırma + kota takibi tek yerde (PLAN.md §7, §9).
class OcrRepository {
  OcrRepository(this._worker, this._firestore);

  final WorkerIstemcisi _worker;
  final FirestoreServisi? _firestore;

  String get _guncelAy => DateFormat('yyyy-MM').format(DateTime.now());

  /// ★ Bu ay kaç sayfa OCR yapıldığı — bizim tahmini sayacımız (PLAN.md §9).
  /// Firestore yoksa (bulut yapılandırılmamışsa) kota takibi anlamsız,
  /// 0 döner (sınırsız kabul edilir).
  Future<int> kotaKullanimi() {
    final FirestoreServisi? firestore = _firestore;
    if (firestore == null) return Future<int>.value(0);
    return firestore.kotaOku(_guncelAy);
  }

  Future<bool> kotaDoluMu() async {
    if (_firestore == null) return false;
    final int kullanim = await kotaKullanimi();
    return kullanim >= aylikUcretsizOcrLimiti;
  }

  /// Azure analizini başlatır. Başarılı olursa kota sayacı bir artırılır
  /// (Azure sayfayı zaten işlemiş sayılır — sonradan hata alsa da kota
  /// harcanmıştır).
  Future<String> baslat(Uint8List gorselVerisi) async {
    final String operationId = await _worker.ocrBaslat(gorselVerisi);
    final FirestoreServisi? firestore = _firestore;
    if (firestore != null) {
      unawaited(firestore.kotaArtir(_guncelAy));
    }
    return operationId;
  }

  /// Tek bir durum sorgusu — bekleme döngüsü ÇAĞIRAN TARAFTA (kuyruk
  /// işleyicisinde), burada değil. Böylece kullanıcı ilerlemeyi görebiliyor
  /// ve uygulama çökerse kaldığı yerden devam edebiliyor (PLAN.md §8).
  Future<OcrIslemSonucu> durumSorgula(String operationId) async {
    final OcrDurumYaniti yanit = await _worker.ocrDurumSorgula(operationId);

    if (yanit.durum == 'bekliyor') {
      return const OcrIslemSonucu.bekliyor();
    }
    if (yanit.hataliMi) {
      return OcrIslemSonucu.hata(yanit.hataMesaji ?? 'Bilinmeyen OCR hatası');
    }

    final Map<String, dynamic> hamSonuc = yanit.sonuc ?? const <String, dynamic>{};
    final OcrSonucu ayrilmisSonuc = azureSonucunuAyristir(hamSonuc);
    return OcrIslemSonucu.bitti(sonuc: ayrilmisSonuc, hamJson: jsonEncode(hamSonuc));
  }

  /// Kuyruktan devam ederken: daha önce kaydedilmiş ham JSON varsa
  /// (uygulama inceleme formundayken çökmüşse) OCR'ı TEKRAR YAPMADAN
  /// doğrudan ayrıştırır — Azure kotası israf edilmez (PLAN.md §8).
  OcrSonucu hamJsondanAyristir(String hamJson) {
    final Object? cozulmus = jsonDecode(hamJson);
    if (cozulmus is! Map<String, dynamic>) return const OcrSonucu();
    return azureSonucunuAyristir(cozulmus);
  }
}

/// [OcrRepository.durumSorgula] sonucu — üç halden biri.
sealed class OcrIslemSonucu {
  const OcrIslemSonucu();

  const factory OcrIslemSonucu.bekliyor() = OcrIslemSonucuBekliyor;
  const factory OcrIslemSonucu.bitti({required OcrSonucu sonuc, required String hamJson}) =
      OcrIslemSonucuBitti;
  const factory OcrIslemSonucu.hata(String mesaj) = OcrIslemSonucuHata;
}

class OcrIslemSonucuBekliyor extends OcrIslemSonucu {
  const OcrIslemSonucuBekliyor();
}

class OcrIslemSonucuBitti extends OcrIslemSonucu {
  const OcrIslemSonucuBitti({required this.sonuc, required this.hamJson});
  final OcrSonucu sonuc;
  final String hamJson;
}

class OcrIslemSonucuHata extends OcrIslemSonucu {
  const OcrIslemSonucuHata(this.mesaj);
  final String mesaj;
}

@Riverpod(keepAlive: true)
OcrRepository ocrRepository(Ref ref) {
  final WorkerIstemcisi worker = ref.watch(workerIstemcisiProvider);
  final FirestoreServisi? firestore =
      Env.bulutYapilandirmasiTamam ? ref.watch(firestoreServisiProvider) : null;
  return OcrRepository(worker, firestore);
}
