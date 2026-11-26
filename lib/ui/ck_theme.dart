import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// CosmoKundli design tokens — mirrors `styles.css` of the CosmoKundli software
/// so the app and the desktop product share one visual language.
class CkColors {
  // Brand
  static const Color orange = Color(0xFFE87800);
  static const Color orangeSoft = Color(0xFFF07E22);
  static const Color red = Color(0xFFEF4444);
  static const Color redDark = Color(0xFFDD2B1C);
  static const Color yellow = Color(0xFFF59E0B);
  static const Color blue = Color(0xFF437FD7);
  static const Color blueDark = Color(0xFF2652A4);
  static const Color green = Color(0xFF10B981);
  static const Color purple = Color(0xFF6C3CE1);
  static const Color linkBlue = Color(0xFF87BEFF);
  // Instrument accent: data, selection, focus
  static const Color cyan = Color(0xFF5CE1FF);
  static const Color cyanTint = Color(0x295CE1FF);
  static const Color cyanStroke = Color(0x735CE1FF);
  static const Color retro = Color(0xFFF5D90A);
  static const Color panelTop = Color(0x12FFFFFF); // see-through glass (MyAcharyaji ~6%)
  static const Color panelBottom = Color(0x0BFFFFFF);
  static const Color panelStroke = Color(0x1FFFFFFF);
  static const Color field = Color(0x8C0A1E50);
  static const Color labelMono = Color(0xFF93A8CF);

  // Space
  static const Color deepSpace = Color(0xFF0C2C68);
  static const Color navy = Color(0xFF0A2A5E);
  static const Color navySheet = Color(0xFF14397E);

