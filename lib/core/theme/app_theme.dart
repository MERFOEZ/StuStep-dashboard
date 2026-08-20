import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// StuStep Premium Palette — Stripe-Tier Vibrant Light Theme
/// ─────────────────────────────────────────────────────────────────────────────
/// Pearl canvas, pristine white surfaces, Electric Cyan → Vivid Blue gradients,
/// multi-layered diffuse shadows, and colored halo effects.
class AppColors {
  AppColors._();

  // ─── Canvas & Surfaces ────────────────────────────────────────────────
  /// Main scaffold background — ultra-premium pearl slate, NOT pure white.
  static const Color canvas = Color(0xFFF4F7F9);

  /// Slightly warmer canvas variant for nested sections.
  static const Color canvasWarm = Color(0xFFF8F9FA);

  /// Cards, sidebars, panels — pristine white to pop against canvas.
  static const Color surface = Color(0xFFFFFFFF);

  /// Slightly tinted surface for table headers, hover states.
  static const Color surfaceTinted = Color(0xFFF8FAFC);

  /// Elevated surface with subtle warmth.
  static const Color surfaceElevated = Color(0xFFFDFDFE);

  /// Surface for hover states — barely tinted.
  static const Color surfaceHover = Color(0xFFF0F4F8);

  // ─── Primary Gradient (Electric Cyan → Vivid Blue) ────────────────────
  static const Color primary = Color(0xFF3A7BD5);
  static const Color primaryLight = Color(0xFF5B9AE8);
  static const Color primaryDark = Color(0xFF2A5FA8);
  static const Color secondary = Color(0xFF00D2FF);
  static const Color secondaryLight = Color(0xFF66E5FF);

