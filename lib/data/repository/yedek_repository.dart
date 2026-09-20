import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/util/csv_guvenlik.dart';
import '../../core/util/para_bicim.dart';
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

  String _dosyaTarihEtiketi(DateTime t) => DateFormat('yyyy-MM-dd_HHmmss').format(t);

  String _ortaklarJson(List<OrtakSatiri> ortaklar, List<DefterSatiriSatiri> satirlar) {
    final List<Map<String, dynamic>> liste = ortaklar.map((OrtakSatiri o) {
      final List<DefterSatiriSatiri> kendiSatirlari =
          satirlar.where((DefterSatiriSatiri s) => s.ortakId == o.id).toList();
      return <String, dynamic>{
        'id': o.id,
        'ortakNo': o.ortakNo,
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
        'Ortak No', 'Adı Soyadı', 'Baba Adı', 'Doğum Yeri', 'Doğum Tarihi',
        'Giriş Tarihi', 'Çıkış Tarihi', 'İkamet Adresi', 'Nüfusa Kayıtlı Olduğu Yer',
        'Aktif', 'Pasif Nedeni',
      ],
      for (final OrtakSatiri o in ortaklar)
        <dynamic>[
          csvFormulKorumasi(o.ortakNo),
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
