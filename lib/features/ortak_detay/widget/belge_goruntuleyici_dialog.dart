import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/config/env.dart';
import '../../../data/goruntu/goruntu_hazirlayici.dart';
import '../../../data/repository/belge_repository.dart';
import '../../../data/repository/kuyruk_repository.dart';
import '../../../data/repository/ortak_repository.dart';
import '../../../domain/model/ortak.dart';

/// Ortağın taranmış orijinal belgesini (yerel dosya veya R2'den indirerek)
/// gösteren diyalog.
class BelgeGoruntuleyiciDialog extends ConsumerStatefulWidget {
  const BelgeGoruntuleyiciDialog({
    required this.ortak,
    this.yerelDosyaYolu,
    super.key,
  });

  final Ortak ortak;
  final String? yerelDosyaYolu;

  static Future<void> goster(
    BuildContext context, {
    required Ortak ortak,
    String? yerelDosyaYolu,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => BelgeGoruntuleyiciDialog(
        ortak: ortak,
        yerelDosyaYolu: yerelDosyaYolu ?? ortak.yerelDosyaYolu,
      ),
    );
  }

  @override
  ConsumerState<BelgeGoruntuleyiciDialog> createState() => _BelgeGoruntuleyiciDialogState();
}

class _BelgeGoruntuleyiciDialogState extends ConsumerState<BelgeGoruntuleyiciDialog> {
  bool _yukleniyor = true;
  bool _bulutaYukleniyor = false;
  String? _hata;
  File? _yerelDosya;
  Uint8List? _r2Verisi;
  final TransformationController _transformController = TransformationController();
  int _dondurmeSayisi = 0;

  void _dondur() {
    setState(() {
      _dondurmeSayisi = (_dondurmeSayisi + 1) % 4;
    });
  }

