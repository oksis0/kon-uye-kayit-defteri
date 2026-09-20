import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/config/env.dart';
import '../../data/repository/ocr_repository.dart';
import '../../data/repository/ortak_repository.dart';
import '../../data/uzak/auth_servisi.dart';
import '../../data/uzak/worker_istemcisi.dart';
import 'widget/kota_gosterge.dart';

/// Ayarlar ekranı (PLAN.md §15, Faz 8).
///
/// ★ Bulut yapılandırılmamışsa (env.json boş) kota/bağlantı/hesap
/// bölümleri hiç gösterilmez — bunun yerine ne yapılması gerektiğini
/// anlatan bir bilgi kartı gösterilir.
class AyarlarEkrani extends ConsumerStatefulWidget {
  const AyarlarEkrani({super.key});

  @override
  ConsumerState<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends ConsumerState<AyarlarEkrani> {
  int? _kotaKullanimi;
  bool _kotaYukleniyor = true;
  bool? _baglantiSonucu;
  bool _baglantiTestEdiliyor = false;

  @override
  void initState() {
    super.initState();
    if (Env.bulutYapilandirmasiTamam) {
      unawaited(_kotayiYukle());
    } else {
      _kotaYukleniyor = false;
    }
  }

  Future<void> _kotayiYukle() async {
    final int kullanim = await ref.read(ocrRepositoryProvider).kotaKullanimi();
    if (mounted) {
      setState(() {
        _kotaKullanimi = kullanim;
        _kotaYukleniyor = false;
      });
    }
  }

  Future<void> _baglantiyiTestEt() async {
    setState(() {
      _baglantiTestEdiliyor = true;
      _baglantiSonucu = null;
    });
    final bool sonuc = await ref.read(workerIstemcisiProvider).saglikKontrolu();
    if (mounted) {
      setState(() {
        _baglantiSonucu = sonuc;
        _baglantiTestEdiliyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Env.bulutYapilandirmasiTamam ? _bulutluIcerik(context) : _bulutsuzIcerik(context),
        ),
      ),
    );
  }

  Widget _bulutsuzIcerik(BuildContext context) {
    final AppColors renkler = context.renkler;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.cloud_off_outlined, size: 32, color: renkler.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Bulut özellikleri henüz yapılandırılmadı',
            style: AppTypography.title.copyWith(color: renkler.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'OCR, buluta senkron ve görsel depolama için Cloudflare Worker, '
            'Firebase ve Azure hesaplarını kurup env.json dosyasını doldurmanız '
            'gerekiyor (bkz. PLAN.md §12.5). O zamana kadar uygulama tamamen '
            'çevrimdışı çalışır — hiçbir veri kaybolmaz, sonradan sorunsuz '
            'buluta bağlanır.',
            style: AppTypography.body.copyWith(color: renkler.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _bulutluIcerik(BuildContext context) {
    final AppColors renkler = context.renkler;
    final AuthServisi auth = ref.read(authServisiProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_kotaYukleniyor)
            const Center(child: CircularProgressIndicator())
          else if (_kotaKullanimi != null)
            KotaGosterge(kullanim: _kotaKullanimi!),
          const SizedBox(height: AppSpacing.xl),
          Text('Bağlantı', style: AppTypography.title.copyWith(color: renkler.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _baglantiTestEdiliyor ? null : () => unawaited(_baglantiyiTestEt()),
                icon: _baglantiTestEdiliyor
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering, size: 18),
                label: const Text('Worker Bağlantısını Test Et'),
              ),
              if (_baglantiSonucu != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  _baglantiSonucu! ? Icons.check_circle : Icons.error_outline,
                  color: _baglantiSonucu! ? renkler.success : renkler.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _baglantiSonucu! ? 'Bağlantı sağlıklı' : 'Worker\'a ulaşılamadı',
                  style: AppTypography.caption.copyWith(
                    color: _baglantiSonucu! ? renkler.success : renkler.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Bulut ve Sunucu Senkronu', style: AppTypography.title.copyWith(color: renkler.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bilgisayardaki tüm ortak kayıtlarını ve taranmış belgeleri sunucuya yükler. Böylece telefonunuzdan veya başka bir cihazdan tüm belgeleri eksiksiz görebilirsiniz.',
            style: AppTypography.caption.copyWith(color: renkler.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: _senkronCalisiyor ? null : _sunucuyaEsitle,
            icon: _senkronCalisiyor
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_sync, size: 18),
            label: Text(_senkronCalisiyor ? 'Sunucuya Eşitleniyor...' : 'Tüm Belgeleri ve Kayıtları Sunucuya Eşitle'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Hesap', style: AppTypography.title.copyWith(color: renkler.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            auth.mevcutKullanici?.email ?? '—',
            style: AppTypography.body.copyWith(color: renkler.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => unawaited(auth.cikisYap()),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  bool _senkronCalisiyor = false;

  Future<void> _sunucuyaEsitle() async {
    setState(() {
      _senkronCalisiyor = true;
    });

    try {
      final OrtakRepository repo = ref.read(ortakRepositoryProvider);
      final int kayitSayisi = await repo.tumunuFirestoreyeIt();
      final int belgeSayisi = await repo.eksikBelgeleriR2yeYukle();
      await repo.firestoretenSenkronizeEt();

      if (mounted) {
        setState(() {
          _senkronCalisiyor = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$kayitSayisi ortak kaydı Firestore\'a, $belgeSayisi taranmış belge Cloudflare R2 sunucusuna eşitlendi.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _senkronCalisiyor = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Senkronizasyon hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
