import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../kuyruk_provider.dart';

/// "X/Y belge işlendi" ilerleme göstergesi (PLAN.md §8).
class IlerlemeCubugu extends StatelessWidget {
  const IlerlemeCubugu({required this.durum, super.key});

  final KuyrukIlerlemeDurumu durum;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final double oran = durum.toplam == 0 ? 0 : durum.tamamlanan / durum.toplam;

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
              Text('İçe Aktarma', style: AppTypography.title.copyWith(color: renkler.textPrimary)),
              const Spacer(),
              Text(
                '${durum.tamamlanan} / ${durum.toplam}',
                style: AppTypography.sayisalTablo.copyWith(color: renkler.textSecondary),
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
              valueColor: AlwaysStoppedAnimation<Color>(renkler.accent),
            ),
          ),
          if (durum.suankiDosyaAdi != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Şu an: ${durum.suankiDosyaAdi}',
              style: AppTypography.caption.copyWith(color: renkler.textSecondary),
            ),
          ],
          if (durum.ocrBekleyenSayisi > 0) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: renkler.accent),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${durum.ocrBekleyenSayisi} belge için Azure OCR sonucu bekleniyor...',
                  style: AppTypography.caption.copyWith(color: renkler.textSecondary),
                ),
              ],
            ),
          ],
          if (durum.sonHata != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              durum.sonHata!,
              style: AppTypography.caption.copyWith(color: renkler.error),
            ),
          ],
        ],
      ),
    );
  }
}
