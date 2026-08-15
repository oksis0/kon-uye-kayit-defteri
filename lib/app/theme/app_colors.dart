import 'package:flutter/material.dart';

/// Monokromatik + tek accent renk sistemi (sıcak nötr griler + mürekkep
/// mavisi). "Ortak Pay Defteri" fiziksel bir kayıt defteri olduğu için sıcak
/// kağıt tonları tercih edildi — soğuk mavi-gri değil.
///
/// Kodda asla ham `Color(0x...)` yazma; her zaman
/// `Theme.of(context).extension<AppColors>()!` üzerinden eriş.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface,
    required this.surfaceContainer,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.error,
    required this.onError,
  });

  /// Ana zemin — "kağıt" rengi.
  final Color surface;

  /// Kart / satır zemini — [surface]'den bir ton koyu (light) / açık (dark).
  final Color surfaceContainer;

  /// Kenarlık, ayraç çizgisi.
  final Color border;

  final Color textPrimary;
  final Color textSecondary;

  /// Tek accent — birincil eylemler, seçili durumlar, linkler.
  final Color accent;
  final Color onAccent;

  /// Durum renkleri — accent'ten bağımsız, sadece işlevsel
  /// (OCR güven skoru, senkron durumu, hata rozetleri).
  final Color success;
  final Color warning;
  final Color error;
  final Color onError;

  static const AppColors light = AppColors(
    surface: Color(0xFFFAF8F3),
    surfaceContainer: Color(0xFFF1ECE1),
    border: Color(0xFFE2DACB),
    textPrimary: Color(0xFF221F1A),
    textSecondary: Color(0xFF6E6656),
    accent: Color(0xFF1F3A5F),
    onAccent: Color(0xFFFFFFFF),
    success: Color(0xFF2E7D4F),
    warning: Color(0xFFA36A00),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
  );

  static const AppColors dark = AppColors(
    surface: Color(0xFF17150F),
    surfaceContainer: Color(0xFF211E17),
    border: Color(0xFF3A3628),
    textPrimary: Color(0xFFF3EFE4),
    textSecondary: Color(0xFFA79E88),
    accent: Color(0xFF7DA0CC),
    onAccent: Color(0xFF0D1B2A),
    success: Color(0xFF6FBF8B),
    warning: Color(0xFFE0A83E),
    error: Color(0xFFE2867E),
    onError: Color(0xFF3A0A07),
  );

  @override
  AppColors copyWith({
    Color? surface,
    Color? surfaceContainer,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? warning,
    Color? error,
    Color? onError,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      onError: onError ?? this.onError,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// Kısayol: `context.renkler.accent` gibi kullanılır.
  AppColors get renkler => Theme.of(this).extension<AppColors>()!;
}
