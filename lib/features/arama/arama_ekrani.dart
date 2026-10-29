import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/util/csv_guvenlik.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../data/repository/ortak_repository.dart';
import '../../domain/model/ortak.dart';
import '../ortak_detay/ortak_detay_ekrani.dart';
import '../rapor/pdf_rapor_disa_aktar.dart';
import 'arama_provider.dart';
import 'widget/arama_cubugu.dart';
import 'widget/filtre_paneli.dart';
import 'widget/ortak_kart.dart';

/// Ana ekran: arama + sonuç listesi.
///
/// ★ Responsive (PLAN.md §14): ≥900px'te ana-detay yan yana (arama solda,
/// seçili ortak sağda). Dar ekranda tam-ekran liste, seçince ayrı sayfaya
/// gidilir.
class AramaEkrani extends ConsumerStatefulWidget {
  const AramaEkrani({super.key});

  static const double _genisEkranEsigi = 900;

  @override
  ConsumerState<AramaEkrani> createState() => _AramaEkraniState();
}

class _AramaEkraniState extends ConsumerState<AramaEkrani> {
  Timer? _periyodikSenkron;
  bool _senkronSuruyor = false;

  @override
  void initState() {
    super.initState();
    // Windows ve mobilde arka planda her 20 saniyede bir bulut değişikliklerini çek
    _periyodikSenkron = Timer.periodic(const Duration(seconds: 20), (_) {
      _arkaPlanSenkron();
    });
  }

  @override
  void dispose() {
    _periyodikSenkron?.cancel();
    super.dispose();
  }

  Future<void> _arkaPlanSenkron() async {
    if (!mounted || _senkronSuruyor) return;
    try {
      await ref.read(ortakRepositoryProvider).tamSenkron();
    } catch (_) {}
  }

