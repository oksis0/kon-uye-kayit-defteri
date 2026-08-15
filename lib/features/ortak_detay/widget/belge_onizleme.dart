import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Taranmış belge görselini yakınlaştırma/kaydırma ile gösterir
/// (PLAN.md §6.2, §7.3). Hem içe aktarma kuyruğunda (henüz buluta
/// yüklenmemiş, yerel dosya yolu) hem ileride inceleme ekranında
/// kullanılacak — bu yüzden şimdilik sadece yerel dosya yolu alıyor.
class BelgeOnizleme extends StatelessWidget {
  const BelgeOnizleme({required this.dosyaYolu, super.key});

  final String dosyaYolu;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final File dosya = File(dosyaYolu);

    if (!dosya.existsSync()) {
      return Container(
        color: renkler.surfaceContainer,
        alignment: Alignment.center,
        child: Text(
          'Görsel bulunamadı:\n$dosyaYolu',
          textAlign: TextAlign.center,
          style: TextStyle(color: renkler.textSecondary),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Center(child: Image.file(dosya, fit: BoxFit.contain)),
      ),
    );
  }
}
