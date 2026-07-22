import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// StuStep premium palette — deep navy surfaces with vibrant neon accents.
class AppColors {
  AppColors._();

  // ─── Gradient Mesh Blobs ─────────────────────────────────────────────
  static const Color blob1 = Color(0xFF6C2BD9); // deep violet
  static const Color blob2 = Color(0xFF7B2FF7); // vivid violet
  static const Color blob3 = Color(0xFF00D4FF); // electric cyan
  static const Color blob4 = Color(0xFF0A0A1A); // abyss navy

  // ─── Surface Levels (depth system) ───────────────────────────────────
  static const Color surface0 = Color(0xFF050510); // deepest
  static const Color surface1 = Color(0xFF0A0A1A); // base background
  static const Color surface2 = Color(0xFF12122E); // card level
  static const Color surface3 = Color(0xFF1A1A40); // elevated
  static const Color surface4 = Color(0xFF222255); // highest

  // ─── Glass ───────────────────────────────────────────────────────────
  static const Color glassFill = Color(0x1AFFFFFF); // white 10%
  static const Color glassBorder = Color(0x33FFFFFF); // white 20%
  static const Color glassHighlight = Color(0x0DFFFFFF); // white 5%
  static const Color glassFillDark = Color(0x0DFFFFFF); // white 5%

  // ─── Primary Gradient ────────────────────────────────────────────────
  static const Color primary = Color(0xFF7B2FF7);
  static const Color primaryLight = Color(0xFFAB7AFF);
  static const Color primaryDark = Color(0xFF5A1FBF);
  static const Color secondary = Color(0xFF00D4FF);
  static const Color secondaryLight = Color(0xFF66E5FF);

  // ─── Neon Accents ────────────────────────────────────────────────────
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonYellow = Color(0xFFFFE600);
  static const Color neonOrange = Color(0xFFFF8A00);

  // ─── Semantic ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Text ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xB3F0F0F5); // 70%
  static const Color textHint = Color(0x80F0F0F5); // 50%
  static const Color textMuted = Color(0x4DF0F0F5); // 30%

  // ─── Background scrim for WCAG contrast over glass ───────────────────
  static const Color textScrim = Color(0x99000000);

  // ─── Stat Card Gradients ─────────────────────────────────────────────
  static const List<Color> gradientViolet = [Color(0xFF7B2FF7), Color(0xFFAB7AFF)];
  static const List<Color> gradientCyan = [Color(0xFF00D4FF), Color(0xFF66E5FF)];
  static const List<Color> gradientGreen = [Color(0xFF10B981), Color(0xFF34D399)];
  static const List<Color> gradientOrange = [Color(0xFFF59E0B), Color(0xFFFBBF24)];
  static const List<Color> gradientPink = [Color(0xFFFF006E), Color(0xFFFF5C9E)];
  static const List<Color> gradientBlue = [Color(0xFF3B82F6), Color(0xFF60A5FA)];

  // ─── Sidebar ─────────────────────────────────────────────────────────
  static const Color sidebarBg = Color(0xFF0D0D22);
  static const Color sidebarActive = Color(0x267B2FF7); // primary 15%
  static const Color sidebarHover = Color(0x1AFFFFFF); // white 10%
}

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
      labelMedium: base.labelMedium?.copyWith(color: AppColors.textSecondary),
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
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface2,
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
        color: AppColors.glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassHighlight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success;
          }
          return AppColors.textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.success.withValues(alpha: 0.3);
          }
          return AppColors.glassBorder;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface3,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        dataTextStyle: textTheme.bodyMedium,
        headingRowColor: WidgetStateProperty.all(AppColors.glassHighlight),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.glassFill;
          }
          return Colors.transparent;
        }),
        dividerThickness: 0.5,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surface4,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
        waitDuration: const Duration(milliseconds: 400),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.3),
        ),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
    );
  }
}
