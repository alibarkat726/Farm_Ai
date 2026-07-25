import 'package:flutter/material.dart';

/// Warm orchard palette — leaf green + apricot accent, outdoor-legible.
class OrchardColors {
  static const Color leafGreen = Color(0xFF2F5D3A);
  static const Color leafGreenDark = Color(0xFF1F3D28);
  static const Color apricot = Color(0xFFD4782E);
  static const Color apricotSoft = Color(0xFFF3D5A8);
  static const Color cream = Color(0xFFF7F4EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1C241E);
  static const Color muted = Color(0xFF5C6B60);
  static const Color urgencyLow = Color(0xFF3D8B5A);
  static const Color urgencyModerate = Color(0xFFC9891A);
  static const Color urgencyHigh = Color(0xFFC23B2E);
  static const Color urgencyCritical = Color(0xFF8B1E1E);
  static const Color calloutBg = Color(0xFFFFF1E0);
  static const Color calloutBorder = Color(0xFFE8A45A);
}

ThemeData buildOrchardTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: OrchardColors.leafGreen,
      onPrimary: Colors.white,
      secondary: OrchardColors.apricot,
      onSecondary: Colors.white,
      surface: OrchardColors.surface,
      onSurface: OrchardColors.ink,
      error: OrchardColors.urgencyHigh,
    ),
    scaffoldBackgroundColor: OrchardColors.cream,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: OrchardColors.leafGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      headlineMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: OrchardColors.ink,
        height: 1.25,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: OrchardColors.ink,
      ),
      titleMedium: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: OrchardColors.ink,
      ),
      bodyLarge: const TextStyle(
        fontSize: 17,
        height: 1.45,
        color: OrchardColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontSize: 15,
        height: 1.45,
        color: OrchardColors.ink,
      ),
      bodySmall: const TextStyle(
        fontSize: 13,
        height: 1.4,
        color: OrchardColors.muted,
      ),
      labelLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OrchardColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD5DDD7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD5DDD7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: OrchardColors.leafGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: OrchardColors.urgencyHigh),
      ),
      labelStyle: const TextStyle(color: OrchardColors.muted, fontSize: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OrchardColors.apricot,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: OrchardColors.leafGreenDark,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: OrchardColors.leafGreen, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: OrchardColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8E3)),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: OrchardColors.surface,
      selectedItemColor: OrchardColors.leafGreen,
      unselectedItemColor: OrchardColors.muted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: OrchardColors.leafGreenDark,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Color urgencyColor(String urgency) {
  switch (urgency.toLowerCase()) {
    case 'low':
      return OrchardColors.urgencyLow;
    case 'moderate':
      return OrchardColors.urgencyModerate;
    case 'high':
      return OrchardColors.urgencyHigh;
    case 'critical':
      return OrchardColors.urgencyCritical;
    default:
      return OrchardColors.muted;
  }
}
