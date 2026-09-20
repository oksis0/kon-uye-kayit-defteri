/// `--dart-define-from-file=env.json` ile derlenmiş yapılandırma değerleri
/// (PLAN.md §12.5). Bunlar gizli değil — Worker URL'i ve Firebase istemci
/// yapılandırması zaten tasarımı gereği açık. Gerçek sırlar (Azure anahtarı,
/// vb.) sadece Cloudflare Worker Secret'larında durur, buraya hiç girmez.
abstract final class Env {
  static const String workerUrl = String.fromEnvironment(
    'WORKER_URL',
    defaultValue: 'https://ortak-defteri-worker.uye-kayit-defteri.workers.dev',
  );
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBHvKsmTMvpmlLYe9jFta8uhpealOThmR0',
  );
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:1035546741648:web:c8250ef151c396355d4115',
  );
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '1035546741648',
  );
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'uye-kayit-defteri',
  );

  /// Bulut özellikleri (senkron, OCR, görsel yükleme) kullanılabilir mi?
  /// `env.json` henüz doldurulmadıysa (örn. Cloudflare/Firebase hesapları
  /// kurulmadan önce) uygulama çökmek yerine bunu kontrol edip kullanıcıya
  /// anlaşılır bir mesaj gösterebilsin diye.
  static bool get bulutYapilandirmasiTamam =>
      workerUrl.isNotEmpty && firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;
}
