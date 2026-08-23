import 'package:drift/drift.dart';

import '../tablolar/uygulama_meta_tablosu.dart';
import '../veritabani.dart';

part 'meta_dao.g.dart';

const String anahtarSonSenkron = 'son_firestore_senkron';
const String anahtarSonYedek = 'son_yedek_tarihi';

@DriftAccessor(tables: [UygulamaMeta])
class MetaDao extends DatabaseAccessor<AppVeritabani> with _$MetaDaoMixin {
  MetaDao(super.db);

  Future<String?> degerAl(String anahtar) async {
    final UygulamaMetaSatiri? satir =
        await (select(uygulamaMeta)..where((t) => t.anahtar.equals(anahtar))).getSingleOrNull();
    return satir?.deger;
  }

  Future<void> degerYaz(String anahtar, String deger) {
    return into(uygulamaMeta).insertOnConflictUpdate(
      UygulamaMetaCompanion.insert(anahtar: anahtar, deger: deger),
    );
  }
}
