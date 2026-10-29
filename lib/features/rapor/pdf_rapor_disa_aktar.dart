import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/rapor/uye_listesi_pdf_servisi.dart';
import '../../data/repository/ortak_repository.dart';
import '../../domain/model/ortak.dart';

/// PDF Raporunu dışa aktarma ve kullanıcıya sunma yardımcısı.
class PdfRaporDisaAktarici {
  const PdfRaporDisaAktarici._();

  /// Verilen ortaklar listesini PDF raporu olarak derleyip kullanıcının seçeceği
  /// klasöre kaydeder ve açma kısayolu sunar.
  static Future<void> calistir(
    BuildContext context, {
    required List<Ortak> ortaklar,
    String? baslik,
    String? altAciklama,
  }) async {
    if (ortaklar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dışa aktarılacak ortak kaydı bulunamadı.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Kullanıcıya işlem başladığını bildir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: <Widget>[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('PDF raporu hazırlanıyor...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // 1. PDF dokümanını üret
      const UyeListesiPdfServisi servis = UyeListesiPdfServisi();
      final List<int> pdfBytes = await servis.raporOlustur(
        ortaklar: ortaklar,
        baslik: baslik ?? 'KOOPERATİF ORTAK / ÜYE KAYIT DEFTERİ LİSTESİ',
        altAciklama: altAciklama,
      );

      final String zamanDamgasi = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String dosyaAdi = 'ortak_listesi_raporu_$zamanDamgasi.pdf';

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobilde: Geçici dizine kaydet ve yerel paylaşım/görüntüleme ekranını aç
        final Directory tempDir = await getTemporaryDirectory();
        final File hedefDosya = File('${tempDir.path}/$dosyaAdi');
        await hedefDosya.writeAsBytes(pdfBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        await SharePlus.instance.share(
          ShareParams(
            files: <XFile>[XFile(hedefDosya.path, mimeType: 'application/pdf', name: dosyaAdi)],
            text: baslik ?? 'KOOPERATİF ORTAK / ÜYE KAYIT DEFTERİ LİSTESİ',
            subject: dosyaAdi,
          ),
        );
        return;
      }

      // Masaüstünde (Windows, macOS, Linux): Kullanıcıya kayıt klasörü seçtir
      final String? hedefDizin = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'PDF Raporunun Kaydedileceği Klasörü Seçin',
      );
      if (hedefDizin == null) return;

      final File hedefDosya = File('$hedefDizin/$dosyaAdi');

      // 3. Dosyayı diske yaz
      await hedefDosya.writeAsBytes(pdfBytes);

      // 4. Başarı SnackBar'ı ve 'Aç' butonu
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Raporu kaydedildi:\n${hedefDosya.path}'),
            backgroundColor: const Color(0xFF2E7D32), // Koyu zümrüt yeşili
            duration: const Duration(seconds: 6),
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken bir hata meydana geldi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Kullanıcı arama ekranında PDF butonuna bastığında arama yapılmışsa
  /// seçenek sunar (Filtrelenmiş Liste mi, Tüm Üyeler mi?), yapılmamışsa
  /// doğrudan tam listeyi yazdırır.
  static Future<void> secenekliRapor(
    BuildContext context,
    WidgetRef ref, {
    required List<Ortak> filtrelenmisOrtaklar,
    required bool aramaVarMi,
  }) async {
    if (!aramaVarMi) {
      // Doğrudan mevcut listeyi PDF'e aktar
      await calistir(
        context,
        ortaklar: filtrelenmisOrtaklar,
        baslik: 'KOOPERATİF GENEL ORTAK / ÜYE KAYIT DEFTERİ LİSTESİ',
      );
      return;
    }

    // Arama veya filtreleme varsa kullanıcıya sor
    final String? secim = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 36),
          title: const Text('PDF Raporu Kapsamı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Hangi üyeleri PDF raporuna dahil etmek istersiniz?'),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.filter_list, color: Color(0xFF1E293B)),
                title: Text('Filtrelenmiş Liste (${filtrelenmisOrtaklar.length} Ortak)'),
                subtitle: const Text('Arama sonucunda şu an ekranda listelenen üyeler'),
                onTap: () => Navigator.of(ctx).pop('filtreli'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.people_alt_outlined, color: Color(0xFF1E293B)),
                title: const Text('Tüm Ortaklar / Üyeler'),
                subtitle: const Text('Veritabanında kayıtlı tüm üyelerin tam listesi'),
                onTap: () => Navigator.of(ctx).pop('tumu'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );

    if (secim == null || !context.mounted) return;

    if (secim == 'filtreli') {
      await calistir(
        context,
        ortaklar: filtrelenmisOrtaklar,
        baslik: 'KOOPERATİF ORTAK / ÜYE LİSTESİ (FİLTRELENMİŞ)',
        altAciklama: 'Arama ve filtreleme kriterlerine uyan kayıtlar listelenmiştir.',
      );
    } else if (secim == 'tumu') {
      try {
        final OrtakRepository repo = ref.read(ortakRepositoryProvider);
        final List<Ortak> tumOrtaklar = await repo.tumOrtaklariGetir(pasifleriDeGoster: true);
        if (context.mounted) {
          await calistir(
            context,
            ortaklar: tumOrtaklar,
            baslik: 'KOOPERATİF GENEL ORTAK / ÜYE KAYIT DEFTERİ LİSTESİ',
            altAciklama: 'Tüm aktif ve pasif üyelerin eksiksiz genel dökümüdür.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tüm üyeler alınırken hata: $e')),
          );
        }
      }
    }
  }
}
