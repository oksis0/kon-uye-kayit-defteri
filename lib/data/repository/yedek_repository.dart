import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/util/csv_guvenlik.dart';
import '../../core/util/para_bicim.dart';
import '../../core/util/turkce_normalize.dart';
import '../../domain/enum/satir_turu.dart';
import '../yerel/dao/meta_dao.dart';
import '../yerel/veritabani.dart';
import '../yerel/veritabani_provider.dart';

part 'yedek_repository.g.dart';

/// Periyodik dışa aktarma (PLAN.md §11).
///
/// ★ Bulut mimarisi (R2 + Firestore) tek-nokta-arıza riskini kaldırıyor
/// ama ücretsiz katmanlarda otomatik yedek YOK. Bu yüzden elle/periyodik
/// dışa aktarma şart.
///
/// ★ JSON + CSV birlikte: JSON tam ve geri yüklenebilir; CSV ise uygulama
/// tamamen yok olsa bile veriyi Excel'de okunabilir kılar. "Yazılım
/// öldüğünde veri hâlâ okunabilir mi?" sorusunun cevabı her zaman evet
/// olmalı.
///
/// ★ Görseller yedeğe DAHİL DEĞİL (3 GB'ı her seferinde kopyalamak pratik
/// değil) — sadece hangi ortağın hangi R2 anahtarına sahip olduğunun
/// listesi (`gorsel_listesi.csv`). Görsellerin kendisi R2'nin dayanıklılığına
/// bırakılıyor; asıl korunması gereken metin veri.
class YedekRepository {
  YedekRepository(this._db);

  final AppVeritabani _db;

  /// [hedefKlasorYolu] altında `yedek_yyyy-MM-dd_HHmmss/` klasörü oluşturup
  /// içine 5 dosya yazar. Döndürülen değer, oluşturulan klasörün tam yolu.
  Future<String> yedekAl(String hedefKlasorYolu) async {
    final DateTime simdi = DateTime.now();
    final String klasorAdi = 'yedek_${_dosyaTarihEtiketi(simdi)}';
    final Directory yedekKlasoru = Directory('$hedefKlasorYolu/$klasorAdi');
    await yedekKlasoru.create(recursive: true);

    final List<OrtakSatiri> ortaklar =
        await _db.ortakDao.tumunuIzle(pasifleriDeGoster: true).first;
    final List<DefterSatiriSatiri> satirlar = await _db.defterSatiriDao.tumunuGetir();

    await File(
      '${yedekKlasoru.path}/ortaklar.json',
    ).writeAsString(_ortaklarJson(ortaklar, satirlar));
    await File('${yedekKlasoru.path}/ortaklar.csv').writeAsString(_ortaklarCsv(ortaklar));
    await File(
      '${yedekKlasoru.path}/defter_satirlari.csv',
    ).writeAsString(_satirlarCsv(ortaklar, satirlar));
    await File(
      '${yedekKlasoru.path}/gorsel_listesi.csv',
    ).writeAsString(_gorselListesiCsv(ortaklar));
    await File('${yedekKlasoru.path}/OZET.txt').writeAsString(_ozet(ortaklar, satirlar, simdi));

    await _db.metaDao.degerYaz(anahtarSonYedek, simdi.toIso8601String());
    return yedekKlasoru.path;
  }

  Future<DateTime?> sonYedekTarihi() async {
    final String? deger = await _db.metaDao.degerAl(anahtarSonYedek);
    return deger == null ? null : DateTime.parse(deger);
  }

