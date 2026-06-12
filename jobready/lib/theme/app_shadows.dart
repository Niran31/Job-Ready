import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppShadows {
  // ── Soft Card Shadow (standard cards) ──────────────────────────────────────
  static List<BoxShadow> cardSoft(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
        blurRadius: 30,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
    ];
  }

  // ── Elevated Shadow (floating elements) ────────────────────────────────────
  static List<BoxShadow> cardElevated(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08),
        blurRadius: 40,
        offset: const Offset(0, 12),
        spreadRadius: 0,
      ),
    ];
  }

  // ── Purple Glow Shadow (important cards) ───────────────────────────────────
  static List<BoxShadow> glowPurple(BuildContext context) {
    return [
      BoxShadow(
        color: AppTheme.primary.withOpacity(0.2),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
    ];
  }

  // ── Nav Bar Shadow ─────────────────────────────────────────────────────────
  static List<BoxShadow> navBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
        blurRadius: 30,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
    ];
  }

  // ── Button Shadow ──────────────────────────────────────────────────────────
  static List<BoxShadow> button(BuildContext context) {
    return [
      BoxShadow(
        color: AppTheme.primary.withOpacity(0.3),
        blurRadius: 16,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
    ];
  }
}
