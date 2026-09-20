import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tarih biçimlendirme (dd.MM.yyyy gibi) Türkçe yerel ayarla çalışsın diye.
  await initializeDateFormatting('tr_TR');

  // ★ Firebase, sadece env.json doldurulmuşsa başlatılır. Doldurulmamışsa
  // uygulama Faz 1-2'deki gibi tamamen çevrimdışı çalışmaya devam eder —
  // Cloudflare/Firebase/Azure hesapları kurulana kadar hiçbir şey bozulmaz
  // (PLAN.md §12.5).
  if (Env.bulutYapilandirmasiTamam) {
    try {
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        // ★★★ ÖNEMLİ (Faz 4'ün gözden kaçırdığı nokta — Faz sonrası düzeltildi):
        // Android/iOS/macOS'ta native Firebase SDK'sı, verilen `appId`'nin
        // KENDİ platformuna ait formatta olmasını istiyor (örn. `...:ios:...`,
        // `...:android:...`) — tek bir "web" appId'sini her platforma
        // dart-define ile geçirmek macOS'ta "Configuration fails: invalid
        // GOOGLE_APP_ID" diyerek uygulamayı ANINDA ÇÖKERTİYOR.
        //
        // Çözüm: bu üç platformda `FirebaseOptions` HİÇ VERİLMİYOR — native
        // SDK, `ios/Runner/GoogleService-Info.plist`,
        // `macos/Runner/GoogleService-Info.plist` ve
        // `android/app/google-services.json` dosyalarını otomatik okuyor.
        await Firebase.initializeApp();
      } else {
        // Windows (ve varsa Linux/Web) için açık FirebaseOptions veriliyor.
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: Env.firebaseApiKey,
            appId: Env.firebaseAppId,
            messagingSenderId: Env.firebaseMessagingSenderId,
            projectId: Env.firebaseProjectId,
          ),
        );
      }
    } catch (e, s) {
      developer.log(
        'Firebase başlatılamadı, uygulama çevrimdışı modda devam ediyor: $e',
        name: 'Main',
        error: e,
        stackTrace: s,
      );
    }
  }

  runApp(const ProviderScope(child: OrtakDefteriUygulamasi()));
}
