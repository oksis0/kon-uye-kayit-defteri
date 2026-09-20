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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.broken_image_outlined, size: 56, color: renkler.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Belge önizlemesi yüklenemedi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: renkler.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Dosya bu cihazda bulunamadı.\nBelgeyi bulut üzerinden görüntülemek için kaydettikten sonra detay ekranından açabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: renkler.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final bool pdfMi = dosyaYolu.toLowerCase().endsWith('.pdf');
    if (pdfMi) {
      return Container(
        color: Colors.black87,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.picture_as_pdf, size: 64, color: Colors.redAccent),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                dosya.path.split(Platform.pathSeparator).last,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('PDF Görüntüleyicide Aç'),
              onPressed: () {
                if (Platform.isMacOS) {
                  Process.run('open', <String>[dosya.path]);
                } else if (Platform.isWindows) {
                  Process.run('explorer.exe', <String>[dosya.path]);
                }
              },
            ),
          ],
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
