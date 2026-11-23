import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  var locale = Rx<Locale>(Locale('en', 'US'));

  void saveLocal(String language, String code) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('language', language);
    sharedPreferences.setString('code', code);
  }

  void getLocal() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String lan = sharedPreferences.getString('language') ?? 'en';
    String? code = sharedPreferences.getString('code');
    locale.value  = Locale(lan, code);
    Get.updateLocale(Locale(lan, code));
  }
}
