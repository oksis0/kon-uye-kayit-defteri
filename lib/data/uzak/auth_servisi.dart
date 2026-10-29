import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/env.dart';

part 'auth_servisi.g.dart';

/// Kimlik doğrulama sırasında oluşan hatalar.
class AuthServisiHatasi implements Exception {
  const AuthServisiHatasi(this.mesaj);
  final String mesaj;

  @override
  String toString() => mesaj;
}

/// PLAN.md §12.2 — tek ortak hesap girişi. Kayıt ol / şifre sıfırla ekranı
/// YOK; kod içinde `createUserWithEmailAndPassword` çağrısı bilinçli olarak
/// bulunmuyor. Tek hesap Firebase Konsolu'ndan elle oluşturulur.
class AuthServisi {
  AuthServisi(this._auth) {
    _authAbonelik = _auth.authStateChanges().listen((User? user) {
      _authDurumKontrolcu.add(user);
    });
    unawaited(_oturumYukle());
  }

  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authAbonelik;
  final StreamController<User?> _authDurumKontrolcu = StreamController<User?>.broadcast();
  final Completer<void> _oturumHazir = Completer<void>();
  bool _yerelGirisYapildi = false;

  String? _restIdToken;
  String? _restRefreshToken;
  String? _restUid;
  String? _restEPosta;
  DateTime? _restTokenBitis;

  Stream<User?> get kullaniciDegisiklikleri => _authDurumKontrolcu.stream;
  User? get mevcutKullanici => _auth.currentUser;
  String? get mevcutKullaniciEPosta => _auth.currentUser?.email ?? _restEPosta;
  String? get mevcutKullaniciUid => _auth.currentUser?.uid ?? _restUid;
  bool get girisYapilmis =>
      _yerelGirisYapildi || _restIdToken != null || _auth.currentUser != null;

  void yerelGirisYap() {
    _yerelGirisYapildi = true;
    _authDurumKontrolcu.add(_auth.currentUser);
  }

  Future<void> girisYap({required String ePosta, required String sifre}) async {
    if (Platform.isWindows || Platform.isLinux) {
      await _restGirisYap(ePosta: ePosta, sifre: sifre);
      return;
    }
    try {
      await _auth
          .signInWithEmailAndPassword(email: ePosta, password: sifre)
          .timeout(const Duration(seconds: 4));
      await _oturumTemizleYerel();
      _yerelGirisYapildi = false;
      _authDurumKontrolcu.add(_auth.currentUser);
    } catch (e) {
      developer.log('Native signInWithEmailAndPassword hatası: $e (REST deneniyor)', name: 'AuthServisi');
      final String hataMetni = e.toString().toLowerCase();
      // Kullanıcı veya şifre doğrudan yanlışsa rethrow
      if (hataMetni.contains('wrong-password') ||
          hataMetni.contains('user-not-found') ||
          hataMetni.contains('invalid-credential') ||
          hataMetni.contains('user-disabled') ||
          hataMetni.contains('invalid-email')) {
        rethrow;
      }
      // Ağ hatası (network-request-failed), zaman aşımı, keychain veya native SDK erişim engellerinde REST API ile giriş yap:
      try {
        await _restGirisYap(ePosta: ePosta, sifre: sifre);
        return;
      } catch (restHata) {
        developer.log('REST girisYap da başarısız: $restHata', name: 'AuthServisi');
        rethrow;
      }
    }
  }

