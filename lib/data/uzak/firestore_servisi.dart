import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/env.dart';
import '../../domain/enum/satir_turu.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ortak.dart';
import 'auth_servisi.dart';

part 'firestore_servisi.g.dart';

const Uuid _uuid = Uuid();

/// Ortak kayıtlarının Firestore ile senkronu (PLAN.md §2.5, §4.4).
///
/// ★ Satırlar alt koleksiyon DEĞİL, `ortaklar/{id}` belgesine gömülü bir
/// dizi — 2.000 ortak × ~20 satır alt koleksiyon olsaydı 42.000 okuma
/// olurdu (günlük 50.000 limitine çok yakın); gömülü dizide 2.000 okuma,
/// 20× tasarruf (PLAN.md §4.4).
///
/// ★ Firestore burada ARAMA MOTORU DEĞİL — sadece senkron/yedek deposu.
/// Tüm aramalar yerel Drift üzerinde SQL ile (PLAN.md §2.5).
class FirestoreServisi {
  FirestoreServisi(this._db, [this._authServisi])
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: <String, dynamic>{
              'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
            },
          ),
        );

  final FirebaseFirestore _db;
  final AuthServisi? _authServisi;
  final Dio _dio;

  bool get _yetkili =>
      FirebaseAuth.instance.currentUser != null ||
      (_authServisi != null && _authServisi.girisYapilmis);

  CollectionReference<Map<String, dynamic>> get _ortaklarKoleksiyonu =>
      _db.collection('ortaklar');

  CollectionReference<Map<String, dynamic>> get _silmeTalepleriKoleksiyonu =>
      _db.collection('silmeTalepleri');

  Future<void> ortakYaz(Ortak ortak, List<DefterSatiri> satirlar) async {
    if (!_yetkili) {
      throw Exception('Buluta yazma yetkisi yok (giriş yapılmamış)');
    }
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await _ortaklarKoleksiyonu
            .doc(ortak.id)
            .set(_ortagiDocaCevir(ortak, satirlar))
            .timeout(const Duration(seconds: 4));
        return;
      } catch (e) {
        developer.log('Firestore ortakYaz SDK hatası veya zaman aşımı: $e (REST deneniyor)', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) {
      throw Exception('REST idToken alınamadı veya Firebase ayarları eksik');
    }

    try {
      final Map<String, dynamic> docData = _ortagiDocaCevir(ortak, satirlar);
      final Map<String, dynamic> payload = <String, dynamic>{
        'fields': _haritayiFirestoreFields(docData),
      };
      await _dio.patch<Map<String, dynamic>>(
        'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents/ortaklar/${ortak.id}',
        data: payload,
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      developer.log('Firestore ortakYaz REST hatası: $e', name: 'Firestore');
      rethrow;
    }
  }

  Future<void> ortakSil(String ortakId) async {
    if (!_yetkili) return;
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await _ortaklarKoleksiyonu.doc(ortakId).delete();
        return;
      } catch (e) {
        developer.log('Firestore ortakSil SDK hatası: $e', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) return;

    try {
      await _dio.delete<void>(
        'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents/ortaklar/$ortakId',
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
          },
        ),
      );
    } catch (e) {
      developer.log('Firestore ortakSil REST hatası: $e', name: 'Firestore');
    }
  }

  // ---------------------------------------------------------------------
  // Azure OCR kota sayacı (PLAN.md §9) — `sistem/kota_{yyyy-MM}`.
  // ★ Bu, uygulamanın kendi TAHMİNİ sayacı. Gerçek kaynak Azure paneli;
  // senkronizasyon kayması ihtimaline karşı ayda bir orada doğrulanmalı.
  // ---------------------------------------------------------------------

  Future<int> kotaOku(String ay) async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> anlik =
            await _db.collection('sistem').doc('kota_$ay').get();
        return (anlik.data()?['ocrSayfaSayisi'] as num?)?.toInt() ?? 0;
      } catch (e) {
        developer.log('Firestore kotaOku SDK hatası: $e', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) return 0;

    try {
      final Response<Map<String, dynamic>> res = await _dio.get<Map<String, dynamic>>(
        'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents/sistem/kota_$ay',
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
          },
        ),
      );
      final Map<String, dynamic>? fields = res.data?['fields'] as Map<String, dynamic>?;
      final Object? sayfaObj = fields?['ocrSayfaSayisi'];
      final Object? intVal =
          (sayfaObj is Map<String, dynamic>) ? sayfaObj['integerValue'] : null;
      return int.tryParse(intVal?.toString() ?? '0') ?? 0;
    } catch (e) {
      developer.log('Firestore kotaOku REST hatası: $e', name: 'Firestore');
      return 0;
    }
  }

  /// Atomik artırma — `FieldValue.increment` sayesinde iki OCR isteği aynı
  /// anda gelse bile sayaç kaybolmaz (transaction'a gerek yok).
  Future<void> kotaArtir(String ay) async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await _db.collection('sistem').doc('kota_$ay').set(
          <String, dynamic>{
            'ocrSayfaSayisi': FieldValue.increment(1),
            'sonGuncelleme': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return;
      } catch (e) {
        developer.log('Firestore kotaArtir SDK hatası: $e', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) return;

    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'writes': <Map<String, dynamic>>[
          <String, dynamic>{
            'transform': <String, dynamic>{
              'document':
                  'projects/${Env.firebaseProjectId}/databases/(default)/documents/sistem/kota_$ay',
              'fieldTransforms': <Map<String, dynamic>>[
                <String, dynamic>{
                  'fieldPath': 'ocrSayfaSayisi',
                  'increment': <String, String>{'integerValue': '1'},
                },
                <String, dynamic>{
                  'fieldPath': 'sonGuncelleme',
                  'setToServerValue': 'REQUEST_TIME',
                },
              ],
            },
          },
        ],
      };
      await _dio.post<Map<String, dynamic>>(
        'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents:commit',
        data: payload,
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      developer.log('Firestore kotaArtir REST hatası: $e', name: 'Firestore');
    }
  }

  // ---------------------------------------------------------------------
  // Kalıcı silme — mezar taşı (PLAN.md §10.2). Adım adım silme sırasında
  // elektrik kesilirse, açılışta [silmeTalepleriGetir] ile yarım kalan
  // işlemler bulunup tamamlanabilir.
  // ---------------------------------------------------------------------

  Future<void> silmeTalebiYaz(String ortakId, {String? r2Anahtari, required String adim}) async {
    if (!_yetkili) return;
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await _silmeTalepleriKoleksiyonu.doc(ortakId).set(<String, dynamic>{
          'ortakId': ortakId,
          'r2Anahtari': r2Anahtari,
          'adim': adim,
          'olusturmaTarihi': FieldValue.serverTimestamp(),
        });
        return;
      } catch (e) {
        developer.log('Firestore silmeTalebiYaz SDK hatası: $e', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) return;

    try {
      final Map<String, dynamic> docData = <String, dynamic>{
        'ortakId': ortakId,
        'r2Anahtari': r2Anahtari,
        'adim': adim,
        'olusturmaTarihi': DateTime.now().toUtc(),
      };
      await _dio.patch<Map<String, dynamic>>(
        'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents/silmeTalepleri/$ortakId',
        data: <String, dynamic>{'fields': _haritayiFirestoreFields(docData)},
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      developer.log('Firestore silmeTalebiYaz REST hatası: $e', name: 'Firestore');
    }
  }

  Future<void> silmeTalebiGuncelle(String ortakId, {required String adim}) async {
    if (!_yetkili) return;
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await _silmeTalepleriKoleksiyonu.doc(ortakId).update(<String, dynamic>{'adim': adim});
        return;
      } catch (e) {
        developer.log('Firestore silmeTalebiGuncelle SDK hatası: $e', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) return;

    try {
      await _dio.patch<Map<String, dynamic>>(
        'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents/silmeTalepleri/$ortakId?updateMask.fieldPaths=adim',
        data: <String, dynamic>{
          'fields': <String, dynamic>{
            'adim': <String, String>{'stringValue': adim},
          },
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      developer.log('Firestore silmeTalebiGuncelle REST hatası: $e', name: 'Firestore');
    }
  }

  Future<void> silmeTalebiSil(String ortakId) async {
    if (!_yetkili) return;
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await _silmeTalepleriKoleksiyonu.doc(ortakId).delete();
        return;
      } catch (e) {
        developer.log('Firestore silmeTalebiSil SDK hatası: $e', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) return;

    try {
      await _dio.delete<void>(
        'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents/silmeTalepleri/$ortakId',
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
          },
        ),
      );
    } catch (e) {
      developer.log('Firestore silmeTalebiSil REST hatası: $e', name: 'Firestore');
    }
  }

  /// Açılışta çağrılır — yarım kalan kalıcı silmeleri bulur (PLAN.md §10.2).
  Future<List<SilmeTalebi>> silmeTalepleriGetir() async {
    if (!_yetkili) return const <SilmeTalebi>[];
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        final QuerySnapshot<Map<String, dynamic>> anlik = await _silmeTalepleriKoleksiyonu.get();
        return anlik.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> veri = doc.data();
          return SilmeTalebi(
            ortakId: veri['ortakId'] as String? ?? doc.id,
            r2Anahtari: veri['r2Anahtari'] as String?,
            adim: veri['adim'] as String? ?? 'r2',
          );
        }).toList();
      } catch (e) {
        developer.log('Firestore silmeTalepleriGetir SDK hatası: $e', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) return const <SilmeTalebi>[];

    try {
      final Response<Map<String, dynamic>> res = await _dio.get<Map<String, dynamic>>(
        'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents/silmeTalepleri',
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
          },
        ),
      );
      final List<dynamic>? documents = res.data?['documents'] as List<dynamic>?;
      if (documents == null) return const <SilmeTalebi>[];

      return documents
          .map((dynamic doc) {
            if (doc is! Map<String, dynamic>) {
              return const SilmeTalebi(ortakId: '', adim: 'r2');
            }
            final String? name = doc['name'] as String?;
            final String docId = name?.split('/').last ?? '';
            final Map<String, dynamic>? fields = doc['fields'] as Map<String, dynamic>?;
            final Map<String, dynamic> veri =
                fields != null ? _firestoreFieldsToMap(fields) : <String, dynamic>{};
            return SilmeTalebi(
              ortakId: veri['ortakId'] as String? ?? docId,
              r2Anahtari: veri['r2Anahtari'] as String?,
              adim: veri['adim'] as String? ?? 'r2',
            );
          })
          .where((SilmeTalebi s) => s.ortakId.isNotEmpty)
          .toList();
    } catch (e) {
      developer.log('Firestore silmeTalepleriGetir REST hatası: $e', name: 'Firestore');
      return const <SilmeTalebi>[];
    }
  }

  /// [sonSenkron]'dan sonra güncellenen kayıtları çeker (delta senkron —
  /// PLAN.md §2.5). İlk senkronda [sonSenkron] çok eski bir tarih verilerek
  /// tüm kayıtlar çekilir.
  Future<List<(Ortak, List<DefterSatiri>)>> degisiklikleriGetir(DateTime sonSenkron) async {
    if (!_yetkili) return const <(Ortak, List<DefterSatiri>)>[];
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        final QuerySnapshot<Map<String, dynamic>> anlik = await _ortaklarKoleksiyonu
            .where('guncellemeTarihi', isGreaterThan: Timestamp.fromDate(sonSenkron))
            .get()
            .timeout(const Duration(seconds: 4));

        return anlik.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          return _docuOrtagaCevir(doc.id, doc.data());
        }).toList();
      } catch (e) {
        developer.log('Firestore degisiklikleriGetir SDK hatası veya zaman aşımı: $e (REST deneniyor)', name: 'Firestore');
      }
    }

    final String? token = await _authServisi?.idTokenAl();
    if (token == null || !Env.bulutYapilandirmasiTamam) {
      return const <(Ortak, List<DefterSatiri>)>[];
    }

    try {
      final List<(Ortak, List<DefterSatiri>)> liste = <(Ortak, List<DefterSatiri>)>[];
      String? pageToken;
      do {
        final Map<String, dynamic> queryParams = <String, dynamic>{
          'pageSize': 300,
          if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
        };
        final Response<Map<String, dynamic>> res = await _dio.get<Map<String, dynamic>>(
          'https://firestore.googleapis.com/v1/projects/${Env.firebaseProjectId}/databases/(default)/documents/ortaklar',
          queryParameters: queryParams,
          options: Options(
            headers: <String, String>{
              'Authorization': 'Bearer $token',
              'User-Agent': 'OrtakDefteri/1.0.0 (Dart/Flutter; Desktop/Mobile)',
            },
          ),
        );
        final List<dynamic>? documents = res.data?['documents'] as List<dynamic>?;
        if (documents != null) {
          for (final dynamic doc in documents) {
            if (doc is! Map<String, dynamic>) continue;
            final String? name = doc['name'] as String?;
            final String docId = name?.split('/').last ?? '';
            final Map<String, dynamic>? fields = doc['fields'] as Map<String, dynamic>?;
            if (fields == null) continue;
            final Map<String, dynamic> veri = _firestoreFieldsToMap(fields);
            final dynamic gt = veri['guncellemeTarihi'];
            final DateTime? guncelleme = gt is Timestamp
                ? gt.toDate()
                : (gt is DateTime ? gt : (gt is String ? DateTime.tryParse(gt) : null));
            if (guncelleme == null || guncelleme.isAfter(sonSenkron)) {
              liste.add(_docuOrtagaCevir(docId, veri));
            }
          }
        }
        pageToken = res.data?['nextPageToken'] as String?;
      } while (pageToken != null && pageToken.isNotEmpty);

      return liste;
    } catch (e) {
      developer.log('Firestore degisiklikleriGetir REST hatası: $e', name: 'Firestore');
      return const <(Ortak, List<DefterSatiri>)>[];
    }
  }

  Map<String, dynamic> _haritayiFirestoreFields(Map<String, dynamic> harita) {
    return harita.map(
      (String k, dynamic v) => MapEntry<String, dynamic>(k, _degeriFirestoreVal(v)),
    );
  }

  Map<String, dynamic> _degeriFirestoreVal(dynamic val) {
    if (val == null) return <String, dynamic>{'nullValue': null};
    if (val is bool) return <String, dynamic>{'booleanValue': val};
    if (val is int) return <String, dynamic>{'integerValue': val.toString()};
    if (val is double) return <String, dynamic>{'doubleValue': val};
    if (val is String) return <String, dynamic>{'stringValue': val};
    if (val is Timestamp) {
      return <String, dynamic>{'timestampValue': val.toDate().toUtc().toIso8601String()};
    }
    if (val is DateTime) {
      return <String, dynamic>{'timestampValue': val.toUtc().toIso8601String()};
    }
    if (val is List) {
      return <String, dynamic>{
        'arrayValue': <String, dynamic>{
          'values': val.map(_degeriFirestoreVal).toList(),
        },
      };
    }
    if (val is Map<String, dynamic>) {
      return <String, dynamic>{
        'mapValue': <String, dynamic>{
          'fields': _haritayiFirestoreFields(val),
        },
      };
    }
    return <String, dynamic>{'stringValue': val.toString()};
  }

  Map<String, dynamic> _firestoreFieldsToMap(Map<String, dynamic> fields) {
    return fields.map(
      (String k, dynamic v) => MapEntry<String, dynamic>(k, _firestoreValToNative(v)),
    );
  }

  dynamic _firestoreValToNative(dynamic val) {
    if (val is! Map<String, dynamic>) return val;
    if (val.containsKey('nullValue')) return null;
    if (val.containsKey('booleanValue')) return val['booleanValue'] as bool;
    if (val.containsKey('integerValue')) {
      return int.tryParse(val['integerValue'].toString()) ?? 0;
    }
    if (val.containsKey('doubleValue')) {
      return (val['doubleValue'] as num).toDouble();
    }
    if (val.containsKey('stringValue')) return val['stringValue'] as String;
    if (val.containsKey('timestampValue')) {
      final DateTime? dt = DateTime.tryParse(val['timestampValue'].toString());
      return dt != null ? Timestamp.fromDate(dt) : null;
    }
    if (val.containsKey('arrayValue')) {
      final List<dynamic>? values =
          (val['arrayValue'] as Map<String, dynamic>?)?['values'] as List<dynamic>?;
      return values?.map(_firestoreValToNative).toList() ?? <dynamic>[];
    }
    if (val.containsKey('mapValue')) {
      final Map<String, dynamic>? innerFields =
          (val['mapValue'] as Map<String, dynamic>?)?['fields'] as Map<String, dynamic>?;
      return innerFields != null ? _firestoreFieldsToMap(innerFields) : <String, dynamic>{};
    }
    return val;
  }

  Map<String, dynamic> _ortagiDocaCevir(Ortak ortak, List<DefterSatiri> satirlar) {
    Timestamp? zaman(DateTime? t) => t == null ? null : Timestamp.fromDate(t);

    return <String, dynamic>{
      'ortakNo': ortak.ortakNo,
      'sayfaNo': ortak.sayfaNo,
      'tcKimlikNo': ortak.tcKimlikNo,
      'adSoyad': ortak.adSoyad,
      'babaAdi': ortak.babaAdi,
      'dogumYeri': ortak.dogumYeri,
      'dogumTarihiHam': ortak.dogumTarihiHam,
      'dogumTarihi': zaman(ortak.dogumTarihi),
      'girisTarihiHam': ortak.girisTarihiHam,
      'girisTarihi': zaman(ortak.girisTarihi),
      'cikisTarihiHam': ortak.cikisTarihiHam,
      'cikisTarihi': zaman(ortak.cikisTarihi),
      'ikametAdresi': ortak.ikametAdresi,
      'nufusKayitYeri': ortak.nufusKayitYeri,
      'aramaAnahtari': ortak.aramaAnahtari,
      'belgeR2Anahtari': ortak.belgeR2Anahtari,
      'ocrGuvenOrtalama': ortak.ocrGuvenOrtalama,
      'aktif': ortak.aktif,
      'pasifNedeni': ortak.pasifNedeni,
      'pasifTarihi': zaman(ortak.pasifTarihi),
      'olusturmaTarihi': Timestamp.fromDate(ortak.olusturmaTarihi),
      'guncellemeTarihi': Timestamp.fromDate(ortak.guncellemeTarihi),
      'satirlar': satirlar.map(_satiriMapaCevir).toList(),
    };
  }

  Map<String, dynamic> _satiriMapaCevir(DefterSatiri satir) {
    return <String, dynamic>{
      // ★ Satır id'si de yazılıyor — pull sırasında aynı satırı tanıyıp
      // güncelleyebilelim diye (yoksa her pull'da satırlar çoğalırdı).
      'id': satir.id,
      'tur': satir.tur.name,
      'siraNo': satir.siraNo,
      'tarihHam': satir.tarihHam,
      'tarih': satir.tarih == null ? null : Timestamp.fromDate(satir.tarih!),
      'no': satir.no,
      'madde': satir.madde,
      'aciklama': satir.aciklama,
      'miktarKurus': satir.miktarKurus,
      'yekunKurus': satir.yekunKurus,
      'miktarHam': satir.miktarHam,
      'yekunHam': satir.yekunHam,
    };
  }

  (Ortak, List<DefterSatiri>) _docuOrtagaCevir(String id, Map<String, dynamic> veri) {
    DateTime? zamanCoz(Object? deger) => deger is Timestamp ? deger.toDate() : null;

    final Ortak ortak = Ortak(
      id: id,
      ortakNo: veri['ortakNo'] as String? ?? '',
      sayfaNo: veri['sayfaNo'] as String?,
      tcKimlikNo: veri['tcKimlikNo'] as String?,
      adSoyad: veri['adSoyad'] as String? ?? '',
      babaAdi: veri['babaAdi'] as String?,
      dogumYeri: veri['dogumYeri'] as String?,
      dogumTarihiHam: veri['dogumTarihiHam'] as String?,
      dogumTarihi: zamanCoz(veri['dogumTarihi']),
      girisTarihiHam: veri['girisTarihiHam'] as String?,
      girisTarihi: zamanCoz(veri['girisTarihi']),
      cikisTarihiHam: veri['cikisTarihiHam'] as String?,
      cikisTarihi: zamanCoz(veri['cikisTarihi']),
      ikametAdresi: veri['ikametAdresi'] as String?,
      nufusKayitYeri: veri['nufusKayitYeri'] as String?,
      aramaAnahtari: veri['aramaAnahtari'] as String? ?? '',
      belgeR2Anahtari: veri['belgeR2Anahtari'] as String?,
      ocrGuvenOrtalama: (veri['ocrGuvenOrtalama'] as num?)?.toDouble(),
      aktif: veri['aktif'] as bool? ?? true,
      pasifNedeni: veri['pasifNedeni'] as String?,
      pasifTarihi: zamanCoz(veri['pasifTarihi']),
      olusturmaTarihi: zamanCoz(veri['olusturmaTarihi']) ?? DateTime.now(),
      guncellemeTarihi: zamanCoz(veri['guncellemeTarihi']) ?? DateTime.now(),
    );

    final List<dynamic> hamSatirlar = veri['satirlar'] as List<dynamic>? ?? const <dynamic>[];
    final List<DefterSatiri> satirlar = hamSatirlar.map((Object? s) {
      final Map<String, dynamic> m = s as Map<String, dynamic>;
      return DefterSatiri(
        id: (m['id'] as String?) ?? _uuid.v4(),
        ortakId: id,
        tur: (m['tur'] as String?) == 'odeme' ? SatirTuru.odeme : SatirTuru.sermaye,
        siraNo: m['siraNo'] as int? ?? 0,
        tarihHam: m['tarihHam'] as String?,
        tarih: zamanCoz(m['tarih']),
        no: m['no'] as String?,
        madde: m['madde'] as String?,
        aciklama: m['aciklama'] as String?,
        miktarKurus: m['miktarKurus'] as int? ?? 0,
        yekunKurus: m['yekunKurus'] as int? ?? 0,
        miktarHam: m['miktarHam'] as String?,
        yekunHam: m['yekunHam'] as String?,
      );
    }).toList();

    return (ortak, satirlar);
  }
}

/// Kalıcı silme mezar taşı (PLAN.md §10.2). [adim] hangi aşamada
/// kalındığını gösterir: `"r2"` → R2 henüz silinmedi, `"firestore"` →
/// R2 silindi ama Firestore kaydı duruyor, `"yerel"` → ikisi de silindi,
/// sadece yerel Drift kaydı kaldı.
class SilmeTalebi {
  const SilmeTalebi({required this.ortakId, this.r2Anahtari, required this.adim});
  final String ortakId;
  final String? r2Anahtari;
  final String adim;
}

/// ★ Sadece `Env.bulutYapilandirmasiTamam == true` iken okunmalı —
/// `FirebaseFirestore.instance` Firebase başlatılmadan çağrılırsa hata
/// fırlatır. Riverpod tembel (lazy) olduğu için bu provider hiç
/// `watch`/`read` edilmezse `FirebaseFirestore.instance`'a hiç dokunulmaz.
@Riverpod(keepAlive: true)
FirestoreServisi firestoreServisi(Ref ref) =>
    FirestoreServisi(FirebaseFirestore.instance, ref.watch(authServisiProvider));
