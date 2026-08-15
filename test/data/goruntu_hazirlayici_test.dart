import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ortak_defteri/data/goruntu/goruntu_hazirlayici.dart';

void main() {
  late Directory geciciKlasor;

  setUp(() {
    geciciKlasor = Directory.systemTemp.createTempSync('goruntu_hazirla_test');
  });

  tearDown(() {
    geciciKlasor.deleteSync(recursive: true);
  });

  // ★ Not: Kademeli sıkıştırma (q90→q75→q60→resize) algoritmasının kendisi
  // gerçek 4MB+ bir görselle test edilmiyor — rastgele piksel verisiyle
  // güvenilir/hızlı bir test üretmek pratik değil (JPEG sıkıştırması gerçek
  // taramalarda öngörülemez davranır). Bu yol, Faz 0'daki 20 sayfalık pilot
  // taramayla elle doğrulanacak (PLAN.md §15).

  test('4MB altındaki dosya HİÇ değiştirilmeden döner (kalite korunur)', () async {
    final img.Image kucukGorsel = img.Image(width: 20, height: 20);
    img.fill(kucukGorsel, color: img.ColorRgb8(120, 90, 60));
    final Uint8List jpegVerisi = img.encodeJpg(kucukGorsel, quality: 90);

    final File dosya = File('${geciciKlasor.path}/kucuk.jpg')
      ..writeAsBytesSync(jpegVerisi);

    final HazirlanmisGorsel sonuc = await GoruntuHazirlayici().hazirla(dosya.path);

    expect(sonuc.orijinalBoyutBayt, jpegVerisi.lengthInBytes);
    expect(sonuc.sonBoyutBayt, jpegVerisi.lengthInBytes);
    expect(sonuc.sikistirildiMi, isFalse);
    expect(sonuc.veriler, jpegVerisi);
  });

  test('HEIC dosyası masaüstünde anlaşılır bir hata fırlatır', () async {
    // Minimal bir HEIC "ftyp" kutusu taklidi: [4 byte boyut][ftyp][heic marka]
    final Uint8List sahteHeicBaslangici = Uint8List.fromList(<int>[
      0x00, 0x00, 0x00, 0x18, // kutu boyutu (önemsiz)
      0x66, 0x74, 0x79, 0x70, // 'ftyp'
      0x68, 0x65, 0x69, 0x63, // 'heic' markası
      ...List<int>.filled(12, 0),
    ]);
    final File dosya = File('${geciciKlasor.path}/sahte.heic')
      ..writeAsBytesSync(sahteHeicBaslangici);

    expect(
      () => GoruntuHazirlayici().hazirla(dosya.path),
      throwsA(isA<GoruntuHazirlamaHatasi>()),
    );
  });
}
