import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../data/repository/ortak_repository.dart';
import '../../domain/enum/satir_turu.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ortak.dart';
import 'ortak_detay_provider.dart';
import 'widget/defter_tablosu.dart';
import 'widget/kimlik_bilgi_karti.dart';

/// Bir ortağın tüm detayı: kimlik bilgileri + sermaye/ödeme tabloları.
///
/// [gomulu] true ise (geniş ekran, ana-detay yan yana düzeni — PLAN.md §14)
/// AppBar/geri tuşu olmadan gösterilir; standalone route olarak açıldığında
/// [gomulu] false'tur.
class OrtakDetayEkrani extends ConsumerWidget {
  const OrtakDetayEkrani({required this.ortakId, this.gomulu = false, super.key});

  final String ortakId;
  final bool gomulu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Ortak?> ortakAsync = ref.watch(ortakDetayProvider(ortakId));

    final Widget govde = ortakAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object hata, StackTrace _) => Center(child: Text('Bir hata oluştu: $hata')),
      data: (Ortak? ortak) {
        if (ortak == null) {
          return const Center(child: Text('Ortak bulunamadı.'));
        }
        return _OrtakDetayIcerik(ortak: ortak);
      },
    );

    if (gomulu) return govde;

    return Scaffold(
      appBar: AppBar(
        title: Text(ortakAsync.value?.adSoyad ?? 'Ortak Detayı'),
        actions: <Widget>[
          if (ortakAsync.value != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Düzenle',
              onPressed: () => Navigator.of(context).pushNamed('/ortak/$ortakId/duzenle'),
            ),
        ],
      ),
      body: govde,
    );
  }
}

class _OrtakDetayIcerik extends ConsumerWidget {
  const _OrtakDetayIcerik({required this.ortak});

  final Ortak ortak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<DefterSatiri>> satirlarAsync =
        ref.watch(ortakSatirlariProvider(ortak.id));
    final OrtakRepository repo = ref.read(ortakRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          KimlikBilgiKarti(ortak: ortak),
          const SizedBox(height: AppSpacing.xl),
          satirlarAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object hata, StackTrace _) => Text('Satırlar yüklenemedi: $hata'),
            data: (List<DefterSatiri> satirlar) {
              final List<DefterSatiri> sermaye =
                  satirlar.where((DefterSatiri s) => s.tur == SatirTuru.sermaye).toList();
              final List<DefterSatiri> odeme =
                  satirlar.where((DefterSatiri s) => s.tur == SatirTuru.odeme).toList();

              Future<void> satirKaydet(DefterSatiri satir) async {
                final DefterSatiri tamSatir = satir.copyWith(ortakId: ortak.id);
                if (tamSatir.id.isEmpty) {
                  await repo.satirEkle(tamSatir);
                } else {
                  await repo.satirGuncelle(tamSatir);
                }
              }

              Future<void> satirSil(String id) => repo.satirSil(id, ortak.id);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DefterTablosu(
                    tur: SatirTuru.sermaye,
                    satirlar: sermaye,
                    onSatirKaydet: satirKaydet,
                    onSatirSil: satirSil,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DefterTablosu(
                    tur: SatirTuru.odeme,
                    satirlar: odeme,
                    onSatirKaydet: satirKaydet,
                    onSatirSil: satirSil,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          if (ortak.aktif) _PasifYapButonu(ortak: ortak, repo: repo),
        ],
      ),
    );
  }
}

class _PasifYapButonu extends StatelessWidget {
  const _PasifYapButonu({required this.ortak, required this.repo});

  final Ortak ortak;
  final OrtakRepository repo;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(foregroundColor: renkler.error, side: BorderSide(color: renkler.error)),
      icon: const Icon(Icons.person_off_outlined, size: 18),
      label: const Text('Üyeliği Sona Erdir (Pasif Yap)'),
      onPressed: () async {
        final String? neden = await showDialog<String>(
          context: context,
          builder: (BuildContext dialogContext) => _PasifNedenDialogu(),
        );
        if (neden != null && neden.trim().isNotEmpty) {
          await repo.pasifYap(ortak.id, neden.trim());
        }
      },
    );
  }
}

class _PasifNedenDialogu extends StatefulWidget {
  @override
  State<_PasifNedenDialogu> createState() => _PasifNedenDialoguState();
}

class _PasifNedenDialoguState extends State<_PasifNedenDialogu> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Üyeliği Sona Erdir'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Kayıt silinmeyecek, sadece pasif olarak işaretlenecek '
            '(PLAN.md §10.1 — yasal saklama ihtimaline karşı).',
            style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Neden (ör. istifa, üyelikten çıkarma)'),
            autofocus: true,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Vazgeç')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Pasif Yap'),
        ),
      ],
    );
  }
}
