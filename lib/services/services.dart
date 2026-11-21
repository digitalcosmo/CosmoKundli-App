import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/routes.dart';

class Services {
  static Future<void> to(String nextScreen) async {
    Get.toNamed(nextScreen);
  }

  static Future<void> off(BuildContext context, String nextScreen) async {
    Get.offNamed(nextScreen);
  }

  static void popUntilHomePage(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static offAll(String nextScreen) {
    Get.offAllNamed(nextScreen);
  }

  static Future<void> back() async {
    Get.back();
  }

  static snackBarSuccess(BuildContext context, String value) {
    Get.snackbar(
      'Success',
      value,
      backgroundColor: AppTheme.success.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: AppTheme.cardRadius,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  static snackBarError(BuildContext context, String value) {
    Get.snackbar(
      'Error',
      value,
      backgroundColor: AppTheme.error.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: AppTheme.cardRadius,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  static covertToJson(String jsonString) {
    Map<String, dynamic> a = jsonDecode(jsonString);
    return a;
  }

  static Future<bool> validateForm(GlobalKey<FormState> formKey) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return false;
    } else {
      formKey.currentState!.save();
      return true;
    }
  }

  static showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          side: BorderSide(color: AppTheme.gmBorder),
        ),
        title: Text(title, style: AppTheme.headingSmall),
        content: Text(message, style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: Text('Yes', style: AppTheme.bodyMedium.copyWith(color: AppTheme.accent)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static void logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    Services.offAll(AppRoutes.login);
  }

  static String formatDate({required DateTime date, String format = 'yyyy-MM-dd'}) {
    DateFormat dateFormat = DateFormat(format);
    return dateFormat.format(date);
  }

  static String formatPhoneNumber(String fullNumber) {
    String digitsOnly = fullNumber.replaceAll(RegExp(r'\D+'), '');
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(digitsOnly.length - 10);
    }
    return digitsOnly;
  }

  static hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static String getRashi(String name) {
    if (name.startsWith('A') || name.startsWith('L') ||
        name.startsWith('E') || name.startsWith('I') || name.startsWith('O')) {
      return 'Mesh';
    } else if (name.startsWith('B') || name.startsWith('V') ||
        name.startsWith('U') || name.startsWith('W')) {
      return 'Vrishbha';
    } else if (name.startsWith('K') || name.startsWith('CHH') ||
        name.startsWith('GH') || name.startsWith('Q') || name.startsWith('C')) {
      return 'Mithuna';
    } else if (name.startsWith('DD') || name.startsWith('H')) {
      return 'Kark';
    } else if (name.startsWith('M') || name.startsWith('TT')) {
      return 'Simha';
    } else if (name.startsWith('P') || name.startsWith('TTHH')) {
      return 'Kanya';
    } else if (name.startsWith('R') || name.startsWith('T')) {
      return 'Tula';
    } else if (name.startsWith('N') || name.startsWith('Y')) {
      return 'Vrishchik';
    } else if (name.startsWith('BH') || name.startsWith('F') || name.startsWith('DH')) {
      return 'Dhanu';
    } else if (name.startsWith('KH') || name.startsWith('J')) {
      return 'Makar';
    } else if (name.startsWith('G') || name.startsWith('S') || name.startsWith('SH')) {
      return 'Kumbh';
    } else if (name.startsWith('D') || name.startsWith('CH') ||
        name.startsWith('Z') || name.startsWith('TH')) {
      return 'Meen';
    } else {
      return 'Unavailable';
    }
  }

  static Color colorOfGrahs({required String type}) {
    switch (type) {
      case 'Rahu':
        return AppTheme.rahuColor.withOpacity(0.25);
      case 'Jupiter':
        return AppTheme.jupiterColor.withOpacity(0.25);
      case 'Saturn':
        return AppTheme.saturnColor.withOpacity(0.25);
      case 'Mercury':
        return AppTheme.mercuryColor.withOpacity(0.25);
      case 'Ketu':
        return AppTheme.ketuColor.withOpacity(0.25);
      case 'Venus':
        return AppTheme.venusColor.withOpacity(0.25);
      case 'Sun':
        return AppTheme.sunColor.withOpacity(0.25);
      case 'Moon':
        return AppTheme.moonColor.withOpacity(0.25);
      case 'Mars':
        return AppTheme.marsColor.withOpacity(0.25);
      default:
        return AppTheme.textMuted;
    }
  }

  static Color cosmoGraphColor(double value) {
    if (value < 30) return Colors.red;
    if (value < 40) return Colors.orange;
    if (value < 50) return Colors.yellow;
    if (value < 60) return Colors.grey;
    if (value < 70) return Colors.cyan;
    if (value < 80) return Colors.blue;
    return Colors.lightGreen;
  }

  static Color graphColors({required String type}) {
    switch (type) {
      case 'Jupiter':
        return const Color(0xffbda502);
      case 'Saturn':
        return const Color(0xff0000FE);
      case 'Mercury':
        return const Color(0xff008001);
      case 'Venus':
        return const Color(0xffFF00FE);
      case 'Sun':
        return const Color(0xffFEA500);
      case 'Moon':
        return const Color(0xffC0C0C0);
      case 'Mars':
        return const Color(0xffFE0000);
      default:
        return AppTheme.textMuted;
    }
  }

  static Color gocharColors({required double value}) {
    if (value >= 50) return Colors.green;
    if (value >= 30) return const Color(0xfff6e84e);
    if (value < 30) return Colors.red;
    return Colors.transparent;
  }

  static Color gocharTextColors({required double value}) {
    if (value >= 50) return Colors.green;
    if (value >= 30) return const Color(0xffbda502);
    if (value < 30) return Colors.red;
    return Colors.transparent;
  }
}
