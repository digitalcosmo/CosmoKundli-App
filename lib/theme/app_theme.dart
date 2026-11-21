import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Background
  static const Color bgPrimary = Color(0xFF0a2a5e);
  static const Color bgSecondary = Color(0xFF0d1b3e);
  static const Color bgTertiary = Color(0xFF112d6a);

  // Glassmorphism
  static const Color gmBg = Color.fromRGBO(255, 255, 255, 0.03);
  static const Color gmHighlight = Color.fromRGBO(255, 255, 255, 0.3);
  static const double gmBlur = 4.0;
  static const Color gmBorder = Color.fromRGBO(255, 255, 255, 0.08);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color.fromRGBO(255, 255, 255, 0.7);
  static const Color textMuted = Color.fromRGBO(255, 255, 255, 0.5);

  // Planet Colors
  static const Color sunColor = Color(0xFFE85D2A);
  static const Color moonColor = Color(0xFFb4effc);
  static const Color marsColor = Color(0xFFff2222);
  static const Color mercuryColor = Color(0xFF10B981);
  static const Color jupiterColor = Color(0xFFF59E0B);
  static const Color venusColor = Color(0xFFEC4899);
  static const Color saturnColor = Color(0xFF6C63FF);
  static const Color rahuColor = Color(0xFF7A7F8C);
  static const Color ketuColor = Color(0xFFA5415B);
  static const Color ascendantColor = Color(0xFFD9B38C);

  // Accent
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF8B83FF);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Radii
  static const double cardRadius = 14.0;
  static const double controlRadius = 22.0;
  static const double pillRadius = 32.0;

  // Glassmorphism Decoration
  static BoxDecoration get glassCard => BoxDecoration(
        color: gmBg,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: gmBorder, width: 1),
      );

  static BoxDecoration get glassControl => BoxDecoration(
        color: gmBg,
        borderRadius: BorderRadius.circular(controlRadius),
        border: Border.all(color: gmBorder, width: 1),
      );

  static BoxDecoration get glassPill => BoxDecoration(
        color: gmBg,
        borderRadius: BorderRadius.circular(pillRadius),
        border: Border.all(color: gmBorder, width: 1),
      );

  static BoxDecoration glassCardCustom({double? radius, Color? color}) =>
      BoxDecoration(
        color: color ?? gmBg,
        borderRadius: BorderRadius.circular(radius ?? cardRadius),
        border: Border.all(color: gmBorder, width: 1),
      );

  // Text Styles
  static TextStyle get displayLarge => GoogleFonts.lexendGiga(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get headingLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get headingMedium => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get headingSmall => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get labelMedium => GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  // ThemeData
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgPrimary,
        primaryColor: accent,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentLight,
          surface: bgSecondary,
          error: error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: headingMedium,
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        textTheme: TextTheme(
          displayLarge: displayLarge,
          headlineMedium: headingLarge,
          headlineSmall: headingMedium,
          titleMedium: headingSmall,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelMedium: labelMedium,
          labelSmall: labelSmall,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: gmBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(controlRadius),
            borderSide: BorderSide(color: gmBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(controlRadius),
            borderSide: BorderSide(color: gmBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(controlRadius),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(controlRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: bgSecondary,
          selectedItemColor: accent,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      );
}
