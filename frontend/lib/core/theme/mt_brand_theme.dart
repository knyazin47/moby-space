import 'package:flutter/material.dart';

/// New-screen tokens from tools/assets/brand.json.
abstract final class MtBrandColors {
  static const blue = Color(0xFF2334C8);
  static const red = Color(0xFFE42C26);
  static const orange = Color(0xFFFF5912);
  static const cloud = Color(0xFFE7F4FF);
  static const sky = Color(0xFF97CFFF);
  static const soft = Color(0xFF82AED3);
  static const ink = Color(0xFF141416);
  static const white = Color(0xFFFFFFFF);
  // Semantic UI neutrals, not additional brand accent colours.
  static const secondary = Color(0xFF535B6B);
  static const border = Color(0xFFD8E2EF);
  static const success = Color(0xFF16734E);
}

abstract final class MtBrandMetrics {
  static const pagePadding = 24.0;
  static const maxContentWidth = 560.0;
  static const sectionGap = 24.0;
  static const fieldGap = 16.0;
  static const radius = 16.0;
  static const buttonHeight = 52.0;
}

ThemeData buildMtBrandTheme() {
  const heading = TextStyle(
    fontFamily: 'TikTokSans',
    color: MtBrandColors.ink,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 0,
  );
  final scheme =
      ColorScheme.fromSeed(
        seedColor: MtBrandColors.blue,
        brightness: Brightness.light,
      ).copyWith(
        primary: MtBrandColors.blue,
        onPrimary: Colors.white,
        secondary: MtBrandColors.red,
        onSecondary: Colors.white,
        tertiary: MtBrandColors.orange,
        onTertiary: MtBrandColors.ink,
        surface: Colors.white,
        onSurface: MtBrandColors.ink,
        error: MtBrandColors.red,
        onError: Colors.white,
        outline: MtBrandColors.border,
        primaryContainer: MtBrandColors.cloud,
        onPrimaryContainer: MtBrandColors.blue,
        secondaryContainer: MtBrandColors.cloud,
        onSecondaryContainer: MtBrandColors.blue,
        tertiaryContainer: MtBrandColors.cloud,
        onTertiaryContainer: MtBrandColors.ink,
        errorContainer: Colors.white,
        onErrorContainer: MtBrandColors.red,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: Colors.white,
        surfaceContainer: Colors.white,
        surfaceContainerHigh: MtBrandColors.cloud,
        surfaceContainerHighest: MtBrandColors.cloud,
        surfaceDim: MtBrandColors.cloud,
        surfaceBright: Colors.white,
        surfaceTint: Colors.transparent,
        onSurfaceVariant: MtBrandColors.secondary,
        outlineVariant: MtBrandColors.border,
        inverseSurface: MtBrandColors.ink,
        onInverseSurface: Colors.white,
        inversePrimary: MtBrandColors.sky,
        shadow: MtBrandColors.ink,
        scrim: MtBrandColors.ink,
      );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displayLarge: heading.copyWith(fontSize: 48),
      headlineLarge: heading.copyWith(fontSize: 32),
      headlineMedium: heading.copyWith(fontSize: 28),
      headlineSmall: heading.copyWith(fontSize: 24),
      titleLarge: heading.copyWith(fontSize: 22),
      titleMedium: heading.copyWith(fontSize: 18),
      bodyLarge: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.5,
        color: MtBrandColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.45,
        color: MtBrandColors.ink,
      ),
      bodySmall: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 1.4,
        color: MtBrandColors.secondary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: MtBrandColors.blue,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: heading.copyWith(fontSize: 22),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(MtBrandMetrics.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
        borderSide: const BorderSide(color: MtBrandColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
        borderSide: const BorderSide(color: MtBrandColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
        borderSide: const BorderSide(color: MtBrandColors.blue, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: MtBrandColors.border,
      thickness: 1,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
