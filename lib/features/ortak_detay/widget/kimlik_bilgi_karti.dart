import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/model/ortak.dart';

import 'belge_goruntuleyici_dialog.dart';

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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool darKart = constraints.maxWidth < 520;

        final Widget cloudIcon = Tooltip(
          message: ortak.belgeR2Anahtari != null
              ? 'Sunucuda mevcut (Telefondan görüntülenebilir)'
              : (ortak.yerelDosyaYolu != null
                  ? 'Sadece bilgisayarda var (Açıldığında sunucuya yüklenecektir)'
                  : 'Belge bulunamadı'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              ortak.belgeR2Anahtari != null
                  ? Icons.cloud_done
                  : (ortak.yerelDosyaYolu != null ? Icons.cloud_queue : Icons.cloud_off),
              size: 18,
              color: ortak.belgeR2Anahtari != null
                  ? renkler.success
                  : (ortak.yerelDosyaYolu != null ? renkler.warning : renkler.textSecondary),
            ),
          ),
        );

        final Widget pasifRozet = !ortak.aktif
            ? Container(
                margin: const EdgeInsets.only(left: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: renkler.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Pasif', style: AppTypography.caption.copyWith(color: renkler.warning)),
              )
            : const SizedBox.shrink();

        final Widget belgeButonu = OutlinedButton.icon(
          icon: const Icon(Icons.document_scanner_outlined, size: 16),
          label: const Text('Taranmış Belgeyi Gör'),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
          onPressed: () => BelgeGoruntuleyiciDialog.goster(context, ortak: ortak),
        );

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
              if (darKart) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        ortak.adSoyad,
                        style: AppTypography.headline.copyWith(color: renkler.textPrimary),
                      ),
                    ),
                    cloudIcon,
                    pasifRozet,
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: belgeButonu,
                ),
              ] else ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        ortak.adSoyad,
                        style: AppTypography.headline.copyWith(color: renkler.textPrimary),
                      ),
                    ),
                    belgeButonu,
                    const SizedBox(width: AppSpacing.xs),
                    cloudIcon,
                    pasifRozet,
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xl,
                runSpacing: AppSpacing.md,
                children: <Widget>[
                  _Alan(etiket: 'Ortak No', deger: ortak.ortakNo, renkler: renkler),
                  if (ortak.sayfaNo != null)
                    _Alan(etiket: 'Sayfa No', deger: ortak.sayfaNo!, renkler: renkler),
                  if (ortak.tcKimlikNo != null)
                    _Alan(etiket: 'T.C. Kimlik No', deger: ortak.tcKimlikNo!, renkler: renkler),
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
                  if (ortak.cikisTarihi != null || (ortak.cikisTarihiHam != null && ortak.cikisTarihiHam!.isNotEmpty))
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
            ],
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxW = constraints.maxWidth;
        final double istenen = genis ? 320 : 180;
        final double width = maxW.isFinite && maxW < istenen ? maxW : istenen;
        return SizedBox(
          width: width,
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
      },
    );
  }
}
