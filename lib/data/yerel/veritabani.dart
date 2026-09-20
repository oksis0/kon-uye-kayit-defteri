import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/enum/kuyruk_durumu.dart';
import '../../domain/enum/satir_turu.dart';
import 'dao/defter_satiri_dao.dart';
import 'dao/kuyruk_dao.dart';
import 'dao/meta_dao.dart';
import 'dao/ortak_dao.dart';
import 'tablolar/defter_satirlari_tablosu.dart';
import 'tablolar/ice_aktarma_kuyrugu_tablosu.dart';
import 'tablolar/ortaklar_tablosu.dart';
import 'tablolar/uygulama_meta_tablosu.dart';

part 'veritabani.g.dart';

/// Uygulamanın yerel SQLite veritabanı. Windows dahil tüm platformlarda
/// `drift_flutter` ile tek satırda kurulur (PLAN.md §13).
///
/// ★ Arama motorumuz bu veritabanıdır — Firestore sadece senkron/yedek
/// deposu (PLAN.md §2.5, yerel-öncelikli arama).
@DriftDatabase(
  tables: [Ortaklar, DefterSatirlari, IceAktarmaKuyrugu, UygulamaMeta],
  daos: [OrtakDao, DefterSatiriDao, KuyrukDao, MetaDao],
)
class AppVeritabani extends _$AppVeritabani {
  AppVeritabani() : super(_veritabaniBaglantisi());

  /// Testlerde bellek-içi veritabanı vermek için.
  AppVeritabani.baglantiIle(super.baglanti);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int eski, int yeni) async {
          if (eski < 2) {
            // ★ createTable her zaman GÜNCEL tablo tanımını kullanır —
            // azureOperationId sütunu burada zaten dahil olur. Bu yüzden
            // aynı geçişte eski < 3 kolunu da çalıştırırsak "duplicate
            // column" hatası alırız (SqliteException code 1).
            await m.createTable(iceAktarmaKuyrugu);
          } else if (eski < 3) {
            await m.addColumn(iceAktarmaKuyrugu, iceAktarmaKuyrugu.azureOperationId);
          }
          if (eski < 4) {
            await m.createTable(uygulamaMeta);
          }
          if (eski < 5) {
            await m.addColumn(ortaklar, ortaklar.sayfaNo);
            await m.addColumn(ortaklar, ortaklar.tcKimlikNo);
          }
          if (eski < 6) {
            await m.addColumn(ortaklar, ortaklar.yerelDosyaYolu);
            await customStatement('''
              UPDATE ortaklar SET yerel_dosya_yolu = (
                SELECT dosya_yolu FROM ice_aktarma_kuyrugu 
                WHERE ice_aktarma_kuyrugu.olusan_ortak_id = ortaklar.id 
                LIMIT 1
              ) WHERE yerel_dosya_yolu IS NULL;
            ''');
          }
        },
      );
}

QueryExecutor _veritabaniBaglantisi() {
  return driftDatabase(name: 'ortak_defteri');
}
