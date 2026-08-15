import 'dart:io';

import 'package:crypto/crypto.dart';

/// Dosyanın sha256 hash'ini hesaplar. Aynı klasör tekrar seçildiğinde veya
/// aynı belge yanlışlıkla iki kez taranıp kuyruğa eklenmek istendiğinde
/// bunu yakalamak için (PLAN.md §8).
///
/// Büyük dosyalarda (yüksek DPI taramalar) belleği şişirmemek için akış
/// (stream) üzerinden okunur — dosya bir kerede belleğe yüklenmez.
Future<String> dosyaHashHesapla(String dosyaYolu) async {
  final Stream<List<int>> akis = File(dosyaYolu).openRead();
  final Digest ozet = await sha256.bind(akis).first;
  return ozet.toString();
}
