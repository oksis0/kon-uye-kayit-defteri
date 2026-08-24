import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/repository/ocr_repository.dart';

/// "Bu ay kaç OCR sayfası kullanıldı" göstergesi (PLAN.md §9).
///
/// ★ Bu, uygulamanın kendi TAHMİNİ sayacı — gerçek kaynak Azure paneli.
/// Senkronizasyon kayması ihtimaline karşı ayda bir orada doğrulanmalı.
class KotaGosterge extends StatelessWidget {
  const KotaGosterge({required this.kullanim, super.key});

  final int kullanim;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final double oran = (kullanim / aylikUcretsizOcrLimiti).clamp(0.0, 1.0);
    final Color renk = kullanim >= aylikUcretsizOcrLimiti
        ? renkler.error
        : (kullanim >= 450 ? renkler.warning : renkler.accent);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: renkler.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renkler.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Azure OCR Kotası (bu ay)',
                style: AppTypography.bodyVurgulu.copyWith(color: renkler.textPrimary),
              ),
              const Spacer(),
              Text(
                '$kullanim / $aylikUcretsizOcrLimiti sayfa',
                style: AppTypography.sayisalTablo.copyWith(color: renk),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: oran,
              minHeight: 6,
              backgroundColor: renkler.surface,
              valueColor: AlwaysStoppedAnimation<Color>(renk),
            ),
          ),
          if (kullanim >= aylikUcretsizOcrLimiti) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kota doldu — kuyruk otomatik duraklıyor. Kalan belgeler '
              'gelecek ay işlenecek (PLAN.md §9).',
              style: AppTypography.caption.copyWith(color: renkler.error),
            ),
          ] else if (kullanim >= 450) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kotanın büyük kısmı kullanıldı.',
              style: AppTypography.caption.copyWith(color: renkler.warning),
            ),
          ],
        ],
      ),
    );
  }
}
