import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/model/ortak.dart';

class KimlikBilgiKarti extends StatelessWidget {
  const KimlikBilgiKarti({required this.ortak, super.key});

  final Ortak ortak;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final DateFormat tarihFormat = DateFormat('dd.MM.yyyy', 'tr_TR');

    String tarihGoster(DateTime? tarih, String? ham) {
      if (tarih != null) return tarihFormat.format(tarih);
      if (ham != null && ham.isNotEmpty) return '$ham (okunamadı)';
      return '—';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: renkler.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renkler.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(ortak.adSoyad, style: AppTypography.headline.copyWith(color: renkler.textPrimary)),
              ),
              if (!ortak.aktif)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: renkler.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Pasif', style: AppTypography.caption.copyWith(color: renkler.warning)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.md,
            children: <Widget>[
              _Alan(etiket: 'Ortak No', deger: ortak.ortakNo, renkler: renkler),
              _Alan(etiket: 'Baba Adı', deger: ortak.babaAdi ?? '—', renkler: renkler),
              _Alan(etiket: 'Doğum Yeri', deger: ortak.dogumYeri ?? '—', renkler: renkler),
              _Alan(
                etiket: 'Doğum Tarihi',
                deger: tarihGoster(ortak.dogumTarihi, ortak.dogumTarihiHam),
                renkler: renkler,
              ),
              _Alan(
                etiket: 'Giriş Tarihi',
                deger: tarihGoster(ortak.girisTarihi, ortak.girisTarihiHam),
                renkler: renkler,
              ),
              _Alan(
                etiket: 'Çıkış Tarihi',
                deger: tarihGoster(ortak.cikisTarihi, ortak.cikisTarihiHam),
                renkler: renkler,
              ),
              _Alan(etiket: 'İkamet Adresi', deger: ortak.ikametAdresi ?? '—', renkler: renkler, genis: true),
              _Alan(
                etiket: 'Nüfusa Kayıtlı Olduğu Yer',
                deger: ortak.nufusKayitYeri ?? '—',
                renkler: renkler,
                genis: true,
              ),
            ],
          ),
          if (ortak.pasifNedeni != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Pasif nedeni: ${ortak.pasifNedeni}',
              style: AppTypography.caption.copyWith(color: renkler.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Alan extends StatelessWidget {
  const _Alan({
    required this.etiket,
    required this.deger,
    required this.renkler,
    this.genis = false,
  });

  final String etiket;
  final String deger;
  final AppColors renkler;
  final bool genis;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: genis ? 320 : 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(etiket, style: AppTypography.caption.copyWith(color: renkler.textSecondary)),
          const SizedBox(height: 2),
          Text(deger, style: AppTypography.body.copyWith(color: renkler.textPrimary)),
        ],
      ),
    );
  }
}
