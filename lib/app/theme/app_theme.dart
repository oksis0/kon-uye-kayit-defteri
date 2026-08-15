import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Uygulama teması. `ColorScheme.fromSeed` KULLANILMIYOR — Material 3'ün
/// varsayılan tohum rengi mor tonlarına kayıyor (CLAUDE.md: "purple gradient
/// on white" yasak). Bunun yerine [AppColors]'taki her rol elle atanıyor.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors renkler, Brightness parlaklik) {
    final ColorScheme colorScheme = ColorScheme(
      brightness: parlaklik,
      primary: renkler.accent,
      onPrimary: renkler.onAccent,
      primaryContainer: renkler.accent,
      onPrimaryContainer: renkler.onAccent,
      secondary: renkler.accent,
      onSecondary: renkler.onAccent,
      secondaryContainer: renkler.surfaceContainer,
      onSecondaryContainer: renkler.textPrimary,
      tertiary: renkler.accent,
      onTertiary: renkler.onAccent,
      error: renkler.error,
      onError: renkler.onError,
      errorContainer: renkler.error,
      onErrorContainer: renkler.onError,
      surface: renkler.surface,
      onSurface: renkler.textPrimary,
      surfaceContainerHighest: renkler.surfaceContainer,
      onSurfaceVariant: renkler.textSecondary,
      outline: renkler.border,
      outlineVariant: renkler.border,
      inverseSurface: renkler.textPrimary,
      onInverseSurface: renkler.surface,
      inversePrimary: renkler.accent,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );

    final TextTheme textTheme = AppTypography.textTheme(renkler.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: parlaklik,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: renkler.surface,
      textTheme: textTheme,
      fontFamily: 'PlusJakartaSans',
      extensions: <ThemeExtension<dynamic>>[renkler],
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: renkler.surface,
        foregroundColor: renkler.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: AppTypography.title.copyWith(color: renkler.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: renkler.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: renkler.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: renkler.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: renkler.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: renkler.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: renkler.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: renkler.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: renkler.error),
        ),
        labelStyle: AppTypography.body.copyWith(color: renkler.textSecondary),
        hintStyle: AppTypography.body.copyWith(color: renkler.textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: renkler.accent,
          foregroundColor: renkler.onAccent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTypography.bodyVurgulu,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: renkler.textPrimary,
          side: BorderSide(color: renkler.border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTypography.bodyVurgulu,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: renkler.accent,
          textStyle: AppTypography.bodyVurgulu,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: renkler.surfaceContainer,
        side: BorderSide(color: renkler.border),
        labelStyle: AppTypography.caption.copyWith(color: renkler.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: renkler.surface,
        selectedIconTheme: IconThemeData(color: renkler.accent),
        unselectedIconTheme: IconThemeData(color: renkler.textSecondary),
        selectedLabelTextStyle: AppTypography.caption.copyWith(color: renkler.accent),
        unselectedLabelTextStyle:
            AppTypography.caption.copyWith(color: renkler.textSecondary),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