  /// Alınan `ortaklar.json` veya `ortaklar.csv` yedeğini okur ve Drift SQLite veritabanına
  /// (insertOnConflictUpdate ile) aktarır.
  Future<YedekGeriYuklemeSonucu> yedektenGeriYukle(String dosyaYolu) async {
    final File dosya = File(dosyaYolu);
    if (!await dosya.exists()) {
      throw Exception('Yedek dosyası bulunamadı: $dosyaYolu');
    }

    if (dosyaYolu.toLowerCase().endsWith('.csv')) {
      return _csvdenGeriYukle(dosya);
    }

    final String jsonMetin = await dosya.readAsString();
    final dynamic cozumlenen = jsonDecode(jsonMetin);
    if (cozumlenen is! List) {
      throw Exception('Geçersiz yedek dosyası formatı.');
    }

    int eklenenOrtak = 0;
    int eklenenSatir = 0;

    for (final dynamic item in cozumlenen) {
      if (item is! Map<String, dynamic>) continue;

      final String id = item['id'] as String;
      final String ortakNo = item['ortakNo'] as String;
      final String adSoyad = item['adSoyad'] as String;
      final String? tcKimlikNo = item['tcKimlikNo'] as String?;
      final String? sayfaNo = item['sayfaNo'] as String?;
      final String? babaAdi = item['babaAdi'] as String?;
      final String? dogumYeri = item['dogumYeri'] as String?;
      final String? dogumTarihiHam = item['dogumTarihiHam'] as String?;
      final DateTime? dogumTarihi = item['dogumTarihi'] != null
          ? DateTime.tryParse(item['dogumTarihi'] as String)
          : null;
      final String? girisTarihiHam = item['girisTarihiHam'] as String?;
      final DateTime? girisTarihi = item['girisTarihi'] != null
          ? DateTime.tryParse(item['girisTarihi'] as String)
          : null;
      final String? cikisTarihiHam = item['cikisTarihiHam'] as String?;
      final DateTime? cikisTarihi = item['cikisTarihi'] != null
          ? DateTime.tryParse(item['cikisTarihi'] as String)
          : null;
      final String? ikametAdresi = item['ikametAdresi'] as String?;
      final String? nufusKayitYeri = item['nufusKayitYeri'] as String?;
      final String? belgeR2Anahtari = item['belgeR2Anahtari'] as String?;
      final String? yerelDosyaYolu = item['yerelDosyaYolu'] as String?;
      final double? ocrGuvenOrtalama = item['ocrGuvenOrtalama'] != null
          ? (item['ocrGuvenOrtalama'] as num).toDouble()
          : null;
      final bool aktif = (item['aktif'] as bool?) ?? true;
      final String? pasifNedeni = item['pasifNedeni'] as String?;
      final DateTime? pasifTarihi = item['pasifTarihi'] != null
          ? DateTime.tryParse(item['pasifTarihi'] as String)
          : null;
      final DateTime olusturmaTarihi = item['olusturmaTarihi'] != null
          ? DateTime.tryParse(item['olusturmaTarihi'] as String) ?? DateTime.now()
          : DateTime.now();
      final DateTime guncellemeTarihi = item['guncellemeTarihi'] != null
          ? DateTime.tryParse(item['guncellemeTarihi'] as String) ?? DateTime.now()
          : DateTime.now();

      final String aramaAnahtari = aramaAnahtariUret(<String?>[
        ortakNo,
        sayfaNo,
        tcKimlikNo,
        adSoyad,
        babaAdi,
        dogumYeri,
        ikametAdresi,
        nufusKayitYeri,
      ]);

      await _db.ortakDao.upsert(
        OrtaklarCompanion(
          id: Value(id),
          ortakNo: Value(ortakNo),
          sayfaNo: Value(sayfaNo),
          tcKimlikNo: Value(tcKimlikNo),
          adSoyad: Value(adSoyad),
          babaAdi: Value(babaAdi),
          dogumYeri: Value(dogumYeri),
          dogumTarihiHam: Value(dogumTarihiHam),
          dogumTarihi: Value(dogumTarihi),
          girisTarihiHam: Value(girisTarihiHam),
          girisTarihi: Value(girisTarihi),
          cikisTarihiHam: Value(cikisTarihiHam),
          cikisTarihi: Value(cikisTarihi),
          ikametAdresi: Value(ikametAdresi),
          nufusKayitYeri: Value(nufusKayitYeri),
          aramaAnahtari: Value(aramaAnahtari),
          belgeR2Anahtari: Value(belgeR2Anahtari),
          yerelDosyaYolu: Value(yerelDosyaYolu),
          ocrGuvenOrtalama: Value(ocrGuvenOrtalama),
          aktif: Value(aktif),
          pasifNedeni: Value(pasifNedeni),
          pasifTarihi: Value(pasifTarihi),
          olusturmaTarihi: Value(olusturmaTarihi),
          guncellemeTarihi: Value(guncellemeTarihi),
        ),
      );
      eklenenOrtak++;

      final dynamic satirlarRaw = item['satirlar'];
      if (satirlarRaw is List) {
        for (final dynamic s in satirlarRaw) {
          if (s is! Map<String, dynamic>) continue;
          final String satirId = (s['id'] as String?) ?? const Uuid().v4();
          final String turStr = (s['tur'] as String?) ?? 'sermaye';
          final SatirTuru tur =
              turStr == 'odeme' ? SatirTuru.odeme : SatirTuru.sermaye;
          final int siraNo = (s['siraNo'] as num?)?.toInt() ?? 1;
          final String? tarihHam = s['tarihHam'] as String?;
          final DateTime? tarih = s['tarih'] != null
              ? DateTime.tryParse(s['tarih'] as String)
              : null;
          final String? no = s['no'] as String?;
          final String? madde = s['madde'] as String?;
          final String? aciklama = s['aciklama'] as String?;
          final int miktarKurus = (s['miktarKurus'] as num?)?.toInt() ?? 0;
          final int yekunKurus = (s['yekunKurus'] as num?)?.toInt() ?? 0;

          await _db.defterSatiriDao.upsert(
            DefterSatirlariCompanion(
              id: Value(satirId),
              ortakId: Value(id),
              tur: Value(tur),
              siraNo: Value(siraNo),
              tarihHam: Value(tarihHam),
              tarih: Value(tarih),
              no: Value(no),
              madde: Value(madde),
              aciklama: Value(aciklama),
              miktarKurus: Value(miktarKurus),
              yekunKurus: Value(yekunKurus),
            ),
          );
          eklenenSatir++;
        }
      }
    }

    return YedekGeriYuklemeSonucu(
      ortakSayisi: eklenenOrtak,
      satirSayisi: eklenenSatir,
    );
  }

