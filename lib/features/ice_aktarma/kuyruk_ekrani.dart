import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/config/env.dart';
import '../../data/repository/kuyruk_repository.dart';
import '../../data/repository/ocr_repository.dart';
import '../../domain/enum/kuyruk_durumu.dart';
import '../../domain/model/ice_aktarma_isi.dart';
import '../../domain/model/ocr_sonucu.dart';
import '../ayarlar/widget/kota_gosterge.dart';
import '../ortak_detay/ortak_duzenle_ekrani.dart';
import 'kuyruk_provider.dart';
import 'widget/ilerleme_cubugu.dart';

/// İçe aktarma kuyruğu — masaüstünde klasör seç, mobilde kamera/galeriden
/// tek tek ekle; taranan dosyaları gör, her birini bir ortağa bağla
/// (PLAN.md §8, §6.2).
class KuyrukEkrani extends ConsumerStatefulWidget {
  const KuyrukEkrani({super.key});

  @override
  ConsumerState<KuyrukEkrani> createState() => _KuyrukEkraniState();
}

class _KuyrukEkraniState extends ConsumerState<KuyrukEkrani> {
  bool get _mobil => Platform.isAndroid || Platform.isIOS;
  int? _kotaKullanimi;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kuyrukIsleyiciProvider.notifier).hazirlamayaDevamEt();
      _kotayiGuncelle();
    });
  }

  Future<void> _kotayiGuncelle() async {
    if (!Env.bulutYapilandirmasiTamam) return;
    try {
      final int kullanim = await ref.read(ocrRepositoryProvider).kotaKullanimi();
      if (mounted) {
        setState(() {
          _kotaKullanimi = kullanim;
        });
      }
    } catch (_) {}
  }

  void _hataGoster(BuildContext context, String baslik, Object hata) {
    try {
      File('app_debug.log').writeAsStringSync(
        '[${DateTime.now().toIso8601String()}] [$baslik] $hata\n',
        mode: FileMode.append,
      );
    } catch (_) {}

    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: Text(baslik),
          content: SelectableText('$hata'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _klasorSec(BuildContext context) async {
    String? klasorYolu;
    try {
      klasorYolu = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Taranmış belgelerin bulunduğu klasörü seçin',
      );
    } catch (e) {
      if (context.mounted) {
        _hataGoster(context, 'Klasör Seçici Hatası', e);
      }
      return;
    }

    if (klasorYolu == null) return;

    try {
      await ref.read(kuyrukIsleyiciProvider.notifier).klasorSecVeIceAktar(klasorYolu);
      await _kotayiGuncelle();
    } catch (e) {
      if (context.mounted) {
        _hataGoster(context, 'İçe Aktarma Hatası', e);
      }
    }
  }

  Future<void> _dosyaSec(BuildContext context) async {
    FilePickerResult? sonuc;
    try {
      sonuc = await FilePicker.platform.pickFiles(
        dialogTitle: 'Taranmış belgeleri seçin',
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: <String>['jpg', 'jpeg', 'png'],
      );
    } catch (e) {
      if (context.mounted) {
        _hataGoster(context, 'Dosya Seçici Hatası', e);
      }
      return;
    }

    if (sonuc == null || sonuc.files.isEmpty) return;

    final List<String> yollar = sonuc.files
        .map((PlatformFile f) => f.path)
        .whereType<String>()
        .toList();
    if (yollar.isNotEmpty) {
      await ref.read(kuyrukIsleyiciProvider.notifier).dosyalariEkleVeIsle(yollar);
      await _kotayiGuncelle();
    }
  }

  /// PLAN.md §6.2 — mobilde `image_picker` ile kamera/galeri.
  Future<void> _mobildenEkle(BuildContext context, ImageSource kaynak) async {
    XFile? dosya;
    try {
      dosya = await ImagePicker().pickImage(source: kaynak);
    } catch (e) {
      if (context.mounted) {
        _hataGoster(context, 'Görsel Seçici Hatası', e);
      }
      return;
    }

    if (dosya == null) return;

    try {
      await ref.read(kuyrukIsleyiciProvider.notifier).tekDosyaEkleVeIsle(dosya.path);
      await _kotayiGuncelle();
    } catch (e) {
      if (context.mounted) {
        _hataGoster(context, 'Görsel Ekleme Hatası', e);
      }
    }
  }

  Future<void> _kuyruguTemizleOnayi(BuildContext context) async {
    final bool? onay = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Kuyruğu Temizle'),
        content: const Text(
          'Kuyruktaki tüm belgeler temizlenecektir. Emin misiniz?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (onay == true) {
      await ref.read(kuyrukRepositoryProvider).kuyruguTemizle();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kuyruk temizlendi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final KuyrukIlerlemeDurumu ilerleme = ref.watch(kuyrukIsleyiciProvider);
    final AsyncValue<List<IceAktarmaIsi>> listeAsync = ref.watch(kuyrukListesiProvider);

    ref.listen(kuyrukIsleyiciProvider, (previous, next) {
      if (previous?.calisiyorMu == true && next.calisiyorMu == false) {
        _kotayiGuncelle();
      }
    });

    final bool temizlemeEtkin = listeAsync.maybeWhen(
      data: (List<IceAktarmaIsi> isler) => isler.isNotEmpty && !ilerleme.calisiyorMu,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('İçe Aktarma Kuyruğu'),
        actions: _mobil
            ? <Widget>[
                if (temizlemeEtkin)
                  IconButton(
                    onPressed: () => _kuyruguTemizleOnayi(context),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Kuyruğu Temizle',
                  ),
                IconButton(
                  onPressed: ilerleme.calisiyorMu
                      ? null
                      : () => ref.read(kuyrukIsleyiciProvider.notifier).ocrOlmayanlariIsle(),
                  icon: const Icon(Icons.document_scanner_outlined),
                  tooltip: 'Eksik Belgeleri OCR ile Tara',
                ),
                IconButton(
                  onPressed: ilerleme.calisiyorMu
                      ? null
                      : () => _mobildenEkle(context, ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  tooltip: 'Kameradan Çek',
                ),
                IconButton(
                  onPressed: ilerleme.calisiyorMu
                      ? null
                      : () => _mobildenEkle(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  tooltip: 'Galeriden Seç',
                ),
                const SizedBox(width: AppSpacing.sm),
              ]
            : <Widget>[
                if (temizlemeEtkin)
                  IconButton(
                    onPressed: () => _kuyruguTemizleOnayi(context),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Kuyruğu Temizle',
                  ),
                IconButton(
                  onPressed: ilerleme.calisiyorMu
                      ? null
                      : () => ref.read(kuyrukIsleyiciProvider.notifier).ocrOlmayanlariIsle(),
                  icon: const Icon(Icons.document_scanner_outlined),
                  tooltip: 'Eksik Belgeleri OCR ile Tara',
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: OutlinedButton.icon(
                    onPressed: ilerleme.calisiyorMu ? null : () => _dosyaSec(context),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Dosya Seç'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: FilledButton.icon(
                    onPressed: ilerleme.calisiyorMu ? null : () => _klasorSec(context),
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
            if (Env.bulutYapilandirmasiTamam) ...<Widget>[
              KotaGosterge(kullanim: _kotaKullanimi ?? 0),
              const SizedBox(height: AppSpacing.md),
            ],
            if (ilerleme.calisiyorMu || ilerleme.toplam > 0 || ilerleme.sonHata != null) ...<Widget>[
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
                        _mobil
                            ? 'Kuyruk boş. Sağ üstten kamera veya galeri ile başlayın.'
                            : 'Kuyruk boş. Sağ üstten bir klasör seçerek başlayın.',
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final List<Widget> eylemler = _eylemler(context, ref);
        final bool dar = constraints.maxWidth < 500 && eylemler.isNotEmpty;

        if (dar) {
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
                    _DurumRozeti(durum: is_.durum),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            is_.dosyaAdi,
                            style: AppTypography.bodyVurgulu.copyWith(color: renkler.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (is_.durum == KuyrukDurumu.tamamlandi && is_.olusanOrtakId != null)
                            Text(
                              'Zaten Kayıtlı Üye • İncelenmeden Otomatik Tamamlandı',
                              style: AppTypography.caption.copyWith(color: renkler.success),
                            )
                          else if (is_.hataMesaji != null)
                            Text(
                              is_.hataMesaji!,
                              style: AppTypography.caption.copyWith(color: renkler.error),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: eylemler,
                ),
              ],
            ),
          );
        }

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
                    if (is_.durum == KuyrukDurumu.tamamlandi && is_.olusanOrtakId != null)
                      Text(
                        'Zaten Kayıtlı Üye • İncelenmeden Otomatik Tamamlandı',
                        style: AppTypography.caption.copyWith(color: renkler.success),
                      )
                    else if (is_.hataMesaji != null)
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
              ...eylemler,
            ],
          ),
        );
      },
    );
  }

  Future<void> _formaGit(BuildContext context, WidgetRef ref) async {
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
  }

  List<Widget> _eylemler(BuildContext context, WidgetRef ref) {
    switch (is_.durum) {
      case KuyrukDurumu.onayBekliyor:
        final bool ocrVar = is_.ocrHamJson != null;
        return <Widget>[
          TextButton(
            onPressed: () => ref.read(kuyrukRepositoryProvider).atla(is_.id),
            child: const Text('Atla'),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (!ocrVar) ...<Widget>[
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(kuyrukIsleyiciProvider.notifier).tekIsiOcrYap(is_.id),
              icon: const Icon(Icons.document_scanner, size: 16),
              label: const Text('OCR ile Tara'),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.tonal(
              onPressed: () => _formaGit(context, ref),
              child: const Text('Elle Doldur'),
            ),
          ] else ...<Widget>[
            FilledButton.icon(
              onPressed: () => _formaGit(context, ref),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('İncele ve Onayla'),
            ),
          ],
        ];
      case KuyrukDurumu.hata:
        return <Widget>[
          OutlinedButton(
            onPressed: () => ref.read(kuyrukRepositoryProvider).yenidenDene(is_.id),
            child: const Text('Yeniden Dene'),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () =>
                ref.read(kuyrukIsleyiciProvider.notifier).tekIsiOcrYap(is_.id),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('OCR Başlat'),
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