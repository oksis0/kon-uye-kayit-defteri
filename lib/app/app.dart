import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class OrtakDefteriUygulamasi extends StatelessWidget {
  const OrtakDefteriUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ortak Pay Defteri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const <Locale>[Locale('tr', 'TR')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
