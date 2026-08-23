import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_servisi.g.dart';

/// PLAN.md §12.2 — tek ortak hesap girişi. Kayıt ol / şifre sıfırla ekranı
/// YOK; kod içinde `createUserWithEmailAndPassword` çağrısı bilinçli olarak
/// bulunmuyor. Tek hesap Firebase Konsolu'ndan elle oluşturulur.
class AuthServisi {
  AuthServisi(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get kullaniciDegisiklikleri => _auth.authStateChanges();
  User? get mevcutKullanici => _auth.currentUser;
  bool get girisYapilmis => _auth.currentUser != null;

  Future<void> girisYap({required String ePosta, required String sifre}) async {
    await _auth.signInWithEmailAndPassword(email: ePosta, password: sifre);
  }

  Future<void> cikisYap() => _auth.signOut();

  /// Worker isteklerinde `Authorization: Bearer <token>` için
  /// (PLAN.md §2.4). `yenile: true` süresi dolmuş token'ı zorla yeniler.
  Future<String?> idTokenAl({bool yenile = false}) async {
    return _auth.currentUser?.getIdToken(yenile);
  }
}

@Riverpod(keepAlive: true)
AuthServisi authServisi(Ref ref) => AuthServisi(FirebaseAuth.instance);

/// Giriş durumunu canlı izler — router guard ve giriş ekranı bunu kullanır.
@riverpod
Stream<User?> authDurumu(Ref ref) {
  return ref.watch(authServisiProvider).kullaniciDegisiklikleri;
}
