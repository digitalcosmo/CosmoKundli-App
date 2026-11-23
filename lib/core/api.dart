import 'dart:convert';

import 'package:dio/dio.dart';

import '../network/network_api_services.dart';
import '../values/urls.dart';

/// Thin wrapper over the existing CosmoKundli API (same endpoints and
/// payloads as the original app). Every call returns a plain map so the UI is
/// tolerant of small response-shape differences.
class Api {
  static final NetworkApiServices _net = NetworkApiServices();

  static Map<String, dynamic> _asMap(dynamic r) {
    if (r is Map<String, dynamic>) return r;
    if (r is Map) return Map<String, dynamic>.from(r);
    if (r is String && r.trim().isNotEmpty) {
      final d = jsonDecode(r);
      if (d is Map) return Map<String, dynamic>.from(d);
      return {'status': true, 'list': d};
    }
    if (r is List) return {'status': true, 'list': r};
    return {'status': false, 'msg': 'Empty response'};
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final r = await _net.postApi(data, endpoint);
    return _asMap(r);
  }

  static Future<Map<String, dynamic>> upload(
      String endpoint, String uid, String filePath) async {
    final form = FormData.fromMap({
      'uID': uid,
      'Image': await MultipartFile.fromFile(filePath),
    });
    final r = await _net.imageApi(form, endpoint);
    return _asMap(r);
  }

  static bool ok(Map<String, dynamic> m) {
    final s = m['status'];
    return s == true || s == 1 || s == '1' || s.toString().toLowerCase() == 'true';
  }

  static String msg(Map<String, dynamic> m, [String fallback = 'Something went wrong']) {
    final v = m['msg'] ?? m['message'];
    return (v == null || v.toString().isEmpty) ? fallback : v.toString();
  }

  /// First list found under common keys.
  static List<Map<String, dynamic>> list(Map<String, dynamic> m,
      [List<String> keys = const ['list', 'members', 'planets', 'data']]) {
    for (final k in keys) {
      final v = m[k];
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }
}

class Endpoints {
  static const login = AppUrls.login;
  static const signUp = AppUrls.signUp;
  static const verifyDevice = AppUrls.verifyDevice;
  static const forgot = AppUrls.forgot_pass;
  static const reset = AppUrls.reset_password;
  static const memberList = AppUrls.memberList;
  static const memberAdd = AppUrls.memberAdd;
  static const memberUpdate = AppUrls.MemberUpdate;
  static const memberDelete = AppUrls.memberDelete;
  static const memberDetails = AppUrls.memberDetails;
  static const birthChart = AppUrls.birthChart;
  static const birthPlanetInfo = AppUrls.bithPlanetInfo;
  static const shadbal = AppUrls.shadbal;
  static const starPowerDaily = AppUrls.Star_Power_Daily;
  static const gocharAnimated = AppUrls.GocharAnimated;
  static const melapakOppList = AppUrls.Melapak_Opp_User_List;
  static const melapakExisting = AppUrls.Melapak_Details_Existing_User;
  static const melapakNew = AppUrls.Melapak_Details_New_User;
  static const panchang = 'Panchang';
  static const profileDetails = 'Profile_Details';
  static const profileUpdate = 'Profile_Update';
  static const displayDetails = 'Display_Details';
  static const displayUpdate = 'Display_Update';
  static const displayFront = 'Display_Front_Image_Update';
  static const displayBack = 'Display_Back_Image_Update';
  static const appDetails = 'App_Details';
  static const appUpdate = 'App_Update';
  static const appIcon = 'App_Icon_Update';
  static const credits = 'Credit_Transactions';
  static const reportHistory = 'Report_History';
  static const changePassword = 'Change_Password';
  static const cosmoPower3 = 'CosmoPower_3Month';
  static const cosmoPower6 = 'CosmoPower_6Month';
  static const cosmoPower12 = 'CosmoPower_12Month';
}
