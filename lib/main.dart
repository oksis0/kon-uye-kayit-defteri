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
  // (PLAN.md §12.5). `flutterfire configure` KULLANILMIYOR — Firebase
  // yapılandırması da diğer her şey gibi tek bir --dart-define-from-file
  // mekanizmasından geçiyor.
  if (Env.bulutYapilandirmasiTamam) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppId,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
      ),
    );
  }

  runApp(const ProviderScope(child: OrtakDefteriUygulamasi()));
}
