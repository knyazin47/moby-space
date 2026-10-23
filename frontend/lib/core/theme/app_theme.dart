import 'package:flutter/material.dart';
import 'mt_brand_theme.dart';

/// Light tokens recovered from packaged resources; see core/theme/app_theme.dart.
abstract final class MobyColors {
  static const brand = Color(0xFF1B74FD);
  static const headerTop = Color(0xFF0A54C2);
  static const headerBottom = Color(0xFF5696F6);
  static const background = Color(0xFFE6E8EA);
  static const productsBackground = Color(0xFFF7FAFD);
  static const surface = Colors.white;
  static const text = Color(0xFF0D0E0F);
  static const secondary = Color(0xFF696E77);
  static const text90 = Color(0xFF8A98AA);
  static const legacyText = Color(0xFF222222);
  static const legacySecondary = Color(0xFF95A7BF);
  static const navBorder = Color(0xFFCDD0D5);
  static const rowBorder = Color(0xFFECEEF1);
  // FinancialOperationHistoryViewHolder applies textAccentGreenLoud to highlighted positive sums.
  static const historyIncoming = Color(0xFF328E02);
  static const incoming = Color(0xFF0BB578);
  static const operationSuccess = Color(0xFF4DC79B);
  static const danger = Color(0xFFED143B);

  // MT Bank 2026 brand palette (tools/assets/brand.json).
  static const mtBlue = MtBrandColors.blue;
  static const mtRed = MtBrandColors.red;
  static const mtOrange = MtBrandColors.orange;
  static const mtCloud = MtBrandColors.cloud;
  static const mtSky = MtBrandColors.sky;
  static const mtSoft = MtBrandColors.soft;
  static const mtBlack = MtBrandColors.ink;
}

abstract final class MobyMetrics {
  static const productBannerHeight = 120.0;
  static const productBannerRadius = 12.0;
  static const productPagerViewportFraction = .9555555556;
  static const navHeight = 63.0;
  static const navRadius = 40.0;
  static const headerRadius = 46.0;
  static const pagePadding = 16.0;
  static const contentBottomPadding = 88.0;
}

ThemeData buildMobyTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: MobyColors.surface,
  colorScheme: ColorScheme.fromSeed(
    seedColor: MobyColors.brand,
    brightness: Brightness.light,
    primary: MobyColors.brand,
    surface: MobyColors.surface,
    onSurface: MobyColors.text,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: MobyColors.legacyText,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: 20,
      color: MobyColors.legacyText,
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    dragHandleColor: Color(0xFFDFDEEB),
    dragHandleSize: Size(36, 4),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      letterSpacing: 0,
      height: kTextHeightNone,
      fontSize: 17,
      color: MobyColors.legacyText,
    ),
    bodyMedium: TextStyle(
      letterSpacing: 0,
      height: kTextHeightNone,
      fontSize: 15,
      color: MobyColors.legacyText,
    ),
    bodySmall: TextStyle(
      letterSpacing: 0,
      height: kTextHeightNone,
      fontSize: 12,
      color: MobyColors.secondary,
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: MobyColors.rowBorder,
    thickness: 1,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: MobyColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: MobyColors.rowBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: MobyColors.rowBorder),
    ),
  ),
);
