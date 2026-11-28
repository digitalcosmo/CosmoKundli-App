import 'dart:convert';

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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

  /// Same as [post], but answers that never change (a client's birth data
  /// and everything computed from it, past months) are kept on the phone and
  /// reused: no second network call, even after restarting the app.
  /// [owner] groups the files so a client's cache can be dropped on edit.
  static Future<Map<String, dynamic>> postKept(String endpoint, Map<String, dynamic> data, {required String owner}) async {
    final key = '$endpoint|${jsonEncode(data)}';
    final hit = await DiskCache.read(owner, key);
    if (hit != null) return hit;
    final r = await post(endpoint, data);
    if (ok(r) || r.values.any((v) => v is List && v.isNotEmpty)) DiskCache.write(owner, key, r);
    return r;
  }

  /// For answers that may still change (the current month): a copy kept on
  /// the phone is returned at once, and a fresh answer is fetched in the
  /// background and kept for next time. With no copy yet, waits for the
  /// network like [post].
  static Future<Map<String, dynamic>> postFresh(String endpoint, Map<String, dynamic> data, {required String owner}) async {
    final key = '$endpoint|${jsonEncode(data)}';
    final net = post(endpoint, data).then((r) {
      if (ok(r) || r.values.any((v) => v is List && v.isNotEmpty)) DiskCache.write(owner, key, r);
      return r;
    });
    final hit = await DiskCache.read(owner, key);
    if (hit == null) return net;
    net.then((_) {}, onError: (Object _) {});
    return hit;
  }

  /// Shares one in-flight/recent answer between screens (client list,
  /// report history, credits) for [ttl]; [force] refetches.
  static final _shared = <String, (DateTime, Future<dynamic>)>{};
  static Future<T> shared<T>(String key, Future<T> Function() load, {Duration ttl = const Duration(seconds: 60), bool force = false}) {
    final hit = _shared[key];
    if (!force && hit != null && DateTime.now().difference(hit.$1) < ttl) return hit.$2 as Future<T>;
    final f = load();
    _shared[key] = (DateTime.now(), f);
    f.then((_) {}, onError: (Object _) {
      if (identical(_shared[key]?.$2, f)) _shared.remove(key);
    });
    return f;
  }

  static void forget(String key) => _shared.remove(key);

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
  static const starPowerReport = 'Star_Power_Report';
  static const cosmoPowerDaily = 'Cosmo_Power_Daily';
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
  static const reportHistoryAll = 'Report_History_All';
  static const reportViewLink = 'Report_View_Link';
  static const reportPrices = 'Report_Prices';
  static const plannerGenerate = 'CK_Planner_Generate';
  static const vibesGenerate = 'Grah_Vibes_Generate';
  static const changePassword = 'Change_Password';
  static const cosmoPower3 = 'CosmoPower_3Month';
  static const cosmoPower6 = 'CosmoPower_6Month';
  static const cosmoPower12 = 'CosmoPower_12Month';
}


/// Small file cache under the app's private support folder.
class DiskCache {
  static Directory? _root;
  static Future<Directory> _dir(String owner) async {
    _root ??= Directory('${(await getApplicationSupportDirectory()).path}/ck_cache');
    final d = Directory('${_root!.path}/${owner.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  static String _name(String key) {
    // FNV-1a hash: short, stable file names
    var h = 0x811c9dc5;
    for (final c in utf8.encode(key)) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return '${h.toRadixString(16)}_${key.length}.json';
  }

  static Future<Map<String, dynamic>?> read(String owner, String key) async {
    try {
      final f = File('${(await _dir(owner)).path}/${_name(key)}');
      if (!await f.exists()) return null;
      final d = jsonDecode(await f.readAsString());
      return d is Map ? Map<String, dynamic>.from(d) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String owner, String key, Map<String, dynamic> v) async {
    try {
      await File('${(await _dir(owner)).path}/${_name(key)}').writeAsString(jsonEncode(v));
    } catch (_) {}
  }

  /// Drops everything kept for [owner] (e.g. a client whose birth data changed).
  static Future<void> drop(String owner) async {
    try {
      final d = await _dir(owner);
      await d.delete(recursive: true);
    } catch (_) {}
  }
}