  // ─── Vibrant Accent Gradients ─────────────────────────────────────────
  static const List<Color> gradientPrimary = [
    Color(0xFF00D2FF),
    Color(0xFF3A7BD5),
  ];
  static const List<Color> gradientViolet = [
    Color(0xFF7B2FF7),
    Color(0xFFAB7AFF),
  ];
  static const List<Color> gradientCyan = [
    Color(0xFF00D2FF),
    Color(0xFF66E5FF),
  ];
  static const List<Color> gradientGreen = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];
  static const List<Color> gradientOrange = [
    Color(0xFFFF8A00),
    Color(0xFFFF6B6B),
  ];
  static const List<Color> gradientPink = [
    Color(0xFFFF006E),
    Color(0xFFFF5C9E),
  ];
  static const List<Color> gradientBlue = [
    Color(0xFF3B82F6),
    Color(0xFF60A5FA),
  ];
  static const List<Color> gradientSunset = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
  ];

  // ─── Neon Accents (for badges, indicators, pulse effects) ─────────────
  static const Color neonGreen = Color(0xFF00D68F);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonOrange = Color(0xFFFF8A00);
  static const Color neonCyan = Color(0xFF00E5FF);

  // ─── Semantic ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Text (dark on light) ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFFCBD5E1);

  // ─── Borders & Dividers ───────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocus = Color(0xFF3A7BD5);

  // ─── Glass (Light Mode Frosted) ───────────────────────────────────────
  static const Color glassFill = Color(0xB3FFFFFF); // white 70%
  static const Color glassBorder = Color(0x33000000); // black 20%
  static const Color glassFillSubtle = Color(0x0A000000); // black 4%

  // ─── Backward-Compat Aliases (legacy dark-theme tokens → light values) ─
  /// Formerly a dark surface; now maps to surfaceTinted for light mode.
  static const Color glassFillDark = Color(0xFFF8FAFC); // = surfaceTinted
  /// Formerly dark sidebar bg; now pristine white surface.
  static const Color sidebarBg = Color(0xFFFFFFFF); // = surface
  /// Formerly a dark raised surface; maps to surfaceElevated.
  static const Color surface3 = Color(0xFFF4F7F9); // = canvas
  /// Formerly the base dark surface; maps to surfaceTinted.
  static const Color surface0 = Color(0xFFF1F5F9); // light slate
  /// Neon yellow for accent icons.
  static const Color neonYellow = Color(0xFFFFD93D);
  /// Gradient second-stop alias used by auth and colleges pages.
  static const Color blob2 = Color(0xFF00D2FF); // = secondary (Electric Cyan)

  // ─── Sidebar ──────────────────────────────────────────────────────────
  static const Color sidebarActive = Color(0x143A7BD5); // primary 8%
  static const Color sidebarHover = Color(0x0A000000); // black 4%

  // ─── Multi-Layered Shadow System ──────────────────────────────────────

  /// Primary soft shadow for floating card elements
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        // Subtle ambient halo
        BoxShadow(
          color: primary.withOpacity(0.02),
          blurRadius: 40,
          offset: Offset.zero,
          spreadRadius: -8,
        ),
      ];

  /// Elevated shadow for hovered/active elements — deeper, wider spread
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 32,
          offset: const Offset(0, 16),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        // Primary halo on elevation
        BoxShadow(
          color: primary.withOpacity(0.04),
          blurRadius: 48,
          offset: Offset.zero,
          spreadRadius: -8,
        ),
      ];

  /// Ultra-soft shadow for sidebar and persistent panels
  static List<BoxShadow> get panelShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 36,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: primary.withOpacity(0.03),
          blurRadius: 48,
          offset: Offset.zero,
          spreadRadius: -10,
        ),
      ];

  /// Card-specific shadow — course cards, stat cards
  static List<BoxShadow> cardShadow({bool hovered = false}) => [
        BoxShadow(
          color: Colors.black.withOpacity(hovered ? 0.06 : 0.035),
          blurRadius: hovered ? 28 : 20,
          offset: Offset(0, hovered ? 14 : 8),
          spreadRadius: hovered ? -2 : -4,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(hovered ? 0.03 : 0.015),
          blurRadius: hovered ? 10 : 6,
          offset: Offset(0, hovered ? 4 : 2),
        ),
        if (hovered)
          BoxShadow(
            color: primary.withOpacity(0.06),
            blurRadius: 32,
            offset: Offset.zero,
            spreadRadius: -6,
          ),
      ];

  /// Colored glow shadow (for gradient buttons)
  static List<BoxShadow> gradientGlow(Color color,
          {bool hovered = false}) =>
      [
        BoxShadow(
          color: color.withOpacity(hovered ? 0.35 : 0.2),
          blurRadius: hovered ? 24 : 16,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        if (hovered)
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 40,
            offset: Offset.zero,
            spreadRadius: -8,
          ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — Fully customized ThemeData, zero Material defaults visible
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  /// Returns a [TextTheme] using Tajawal (Arabic) or Inter (English).
  static TextTheme _buildTextTheme(bool isArabic) {
    final base = isArabic
        ? GoogleFonts.tajawalTextTheme()
        : GoogleFonts.interTextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      displaySmall: base.displaySmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: AppColors.textPrimary),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.textSecondary),
      bodySmall: base.bodySmall?.copyWith(color: AppColors.textHint),
      labelLarge: base.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelMedium:
          base.labelMedium?.copyWith(color: AppColors.textSecondary),
      labelSmall: base.labelSmall?.copyWith(
        color: AppColors.textHint,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData buildTheme({required bool isArabic}) {
    final textTheme = _buildTextTheme(isArabic);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceTinted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodySmall,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success;
          }
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success.withValues(alpha: 0.3);
          }
          return AppColors.border;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
        dataTextStyle: textTheme.bodyMedium,
        headingRowColor:
            WidgetStateProperty.all(AppColors.surfaceTinted),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primary.withValues(alpha: 0.04);
          }
          return Colors.transparent;
        }),
        dividerThickness: 0.5,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppColors.softShadow,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
        waitDuration: const Duration(milliseconds: 400),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.textMuted.withValues(alpha: 0.4),
        ),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
    );
  }
}
