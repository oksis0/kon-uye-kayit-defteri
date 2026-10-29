import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/env.dart';
import 'auth_servisi.dart';

part 'worker_istemcisi.g.dart';

/// Cloudflare Worker'a yapılan TÜM HTTP çağrıları tek yerde (PLAN.md §2.3).
///
/// Uygulamanın içinde Azure/R2 anahtarı YOK — her istek Firebase ID
/// token'ı ile imzalanıyor, Worker bunu doğrulayıp Azure/R2'ye erişiyor
/// (PLAN.md §2.4). Bu istemci sadece düz HTTP yapıyor; SigV4 gibi bir
/// imzalama gerekmiyor çünkü R2 binding üzerinden erişiliyor (§2.2).
class WorkerIstemcisi {
  WorkerIstemcisi(this._authServisi)
      : _dio = Dio(
          BaseOptions(
            baseUrl: Env.workerUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 60),
            headers: <String, dynamic>{
              'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
              'Accept': 'application/json',
            },
          ),
        );

  final AuthServisi _authServisi;
  final Dio _dio;

  Future<Options> _yetkiliSecenekler({String? icerikTuru, bool tokenYenile = false}) async {
    final String? token = await _authServisi.idTokenAl(yenile: tokenYenile);
    if (token == null) {
      throw WorkerIstemcisiHatasi('Giriş yapılmamış — Worker isteği gönderilemez.');
    }
    return Options(
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
        if (icerikTuru case final String tur) 'Content-Type': tur,
      },
    );
  }

  /// Ayarlar ekranındaki bağlantı testi için (PLAN.md §2.3). Auth gerektirmez.
  Future<bool> saglikKontrolu() async {
    try {
      final Response<dynamic> yanit = await _dio.get<dynamic>('/saglik');
      return yanit.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  /// Azure OCR analizini başlatır — Worker hemen `operationId` döner,
  /// BEKLEMEZ (§2.3). Bekleme döngüsü [ocrDurumSorgula] ile burada,
  /// istemci tarafında yapılır.
  Future<String> ocrBaslat(Uint8List gorselVerisi) async {
    Options secenekler = await _yetkiliSecenekler(icerikTuru: 'image/jpeg');
    try {
      final Response<Map<String, dynamic>> yanit = await _dio.post<Map<String, dynamic>>(
        '/ocr/basla',
        data: gorselVerisi,
        options: secenekler,
      );
      final String? operationId = yanit.data?['operationId'] as String?;
      if (operationId == null) {
        throw WorkerIstemcisiHatasi('Worker operationId döndürmedi.');
      }
      return operationId;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        try {
          secenekler = await _yetkiliSecenekler(icerikTuru: 'image/jpeg', tokenYenile: true);
          final Response<Map<String, dynamic>> yanit = await _dio.post<Map<String, dynamic>>(
            '/ocr/basla',
            data: gorselVerisi,
            options: secenekler,
          );
          final String? operationId = yanit.data?['operationId'] as String?;
          if (operationId == null) throw WorkerIstemcisiHatasi('Worker operationId döndürmedi.');
          return operationId;
        } on DioException catch (retryErr) {
          throw WorkerIstemcisiHatasi(_dioHataMesaji(retryErr));
        }
      }
      throw WorkerIstemcisiHatasi(_dioHataMesaji(e));
    }
  }

  /// Tek bir durum sorgusu — Worker da tek bir Azure sorgusu yapıp döner,
  /// döngü YOK. İstemci bunu periyodik çağırarak "poll" eder.
  Future<OcrDurumYaniti> ocrDurumSorgula(String operationId) async {
    Options secenekler = await _yetkiliSecenekler();
    try {
      final Response<Map<String, dynamic>> yanit = await _dio.get<Map<String, dynamic>>(
        '/ocr/durum/${Uri.encodeComponent(operationId)}',
        options: secenekler,
      );
      final Map<String, dynamic> veri = yanit.data ?? <String, dynamic>{};
      return OcrDurumYaniti(
        durum: veri['durum'] as String? ?? 'hata',
        sonuc: veri['sonuc'] as Map<String, dynamic>?,
        hataMesaji: veri['mesaj'] as String?,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        try {
          secenekler = await _yetkiliSecenekler(tokenYenile: true);
          final Response<Map<String, dynamic>> yanit = await _dio.get<Map<String, dynamic>>(
            '/ocr/durum/${Uri.encodeComponent(operationId)}',
            options: secenekler,
          );
          final Map<String, dynamic> veri = yanit.data ?? <String, dynamic>{};
          return OcrDurumYaniti(
            durum: veri['durum'] as String? ?? 'hata',
            sonuc: veri['sonuc'] as Map<String, dynamic>?,
            hataMesaji: veri['mesaj'] as String?,
          );
        } on DioException catch (retryErr) {
          throw WorkerIstemcisiHatasi(_dioHataMesaji(retryErr));
        }
      }
      throw WorkerIstemcisiHatasi(_dioHataMesaji(e));
    }
  }

  Future<void> belgeYukle(String anahtar, Uint8List veriler) async {
    Options secenekler = await _yetkiliSecenekler(icerikTuru: 'image/jpeg');
    try {
      await _dio.put<void>(
        '/belge/${Uri.encodeComponent(anahtar)}',
        data: veriler,
        options: secenekler,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        try {
          secenekler = await _yetkiliSecenekler(icerikTuru: 'image/jpeg', tokenYenile: true);
          await _dio.put<void>(
            '/belge/${Uri.encodeComponent(anahtar)}',
            data: veriler,
            options: secenekler,
          );
          return;
        } on DioException catch (retryErr) {
          throw WorkerIstemcisiHatasi(_dioHataMesaji(retryErr));
        }
      }
      throw WorkerIstemcisiHatasi(_dioHataMesaji(e));
    }
  }

  Future<Uint8List> belgeGetir(String anahtar) async {
    Options secenekler = await _yetkiliSecenekler();
    try {
      final Response<List<int>> yanit = await _dio.get<List<int>>(
        '/belge/${Uri.encodeComponent(anahtar)}',
        options: secenekler.copyWith(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(yanit.data ?? const <int>[]);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        try {
          secenekler = await _yetkiliSecenekler(tokenYenile: true);
          final Response<List<int>> yanit = await _dio.get<List<int>>(
            '/belge/${Uri.encodeComponent(anahtar)}',
            options: secenekler.copyWith(responseType: ResponseType.bytes),
          );
          return Uint8List.fromList(yanit.data ?? const <int>[]);
        } on DioException catch (retryErr) {
          throw WorkerIstemcisiHatasi(_dioHataMesaji(retryErr));
        }
      }
      throw WorkerIstemcisiHatasi(_dioHataMesaji(e));
    }
  }

  Future<void> belgeSil(String anahtar) async {
    Options secenekler = await _yetkiliSecenekler();
    try {
      await _dio.delete<void>(
        '/belge/${Uri.encodeComponent(anahtar)}',
        options: secenekler,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        try {
          secenekler = await _yetkiliSecenekler(tokenYenile: true);
          await _dio.delete<void>(
            '/belge/${Uri.encodeComponent(anahtar)}',
            options: secenekler,
          );
          return;
        } on DioException catch (retryErr) {
          throw WorkerIstemcisiHatasi(_dioHataMesaji(retryErr));
        }
      }
      throw WorkerIstemcisiHatasi(_dioHataMesaji(e));
    }
  }

  String _dioHataMesaji(DioException e) {
    final Object? veri = e.response?.data;
    if (veri is Map && veri['hata'] != null) return veri['hata'].toString();
    return e.message ?? 'Bilinmeyen ağ hatası';
  }
}

/// Worker'ın `/ocr/durum/:id` yanıtı (PLAN.md §2.3).
class OcrDurumYaniti {
  const OcrDurumYaniti({required this.durum, this.sonuc, this.hataMesaji});

  /// "bekliyor" | "bitti" | "hata"
  final String durum;
  final Map<String, dynamic>? sonuc;
  final String? hataMesaji;

  bool get bittiMi => durum == 'bitti';
  bool get hataliMi => durum == 'hata';
}

class WorkerIstemcisiHatasi implements Exception {
  WorkerIstemcisiHatasi(this.mesaj);
  final String mesaj;

  @override
  String toString() => mesaj;
}

@Riverpod(keepAlive: true)
WorkerIstemcisi workerIstemcisi(Ref ref) {
  return WorkerIstemcisi(ref.watch(authServisiProvider));
}
