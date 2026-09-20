import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../data/repository/yedek_repository.dart';

/// Elle yedek alma ekranı (PLAN.md §11). Otomatik/zamanlanmış yedek Faz 11 —
/// Windows Task Scheduler entegrasyonu gerektiriyor, önce manuel buton.
class YedekEkrani extends ConsumerStatefulWidget {
  const YedekEkrani({super.key});

  @override
  ConsumerState<YedekEkrani> createState() => _YedekEkraniState();
}

class _YedekEkraniState extends ConsumerState<YedekEkrani> {
  DateTime? _sonYedek;
  bool _yukleniyor = true;
  bool _yedekAliniyor = false;
  String? _sonMesaj;
  bool _sonMesajHataMi = false;

  @override
  void initState() {
    super.initState();
    _sonYedekTarihiniYukle();
  }

  Future<void> _sonYedekTarihiniYukle() async {
    final DateTime? tarih = await ref.read(yedekRepositoryProvider).sonYedekTarihi();
    if (mounted) {
      setState(() {
        _sonYedek = tarih;
        _yukleniyor = false;
      });
    }
  }

  Future<void> _yedekAl() async {
    final String? klasorYolu = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Yedeğin kaydedileceği klasörü seçin (ör. OneDrive/Drive klasörünüz)',
    );
    if (klasorYolu == null) return;

    setState(() {
      _yedekAliniyor = true;
      _sonMesaj = null;
    });

    try {
      final String yedekYolu = await ref.read(yedekRepositoryProvider).yedekAl(klasorYolu);
      setState(() {
        _sonMesaj = 'Yedek alındı: $yedekYolu';
        _sonMesajHataMi = false;
        _sonYedek = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _sonMesaj = 'Yedek alınamadı: $e';
        _sonMesajHataMi = true;
      });
    } finally {
      if (mounted) setState(() => _yedekAliniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final int? gecenGun = _sonYedek == null
        ? null
        : DateTime.now().difference(_sonYedek!).inDays;
    final bool uyariGoster = gecenGun == null || gecenGun >= 7;

    return Scaffold(
      appBar: AppBar(title: const Text('Yedekleme')),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bulut mimarisi (R2 + Firestore) tek-nokta-arıza riskini kaldırıyor, '
                      'ama ücretsiz katmanlarda otomatik yedek yok. Metin verinizi (görseller '
                      'hariç) periyodik olarak kendi kontrolünüzdeki bir klasöre '
                      '(örn. OneDrive/Drive) dışa aktarın.',
                      style: AppTypography.body.copyWith(color: renkler.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: uyariGoster
                            ? renkler.warning.withValues(alpha: 0.12)
                            : renkler.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: uyariGoster ? renkler.warning : renkler.border,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            uyariGoster ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            color: uyariGoster ? renkler.warning : renkler.success,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _sonYedek == null
                                  ? 'Henüz hiç yedek alınmadı.'
                                  : 'Son yedek: ${DateFormat('dd.MM.yyyy HH:mm', 'tr_TR').format(_sonYedek!)}'
                                        ' ($gecenGun gün önce)',
                              style: AppTypography.body.copyWith(color: renkler.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: _yedekAliniyor ? null : _yedekAl,
                      icon: _yedekAliniyor
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.backup_outlined, size: 18),
                      label: Text(_yedekAliniyor ? 'Yedek alınıyor...' : 'Yedek Al'),
                    ),
                    if (_sonMesaj != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _sonMesaj!,
                        style: AppTypography.caption.copyWith(
                          color: _sonMesajHataMi ? renkler.error : renkler.success,
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