  // Text
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA9BADB);
  static const Color textTertiary = Color(0xFFDFE2EB);
  static const Color textMuted = Color(0x80FFFFFF);
  static const Color textDim = Color(0x59FFFFFF);

  // Glass
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassFillStrong = Color(0x1AFFFFFF);
  static const Color glassStroke = Color(0x40FFFFFF);
  static const Color glassHighlight = Color(0x4DFFFFFF);
  static const Color orangeTint = Color(0x33F07E22);
  static const Color orangeStroke = Color(0x66F07E22);

  // Planets (solid)
  static const Color sun = Color(0xFFE85D2A);
  static const Color moon = Color(0xFFB4EFFC);
  static const Color mars = Color(0xFFFF3B3B);
  static const Color mercury = Color(0xFF10B981);
  static const Color jupiter = Color(0xFFF59E0B);
  static const Color venus = Color(0xFFEC4899);
  static const Color saturn = Color(0xFF8B84FF);
  static const Color rahu = Color(0xFFA9AEB8);
  static const Color ketu = Color(0xFFD0607F);
  static const Color ascendant = Color(0xFFD9B38C);

  static const LinearGradient cta = LinearGradient(
    colors: [Color(0xFFEB4B36), Color(0xFFF56720), Color(0xFFF59E0B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class CkRadius {
  static const double card = 22;
  static const double control = 22;
  static const double pill = 32;
  static const double input = 14;
}

class CkMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Curve ease = Cubic(.22, 1, .36, 1);
  static const Curve spring = Curves.easeOutBack;
}

class CkTheme {
  static TextTheme _text() {
    final body = GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: CkColors.text, displayColor: CkColors.text);
    TextStyle? h(TextStyle? s) =>
        GoogleFonts.inter(textStyle: s, fontWeight: FontWeight.w600);
    return body.copyWith(
      displayLarge: h(body.displayLarge),
      displayMedium: h(body.displayMedium),
      displaySmall: h(body.displaySmall),
      headlineLarge: h(body.headlineLarge),
      headlineMedium: h(body.headlineMedium),
      headlineSmall: h(body.headlineSmall),
      titleLarge: h(body.titleLarge),
      titleMedium: h(body.titleMedium),
      titleSmall: h(body.titleSmall),
      labelLarge: GoogleFonts.inter(
          textStyle: body.labelLarge, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: CkColors.orange,
      brightness: Brightness.dark,
    ).copyWith(
      primary: CkColors.orangeSoft,
      onPrimary: Colors.white,
      secondary: CkColors.linkBlue,
      surface: CkColors.navySheet,
      onSurface: CkColors.text,
      error: CkColors.red,
    );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(CkRadius.input),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: CkColors.deepSpace,
      canvasColor: CkColors.navySheet,
      textTheme: _text(),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: CkColors.text,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      iconTheme: const IconThemeData(color: CkColors.text),
      dividerTheme: const DividerThemeData(color: CkColors.glassStroke),
      cardTheme: CardThemeData(
        color: CkColors.glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CkRadius.card),
          side: const BorderSide(color: CkColors.glassStroke),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CkColors.navySheet.withOpacity(0.96),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: CkColors.glassStroke),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: CkColors.navySheet.withOpacity(0.97),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: CkColors.navySheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CkColors.glassStroke),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CkColors.navySheet,
        contentTextStyle: const TextStyle(color: CkColors.text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CkColors.glassStroke),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CkColors.glassFill,
        hintStyle: const TextStyle(color: CkColors.textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: CkColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: CkColors.orangeSoft),
        prefixIconColor: CkColors.textSecondary,
        suffixIconColor: CkColors.textSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(CkColors.glassStroke),
        enabledBorder: border(CkColors.glassStroke),
        focusedBorder: border(CkColors.orangeSoft, 1.4),
        errorBorder: border(CkColors.red),
        focusedErrorBorder: border(CkColors.red, 1.4),
        disabledBorder: border(CkColors.glassFillStrong),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: GoogleFonts.inter(
            color: CkColors.text, fontWeight: FontWeight.w600, fontSize: 13),
        dataTextStyle: GoogleFonts.inter(color: CkColors.textTertiary),
        headingRowColor: const WidgetStatePropertyAll(CkColors.glassFillStrong),
        dividerThickness: 0.6,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: CkColors.text,
        unselectedLabelColor: CkColors.textMuted,
        dividerHeight: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? CkColors.orangeSoft : null),
        side: const BorderSide(color: CkColors.textSecondary),
      ),
      radioTheme: const RadioThemeData(
        fillColor: WidgetStatePropertyAll(CkColors.orangeSoft),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: CkColors.orangeSoft),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: CkColors.navySheet,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: CkColors.navy,
        headerForegroundColor: CkColors.text,
        dayForegroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected)
            ? const Color(0xFF06204F)
            : st.contains(WidgetState.disabled)
                ? CkColors.textDim
                : CkColors.text),
        dayBackgroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? CkColors.cyan : null),
        dayOverlayColor: const WidgetStatePropertyAll(CkColors.cyanTint),
        todayForegroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? const Color(0xFF06204F) : CkColors.cyan),
        todayBackgroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? CkColors.cyan : null),
        todayBorder: const BorderSide(color: CkColors.cyan),
        yearForegroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? const Color(0xFF06204F) : CkColors.text),
        yearBackgroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? CkColors.cyan : null),
        dividerColor: CkColors.panelStroke,
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: CkColors.textSecondary),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: CkColors.cyan),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: CkColors.glassStroke),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: CkColors.navySheet,
        dialBackgroundColor: CkColors.navy,
        dialHandColor: CkColors.cyan,
        dialTextColor: WidgetStateColor.resolveWith((st) => st.contains(WidgetState.selected) ? const Color(0xFF06204F) : CkColors.text),
        hourMinuteColor: WidgetStateColor.resolveWith((st) => st.contains(WidgetState.selected) ? CkColors.cyanTint : CkColors.field),
        hourMinuteTextColor: WidgetStateColor.resolveWith((st) => st.contains(WidgetState.selected) ? CkColors.cyan : CkColors.text),
        dayPeriodColor: CkColors.cyanTint,
        dayPeriodTextColor: WidgetStateColor.resolveWith((st) => st.contains(WidgetState.selected) ? CkColors.cyan : CkColors.textSecondary),
        dayPeriodBorderSide: const BorderSide(color: CkColors.cyanStroke),
        entryModeIconColor: CkColors.cyan,
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: CkColors.textSecondary),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: CkColors.cyan),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: CkColors.glassStroke),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: CkColors.orangeSoft),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CkColors.orangeTint,
          foregroundColor: CkColors.text,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CkRadius.control),
            side: const BorderSide(color: CkColors.orangeStroke),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
