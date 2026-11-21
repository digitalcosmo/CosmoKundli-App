import 'dart:convert';
import 'package:cosmo_kundli/values/sp_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static Future<void> saveLanguage(String languageName, String code) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.language, languageName);
    prefs.setString(SPKeys.code, code);
  }

  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(SPKeys.isLoggedIn, isLoggedIn);
  }

  static Future<bool> getLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SPKeys.isLoggedIn) ?? false;
  }

  static Future<void> setuID(String uId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.uID, uId);
  }

  static Future<String?> getuID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPKeys.uID);
  }

  static Future<void> setmID(String mId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.mID, mId);
  }

  static Future<String?> getmID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPKeys.mID);
  }

  static Future<void> setFeatures(List<String> featureList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.featureList, jsonEncode(featureList));
  }

  static Future<String> getFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPKeys.featureList) ?? '[]';
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
