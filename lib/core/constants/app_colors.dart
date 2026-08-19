import 'package:flutter/material.dart';

/// Design tokens for the admin dashboard.
class AppColors {
  AppColors._();

  // ─── Brand ───
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7FF5);
  static const Color primaryDark = Color(0xFF4A3FCF);

  static const Color accent = Color(0xFF00CEFF);
  static const Color accentDark = Color(0xFF00A4CC);

  // ─── Surfaces (Dark Theme) ───
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252542);
  static const Color surfaceLighter = Color(0xFF2F2F52);
  static const Color card = Color(0xFF1E1E36);

  // ─── Text ───
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF9A9ABF);
  static const Color textMuted = Color(0xFF6B6B8D);

  // ─── Semantic ───
  static const Color success = Color(0xFF00E676);
  static const Color successDark = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningDark = Color(0xFFFF8F00);
  static const Color error = Color(0xFFFF5252);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color info = Color(0xFF448AFF);

  // ─── Sidebar ───
  static const Color sidebarBg = Color(0xFF12121F);
  static const Color sidebarHover = Color(0xFF1E1E36);
  static const Color sidebarActive = Color(0xFF6C5CE7);

  // ─── Borders ───
  static const Color border = Color(0xFF2A2A45);
  static const Color borderLight = Color(0xFF3A3A5C);

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E36), Color(0xFF252542)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
