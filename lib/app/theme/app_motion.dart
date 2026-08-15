import 'package:flutter/material.dart';

/// Hareket kuralları: süre maksimum 240ms, overshoot/bounce yok,
/// liste öğeleri 40ms stagger ile. Gereksiz animasyon eklenmez —
/// sadece anlam katan animasyonlar (CLAUDE.md).
abstract final class AppMotion {
  static const Duration hizli = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration yavas = Duration(milliseconds: 240);

  static const Duration listeGecikmeAdimi = Duration(milliseconds: 40);

  static const Curve egri = Curves.easeOut;
  static const Curve gecisEgrisi = Curves.fastOutSlowIn;

  /// Liste öğesi [index] için kademeli (staggered) gecikme hesaplar.
  /// Çok uzun listelerde toplam gecikmeyi 400ms ile sınırlar.
  static Duration listeGecikmesi(int index) {
    final int sinirliIndex = index > 10 ? 10 : index;
    return listeGecikmeAdimi * sinirliIndex;
  }
}
