import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/data/repository/kuyruk_repository.dart';
import 'package:ortak_defteri/data/yerel/veritabani.dart';
import 'package:ortak_defteri/domain/enum/kuyruk_durumu.dart';
import 'package:ortak_defteri/domain/model/ice_aktarma_isi.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('KuyrukRepository Testleri', () {
    late AppVeritabani db;
    late KuyrukRepository repo;
    late Directory tempDir;
    late File testGorsel;

    setUp(() async {
      db = AppVeritabani.baglantiIle(DatabaseConnection(NativeDatabase.memory()));
      repo = KuyrukRepository(db);
      tempDir = await Directory.systemTemp.createTemp('kuyruk_test_');
      testGorsel = File('${tempDir.path}/test_belge.jpg');
      await testGorsel.writeAsBytes(<int>[1, 2, 3, 4, 5]);
    });

    tearDown(() async {
      await db.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('dosyaEkle kuyruğa yeni iş ekler ve yinelenen dosyaları engeller', () async {
      final bool eklendi1 = await repo.dosyaEkle(testGorsel.path);
      expect(eklendi1, isTrue);

      final List<IceAktarmaIsi> isler = await repo.tumunuIzle().first;
      expect(isler.length, 1);
      expect(isler.first.durum, KuyrukDurumu.bekliyor);

      // Aynı dosya (aynı sha256) tekrar eklenemez
      final bool eklendi2 = await repo.dosyaEkle(testGorsel.path);
      expect(eklendi2, isFalse);
    });

    test('ocrIcinYenidenKuyrugaAl onayBekliyor durumundaki işi sıfırlayıp bekliyor yapar', () async {
      await repo.dosyaEkle(testGorsel.path);
      final List<IceAktarmaIsi> isler = await repo.tumunuIzle().first;
      final String isId = isler.first.id;

      // Manuel olarak onayBekliyor ve hata alanları simüle edelim
      await db.kuyrukDao.guncelle(
        IceAktarmaKuyruguCompanion(
          id: Value(isId),
          durum: const Value(KuyrukDurumu.onayBekliyor),
          hataMesaji: const Value('Geçici hata'),
          azureOperationId: const Value('op-123'),
        ),
      );

      IceAktarmaIsi? guncel = await repo.idIleGetir(isId);
      expect(guncel?.durum, KuyrukDurumu.onayBekliyor);

      // Sıfırlayıp tekrar kuyruğa alalım
      await repo.ocrIcinYenidenKuyrugaAl(isId);

      guncel = await repo.idIleGetir(isId);
      expect(guncel?.durum, KuyrukDurumu.bekliyor);
      expect(guncel?.hataMesaji, isNull);
      expect(guncel?.azureOperationId, isNull);
      expect(guncel?.ocrHamJson, isNull);
    });

    test('dosyaEkle veritabanında zaten kayıtlı bir ortağa ait görseli kuyruğa eklemez', () async {
      // Bir ortağı testGorsel dosyasıyla kaydedelim
      await db.ortakDao.ekle(
        OrtaklarCompanion.insert(
          id: 'ortak-1',
          ortakNo: '101',
          adSoyad: 'Ali Veli',
          tcKimlikNo: const Value('12345678901'),
          yerelDosyaYolu: Value(testGorsel.path),
          aramaAnahtari: '101 ali veli 12345678901',
          olusturmaTarihi: DateTime.now(),
          guncellemeTarihi: DateTime.now(),
        ),
      );

      // Şimdi bu dosya kuyruğa eklenmek istendiğinde zaten kayıtlı olduğu için false dönmeli
      final bool eklendi = await repo.dosyaEkle(testGorsel.path);
      expect(eklendi, isFalse);

      final List<IceAktarmaIsi> isler = await repo.tumunuIzle().first;
      expect(isler, isEmpty);
    });
  });
}
