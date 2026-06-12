import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);       // Vibrant Violet
  static const Color secondary = Color(0xFFA855F7);     // Soft Purple
  static const Color accent = Color(0xFFF59E0B);        // Warm Amber
  static const Color success = Color(0xFF22C55E);       // Fresh Green
  static const Color error = Color(0xFFEF4444);         // Soft Red
  static const Color warning = Color(0xFFF59E0B);       // Amber (same as accent)

  // ── Light Mode Colors ──────────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardLightAlt = Color(0xFFF1F5F9);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color surfaceLight = Color(0xFFF1F5F9);

  // ── Dark Mode Colors ───────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardDarkAlt = Color(0xFF334155);
  static const Color textLight = Color(0xFFF1F5F9);
  static const Color textMutedDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF334155);

  // ── Convenience Getters for dynamic theming ────────────────────────────────
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textLight : textDark;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textMutedDark : textMuted;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;

  static Color bgColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;

  static Color dividerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dividerDark : dividerLight;

  static Color cardAltColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDarkAlt : cardLightAlt;

  // ── Text Theme Builder ─────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.dark ? textLight : textDark;
    final mutedColor = brightness == Brightness.dark ? textMutedDark : textMuted;

    return TextTheme(
      headlineLarge: GoogleFonts.plusJakartaSans(
        color: baseColor, fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: baseColor, fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.inter(
        color: baseColor, fontWeight: FontWeight.w600, fontSize: 18,
      ),
      titleMedium: GoogleFonts.inter(
        color: baseColor, fontWeight: FontWeight.w600, fontSize: 16,
      ),
      bodyLarge: GoogleFonts.inter(
        color: baseColor, fontSize: 15, fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: mutedColor, fontSize: 14, fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.inter(
        color: mutedColor, fontSize: 12, fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.inter(
        color: baseColor, fontWeight: FontWeight.w600, fontSize: 14,
      ),
      labelMedium: GoogleFonts.inter(
        color: mutedColor, fontWeight: FontWeight.w500, fontSize: 12,
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: cardLight,
        error: error,
        onPrimary: Colors.white,
        onSurface: textDark,
        onSecondary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textDark, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: _buildTextTheme(Brightness.light),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: dividerLight,
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary : textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary.withOpacity(0.4) : dividerLight),
      ),
      dividerTheme: const DividerThemeData(color: dividerLight, thickness: 1),
      popupMenuTheme: PopupMenuThemeData(
        color: cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: cardDark,
        error: error,
        onPrimary: Colors.white,
        onSurface: textLight,
        onSecondary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textLight, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDarkAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textMutedDark, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textMutedDark, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: cardDarkAlt,
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary : textMutedDark),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary.withOpacity(0.4) : cardDarkAlt),
      ),
      dividerTheme: const DividerThemeData(color: dividerDark, thickness: 1),
      popupMenuTheme: PopupMenuThemeData(
        color: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
    );
  }
}
