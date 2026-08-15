import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

/// Hazırlama sonucu — UI'de "4.2 MB → 1.1 MB'a düşürüldü" gibi geri bildirim
/// göstermek için orijinal/son boyut da taşınıyor.
class HazirlanmisGorsel {
  const HazirlanmisGorsel({
    required this.veriler,
    required this.orijinalBoyutBayt,
    required this.sonBoyutBayt,
  });

  final Uint8List veriler;
  final int orijinalBoyutBayt;
  final int sonBoyutBayt;

  bool get sikistirildiMi => sonBoyutBayt != orijinalBoyutBayt;
}

/// Bir dosyayı OCR'a göndermeye hazır JPEG byte'larına çevirir:
/// HEIC→JPEG dönüşümü + 4MB boyut kontrolü (PLAN.md §6.3).
///
/// ★ Kaynak dosya ASLA taşınmaz/silinmez/üzerine yazılmaz — sadece okunur.
/// Bu, kuyruğun çökme dayanıklılığının bir parçası (PLAN.md §8).
///
/// Platforma göre iki farklı uygulama: masaüstünde saf Dart `image` paketi
/// (Isolate içinde, native eklenti Windows'ta güvenilir değil), mobilde
/// native `flutter_image_compress`. Tek arayüz, iki uygulama.
abstract class GoruntuHazirlayici {
  factory GoruntuHazirlayici() {
    if (Platform.isAndroid || Platform.isIOS) {
      return _MobilGoruntuHazirlayici();
    }
    return _MasaustuGoruntuHazirlayici();
  }

  Future<HazirlanmisGorsel> hazirla(String dosyaYolu);
}

const int _dortMbBayt = 4 * 1024 * 1024;
const int _enUzunKenarSiniri = 2400;

bool _heicMi(Uint8List basHeader) {
  if (basHeader.length < 12) return false;
  final bool ftypVarMi = basHeader[4] == 0x66 && // f
      basHeader[5] == 0x74 && // t
      basHeader[6] == 0x79 && // y
      basHeader[7] == 0x70; // p
  if (!ftypVarMi) return false;

  final String marka = String.fromCharCodes(basHeader.sublist(8, 12));
  const Set<String> heicMarkalari = <String>{
    'heic', 'heix', 'hevc', 'hevx', 'heim', 'heis', 'hevm', 'hevs', 'mif1', 'msf1',
  };
  return heicMarkalari.contains(marka);
}

/// ---------------------------------------------------------------------
/// Masaüstü: saf Dart `image` paketi. Yavaş olabildiği için Isolate'te
/// çalıştırılır — arayüz donmasın diye (PLAN.md §6.3).
/// ---------------------------------------------------------------------
class _MasaustuGoruntuHazirlayici implements GoruntuHazirlayici {
  @override
  Future<HazirlanmisGorsel> hazirla(String dosyaYolu) async {
    final Uint8List ham = await File(dosyaYolu).readAsBytes();

    if (_heicMi(ham)) {
      // Masaüstü tarayıcıları (NAPS2 vb.) HEIC üretmiyor — bu bir güvenlik
      // ağı. `image` paketinin HEIC decoder'ı yok, bu yüzden burada devam
      // edemeyiz; kullanıcıya anlaşılır bir hata döndürmek en doğrusu.
      throw GoruntuHazirlamaHatasi(
        'HEIC formatı masaüstünde desteklenmiyor. Lütfen tarama '
        'programınızda çıktı formatını JPEG olarak ayarlayın.',
      );
    }

    if (ham.lengthInBytes <= _dortMbBayt) {
      return HazirlanmisGorsel(
        veriler: ham,
        orijinalBoyutBayt: ham.lengthInBytes,
        sonBoyutBayt: ham.lengthInBytes,
      );
    }

    final Uint8List sikistirilmis = await Isolate.run(() => _sikistir(ham));
    return HazirlanmisGorsel(
      veriler: sikistirilmis,
      orijinalBoyutBayt: ham.lengthInBytes,
      sonBoyutBayt: sikistirilmis.lengthInBytes,
    );
  }

  /// Isolate içinde çalışır — üst seviye/static fonksiyon olmalı.
  static Uint8List _sikistir(Uint8List ham) {
    final img.Image? goruntu = img.decodeImage(ham);
    if (goruntu == null) {
      throw GoruntuHazirlamaHatasi('Görsel okunamadı — dosya bozuk olabilir.');
    }

    // Kademeli kalite düşürme (PLAN.md §6.3): %90 → %75 → %60.
    for (final int kalite in const <int>[90, 75, 60]) {
      final Uint8List deneme = img.encodeJpg(goruntu, quality: kalite);
      if (deneme.lengthInBytes <= _dortMbBayt) return deneme;
    }

    // Hâlâ büyükse: en uzun kenarı küçült + %75.
    final bool genisDahaBuyuk = goruntu.width >= goruntu.height;
    final img.Image kucultulmus = img.copyResize(
      goruntu,
      width: genisDahaBuyuk ? _enUzunKenarSiniri : null,
      height: genisDahaBuyuk ? null : _enUzunKenarSiniri,
    );
    return img.encodeJpg(kucultulmus, quality: 75);
  }
}

/// ---------------------------------------------------------------------
/// Mobil: native `flutter_image_compress` — hızlı, az bellek.
/// ---------------------------------------------------------------------
class _MobilGoruntuHazirlayici implements GoruntuHazirlayici {
  @override
  Future<HazirlanmisGorsel> hazirla(String dosyaYolu) async {
    final Uint8List ham = await File(dosyaYolu).readAsBytes();
    final int orijinalBoyut = ham.lengthInBytes;

    // flutter_image_compress HEIC dahil çoğu formatı native ImageIO/BitmapFactory
    // ile çözüp JPEG'e çevirebiliyor — HEIC için ayrı bir adım gerekmiyor.
    if (orijinalBoyut <= _dortMbBayt && !_heicMi(ham)) {
      return HazirlanmisGorsel(
        veriler: ham,
        orijinalBoyutBayt: orijinalBoyut,
        sonBoyutBayt: orijinalBoyut,
      );
    }

    for (final int kalite in const <int>[90, 75, 60]) {
      final Uint8List? sonuc = await FlutterImageCompress.compressWithFile(
        dosyaYolu,
        quality: kalite,
        format: CompressFormat.jpeg,
      );
      if (sonuc == null) {
        throw GoruntuHazirlamaHatasi('Görsel sıkıştırılamadı.');
      }
      if (sonuc.lengthInBytes <= _dortMbBayt) {
        return HazirlanmisGorsel(
          veriler: sonuc,
          orijinalBoyutBayt: orijinalBoyut,
          sonBoyutBayt: sonuc.lengthInBytes,
        );
      }
    }

    final Uint8List? sonDeneme = await FlutterImageCompress.compressWithFile(
      dosyaYolu,
      quality: 75,
      format: CompressFormat.jpeg,
      minWidth: _enUzunKenarSiniri,
      minHeight: _enUzunKenarSiniri,
    );
    if (sonDeneme == null) {
      throw GoruntuHazirlamaHatasi('Görsel sıkıştırılamadı.');
    }
    return HazirlanmisGorsel(
      veriler: sonDeneme,
      orijinalBoyutBayt: orijinalBoyut,
      sonBoyutBayt: sonDeneme.lengthInBytes,
    );
  }
}

class GoruntuHazirlamaHatasi implements Exception {
  GoruntuHazirlamaHatasi(this.mesaj);
  final String mesaj;

  @override
  String toString() => mesaj;
}
