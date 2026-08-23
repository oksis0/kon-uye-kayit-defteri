import 'dart:convert';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/model/ocr_sonucu.dart';
import '../uzak/worker_istemcisi.dart';
import 'ocr_ayristirici.dart';

part 'ocr_repository.g.dart';

/// OCR başlatma + bekleme + ayrıştırma tek yerde (PLAN.md §7).
class OcrRepository {
  OcrRepository(this._worker);

  final WorkerIstemcisi _worker;

  Future<String> baslat(Uint8List gorselVerisi) => _worker.ocrBaslat(gorselVerisi);

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
  return OcrRepository(ref.watch(workerIstemcisiProvider));
}
