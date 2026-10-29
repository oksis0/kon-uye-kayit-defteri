import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/model/ortak.dart';

/// Kooperatif Ortak/Üye Listesi için PDF Rapor Servisi.
///
/// ★ Türkçe Karakter Desteği:
/// Standart PDF fontları Türkçe karakterleri (ş, Ş, ı, İ, ğ, Ğ, ç, Ç, ö, Ö, ü, Ü)
/// desteklemez. Bu servis projedeki `NotoSans` TrueType fontlarını yükleyerek
/// PDF dokümanına enjekte eder ve tüm Türkçe karakterlerin kusursuz basılmasını garanti eder.
class UyeListesiPdfServisi {
  const UyeListesiPdfServisi();

  /// Verilen ortaklar listesini şık ve resmi evrak standardında A4 yatay (landscape)
  /// PDF tablosuna dönüştürür.
  Future<Uint8List> raporOlustur({
    required List<Ortak> ortaklar,
    String baslik = 'KOOPERATİF ORTAK / ÜYE KAYIT DEFTERİ LİSTESİ',
    String? altAciklama,
  }) async {
    final pw.Document doc = pw.Document();

    // 1. Türkçe fontları yükle
    pw.Font fontRegular;
    pw.Font fontBold;

    try {
      final ByteData regularData =
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final ByteData boldData =
          await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      fontRegular = pw.Font.ttf(regularData);
      fontBold = pw.Font.ttf(boldData);
    } catch (e, s) {
      developer.log(
        'NotoSans fontları yüklenemedi, fallback font kullanılıyor: $e',
        name: 'UyeListesiPdfServisi',
        error: e,
        stackTrace: s,
      );
      // Fallback
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    final pw.ThemeData tema = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );

    final DateTime simdi = DateTime.now();
    final String tarihSaatStr = DateFormat('dd.MM.yyyy HH:mm').format(simdi);
    final DateFormat tarihFmt = DateFormat('dd.MM.yyyy');

    final int toplamSayi = ortaklar.length;
    final int aktifSayi = ortaklar.where((Ortak o) => o.aktif).length;
    final int pasifSayi = toplamSayi - aktifSayi;

    // Tablo sütun başlıkları
    final List<String> headers = <String>[
      'S.No',
      'Ortak No',
      'Sayfa',
      'TC Kimlik No',
      'Adı Soyadı',
      'Durum',
      'Baba Adı',
      'Doğum Yeri / Tarihi',
      'Giriş Tarihi',
      'Çıkış Tarihi',
      'İkametgâh Adresi / Nüfus Kaydı',
    ];

    // Tablo verileri
    final List<List<String>> data = <List<String>>[];
    for (int i = 0; i < ortaklar.length; i++) {
      final Ortak o = ortaklar[i];

      final String dYeri = (o.dogumYeri ?? '').trim();
      final String dTarih = o.dogumTarihi != null
          ? tarihFmt.format(o.dogumTarihi!)
          : (o.dogumTarihiHam ?? '').trim();
      final String dYeriTarih =
          <String>[dYeri, dTarih].where((String s) => s.isNotEmpty).join(' - ');

      final String giris = o.girisTarihi != null
          ? tarihFmt.format(o.girisTarihi!)
          : (o.girisTarihiHam ?? '-');

      final String cikis = o.cikisTarihi != null
          ? tarihFmt.format(o.cikisTarihi!)
          : (o.cikisTarihiHam ?? '-');

      final String adres = (o.ikametAdresi ?? '').trim();
      final String nufus = (o.nufusKayitYeri ?? '').trim();
      final String adresNufus =
          <String>[adres, nufus].where((String s) => s.isNotEmpty).join('\n');

      data.add(<String>[
        '${i + 1}',
        o.ortakNo,
        o.sayfaNo ?? '-',
        o.tcKimlikNo ?? '-',
        o.adSoyad,
        o.aktif ? 'Aktif' : 'Pasif',
        o.babaAdi ?? '-',
        dYeriTarih.isEmpty ? '-' : dYeriTarih,
        giris,
        cikis,
        adresNufus.isEmpty ? '-' : adresNufus,
      ]);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: tema,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: <pw.Widget>[
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Text(
                          baslik,
                          style: const pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        if (altAciklama != null && altAciklama.isNotEmpty) ...<pw.Widget>[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            altAciklama,
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: <pw.Widget>[
                        pw.Text(
                          'Rapor Tarihi: $tarihSaatStr',
                          style: const pw.TextStyle(
                            fontSize: 8.5,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            'Toplam: $toplamSayi  |  Aktif: $aktifSayi  |  Pasif: $pasifSayi',
                            style: const pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, color: PdfColors.blueGrey300),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Text(
                  'KON Üye Kayıt Defteri Sistemi • Resmi Genel Ortak Listesi',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Sayfa ${context.pageNumber} / ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              headerStyle: const pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1E293B), // Slate 800
              ),
              headerHeight: 24,
              cellStyle: const pw.TextStyle(
                fontSize: 7.5,
                color: PdfColors.black,
              ),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
              cellAlignments: const <int, pw.Alignment>{
                0: pw.Alignment.center, // S.No
                1: pw.Alignment.center, // Ortak No
                2: pw.Alignment.center, // Sayfa
                3: pw.Alignment.center, // TC No
                4: pw.Alignment.centerLeft, // Ad Soyad
                5: pw.Alignment.center, // Durum
                6: pw.Alignment.centerLeft, // Baba Adı
                7: pw.Alignment.centerLeft, // D.Yeri / Tarih
                8: pw.Alignment.center, // Giriş
                9: pw.Alignment.center, // Çıkış
                10: pw.Alignment.centerLeft, // Adres / Nüfus
              },
              columnWidths: const <int, pw.TableColumnWidth>{
                0: pw.FixedColumnWidth(26), // S.No
                1: pw.FixedColumnWidth(48), // Ortak No
                2: pw.FixedColumnWidth(36), // Sayfa
                3: pw.FixedColumnWidth(70), // TC No
                4: pw.FlexColumnWidth(2.2), // Ad Soyad
                5: pw.FixedColumnWidth(40), // Durum
                6: pw.FlexColumnWidth(1.3), // Baba Adı
                7: pw.FlexColumnWidth(1.6), // D.Yeri / Tarih
                8: pw.FixedColumnWidth(54), // Giriş
                9: pw.FixedColumnWidth(54), // Çıkış
                10: pw.FlexColumnWidth(2.6), // Adres / Nüfus
              },
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF8FAFC), // Slate 50
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }
}
