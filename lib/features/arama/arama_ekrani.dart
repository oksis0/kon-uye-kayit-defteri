import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../data/repository/ortak_repository.dart';
import '../../domain/model/ortak.dart';
import '../ortak_detay/ortak_detay_ekrani.dart';
import 'arama_provider.dart';
import 'widget/arama_cubugu.dart';
import 'widget/filtre_paneli.dart';
import 'widget/ortak_kart.dart';

/// Ana ekran: arama + sonuç listesi.
///
/// ★ Responsive (PLAN.md §14): ≥900px'te ana-detay yan yana (arama solda,
/// seçili ortak sağda). Dar ekranda tam-ekran liste, seçince ayrı sayfaya
/// gidilir.
class AramaEkrani extends ConsumerWidget {
  const AramaEkrani({super.key});

  static const double _genisEkranEsigi = 900;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ★ Uygulama açılışında bir kerelik Firestore senkronu tetikler
    // (bulut yapılandırılmamışsa no-op — PLAN.md §2.5). Sonuç bilerek
    // yok sayılıyor: senkron arka planda beklenmeden ilerler, arama
    // ekranı zaten yerel Drift üzerinden çalışıyor.
    ref.watch(baslangicSenkronuProvider);

    final bool genisEkran = MediaQuery.sizeOf(context).width >= _genisEkranEsigi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ortak Pay Defteri'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push('/yedek'),
            icon: const Icon(Icons.backup_outlined),
            tooltip: 'Yedekleme',
          ),
          const SizedBox(width: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: OutlinedButton.icon(
              onPressed: () => context.push('/ice-aktarma'),
              icon: const Icon(Icons.folder_open_outlined, size: 18),
              label: const Text('İçe Aktar'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: () => context.push('/ortak/yeni'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Yeni Ortak'),
            ),
          ),
        ],
      ),
      body: genisEkran ? const _GenisDuzen() : const _DarDuzen(),
    );
  }
}

class _AramaVeListe extends ConsumerStatefulWidget {
  const _AramaVeListe({required this.onSecim, required this.seciliId});

  final ValueChanged<Ortak> onSecim;
  final String? seciliId;

  @override
  ConsumerState<_AramaVeListe> createState() => _AramaVeListeState();
}

class _AramaVeListeState extends ConsumerState<_AramaVeListe> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final AsyncValue<List<Ortak>> sonuclarAsync = ref.watch(aramaSonuclariProvider);
    final bool pasifleriDeGoster = ref.watch(pasifleriDeGosterProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AramaCubugu(
            controller: _controller,
            onDegisti: (String deger) =>
                ref.read(aramaSorgusuProvider.notifier).guncelle(deger),
          ),
          const SizedBox(height: AppSpacing.xs),
          FiltrePaneli(
            pasifleriDeGoster: pasifleriDeGoster,
            onDegisti: (bool deger) =>
                ref.read(pasifleriDeGosterProvider.notifier).degistir(deger),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: sonuclarAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object hata, StackTrace _) => Center(
                child: Text('Bir hata oluştu: $hata', style: AppTypography.body.copyWith(color: renkler.error)),
              ),
              data: (List<Ortak> sonuclar) {
                if (sonuclar.isEmpty) {
                  return Center(
                    child: Text(
                      'Sonuç bulunamadı.',
                      style: AppTypography.body.copyWith(color: renkler.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: sonuclar.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (BuildContext context, int index) {
                    final Ortak ortak = sonuclar[index];
                    return OrtakKart(
                      ortak: ortak,
                      secili: ortak.id == widget.seciliId,
                      onTap: () => widget.onSecim(ortak),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GenisDuzen extends ConsumerWidget {
  const _GenisDuzen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors renkler = context.renkler;
    final String? seciliId = ref.watch(seciliOrtakIdProvider);

    return Row(
      children: <Widget>[
        SizedBox(
          width: 380,
          child: _AramaVeListe(
            seciliId: seciliId,
            onSecim: (Ortak ortak) => ref.read(seciliOrtakIdProvider.notifier).sec(ortak.id),
          ),
        ),
        VerticalDivider(width: 1, color: renkler.border),
        Expanded(
          child: seciliId == null
              ? Center(
                  child: Text(
                    'Bir ortak seçin',
                    style: AppTypography.body.copyWith(color: renkler.textSecondary),
                  ),
                )
              : OrtakDetayEkrani(ortakId: seciliId, gomulu: true, key: ValueKey<String>(seciliId)),
        ),
      ],
    );
  }
}

class _DarDuzen extends StatelessWidget {
  const _DarDuzen();

  @override
  Widget build(BuildContext context) {
    return _AramaVeListe(
      seciliId: null,
      onSecim: (Ortak ortak) => context.push('/ortak/${ortak.id}'),
    );
  }
}