  Future<void> _manuelSenkron() async {
    if (_senkronSuruyor) return;
    setState(() => _senkronSuruyor = true);
    try {
      final (int yuklenen, int indirilen) =
          await ref.read(ortakRepositoryProvider).tamSenkron();
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final String mesaj = (yuklenen > 0 || indirilen > 0)
          ? 'Eşitleme tamamlandı: $yuklenen yerel değişiklik buluta aktarıldı, $indirilen bulut güncellemesi alındı.'
          : 'Veriler güncel — bulutla eşitlendi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mesaj),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Senkronizasyon hatası: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _senkronSuruyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(baslangicSenkronuProvider);

    final bool genisEkran = MediaQuery.sizeOf(context).width >= AramaEkrani._genisEkranEsigi;
    final bool cokDarEkran = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KON Üye Kayıt Defteri'),
        actions: <Widget>[
          if (!cokDarEkran) ...<Widget>[
            IconButton(
              onPressed: _senkronSuruyor ? null : _manuelSenkron,
              icon: _senkronSuruyor
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              tooltip: 'Bulutla Eşitle / Yenile',
            ),
            IconButton(
              onPressed: () async {
                final OrtakRepository repo = ref.read(ortakRepositoryProvider);
                final List<Ortak> tumu =
                    await repo.tumOrtaklariGetir(pasifleriDeGoster: true);
                if (!context.mounted) return;
                await PdfRaporDisaAktarici.calistir(
                  context,
                  ortaklar: tumu,
                  baslik: 'KOOPERATİF GENEL ORTAK / ÜYE KAYIT DEFTERİ LİSTESİ',
                );
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Tüm Üyelerin PDF Raporu',
            ),
            IconButton(
              onPressed: () => context.push('/ayarlar'),
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Ayarlar',
            ),
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
                onPressed: () async {
                  final dynamic yeniId = await context.push('/ortak/yeni');
                  if (yeniId is String && yeniId.isNotEmpty && mounted) {
                    ref.read(seciliOrtakIdProvider.notifier).sec(yeniId);
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni Ortak'),
              ),
            ),
          ] else ...<Widget>[
            IconButton(
              onPressed: _senkronSuruyor ? null : () => _manuelSenkron(),
              icon: _senkronSuruyor
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              tooltip: 'Bulutla Eşitle / Yenile',
            ),
            IconButton(
              onPressed: () => context.push('/ice-aktarma'),
              icon: const Icon(Icons.folder_open_outlined),
              tooltip: 'İçe Aktar',
            ),
            IconButton.filled(
              onPressed: () async {
                final dynamic yeniId = await context.push('/ortak/yeni');
                if (yeniId is String && yeniId.isNotEmpty && mounted && context.mounted) {
                  ref.read(seciliOrtakIdProvider.notifier).sec(yeniId);
                  await context.push('/ortak/$yeniId');
                }
              },
              icon: const Icon(Icons.add),
              tooltip: 'Yeni Ortak',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Diğer',
              onSelected: (String rota) async {
                if (rota == 'senkron') {
                  await _manuelSenkron();
                } else if (rota == 'pdf_rapor') {
                  final OrtakRepository repo = ref.read(ortakRepositoryProvider);
                  final List<Ortak> tumu =
                      await repo.tumOrtaklariGetir(pasifleriDeGoster: true);
                  if (mounted && context.mounted) {
                    await PdfRaporDisaAktarici.calistir(
                      context,
                      ortaklar: tumu,
                      baslik: 'KOOPERATİF GENEL ORTAK / ÜYE KAYIT DEFTERİ LİSTESİ',
                    );
                  }
                } else {
                  if (context.mounted) {
                    await context.push(rota);
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'senkron',
                  child: ListTile(
                    leading: Icon(Icons.sync, color: Colors.blueAccent),
                    title: Text('Bulutla Eşitle (Yenile)'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'pdf_rapor',
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent),
                    title: Text('PDF Raporu İndir'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: '/ayarlar',
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Ayarlar'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: '/yedek',
                  child: ListTile(
                    leading: Icon(Icons.backup_outlined),
                    title: Text('Yedekleme'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
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

  Future<void> _csvDisaAktar(BuildContext context, List<Ortak> ortaklar) async {
    if (ortaklar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dışa aktarılacak kayıt bulunamadı.')),
      );
      return;
    }

    try {
      final String dosyaAdi =
          'ortak_listesi_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';

      final DateFormat csvTarihFmt = DateFormat('dd.MM.yyyy');
      String tarihMetni(DateTime? tarih, String? ham) {
        if (tarih != null) return csvTarihFmt.format(tarih);
        if (ham != null && ham.trim().isNotEmpty) return ham.trim();
        return '';
      }

      final List<List<dynamic>> satirlar = <List<dynamic>>[
        <String>[
          'Ortak No',
          'Adı Soyadı',
          'TC Kimlik No',
          'Durum',
          'Sayfa No',
          'Baba Adı',
          'Doğum Yeri',
          'Doğum Tarihi',
          'Giriş Tarihi',
          'Çıkış Tarihi',
          'İkamet Adresi',
          'Nüfusa Kayıtlı Olduğu Yer',
          'Pasif Nedeni',
        ],
        for (final Ortak o in ortaklar)
          <dynamic>[
            csvFormulKorumasi(o.ortakNo),
            csvFormulKorumasi(o.adSoyad),
            csvFormulKorumasi(o.tcKimlikNo),
            o.aktif ? 'Aktif' : 'Pasif',
            csvFormulKorumasi(o.sayfaNo),
            csvFormulKorumasi(o.babaAdi),
            csvFormulKorumasi(o.dogumYeri),
            csvFormulKorumasi(tarihMetni(o.dogumTarihi, o.dogumTarihiHam)),
            csvFormulKorumasi(tarihMetni(o.girisTarihi, o.girisTarihiHam)),
            csvFormulKorumasi(tarihMetni(o.cikisTarihi, o.cikisTarihiHam)),
            csvFormulKorumasi(o.ikametAdresi),
            csvFormulKorumasi(o.nufusKayitYeri),
            csvFormulKorumasi(o.pasifNedeni),
          ],
      ];

      final String csvIcerik = '\uFEFF${const ListToCsvConverter().convert(satirlar)}';

      if (Platform.isAndroid || Platform.isIOS) {
        final Directory tempDir = await getTemporaryDirectory();
        final File hedefDosya = File('${tempDir.path}/$dosyaAdi');
        await hedefDosya.writeAsString(csvIcerik);

        await SharePlus.instance.share(
          ShareParams(
            files: <XFile>[XFile(hedefDosya.path, mimeType: 'text/csv', name: dosyaAdi)],
            text: 'KON Üye Kayıt Defteri Excel/CSV Dökümü',
            subject: dosyaAdi,
          ),
        );
        return;
      }

      final String? hedefDizin = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Excel/CSV Dosyasının Kaydedileceği Klasörü Seçin',
      );
      if (hedefDizin == null) return;

      final File hedefDosya = File('$hedefDizin/$dosyaAdi');
      await hedefDosya.writeAsString(csvIcerik);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel (CSV) dosyası kaydedildi:\n${hedefDosya.path}'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Aç',
              textColor: Colors.white,
              onPressed: () {
                if (Platform.isMacOS) {
                  unawaited(Process.run('open', <String>[hedefDosya.path]));
                } else if (Platform.isWindows) {
                  unawaited(Process.run('explorer.exe', <String>[hedefDosya.path]));
                } else if (Platform.isLinux) {
                  unawaited(Process.run('xdg-open', <String>[hedefDosya.path]));
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dışa aktarma hatası: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _pdfRaporDisaAktar(BuildContext context, List<Ortak> ortaklar) {
    final bool aramaVarMi = _controller.text.trim().isNotEmpty;
    PdfRaporDisaAktarici.secenekliRapor(
      context,
      ref,
      filtrelenmisOrtaklar: ortaklar,
      aramaVarMi: aramaVarMi,
    );
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

                final int toplamSayi = sonuclar.length;
                final int aktifSayi = sonuclar.where((Ortak o) => o.aktif).length;
                final int pasifSayi = toplamSayi - aktifSayi;

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.xs),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '$toplamSayi Ortak ($aktifSayi Aktif${pasifSayi > 0 ? ', $pasifSayi Pasif' : ''})',
                              style: AppTypography.caption.copyWith(
                                color: renkler.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Tooltip(
                            message: 'Ortak listesini PDF raporu olarak indir',
                            child: FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                              icon: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.redAccent),
                              label: const Text('PDF Raporu', style: TextStyle(fontSize: 12)),
                              onPressed: () => _pdfRaporDisaAktar(context, sonuclar),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Tooltip(
                            message: 'Listeyi Excel (CSV) olarak indir',
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              icon: const Icon(Icons.file_download_outlined, size: 16),
                              label: const Text('Excel/CSV', style: TextStyle(fontSize: 12)),
                              onPressed: () => _csvDisaAktar(context, sonuclar),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
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
                      ),
                    ),
                  ],
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
