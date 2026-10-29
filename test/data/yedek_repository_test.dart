import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ortak_defteri/data/repository/yedek_repository.dart';
import 'package:ortak_defteri/data/yerel/veritabani.dart';
import 'package:ortak_defteri/domain/enum/satir_turu.dart';

void main() {
  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('tr_TR', null);
  });

  group('YedekRepository Yedek Alma ve Geri Yükleme Testleri', () {
    late AppVeritabani db;
    late YedekRepository repository;
    late Directory tempDir;

    setUp(() async {
      db = AppVeritabani.baglantiIle(DatabaseConnection(NativeDatabase.memory()));
      repository = YedekRepository(db);
      tempDir = await Directory.systemTemp.createTemp('yedek_test_');

      // Örnek ortak ve defter satırı ekleyelim
      await db.ortakDao.ekle(
        OrtaklarCompanion.insert(
          id: 'test-ortak-1',
          ortakNo: '101',
          sayfaNo: const Value('5'),
          tcKimlikNo: const Value('12345678901'),
          adSoyad: 'Ali Veli',
          aktif: const Value(true),
          aramaAnahtari: '101 ali veli',
          olusturmaTarihi: DateTime.now(),
          guncellemeTarihi: DateTime.now(),
        ),
      );

      await db.defterSatiriDao.ekle(
        DefterSatirlariCompanion.insert(
          id: 'satir-1',
          ortakId: 'test-ortak-1',
          tur: SatirTuru.sermaye,
          siraNo: 1,
          miktarKurus: const Value(500000),
          yekunKurus: const Value(500000),
        ),
      );
    });

    tearDown(() async {
      await db.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('yedekAl tüm dosyaları üretir ve yedektenGeriYukle yeni veritabanına aktarır', () async {
      final String olusanKlasor = await repository.yedekAl(tempDir.path);
      final File jsonDosyasi = File('$olusanKlasor/ortaklar.json');
      expect(jsonDosyasi.existsSync(), isTrue);

      // Yeni ve boş bir veritabanı oluşturalım
      final AppVeritabani yeniDb = AppVeritabani.baglantiIle(DatabaseConnection(NativeDatabase.memory()));
      final YedekRepository yeniRepo = YedekRepository(yeniDb);

      try {
        final YedekGeriYuklemeSonucu sonuc = await yeniRepo.yedektenGeriYukle(jsonDosyasi.path);
        expect(sonuc.ortakSayisi, equals(1));
        expect(sonuc.satirSayisi, equals(1));

        final OrtakSatiri? yuklenenOrtak = await yeniDb.ortakDao.idIleBul('test-ortak-1');
        expect(yuklenenOrtak, isNotNull);
        expect(yuklenenOrtak!.ortakNo, equals('101'));
        expect(yuklenenOrtak.adSoyad, equals('Ali Veli'));
        expect(yuklenenOrtak.tcKimlikNo, equals('12345678901'));

        final List<DefterSatiriSatiri> yuklenenSatirlar = await yeniDb.defterSatiriDao.tumunuGetir();
        expect(yuklenenSatirlar.length, equals(1));
        expect(yuklenenSatirlar.first.miktarKurus, equals(500000));
      } finally {
        await yeniDb.close();
      }
    });
  });
}
