import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../data/repository/kuyruk_repository.dart';
import '../../data/repository/ocr_repository.dart';
import '../../domain/enum/kuyruk_durumu.dart';
import '../../domain/model/ice_aktarma_isi.dart';
import '../../domain/model/ocr_sonucu.dart';
import '../ortak_detay/ortak_duzenle_ekrani.dart';
import 'kuyruk_provider.dart';
import 'widget/ilerleme_cubugu.dart';

/// İçe aktarma kuyruğu — klasör seç, taranan dosyaları gör, her birini
/// bir ortağa bağla (PLAN.md §8).
///
/// ★ Faz 2 kapsamı: OCR YOK. Kuyruk sadece görsel hazırlar; kullanıcı
/// "Ortak Ekle" ile formu elle doldurur (görsel yanında önizlenir).
class KuyrukEkrani extends ConsumerWidget {
  const KuyrukEkrani({super.key});

  Future<void> _klasorSec(BuildContext context, WidgetRef ref) async {
    final String? klasorYolu = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Taranmış belgelerin bulunduğu klasörü seçin',
    );
    if (klasorYolu == null) return;
    await ref.read(kuyrukIsleyiciProvider.notifier).klasorSecVeIceAktar(klasorYolu);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors renkler = context.renkler;
    final KuyrukIlerlemeDurumu ilerleme = ref.watch(kuyrukIsleyiciProvider);
    final AsyncValue<List<IceAktarmaIsi>> listeAsync = ref.watch(kuyrukListesiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İçe Aktarma Kuyruğu'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: ilerleme.calisiyorMu ? null : () => _klasorSec(context, ref),
              icon: const Icon(Icons.folder_open_outlined, size: 18),
              label: const Text('Klasör Seç'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (ilerleme.calisiyorMu || ilerleme.toplam > 0) ...<Widget>[
              IlerlemeCubugu(durum: ilerleme),
              const SizedBox(height: AppSpacing.md),
            ],
            Expanded(
              child: listeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object hata, StackTrace _) => Center(child: Text('Hata: $hata')),
                data: (List<IceAktarmaIsi> isler) {
                  if (isler.isEmpty) {
                    return Center(
                      child: Text(
                        'Kuyruk boş. Sağ üstten bir klasör seçerek başlayın.',
                        style: AppTypography.body.copyWith(color: renkler.textSecondary),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: isler.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (BuildContext context, int index) {
                      return _KuyrukSatiri(is_: isler[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KuyrukSatiri extends ConsumerWidget {
  const _KuyrukSatiri({required this.is_});

  final IceAktarmaIsi is_;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors renkler = context.renkler;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: renkler.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renkler.border),
      ),
      child: Row(
        children: <Widget>[
          _DurumRozeti(durum: is_.durum),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  is_.dosyaAdi,
                  style: AppTypography.bodyVurgulu.copyWith(color: renkler.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                if (is_.hataMesaji != null)
                  Text(
                    is_.hataMesaji!,
                    style: AppTypography.caption.copyWith(color: renkler.error),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ..._eylemler(context, ref),
        ],
      ),
    );
  }

  List<Widget> _eylemler(BuildContext context, WidgetRef ref) {
    switch (is_.durum) {
      case KuyrukDurumu.onayBekliyor:
        return <Widget>[
          TextButton(
            onPressed: () => ref.read(kuyrukRepositoryProvider).atla(is_.id),
            child: const Text('Atla'),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () async {
              // ★ ocrHamJson doluysa (bulut yapılandırılmışsa) burada
              // ayrıştırılır — form OCR sonuçlarıyla ön-dolu açılır.
              // Boşsa (Faz 1-2 elle akışı) tamamen boş form açılır.
              final OcrSonucu? ocrSonucu = is_.ocrHamJson != null
                  ? ref.read(ocrRepositoryProvider).hamJsondanAyristir(is_.ocrHamJson!)
                  : null;

              await context.push<String>(
                '/ortak/yeni',
                extra: OrtakYeniParametreleri(
                  iceAktarmaIsiId: is_.id,
                  onizlemeGorselYolu: is_.dosyaYolu,
                  ocrSonucu: ocrSonucu,
                ),
              );
            },
            child: const Text('Ortak Ekle'),
          ),
        ];
      case KuyrukDurumu.hata:
        return <Widget>[
          OutlinedButton(
            onPressed: () => ref.read(kuyrukRepositoryProvider).yenidenDene(is_.id),
            child: const Text('Yeniden Dene'),
          ),
        ];
      case KuyrukDurumu.tamamlandi:
        return <Widget>[
          if (is_.olusanOrtakId != null)
            TextButton(
              onPressed: () => context.push('/ortak/${is_.olusanOrtakId}'),
              child: const Text('Kaydı Gör'),
            ),
        ];
      case KuyrukDurumu.bekliyor:
      case KuyrukDurumu.hazirlaniyor:
      case KuyrukDurumu.ocrYapiliyor:
      case KuyrukDurumu.atlandi:
        return const <Widget>[];
    }
  }
}

class _DurumRozeti extends StatelessWidget {
  const _DurumRozeti({required this.durum});

  final KuyrukDurumu durum;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final (Color renk, IconData ikon) = switch (durum) {
      KuyrukDurumu.bekliyor => (renkler.textSecondary, Icons.schedule),
      KuyrukDurumu.hazirlaniyor => (renkler.accent, Icons.autorenew),
      KuyrukDurumu.ocrYapiliyor => (renkler.accent, Icons.document_scanner_outlined),
      KuyrukDurumu.onayBekliyor => (renkler.warning, Icons.edit_note),
      KuyrukDurumu.tamamlandi => (renkler.success, Icons.check_circle_outline),
      KuyrukDurumu.hata => (renkler.error, Icons.error_outline),
      KuyrukDurumu.atlandi => (renkler.textSecondary, Icons.block),
    };

    return Tooltip(
      message: durum.etiket,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(ikon, size: 18, color: renk),
      ),
    );
  }
}