  Future<YedekGeriYuklemeSonucu> _csvdenGeriYukle(File dosya) async {
    String metin = await dosya.readAsString();
    if (metin.startsWith('\uFEFF')) {
      metin = metin.substring(1);
    }
    final List<List<dynamic>> satirlar =
        const CsvToListConverter(shouldParseNumbers: false).convert(metin);
    if (satirlar.isEmpty) {
      throw Exception('CSV dosyası boş.');
    }

    int eklenenOrtak = 0;
    // İlk satır başlıklar: Ortak No, Sayfa No, TC Kimlik No, Adı Soyadı, ...
    for (int i = 1; i < satirlar.length; i++) {
      final List<dynamic> satir = satirlar[i];
      if (satir.length < 4) continue;

      String temizle(dynamic val) {
        if (val == null) return '';
        String s = val.toString().trim();
        if (s.startsWith("'") &&
            (s.startsWith("'=") || s.startsWith("'+") || s.startsWith("'-") || s.startsWith("'@"))) {
          s = s.substring(1);
        }
        return s;
      }

      final String ortakNo = temizle(satir[0]);
      if (ortakNo.isEmpty) continue;

      final String sayfaNo = temizle(satir[1]);
      final String tcKimlikNo = temizle(satir[2]);
      final String adSoyad = temizle(satir[3]);
      if (adSoyad.isEmpty) continue;

      final String babaAdi = satir.length > 4 ? temizle(satir[4]) : '';
      final String dogumYeri = satir.length > 5 ? temizle(satir[5]) : '';
      final String dogumTarihiHam = satir.length > 6 ? temizle(satir[6]) : '';
      final String girisTarihiHam = satir.length > 7 ? temizle(satir[7]) : '';
      final String cikisTarihiHam = satir.length > 8 ? temizle(satir[8]) : '';
      final String ikametAdresi = satir.length > 9 ? temizle(satir[9]) : '';
      final String nufusKayitYeri = satir.length > 10 ? temizle(satir[10]) : '';
      final String aktifStr = satir.length > 11 ? temizle(satir[11]) : 'Evet';
      final bool aktif = aktifStr.toLowerCase() != 'hayır' && aktifStr.toLowerCase() != 'false';
      final String pasifNedeni = satir.length > 12 ? temizle(satir[12]) : '';

      OrtakSatiri? mevcut;
      if (tcKimlikNo.isNotEmpty) {
        mevcut = await _db.ortakDao.tcKimlikNoIleBul(tcKimlikNo);
      }
      mevcut ??= await _db.ortakDao.ortakNoIleBul(ortakNo);
      final String id = mevcut?.id ?? const Uuid().v4();

      await _db.ortakDao.ekle(
        OrtaklarCompanion.insert(
          id: id,
          ortakNo: ortakNo,
          sayfaNo: sayfaNo.isEmpty ? const Value.absent() : Value(sayfaNo),
          tcKimlikNo: tcKimlikNo.isEmpty ? const Value.absent() : Value(tcKimlikNo),
          adSoyad: adSoyad,
          babaAdi: babaAdi.isEmpty ? const Value.absent() : Value(babaAdi),
          dogumYeri: dogumYeri.isEmpty ? const Value.absent() : Value(dogumYeri),
          dogumTarihiHam: dogumTarihiHam.isEmpty ? const Value.absent() : Value(dogumTarihiHam),
          girisTarihiHam: girisTarihiHam.isEmpty ? const Value.absent() : Value(girisTarihiHam),
          cikisTarihiHam: cikisTarihiHam.isEmpty ? const Value.absent() : Value(cikisTarihiHam),
          ikametAdresi: ikametAdresi.isEmpty ? const Value.absent() : Value(ikametAdresi),
          nufusKayitYeri: nufusKayitYeri.isEmpty ? const Value.absent() : Value(nufusKayitYeri),
          aktif: Value(aktif),
          pasifNedeni: pasifNedeni.isEmpty ? const Value.absent() : Value(pasifNedeni),
          aramaAnahtari: turkceNormalize('$ortakNo $adSoyad $tcKimlikNo'),
          olusturmaTarihi: mevcut?.olusturmaTarihi ?? DateTime.now(),
          guncellemeTarihi: DateTime.now(),
        ),
      );
      eklenenOrtak++;
    }

    return YedekGeriYuklemeSonucu(
      ortakSayisi: eklenenOrtak,
      satirSayisi: 0,
    );
  }

