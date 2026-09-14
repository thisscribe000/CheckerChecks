import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StitchTheme {
  // Stitch Design System Colors
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF444748);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceVariant = Color(0xFFE2E2E2);
  static const Color surfaceDim = Color(0xFFDADADA);
  static const Color outlineVariant = Color(0xFFC4C7C7);
  static const Color outline = Color(0xFF747878);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color success = Color(0xFF059669);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);

  // Typography Styles
  static TextStyle display(BuildContext context) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primary,
      );

  static TextStyle headlineLg(BuildContext context) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: primary,
      );

  static TextStyle headlineMd(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primary,
      );

  static TextStyle titleLg(BuildContext context) => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primary,
      );

  static TextStyle bodyLg(BuildContext context) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      );

  static TextStyle bodyMd(BuildContext context) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: onSurface,
      );

  static TextStyle bodySm(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      );

  static TextStyle labelCaps(BuildContext context) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: onSurfaceVariant,
      );

  static TextStyle monoSm(BuildContext context) => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      );

  // Card & Button Decoration Utilities
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceContainerLowest,
    borderRadius: BorderRadius.circular(4.0),
    border: Border.all(color: outlineVariant, width: 1.0),
  );

  static BoxDecoration cardDecorationActive = BoxDecoration(
    color: surfaceContainerLowest,
    borderRadius: BorderRadius.circular(4.0),
    border: Border.all(color: primary, width: 1.5),
  );

  static BoxDecoration errorCardDecoration = BoxDecoration(
    color: errorContainer,
    borderRadius: BorderRadius.circular(4.0),
    border: Border.all(color: error, width: 1.0),
  );

  // MaterialApp Theme Specification
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        surface: surface,
        onSurface: onSurface,
        outline: outline,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: primary,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
