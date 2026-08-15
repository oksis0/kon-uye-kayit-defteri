import 'package:flutter/material.dart';

/// Tipografi hiyerarşisi: Display / Headline / Title / Body / Caption.
///
/// İki font ailesi:
/// - **Plus Jakarta Sans** — arayüz/gövde metni (Inter yasak, CLAUDE.md)
/// - **IBM Plex Mono** — sadece sayısal/tablo verisi. Sabit genişlikli
///   rakamlar sayesinde para sütunlarında haneler alt alta hizalanır;
///   muhasebe tablosunda bu okunabilirlik farkı yaratır.
abstract final class AppTypography {
  static const String _arayuzAile = 'PlusJakartaSans';
  static const String _sayisalAile = 'IBMPlexMono';

  static const TextStyle display = TextStyle(
    fontFamily: _arayuzAile,
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: _arayuzAile,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _arayuzAile,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _arayuzAile,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyVurgulu = TextStyle(
    fontFamily: _arayuzAile,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _arayuzAile,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  /// Sermaye/ödeme tablolarındaki miktar hücreleri, ortak no gibi
  /// hizalanması gereken sayısal alanlar için. Sabit genişlikli rakamlar.
  static const TextStyle sayisalTablo = TextStyle(
    fontFamily: _sayisalAile,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle sayisalBuyuk = TextStyle(
    fontFamily: _sayisalAile,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(Color renk) {
    return TextTheme(
      displayLarge: display.copyWith(color: renk),
      headlineMedium: headline.copyWith(color: renk),
      titleMedium: title.copyWith(color: renk),
      bodyMedium: body.copyWith(color: renk),
      bodyLarge: bodyVurgulu.copyWith(color: renk),
      labelSmall: caption.copyWith(color: renk),
    );
  }
}