  String _dosyaTarihEtiketi(DateTime t) => DateFormat('yyyy-MM-dd_HHmmss').format(t);

  String _ortaklarJson(List<OrtakSatiri> ortaklar, List<DefterSatiriSatiri> satirlar) {
    final List<Map<String, dynamic>> liste = ortaklar.map((OrtakSatiri o) {
      final List<DefterSatiriSatiri> kendiSatirlari =
          satirlar.where((DefterSatiriSatiri s) => s.ortakId == o.id).toList();
      return <String, dynamic>{
        'id': o.id,
        'ortakNo': o.ortakNo,
        'sayfaNo': o.sayfaNo,
        'tcKimlikNo': o.tcKimlikNo,
        'adSoyad': o.adSoyad,
        'babaAdi': o.babaAdi,
        'dogumYeri': o.dogumYeri,
        'dogumTarihiHam': o.dogumTarihiHam,
        'dogumTarihi': o.dogumTarihi?.toIso8601String(),
        'girisTarihiHam': o.girisTarihiHam,
        'girisTarihi': o.girisTarihi?.toIso8601String(),
        'cikisTarihiHam': o.cikisTarihiHam,
        'cikisTarihi': o.cikisTarihi?.toIso8601String(),
        'ikametAdresi': o.ikametAdresi,
        'nufusKayitYeri': o.nufusKayitYeri,
        'belgeR2Anahtari': o.belgeR2Anahtari,
        'yerelDosyaYolu': o.yerelDosyaYolu,
        'ocrGuvenOrtalama': o.ocrGuvenOrtalama,
        'aktif': o.aktif,
        'pasifNedeni': o.pasifNedeni,
        'pasifTarihi': o.pasifTarihi?.toIso8601String(),
        'olusturmaTarihi': o.olusturmaTarihi.toIso8601String(),
        'guncellemeTarihi': o.guncellemeTarihi.toIso8601String(),
        'satirlar': kendiSatirlari
            .map(
              (DefterSatiriSatiri s) => <String, dynamic>{
                'tur': s.tur.name,
                'siraNo': s.siraNo,
                'tarihHam': s.tarihHam,
                'no': s.no,
                'madde': s.madde,
                'aciklama': s.aciklama,
                'miktarKurus': s.miktarKurus,
                'yekunKurus': s.yekunKurus,
              },
            )
            .toList(),
      };
    }).toList();

    return const JsonEncoder.withIndent('  ').convert(liste);
  }

