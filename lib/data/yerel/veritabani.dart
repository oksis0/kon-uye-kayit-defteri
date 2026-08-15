import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/enum/kuyruk_durumu.dart';
import '../../domain/enum/satir_turu.dart';
import 'dao/defter_satiri_dao.dart';
import 'dao/kuyruk_dao.dart';
import 'dao/ortak_dao.dart';
import 'tablolar/defter_satirlari_tablosu.dart';
import 'tablolar/ice_aktarma_kuyrugu_tablosu.dart';
import 'tablolar/ortaklar_tablosu.dart';

part 'veritabani.g.dart';

/// Uygulamanın yerel SQLite veritabanı. Windows dahil tüm platformlarda
/// `drift_flutter` ile tek satırda kurulur (PLAN.md §13).
///
/// ★ Arama motorumuz bu veritabanıdır — Firestore sadece senkron/yedek
/// deposu (PLAN.md §2.5, yerel-öncelikli arama).
@DriftDatabase(
  tables: [Ortaklar, DefterSatirlari, IceAktarmaKuyrugu],
  daos: [OrtakDao, DefterSatiriDao, KuyrukDao],
)
class AppVeritabani extends _$AppVeritabani {
  AppVeritabani() : super(_veritabaniBaglantisi());

  /// Testlerde bellek-içi veritabanı vermek için.
  AppVeritabani.baglantiIle(super.baglanti);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int eski, int yeni) async {
          if (eski < 2) {
            await m.createTable(iceAktarmaKuyrugu);
          }
        },
      );
}

QueryExecutor _veritabaniBaglantisi() {
  return driftDatabase(name: 'ortak_defteri');
}
