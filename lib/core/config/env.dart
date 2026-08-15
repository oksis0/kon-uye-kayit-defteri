/// `--dart-define-from-file=env.json` ile derlenmiş yapılandırma değerleri
/// (PLAN.md §12.5). Bunlar gizli değil — Worker URL'i ve Firebase istemci
/// yapılandırması zaten tasarımı gereği açık. Gerçek sırlar (Azure anahtarı,
/// vb.) sadece Cloudflare Worker Secret'larında durur, buraya hiç girmez.
abstract final class Env {
  static const String workerUrl = String.fromEnvironment('WORKER_URL');
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String firebaseMessagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  /// Bulut özellikleri (senkron, OCR, görsel yükleme) kullanılabilir mi?
  /// `env.json` henüz doldurulmadıysa (örn. Cloudflare/Firebase hesapları
  /// kurulmadan önce) uygulama çökmek yerine bunu kontrol edip kullanıcıya
  /// anlaşılır bir mesaj gösterebilsin diye.
  static bool get bulutYapilandirmasiTamam =>
      workerUrl.isNotEmpty && firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;
}
