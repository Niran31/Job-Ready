import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppGradients {
  // ── Primary CTA Button Gradient ────────────────────────────────────────────
  static const LinearGradient primaryCta = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.accent,
    ],
  );

  // ── Soft Purple Welcome/Hero Card ──────────────────────────────────────────
  static LinearGradient welcomeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [AppTheme.primary.withOpacity(0.35), AppTheme.cardDark]
          : [AppTheme.primary.withOpacity(0.12), AppTheme.secondary.withOpacity(0.06)],
    );
  }

  // ── Important Card Glow ────────────────────────────────────────────────────
  static LinearGradient cardGlow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [AppTheme.primary.withOpacity(0.25), AppTheme.cardDark]
          : [AppTheme.primary.withOpacity(0.08), AppTheme.cardLight],
    );
  }

  // ── Success Gradient ───────────────────────────────────────────────────────
  static LinearGradient successGlow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [AppTheme.success.withOpacity(0.25), AppTheme.cardDark]
          : [AppTheme.success.withOpacity(0.08), AppTheme.cardLight],
    );
  }

  // ── Warning/Amber Gradient ─────────────────────────────────────────────────
  static LinearGradient warningGlow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [AppTheme.accent.withOpacity(0.25), AppTheme.cardDark]
          : [AppTheme.accent.withOpacity(0.08), AppTheme.cardLight],
    );
  }

  // ── Error/Danger Gradient ──────────────────────────────────────────────────
  static LinearGradient errorGlow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [AppTheme.error.withOpacity(0.25), AppTheme.cardDark]
          : [AppTheme.error.withOpacity(0.08), AppTheme.cardLight],
    );
  }

  // ── Status Gradients ───────────────────────────────────────────────────────
  static LinearGradient statusGradient(Color color, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [color.withOpacity(0.2), AppTheme.cardDark]
          : [color.withOpacity(0.08), AppTheme.cardLight],
    );
  }

  // ── Banner Gradient ────────────────────────────────────────────────────────
  static const LinearGradient banner = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppTheme.primary, AppTheme.secondary],
  );

  // ── Progress Bar Gradient ──────────────────────────────────────────────────
  static const LinearGradient progressBar = LinearGradient(
    colors: [AppTheme.primary, AppTheme.secondary],
  );
}