  String _ortaklarCsv(List<OrtakSatiri> ortaklar) {
    final List<List<dynamic>> satirlar = <List<dynamic>>[
      <String>[
        'Ortak No', 'Sayfa No', 'TC Kimlik No', 'Adı Soyadı', 'Baba Adı', 'Doğum Yeri', 'Doğum Tarihi',
        'Giriş Tarihi', 'Çıkış Tarihi', 'İkamet Adresi', 'Nüfusa Kayıtlı Olduğu Yer',
        'Aktif', 'Pasif Nedeni',
      ],
      for (final OrtakSatiri o in ortaklar)
        <dynamic>[
          csvFormulKorumasi(o.ortakNo),
          csvFormulKorumasi(o.sayfaNo),
          csvFormulKorumasi(o.tcKimlikNo),
          csvFormulKorumasi(o.adSoyad),
          csvFormulKorumasi(o.babaAdi),
          csvFormulKorumasi(o.dogumYeri),
          csvFormulKorumasi(o.dogumTarihiHam),
          csvFormulKorumasi(o.girisTarihiHam),
          csvFormulKorumasi(o.cikisTarihiHam),
          csvFormulKorumasi(o.ikametAdresi),
          csvFormulKorumasi(o.nufusKayitYeri),
          o.aktif ? 'Evet' : 'Hayır',
          csvFormulKorumasi(o.pasifNedeni),
        ],
    ];
    return '\uFEFF${const ListToCsvConverter().convert(satirlar)}';
  }

  String _satirlarCsv(List<OrtakSatiri> ortaklar, List<DefterSatiriSatiri> satirlar) {
    final Map<String, String> ortakNoTablosu = <String, String>{
      for (final OrtakSatiri o in ortaklar) o.id: o.ortakNo,
    };

    final List<List<dynamic>> csvSatirlari = <List<dynamic>>[
      <String>['Ortak No', 'Tür', 'Tarih', 'No', 'Mad.', 'Açıklama', 'Miktar', 'Yekün'],
      for (final DefterSatiriSatiri s in satirlar)
        <dynamic>[
          csvFormulKorumasi(ortakNoTablosu[s.ortakId] ?? s.ortakId),
          s.tur.etiket,
          csvFormulKorumasi(s.tarihHam),
          csvFormulKorumasi(s.no),
          csvFormulKorumasi(s.madde),
          csvFormulKorumasi(s.aciklama),
          kurusuBicimlendir(s.miktarKurus),
          kurusuBicimlendir(s.yekunKurus),
        ],
    ];
    return '\uFEFF${const ListToCsvConverter().convert(csvSatirlari)}';
  }

  String _gorselListesiCsv(List<OrtakSatiri> ortaklar) {
    final List<List<dynamic>> satirlar = <List<dynamic>>[
      <String>['Ortak No', 'Adı Soyadı', 'R2 Anahtarı'],
      for (final OrtakSatiri o in ortaklar)
        if (o.belgeR2Anahtari != null)
          <dynamic>[
            csvFormulKorumasi(o.ortakNo),
            csvFormulKorumasi(o.adSoyad),
            csvFormulKorumasi(o.belgeR2Anahtari),
          ],
    ];
    return '\uFEFF${const ListToCsvConverter().convert(satirlar)}';
  }

  String _ozet(List<OrtakSatiri> ortaklar, List<DefterSatiriSatiri> satirlar, DateTime simdi) {
    final int aktifSayisi = ortaklar.where((OrtakSatiri o) => o.aktif).length;
    final int gorselSayisi = ortaklar.where((OrtakSatiri o) => o.belgeR2Anahtari != null).length;
    return '''
Ortak Pay Defteri — Yedek Özeti
================================
Tarih: ${DateFormat('dd.MM.yyyy HH:mm', 'tr_TR').format(simdi)}

Toplam ortak: ${ortaklar.length}
  - Aktif: $aktifSayisi
  - Pasif: ${ortaklar.length - aktifSayisi}
Toplam defter satırı: ${satirlar.length}
Görseli olan kayıt: $gorselSayisi

Dosyalar:
  - ortaklar.json         : Tam veri, geri yükleme için (makine-okunur)
  - ortaklar.csv           : Kimlik bilgileri (Excel'de açılır)
  - defter_satirlari.csv   : Sermaye Yüklenmeleri + Ödemeler
  - gorsel_listesi.csv     : Ortak <-> R2 anahtarı eşleşmesi
                             (görsellerin kendisi bu yedekte YOK,
                             R2'de duruyor — PLAN.md §11)
''';
  }
}

@Riverpod(keepAlive: true)
YedekRepository yedekRepository(Ref ref) {
  final AppVeritabani db = ref.watch(veritabaniProvider);
  return YedekRepository(db);
}

class YedekGeriYuklemeSonucu {
  const YedekGeriYuklemeSonucu({
    required this.ortakSayisi,
    required this.satirSayisi,
  });

  final int ortakSayisi;
  final int satirSayisi;
}