  Future<void> _restGirisYap({required String ePosta, required String sifre}) async {
    if (!Env.bulutYapilandirmasiTamam || Env.firebaseApiKey.isEmpty) {
      yerelGirisYap();
      return;
    }

    try {
      final Dio dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final Response<Map<String, dynamic>> yanit = await dio.post<Map<String, dynamic>>(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${Env.firebaseApiKey}',
        data: <String, dynamic>{
          'email': ePosta.trim(),
          'password': sifre,
          'returnSecureToken': true,
        },
        options: Options(contentType: 'application/json'),
      );

      final Map<String, dynamic>? veri = yanit.data;
      if (veri != null) {
        _restIdToken = veri['idToken'] as String?;
        _restRefreshToken = veri['refreshToken'] as String?;
        _restUid = veri['localId'] as String?;
        _restEPosta = veri['email'] as String?;
        final int expiresIn = int.tryParse(veri['expiresIn']?.toString() ?? '3600') ?? 3600;
        _restTokenBitis = DateTime.now().add(Duration(seconds: expiresIn - 60));
        _yerelGirisYapildi = true;

        await _oturumKaydet();
        _authDurumKontrolcu.add(_auth.currentUser);
      }
    } on DioException catch (dioErr) {
      final Object? hataVerisi = dioErr.response?.data;
      String mesaj = 'Giriş yapılamadı.';
      if (hataVerisi is Map<String, dynamic>) {
        final Object? errorObj = hataVerisi['error'];
        if (errorObj is Map<String, dynamic>) {
          final String hataKodu = errorObj['message']?.toString() ?? '';
          if (hataKodu.contains('EMAIL_NOT_FOUND') ||
              hataKodu.contains('INVALID_PASSWORD') ||
              hataKodu.contains('INVALID_LOGIN_CREDENTIALS')) {
            mesaj = 'E-posta veya şifre hatalı.';
          } else if (hataKodu.contains('USER_DISABLED')) {
            mesaj = 'Bu kullanıcı hesabı devre dışı bırakılmış.';
          } else if (hataKodu.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
            mesaj = 'Çok fazla başarısız deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
          } else {
            mesaj = 'Giriş hatası: $hataKodu';
          }
        }
      } else if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout ||
          dioErr.type == DioExceptionType.connectionError) {
        mesaj = 'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.';
      }
      throw AuthServisiHatasi(mesaj);
    } catch (e) {
      if (e is AuthServisiHatasi) rethrow;
      throw AuthServisiHatasi('Giriş başarısız: $e');
    }
  }

  Future<void> _restTokenYenile() async {
    if (_restRefreshToken == null || !Env.bulutYapilandirmasiTamam || Env.firebaseApiKey.isEmpty) {
      return;
    }

    try {
      final Dio dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final Response<Map<String, dynamic>> yanit = await dio.post<Map<String, dynamic>>(
        'https://securetoken.googleapis.com/v1/token?key=${Env.firebaseApiKey}',
        data: <String, String>{
          'grant_type': 'refresh_token',
          'refresh_token': _restRefreshToken!,
        },
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      final Map<String, dynamic>? veri = yanit.data;
      if (veri != null) {
        _restIdToken = veri['id_token'] as String?;
        _restRefreshToken = veri['refresh_token'] as String?;
        final int expiresIn = int.tryParse(veri['expires_in']?.toString() ?? '3600') ?? 3600;
        _restTokenBitis = DateTime.now().add(Duration(seconds: expiresIn - 60));
        await _oturumKaydet();
      }
    } catch (e) {
      developer.log('REST token yenileme hatası: $e', name: 'AuthServisi');
    }
  }

  Future<File?> _oturumDosyasiAl() async {
    try {
      final Directory dir = await getApplicationSupportDirectory();
      return File('${dir.path}/rest_auth_session.json');
    } catch (_) {
      return null;
    }
  }

  Future<void> _oturumKaydet() async {
    try {
      final File? dosya = await _oturumDosyasiAl();
      if (dosya == null) return;
      final Map<String, dynamic> veri = <String, dynamic>{
        'idToken': _restIdToken,
        'refreshToken': _restRefreshToken,
        'uid': _restUid,
        'email': _restEPosta,
        'tokenBitis': _restTokenBitis?.toIso8601String(),
      };
      await dosya.writeAsString(jsonEncode(veri));
    } catch (e) {
      developer.log('Oturum kaydedilemedi: $e', name: 'AuthServisi');
    }
  }

  Future<void> _oturumYukle() async {
    try {
      final File? dosya = await _oturumDosyasiAl();
      if (dosya == null || !await dosya.exists()) return;
      final String icerik = await dosya.readAsString();
      final dynamic json = jsonDecode(icerik);
      if (json is! Map<String, dynamic>) return;
      _restIdToken = json['idToken'] as String?;
      _restRefreshToken = json['refreshToken'] as String?;
      _restUid = json['uid'] as String?;
      _restEPosta = json['email'] as String?;
      if (json['tokenBitis'] != null) {
        _restTokenBitis = DateTime.tryParse(json['tokenBitis'] as String);
      }
      if (_restIdToken != null) {
        _yerelGirisYapildi = true;
        _authDurumKontrolcu.add(_auth.currentUser);
      }
    } catch (e) {
      developer.log('Oturum yüklenemedi: $e', name: 'AuthServisi');
    } finally {
      if (!_oturumHazir.isCompleted) {
        _oturumHazir.complete();
      }
    }
  }

  Future<void> _oturumTemizleYerel() async {
    _restIdToken = null;
    _restRefreshToken = null;
    _restUid = null;
    _restEPosta = null;
    _restTokenBitis = null;
    try {
      final File? dosya = await _oturumDosyasiAl();
      if (dosya != null && await dosya.exists()) {
        await dosya.delete();
      }
    } catch (_) {}
  }

  Future<void> cikisYap() async {
    _yerelGirisYapildi = false;
    await _oturumTemizleYerel();
    _authDurumKontrolcu.add(null);
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  /// Worker isteklerinde `Authorization: Bearer <token>` için
  /// (PLAN.md §2.4). `yenile: true` süresi dolmuş token'ı zorla yeniler.
  Future<String?> idTokenAl({bool yenile = false}) async {
    if (!_oturumHazir.isCompleted) {
      await _oturumHazir.future;
    }
    if (_auth.currentUser != null) {
      try {
        return await _auth.currentUser!.getIdToken(yenile);
      } catch (_) {}
    }
    if (_restIdToken != null) {
      final DateTime simdi = DateTime.now();
      if (yenile || (_restTokenBitis != null && simdi.isAfter(_restTokenBitis!))) {
        await _restTokenYenile();
      }
      return _restIdToken;
    }
    return null;
  }

  void dispose() {
    _authAbonelik?.cancel();
    _authDurumKontrolcu.close();
  }
}

@Riverpod(keepAlive: true)
AuthServisi authServisi(Ref ref) {
  final AuthServisi servis = AuthServisi(FirebaseAuth.instance);
  ref.onDispose(servis.dispose);
  return servis;
}

/// Giriş durumunu canlı izler — router guard ve giriş ekranı bunu kullanır.
@riverpod
Stream<User?> authDurumu(Ref ref) {
  return ref.watch(authServisiProvider).kullaniciDegisiklikleri;
}
