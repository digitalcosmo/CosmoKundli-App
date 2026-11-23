import 'dart:convert';

import 'package:cosmo_kundali/values/sp_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static void saveLanguage(String languageName, String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.language, languageName);
    prefs.setString(SPKeys.code, code);
  }

  static void getLanguage(String languageName, String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString(SPKeys.language);
    prefs.getString(SPKeys.code);
  }

  static void setLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SPKeys.isLoggedIn, isLoggedIn);
  }

  static Future<bool> getLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool(SPKeys.isLoggedIn);
    return isLoggedIn ?? false;
  }

  static void setuID(String uId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.uID, uId);
  }

  // static void getuID() async
  // {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.getString(SPKeys.uID);
  // }

  static Future<String?> getuID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPKeys.uID);
  }


  static void setmID(String mId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.mID, mId);
  }


  static Future<String?> getmID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPKeys.mID);
  }

  static void setFeatures(List<String> featureList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.featureList, jsonEncode(featureList));
  }

  static Future<String> getFeatures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? featureListString = prefs.getString(SPKeys.featureList);

    return featureListString!;
  }


}
