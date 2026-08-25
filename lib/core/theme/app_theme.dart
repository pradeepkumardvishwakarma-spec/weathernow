import 'package:flutter/material.dart';

/// Central design tokens + ThemeData. Semantic colors (accent/warning/danger)
/// are exposed as static consts so widgets reference `AppTheme.warningColor`
/// etc. instead of hard-coding `Colors.orange`/`Colors.red` inline - one
/// place to keep the palette consistent.
class AppTheme {
  static const primaryColor = Color(0xFF4A90E2); // Sky Blue - main theme color
  static const _primaryDark = Color(0xFF305E93); // darker shade for dark-mode AppBar contrast
  static const backgroundLight = Color(0xFFF5F6FA); // Light Gray - screen background
  static const accentColor = Color(0xFF2ECC71); // Green - positive weather states
  static const warningColor = Color(0xFFF1C40F); // Yellow - warnings (e.g. stale/cached data)
  static const dangerColor = Color(0xFFE74C3C); // Red - severe weather / errors
  static const textColor = Color(0xFF2C3E50); // Dark Gray - primary text
  static const lightText = Color(0xFFECF0F1); // Light Gray - secondary/dark-mode text
  static const surfaceWhite = Color(0xFFFFFFFF); // White - card/surface background
  static const starColor = Color(0xFFFFC107); // Amber - favorited/starred indicator
  static const mutedColor = Color(0xFF7F8C8D); // Muted Gray - secondary icons/metadata, pairs with textColor
  static const iconBackdrop = Color(0xFFD6EAF8); // Light Sky Blue - weather-icon backdrop, so a
  // white/light icon glyph (e.g. clouds) stays visible against a white/near-white card in light mode

  // A solid AppBarTheme color/height is a flat fill with no image, gradient
  // or shader - costs nothing extra on the raster thread regardless of value.
  static const _appBarHeight = 48.0;

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: surfaceWhite,
    textTheme: Typography.material2021().black.apply(bodyColor: textColor, displayColor: textColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: surfaceWhite,
      elevation: 0,
      toolbarHeight: _appBarHeight,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark),
    textTheme: Typography.material2021().white.apply(bodyColor: lightText, displayColor: lightText),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryDark,
      foregroundColor: surfaceWhite,
      elevation: 0,
      toolbarHeight: _appBarHeight,
    ),
  );
}
