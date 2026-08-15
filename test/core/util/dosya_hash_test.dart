import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/core/util/dosya_hash.dart';

void main() {
  late Directory geciciKlasor;

  setUp(() {
    geciciKlasor = Directory.systemTemp.createTempSync('dosya_hash_test');
  });

  tearDown(() {
    geciciKlasor.deleteSync(recursive: true);
  });

  test('aynı içerik aynı hash üretir', () async {
    final File a = File('${geciciKlasor.path}/a.jpg')..writeAsStringSync('ayni-icerik');
    final File b = File('${geciciKlasor.path}/b.jpg')..writeAsStringSync('ayni-icerik');

    final String hashA = await dosyaHashHesapla(a.path);
    final String hashB = await dosyaHashHesapla(b.path);

    expect(hashA, hashB);
  });

  test('farklı içerik farklı hash üretir', () async {
    final File a = File('${geciciKlasor.path}/a.jpg')..writeAsStringSync('icerik-1');
    final File b = File('${geciciKlasor.path}/b.jpg')..writeAsStringSync('icerik-2');

    final String hashA = await dosyaHashHesapla(a.path);
    final String hashB = await dosyaHashHesapla(b.path);

    expect(hashA, isNot(hashB));
  });

  test('hash 64 karakterlik hex string döner (sha256)', () async {
    final File dosya = File('${geciciKlasor.path}/a.jpg')..writeAsStringSync('test');
    final String hash = await dosyaHashHesapla(dosya.path);
    expect(hash.length, 64);
    expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(hash), isTrue);
  });
}
