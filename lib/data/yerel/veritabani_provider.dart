import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'veritabani.dart';

part 'veritabani_provider.g.dart';

/// Uygulama boyunca tek bir veritabanı bağlantısı — `keepAlive: true`,
/// çünkü kapanıp yeniden açılması gereksiz ve dosya kilidi sorunlarına
/// yol açabilir.
@Riverpod(keepAlive: true)
AppVeritabani veritabani(Ref ref) {
  final AppVeritabani db = AppVeritabani();
  ref.onDispose(db.close);
  return db;
}
