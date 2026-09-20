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
    final String altBaslik = <String?>[
      if (ortak.tcKimlikNo != null && ortak.tcKimlikNo!.isNotEmpty) 'TC: ${ortak.tcKimlikNo}',
      if (ortak.sayfaNo != null && ortak.sayfaNo!.isNotEmpty) 'Sayfa: ${ortak.sayfaNo}',
      ortak.babaAdi,
      ortak.dogumYeri,
    ].where((String? deger) => deger != null && deger.isNotEmpty).join(' · ');

    final bool pasif = !ortak.aktif;

    return Opacity(
      opacity: pasif ? 0.82 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: secili ? renkler.accent.withValues(alpha: 0.08) : renkler.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: secili
                  ? renkler.accent
                  : (pasif ? renkler.warning.withValues(alpha: 0.5) : renkler.border),
              width: secili ? 2 : (pasif ? 1.5 : 1),
            ),
          ),
          child: Row(
            children: <Widget>[
              if (pasif) ...<Widget>[
                Container(
                  width: 4,
                  height: 38,
                  decoration: BoxDecoration(
                    color: renkler.warning,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: pasif ? renkler.warning.withValues(alpha: 0.08) : renkler.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: pasif ? renkler.warning.withValues(alpha: 0.4) : renkler.border),
                ),
                child: Text(
                  ortak.ortakNo,
                  style: AppTypography.sayisalTablo.copyWith(
                    color: pasif ? renkler.warning : renkler.textSecondary,
                    fontSize: 12,
                    fontWeight: pasif ? FontWeight.bold : FontWeight.normal,
                  ),
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
                      style: AppTypography.bodyVurgulu.copyWith(
                        color: pasif ? renkler.textSecondary : renkler.textPrimary,
                        decoration: pasif ? TextDecoration.none : null,
                      ),
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
              if (pasif) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: renkler.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: renkler.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.pause_circle_outline, size: 12, color: renkler.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Pasif',
                        style: AppTypography.caption.copyWith(
                          color: renkler.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
