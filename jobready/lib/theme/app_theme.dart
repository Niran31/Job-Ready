import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (SaaS Professional Palette)
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color secondary = Color(0xFF64748B); // Slate 500
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Light Theme Colors
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color textLightPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textLightSecondary = Color(0xFF64748B); // Slate 500
  static const Color dividerLight = Color(0xFFE2E8F0); // Slate 200

  // Dark Theme Colors
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textDarkPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textDarkSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color dividerDark = Color(0xFF334155); // Slate 700

  // Helpers for dynamic theming
  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDarkPrimary : textLightPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDarkSecondary : textLightSecondary;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dividerDark : dividerLight;

  static Color scaffoldBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: bgLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        error: danger,
      ),
      dividerColor: dividerLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textLightPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        displayMedium: GoogleFonts.inter(color: textLightPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: GoogleFonts.inter(color: textLightPrimary, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.inter(color: textLightPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textLightPrimary, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: textLightSecondary, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.inter(color: textLightPrimary, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        foregroundColor: textLightPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textLightPrimary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surfaceDark,
        error: danger,
      ),
      dividerColor: dividerDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textDarkPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        displayMedium: GoogleFonts.inter(color: textDarkPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: GoogleFonts.inter(color: textDarkPrimary, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.inter(color: textDarkPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textDarkPrimary, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: textDarkSecondary, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.inter(color: textDarkPrimary, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        foregroundColor: textDarkPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDarkPrimary),
      ),
    );
  }
}