  @override
  void initState() {
    super.initState();
    _belgeyiYukle();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _arkaPlandaBulutaYukle(String dosyaYolu) {
    if (!Env.bulutYapilandirmasiTamam || _bulutaYukleniyor) return;
    setState(() {
      _bulutaYukleniyor = true;
    });

    Future<void>.microtask(() async {
      try {
        final HazirlanmisGorsel hazir = await GoruntuHazirlayici().hazirla(dosyaYolu);
        final BelgeRepository belgeRepo = ref.read(belgeRepositoryProvider);
        final String anahtar = belgeRepo.anahtarUret(widget.ortak.id);
        await belgeRepo.yukle(anahtar, hazir.veriler);

        final Ortak guncel = widget.ortak.copyWith(
          belgeR2Anahtari: anahtar,
          yerelDosyaYolu: dosyaYolu,
          guncellemeTarihi: DateTime.now(),
        );
        await ref.read(ortakRepositoryProvider).guncelle(guncel);
        if (mounted) {
          setState(() {
            _bulutaYukleniyor = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _bulutaYukleniyor = false;
          });
        }
      }
    });
  }

  Future<void> _belgeyiYukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      // 1) widget.yerelDosyaYolu veya widget.ortak.yerelDosyaYolu kontrol et
      final String? dogrudanYol = widget.yerelDosyaYolu ?? widget.ortak.yerelDosyaYolu;
      if (dogrudanYol != null && dogrudanYol.isNotEmpty) {
        final File dosya = File(dogrudanYol);
        if (await dosya.exists()) {
          // Yerel dosya varsa ama R2 bulutunda henüz yoksa arka planda sunucuya da yükle
          if (widget.ortak.belgeR2Anahtari == null && Env.bulutYapilandirmasiTamam) {
            _arkaPlandaBulutaYukle(dosya.path);
          }

          if (mounted) {
            setState(() {
              _yerelDosya = dosya;
              _yukleniyor = false;
            });
          }
          return;
        }
      }

      // 2) Kuyruk tablosundan ortağın oluşturulduğu dosya yoluna bak
      final KuyrukRepository kuyrukRepo = ref.read(kuyrukRepositoryProvider);
      final String? kayitliYol = await kuyrukRepo.ortaginDosyaYolunuBul(widget.ortak.id);
      if (kayitliYol != null && kayitliYol.isNotEmpty) {
        final File dosya = File(kayitliYol);
        if (await dosya.exists()) {
          if (widget.ortak.belgeR2Anahtari == null && Env.bulutYapilandirmasiTamam) {
            _arkaPlandaBulutaYukle(dosya.path);
          }

          // Ortak nesnesine de bu yolu kaydedelim ki bir sonraki seferde doğrudan açılsın
          if (widget.ortak.yerelDosyaYolu == null) {
            try {
              final OrtakRepository ortakRepo = ref.read(ortakRepositoryProvider);
              await ortakRepo.guncelle(widget.ortak.copyWith(yerelDosyaYolu: kayitliYol));
            } catch (_) {}
          }

          if (mounted) {
            setState(() {
              _yerelDosya = dosya;
              _yukleniyor = false;
            });
          }
          return;
        }
      }

      // 3) Bulutta R2 anahtarı varsa R2'den indir (Telefonda açıldığında)
      if (Env.bulutYapilandirmasiTamam && widget.ortak.belgeR2Anahtari != null) {
        final BelgeRepository belgeRepo = ref.read(belgeRepositoryProvider);
        final Uint8List veri = await belgeRepo.indir(widget.ortak.belgeR2Anahtari!);
        if (veri.isNotEmpty) {
          if (mounted) {
            setState(() {
              _r2Verisi = veri;
              _yukleniyor = false;
            });
          }
          return;
        }
      }

      // Hiçbir yerde bulunamadı
      if (mounted) {
        setState(() {
          _yukleniyor = false;
          _hata = widget.ortak.belgeR2Anahtari == null
              ? 'Bu belge henüz sunucuya (buluta) yüklenmemiş.\n'
                'Belgenin tarandığı bilgisayardan uygulamayı açtığınızda belge otomatik olarak sunucuya aktarılacaktır.'
              : 'Sunucudaki belgeye erişilemedi.\n'
                'Lütfen internet bağlantınızı veya giriş durumunuzu kontrol edin.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _yukleniyor = false;
          _hata = 'Belge yüklenirken bir hata oluştu: $e';
        });
      }
    }
  }

  /// Dosyayı varsayılan uygulamada açar.
  /// [bytes] verildiğinde önce sistem geçici dizinine yazar, sonra açar.
  Future<void> _hariciUygulamadaAc(String dosyaYolu, {Uint8List? bytes}) async {
    String hedefYol = dosyaYolu;
    if (bytes != null) {
      // R2'den gelen veriyi geçici dosyaya yaz
      final Directory tempDir = Directory.systemTemp;
      final String uzanti = dosyaYolu.toLowerCase().endsWith('.pdf') ? '.pdf' : '.jpg';
      final File tempDosya = File(
        '${tempDir.path}/belge_preview_${DateTime.now().millisecondsSinceEpoch}$uzanti',
      );
      await tempDosya.writeAsBytes(bytes);
      hedefYol = tempDosya.path;
    }
    if (Platform.isMacOS) {
      unawaited(Process.run('open', <String>[hedefYol]));
    } else if (Platform.isWindows) {
      unawaited(Process.run('explorer.exe', <String>[hedefYol]));
    } else if (Platform.isLinux) {
      unawaited(Process.run('xdg-open', <String>[hedefYol]));
    }
  }

  void _zoom(double factor) {
    final Matrix4 current = _transformController.value;
    final double currentScale = current.getMaxScaleOnAxis();
    final double targetScale = (currentScale * factor).clamp(0.5, 8.0);
    final double effectiveFactor = targetScale / currentScale;

    final Matrix4 next = current.clone()..scaleByDouble(effectiveFactor, effectiveFactor, 1.0, 1.0);
    _transformController.value = next;
  }

  void _sifirla() {
    _transformController.value = Matrix4.identity();
    setState(() {
      _dondurmeSayisi = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final Size screenSize = MediaQuery.of(context).size;
    final bool mobilde = screenSize.width < 650;

    return Dialog(
      backgroundColor: renkler.surfaceContainer,
      insetPadding: mobilde
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: renkler.border),
      ),
      child: SizedBox(
        width: mobilde ? screenSize.width : screenSize.width * 0.9,
        height: mobilde ? screenSize.height : screenSize.height * 0.88,
        child: Column(
          children: <Widget>[
            // Başlık Çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  Icon(Icons.document_scanner, color: renkler.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Taranmış Belge — ${widget.ortak.adSoyad}',
                          style: AppTypography.headline.copyWith(
                            fontSize: 16,
                            color: renkler.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Ortak No: ${widget.ortak.ortakNo}'
                          '${widget.ortak.sayfaNo != null ? ' • Sayfa: ${widget.ortak.sayfaNo}' : ''}'
                          '${widget.ortak.tcKimlikNo != null ? ' • TC: ${widget.ortak.tcKimlikNo}' : ''}',
                          style: AppTypography.caption.copyWith(color: renkler.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: (widget.ortak.belgeR2Anahtari != null || _r2Verisi != null)
                        ? 'Sunucuda Aktif (Telefonda Görünür)'
                        : (_bulutaYukleniyor ? 'Sunucuya Yükleniyor...' : 'Sadece Yerel'),
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (widget.ortak.belgeR2Anahtari != null || _r2Verisi != null)
                            ? renkler.success.withValues(alpha: 0.15)
                            : (_bulutaYukleniyor
                                ? renkler.accent.withValues(alpha: 0.15)
                                : renkler.warning.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (widget.ortak.belgeR2Anahtari != null || _r2Verisi != null)
                              ? renkler.success.withValues(alpha: 0.4)
                              : (_bulutaYukleniyor
                                  ? renkler.accent.withValues(alpha: 0.4)
                                  : renkler.warning.withValues(alpha: 0.4)),
                        ),
                      ),
                      child: Icon(
                        (widget.ortak.belgeR2Anahtari != null || _r2Verisi != null)
                            ? Icons.cloud_done
                            : (_bulutaYukleniyor ? Icons.cloud_upload : Icons.cloud_queue),
                        size: 18,
                        color: (widget.ortak.belgeR2Anahtari != null || _r2Verisi != null)
                            ? renkler.success
                            : (_bulutaYukleniyor ? renkler.accent : renkler.warning),
                      ),
                    ),
                  ),
                  if (_yerelDosya != null || _r2Verisi != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: mobilde
                          ? IconButton(
                              icon: const Icon(Icons.open_in_new, size: 20),
                              tooltip: 'Varsayılan Uygulamada Aç',
                              onPressed: () => _hariciUygulamadaAc(
                                _yerelDosya?.path ?? 'r2_belge',
                                bytes: _yerelDosya == null ? _r2Verisi : null,
                              ),
                            )
                          : OutlinedButton.icon(
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Varsayılan Uygulamada Aç'),
                              onPressed: () => _hariciUygulamadaAc(
                                _yerelDosya?.path ?? 'r2_belge',
                                bytes: _yerelDosya == null ? _r2Verisi : null,
                              ),
                            ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Kapat',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // İçerik Alanı
            Expanded(
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                child: _icerikOlustur(renkler),
              ),
            ),

            // Alt Çubuk (İşlemler ve Yakınlaştırma Araçları)
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                children: <Widget>[
                  if (!mobilde)
                    Expanded(
                      child: Text(
                        'İpucu: Fare tekerleğiyle yakınlaştırabilir veya düğmeleri kullanabilirsiniz.',
                        style: AppTypography.caption.copyWith(color: renkler.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.zoom_out, size: 20),
                    tooltip: 'Uzaklaştır',
                    onPressed: () => _zoom(0.8),
                  ),
                  Tooltip(
                    message: 'Orijinal boyuta ve yöne dön',
                    child: TextButton(
                      onPressed: _sifirla,
                      child: const Text('%100'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, size: 20),
                    tooltip: 'Yakınlaştır',
                    onPressed: () => _zoom(1.25),
                  ),
                  IconButton(
                    icon: const Icon(Icons.rotate_right, size: 20),
                    tooltip: '90° Sağa Döndür',
                    onPressed: _dondur,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kapat'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icerikOlustur(AppColors renkler) {
    if (_yukleniyor) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text('Belge yükleniyor...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_hata != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.info_outline, size: 48, color: renkler.warning),
              const SizedBox(height: AppSpacing.md),
              Text(
                _hata!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    // PDF dosyası ise
    final String? dosyaYolu = _yerelDosya?.path.toLowerCase();
    final bool pdfMi = dosyaYolu != null && dosyaYolu.endsWith('.pdf');
    if (pdfMi) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.picture_as_pdf, size: 64, color: Colors.redAccent),
            const SizedBox(height: AppSpacing.md),
            Text(
              _yerelDosya!.path.split(Platform.pathSeparator).last,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'PDF belgeleri sistemin yerleşik görüntüleyicisinde açılır.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Önizleme / PDF Okuyucuda Aç'),
              onPressed: () => _hariciUygulamadaAc(_yerelDosya!.path),
            ),
          ],
        ),
      );
    }

    // Görsel ise InteractiveViewer ile göster
    Widget gorsel;
    if (_yerelDosya != null) {
      gorsel = Image.file(
        _yerelDosya!,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Center(
          child: Text('Görsel yüklenemedi', style: TextStyle(color: Colors.white70)),
        ),
      );
    } else if (_r2Verisi != null) {
      gorsel = Image.memory(
        _r2Verisi!,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Center(
          child: Text('Bulut görseli yüklenemedi', style: TextStyle(color: Colors.white70)),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: InteractiveViewer(
        transformationController: _transformController,
        clipBehavior: Clip.hardEdge,
        minScale: 0.5,
        maxScale: 8.0,
        boundaryMargin: EdgeInsets.zero,
        child: Center(
          child: RotatedBox(
            quarterTurns: _dondurmeSayisi,
            child: gorsel,
          ),
        ),
      ),
    );
  }
}
