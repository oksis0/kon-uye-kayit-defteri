import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/model/ortak.dart';

class OrtakKart extends StatelessWidget {
  const OrtakKart({
    required this.ortak,
    required this.secili,
    required this.onTap,
    super.key,
  });

  final Ortak ortak;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final String altBaslik = <String?>[ortak.babaAdi, ortak.dogumYeri]
        .where((String? deger) => deger != null && deger.isNotEmpty)
        .join(' · ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: secili ? renkler.accent.withValues(alpha: 0.08) : renkler.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: secili ? renkler.accent : renkler.border,
            width: secili ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: renkler.surface,
                shape: BoxShape.circle,
                border: Border.all(color: renkler.border),
              ),
              child: Text(
                ortak.ortakNo,
                style: AppTypography.sayisalTablo
                    .copyWith(color: renkler.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    ortak.adSoyad,
                    style: AppTypography.bodyVurgulu.copyWith(color: renkler.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (altBaslik.isNotEmpty)
                    Text(
                      altBaslik,
                      style: AppTypography.caption.copyWith(color: renkler.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!ortak.aktif) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: renkler.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Pasif', style: AppTypography.caption.copyWith(color: renkler.warning)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
