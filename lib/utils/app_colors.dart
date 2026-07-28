import 'package:flutter/material.dart';

/// Semua warna di sini diambil PERSIS dari file DESIGN.md hasil export Stitch,
/// supaya tampilan Flutter identik dengan mockup HTML yang sudah Anda buat.
class AppColors {
  AppColors._();

  // ==== Brand Colors (dari DESIGN.md) ====
  static const primary = Color(0xFF0D631B);          // Pandan Green
  static const primaryContainer = Color(0xFF2E7D32);   // Pandan Green (tombol utama)
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFCBFFC2);
  static const primaryFixed = Color(0xFFA3F69C);
  static const primaryFixedDim = Color(0xFF88D982);

  static const secondary = Color(0xFF77574D);          // Gula Aren Brown
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFED3C7);
  static const onSecondaryContainer = Color(0xFF795950);

  static const tertiary = Color(0xFF6E5100);           // Egg Yolk Yellow (rating/promo)
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF8C6800);
  static const tertiaryFixed = Color(0xFFFFDFA0);
  static const tertiaryFixedDim = Color(0xFFF8BD2A);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);

  // ==== Surfaces / Background ====
  static const background = Color(0xFFF7FBF0);         // dipakai Home, Cart, dst
  static const splashBackground = Color(0xFFFFF8E1);   // Soft Coconut Milk Cream (Splash & Login)
  static const onBackground = Color(0xFF181D17);

  static const surface = Color(0xFFF7FBF0);
  static const surfaceContainerLowest = Color(0xFFFFFFFF); // warna card produk
  static const surfaceContainerLow = Color(0xFFF1F5EB);
  static const surfaceContainer = Color(0xFFEBEFE5);
  static const surfaceContainerHigh = Color(0xFFE5EADF);
  static const surfaceContainerHighest = Color(0xFFE0E4DA);

  static const onSurface = Color(0xFF181D17);
  static const onSurfaceVariant = Color(0xFF40493D);
  static const outline = Color(0xFF707A6C);
  static const outlineVariant = Color(0xFFBFCABA);

  // Border tipis "jahitan" khas kemasan tradisional (dipakai di Login & Card)
  static const stitchingBorder = Color(0xFFEFEBE9);
}
