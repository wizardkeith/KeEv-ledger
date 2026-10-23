import 'package:flutter/material.dart';

abstract final class KeEvColors {
  static const lightPurple = Color(0xFFDAA7E7),
      purple = Color(0xFFB847CD),
      midPurple = Color(0xFF9F44C5),
      deepPurple = Color(0xFF7D40B9),
      deepBlue = Color(0xFF4037A4);
}

/// Production UI fonts are bundled in pubspec.yaml; the platform list is last.
abstract final class KeEvTypography {
  static const latin = 'Plus Jakarta Sans';
  static const hongKong = 'Noto Sans HK';
  static const simplified = 'Noto Sans SC';
  static const japanese = 'Noto Sans JP';
  static const thai = 'Noto Sans Thai';

  static String familyFor(Locale? locale) =>
      switch ((locale?.languageCode, locale?.countryCode)) {
        ('zh', 'CN') => simplified,
        ('zh', _) => hongKong,
        ('ja', _) => japanese,
        ('th', _) => thai,
        _ => latin,
      };

  static List<String> fallbacksFor(Locale? locale) {
    final primary = familyFor(locale);
    return [
      for (final family in [latin, hongKong, simplified, japanese, thai])
        if (family != primary) family,
      'PingFang HK',
      'PingFang SC',
      'Hiragino Sans',
      'Thonburi',
    ];
  }

  static TextStyle? financialAmount(
    TextTheme textTheme, {
    bool large = false,
  }) => (large ? textTheme.headlineMedium : textTheme.titleLarge)?.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

ThemeData keevTheme(Brightness brightness, {Locale? locale}) {
  final dark = brightness == Brightness.dark;
  final family = KeEvTypography.familyFor(locale);
  final fallbacks = KeEvTypography.fallbacksFor(locale);
  final baseText = ThemeData(
    useMaterial3: true,
    brightness: brightness,
  ).textTheme.apply(fontFamily: family, fontFamilyFallback: fallbacks);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: KeEvColors.deepPurple,
        brightness: brightness,
      ).copyWith(
        primary: dark ? KeEvColors.lightPurple : KeEvColors.deepPurple,
        onPrimary: dark ? const Color(0xFF24122D) : Colors.white,
        surface: dark ? const Color(0xFF171420) : const Color(0xFFFCFAFF),
        onSurface: dark ? const Color(0xFFF4EFF7) : const Color(0xFF211A29),
      );
  return ThemeData(
    useMaterial3: true,
    fontFamily: family,
    fontFamilyFallback: fallbacks,
    textTheme: baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(height: 1.18),
      headlineLarge: baseText.headlineLarge?.copyWith(height: 1.22),
      headlineMedium: baseText.headlineMedium?.copyWith(height: 1.25),
      headlineSmall: baseText.headlineSmall?.copyWith(height: 1.28),
      titleLarge: baseText.titleLarge?.copyWith(height: 1.3),
      titleMedium: baseText.titleMedium?.copyWith(height: 1.3),
      titleSmall: baseText.titleSmall?.copyWith(height: 1.3),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.42),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.4),
      bodySmall: baseText.bodySmall?.copyWith(height: 1.4),
      labelLarge: baseText.labelLarge?.copyWith(height: 1.3),
      labelMedium: baseText.labelMedium?.copyWith(height: 1.3),
      labelSmall: baseText.labelSmall?.copyWith(height: 1.3),
    ),
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: scheme.surface,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.all(16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.all(16),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      minTileHeight: 56,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
