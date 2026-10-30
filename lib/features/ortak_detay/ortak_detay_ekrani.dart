import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../data/repository/ortak_repository.dart';
import '../../domain/enum/satir_turu.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ortak.dart';
import 'ortak_detay_provider.dart';
import 'widget/belge_goruntuleyici_dialog.dart';
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
          if (ortakAsync.value != null) ...<Widget>[
            if (!ortakAsync.value!.aktif)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.renkler.success,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.how_to_reg, size: 16),
                  label: const Text('Aktif Et'),
                  onPressed: () => aktifEtOnayli(
                    context: context,
                    repo: ref.read(ortakRepositoryProvider),
                    ortak: ortakAsync.value!,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              tooltip: 'Taranmış Belgeyi Gör',
              onPressed: () => BelgeGoruntuleyiciDialog.goster(context, ortak: ortakAsync.value!),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Düzenle',
              onPressed: () => context.push('/ortak/$ortakId/duzenle'),
            ),
          ],
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: KimlikBilgiKarti(
                  ortak: ortak,
                  onAktifEt: () => aktifEtOnayli(
                    context: context,
                    repo: repo,
                    ortak: ortak,
                  ),
                ),
              ),
              _DahaFazlaMenusu(ortak: ortak, repo: repo),
            ],
          ),
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
          IslemButonlari(ortak: ortak, repo: repo),
        ],
      ),
    );
  }
}

/// "⋯" menüsü — PLAN.md §10.2: kalıcı silme YANLIŞLIKLA tıklanamayacak
/// şekilde bilinçli olarak bir menünün içinde, ayrı bir buton değil.
class _DahaFazlaMenusu extends StatelessWidget {
  const _DahaFazlaMenusu({required this.ortak, required this.repo});

  final Ortak ortak;
  final OrtakRepository repo;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          onTap: () async {
            await Future<void>.delayed(Duration.zero);
            if (context.mounted) {
              unawaited(kaliciSilOnayli(context: context, repo: repo, ortak: ortak));
            }
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.delete_forever_outlined, size: 18, color: context.renkler.error),
              const SizedBox(width: AppSpacing.sm),
              Text('Kalıcı Sil', style: TextStyle(color: context.renkler.error)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bir ortağı çift onaylı diyalog ve işlem göstergesiyle kalıcı olarak siler.
Future<void> kaliciSilOnayli({
  required BuildContext context,
  required OrtakRepository repo,
  required Ortak ortak,
}) async {
  final bool? onaylandi = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => _KaliciSilDialogu(ortak: ortak),
  );
  if (onaylandi != true || !context.mounted) return;

  // Silme işlemi sürerken kullanıcıyı bilgilendiren modal gösterge
  unawaited(showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => PopScope(
      canPop: false,
      child: Center(
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${ortak.adSoyad} siliniyor...',
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Bulut ve yerel kayıtlar temizleniyor',
                  style: AppTypography.caption.copyWith(color: context.renkler.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ));

  try {
    await repo.kaliciSil(ortak.id);
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Progress dialog kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ortak.adSoyad} (No: ${ortak.ortakNo}) kalıcı olarak silindi.'),
          backgroundColor: context.renkler.success,
        ),
      );
      Navigator.of(context).maybePop(); // Detay ekranından çık
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Progress dialog kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silme işlemi sırasında hata: $e'),
          backgroundColor: context.renkler.error,
        ),
      );
    }
  }
}

class _KaliciSilDialogu extends StatefulWidget {
  const _KaliciSilDialogu({required this.ortak});
  final Ortak ortak;

  @override
  State<_KaliciSilDialogu> createState() => _KaliciSilDialoguState();
}

class _KaliciSilDialoguState extends State<_KaliciSilDialogu> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _onayliMi => _controller.text.trim() == widget.ortak.ortakNo;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    return AlertDialog(
      title: const Text('Kalıcı olarak sil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '"${widget.ortak.adSoyad}" (Ortak No: ${widget.ortak.ortakNo}) kalıcı olarak '
            'silinecek: görsel, bulut kaydı ve yerel kayıt sırayla silinir. '
            'Bu işlem GERİ ALINAMAZ.',
            style: AppTypography.body.copyWith(color: renkler.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Onaylamak için Ortak No\'yu yazın: ${widget.ortak.ortakNo}',
            style: AppTypography.caption.copyWith(color: renkler.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (String _) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Ortak No'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: renkler.error),
          onPressed: _onayliMi ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Kalıcı Sil'),
        ),
      ],
    );
  }
}

class IslemButonlari extends StatelessWidget {
  const IslemButonlari({required this.ortak, this.repo, super.key});

  final Ortak ortak;
  final OrtakRepository? repo;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        // Pasif / Aktif Butonu (Sarı/Amber)
        if (ortak.aktif)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: renkler.warning,
              side: BorderSide(color: renkler.warning),
            ),
            icon: const Icon(Icons.person_off_outlined, size: 18),
            label: const Text('Üyeliği Sona Erdir (Pasif Yap)'),
            onPressed: () async {
              final String? neden = await showDialog<String>(
                context: context,
                builder: (BuildContext dialogContext) => _PasifNedenDialogu(),
              );
              if (neden != null && neden.trim().isNotEmpty) {
                await repo?.pasifYap(ortak.id, neden.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${ortak.adSoyad} pasif duruma getirildi ve buluta aktarıldı.'),
                      backgroundColor: renkler.warning,
                    ),
                  );
                }
              }
            },
          )
        else
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: renkler.success,
              side: BorderSide(color: renkler.success),
            ),
            icon: const Icon(Icons.how_to_reg_outlined, size: 18),
            label: const Text('Ortağı Yeniden Aktif Yap'),
            onPressed: () {
              if (repo != null) {
                unawaited(aktifEtOnayli(context: context, repo: repo!, ortak: ortak));
              }
            },
          ),

        // Kalıcı Sil Butonu (Kırmızı)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: renkler.error,
            side: BorderSide(color: renkler.error),
          ),
          icon: const Icon(Icons.delete_forever_outlined, size: 18),
          label: const Text('Ortağı Kalıcı Sil'),
          onPressed: () {
            if (repo != null) {
              unawaited(kaliciSilOnayli(context: context, repo: repo!, ortak: ortak));
            }
          },
        ),
      ],
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

/// Pasif durumdaki bir ortağı onay alarak yeniden aktif yapar.
Future<void> aktifEtOnayli({
  required BuildContext context,
  required OrtakRepository repo,
  required Ortak ortak,
}) async {
  final bool? onaylandi = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Ortağı Aktif Et'),
      content: Text(
        '"${ortak.adSoyad}" (Ortak No: ${ortak.ortakNo}) yeniden aktif üye '
        'durumuna getirilecek. Onaylıyor musunuz?',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.renkler.success,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Aktif Et'),
        ),
      ],
    ),
  );

  if (onaylandi == true && context.mounted) {
    await repo.aktifYap(ortak.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ortak.adSoyad} başarıyla aktif duruma getirildi.'),
          backgroundColor: context.renkler.success,
        ),
      );
    }
  }
}
