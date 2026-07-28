import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tema global aplikasi. Dipanggil sekali di main.dart lewat MaterialApp(theme: AppTheme.light).
///
/// Tiga font sesuai DESIGN.md:
/// - Playfair Display  -> logo / brand "Warung Jajan" (displayBrand)
/// - Bricolage Grotesque -> semua judul/headline
/// - Plus Jakarta Sans -> body text, label, tombol
class AppTheme {
  AppTheme._();

  // ==== Text Styles (nama & ukuran sesuai DESIGN.md) ====
  static TextStyle get displayBrand => GoogleFonts.playfairDisplay(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 48 / 40,
        letterSpacing: -0.02 * 40,
        color: AppColors.primary,
      );

  static TextStyle get headlineLg => GoogleFonts.bricolageGrotesque(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.bricolageGrotesque(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.bricolageGrotesque(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 18 / 14,
        color: AppColors.onSurface,
      );

  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: AppColors.onSurfaceVariant,
      );

  // ==== Spacing (dari DESIGN.md, dipakai manual di screen: AppSpacing.md, dst) ====

  // ==== Radius standar 12px untuk kartu, tombol, input ====
  static const BorderRadius radiusDefault = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999));

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        outline: AppColors.outline,
      ),
      textTheme: TextTheme(
        displayLarge: displayBrand,
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        labelLarge: labelLg,
        labelSmall: labelSm,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radiusDefault,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusDefault,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusDefault,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radiusDefault),
          textStyle: labelLg.copyWith(color: Colors.white),
          elevation: 2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        titleTextStyle: headlineMd.copyWith(color: AppColors.primary),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1)),
        ),
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
  }
}
