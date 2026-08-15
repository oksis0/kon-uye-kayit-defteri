import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tarih biçimlendirme (dd.MM.yyyy gibi) Türkçe yerel ayarla çalışsın diye.
  await initializeDateFormatting('tr_TR');

  runApp(const ProviderScope(child: OrtakDefteriUygulamasi()));
}
