import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ortak_defteri/data/repository/ortak_repository.dart';
import 'package:ortak_defteri/data/yerel/tablolar/ortaklar_tablosu.dart';
import 'package:ortak_defteri/data/yerel/veritabani.dart';
import 'package:ortak_defteri/domain/enum/satir_turu.dart';
import 'package:ortak_defteri/domain/model/defter_satiri.dart';
import 'package:ortak_defteri/domain/model/ortak.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('Senkron ve Pasif Durum Testleri', () {
    late AppVeritabani db;
    late OrtakRepository repo;

    setUp(() {
      db = AppVeritabani.baglantiIle(DatabaseConnection(NativeDatabase.memory()));
      repo = OrtakRepository(db, null, null);
    });

    tearDown(() async {
      await db.close();
    });

    test('pasifYap ve aktifYap senkronDurumu beklemede olarak kaydeder', () async {
      final Ortak ortak = Ortak(
        id: 'test-1',
        adSoyad: 'Ahmet Yılmaz',
        tcKimlikNo: '12345678901',
        ortakNo: '100',
        aramaAnahtari: 'ahmet yilmaz',
        olusturmaTarihi: DateTime.now(),
        guncellemeTarihi: DateTime.now(),
        aktif: true,
      );

      await repo.ekle(ortak);
      final Ortak? eklenen = await repo.idIleGetir('test-1');
      expect(eklenen, isNotNull);
      expect(eklenen!.aktif, isTrue);

      // Pasif yap
      await repo.pasifYap('test-1', 'İstifa etti');
      final Ortak? pasif = await repo.idIleGetir('test-1');
      expect(pasif!.aktif, isFalse);
      expect(pasif.pasifNedeni, 'İstifa etti');

      // Veritabanı seviyesinde senkronDurumu beklemede olmalı
      final OrtakSatiri? yerelSatir = await db.ortakDao.idIleBul('test-1');
      expect(yerelSatir, isNotNull);
      expect(yerelSatir!.senkronDurumu, SenkronDurumu.beklemede);

      // bekleyenleriGetir listesinde yer almalı
      final List<OrtakSatiri> bekleyenler = await db.ortakDao.bekleyenleriGetir();
      expect(bekleyenler.length, 1);
      expect(bekleyenler.first.id, 'test-1');

      // Aktif yap
      await repo.aktifYap('test-1');
      final Ortak? aktif = await repo.idIleGetir('test-1');
      expect(aktif!.aktif, isTrue);
      expect(aktif.pasifNedeni, isNull);

      final OrtakSatiri? yerelAktif = await db.ortakDao.idIleBul('test-1');
      expect(yerelAktif!.senkronDurumu, SenkronDurumu.beklemede);
    });

    test('ortaginSatirlariniGetir doğrudan satır listesi döner', () async {
      final Ortak ortak = Ortak(
        id: 'test-2',
        adSoyad: 'Mehmet Demir',
        tcKimlikNo: '98765432101',
        ortakNo: '101',
        aramaAnahtari: 'mehmet demir',
        olusturmaTarihi: DateTime.now(),
        guncellemeTarihi: DateTime.now(),
        aktif: true,
      );
      await repo.ekle(ortak);

      await repo.satirEkle(
        const DefterSatiri(
          id: 'satir-1',
          ortakId: 'test-2',
          tur: SatirTuru.sermaye,
          siraNo: 1,
          miktarKurus: 50000,
        ),
      );

      final List<DefterSatiriSatiri> satirlar =
          await db.defterSatiriDao.ortaginSatirlariniGetir('test-2');
      expect(satirlar.length, 1);
      expect(satirlar.first.id, 'satir-1');
      expect(satirlar.first.ortakId, 'test-2');
    });

    test('kaliciSil ortak ve tum defter satirlarini veritabanindan siler', () async {
      final Ortak ortak = Ortak(
        id: 'test-sil-1',
        adSoyad: 'Silinecek Üye',
        tcKimlikNo: '11111111111',
        ortakNo: '999',
        aramaAnahtari: 'silinecek uye',
        olusturmaTarihi: DateTime.now(),
        guncellemeTarihi: DateTime.now(),
        aktif: true,
      );
      await repo.ekle(ortak);
      await repo.satirEkle(
        const DefterSatiri(
          id: 'satir-sil-1',
          ortakId: 'test-sil-1',
          tur: SatirTuru.sermaye,
          siraNo: 1,
          miktarKurus: 100000,
        ),
      );

      expect(await repo.idIleGetir('test-sil-1'), isNotNull);
      expect((await db.defterSatiriDao.ortaginSatirlariniGetir('test-sil-1')).length, 1);

      await repo.kaliciSil('test-sil-1');

      expect(await repo.idIleGetir('test-sil-1'), isNull);
      expect((await db.defterSatiriDao.ortaginSatirlariniGetir('test-sil-1')).isEmpty, isTrue);
    });
  });
}
