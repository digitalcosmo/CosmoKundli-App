import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/sp_keys.dart';
import 'client_data.dart';

/// A client (member) as returned by MemberList.
class Client {
  final String mId;
  final String name;
  final String gender;
  final String dobRaw; // "dd-MM-yyyy HH:mm:ss"
  final String city;

  const Client({
    required this.mId,
    required this.name,
    required this.gender,
    required this.dobRaw,
    required this.city,
  });

  factory Client.fromJson(Map<String, dynamic> j) => Client(
        mId: (j['mID'] ?? j['mid'] ?? '').toString(),
        name: (j['Name'] ?? j['name'] ?? '').toString().trim(),
        gender: (j['Gender'] ?? j['gender'] ?? '').toString(),
        dobRaw: (j['DOB'] ?? j['dob'] ?? '').toString(),
        city: (j['City'] ?? j['city'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() =>
      {'mID': mId, 'Name': name, 'Gender': gender, 'DOB': dobRaw, 'City': city};

  DateTime? get birth {
    for (final f in ['dd-MM-yyyy HH:mm:ss', 'dd-MM-yyyy HH:mm', 'yyyy-MM-dd HH:mm:ss', 'dd-MM-yyyy', 'yyyy-MM-dd']) {
      try {
        return DateFormat(f).parseStrict(dobRaw);
      } catch (_) {}
    }
    return null;
  }

  String get dateText {
    final b = birth;
    return b == null ? dobRaw : DateFormat('dd MMM yyyy').format(b);
  }

  String get timeText {
    final b = birth;
    return b == null ? '' : DateFormat('HH:mm').format(b);
  }

  String get genderText {
    final g = gender.toLowerCase();
    if (g.startsWith('f')) return 'Female';
    if (g.startsWith('m')) return 'Male';
    return gender;
  }

  bool get isFemale => gender.toLowerCase().startsWith('f');

  String get initials {
    final p = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    return (p.first[0] + (p.length > 1 ? p[1][0] : '')).toUpperCase();
  }

  String get subtitle =>
      [dateText, timeText, city].where((e) => e.trim().isNotEmpty).join(' · ');
}

/// App-wide session: signed-in user and the client currently open.
class Session {
  static late SharedPreferences _p;
  static String? deviceId;
  static final ValueNotifier<Client?> client = ValueNotifier(null);
  static final ValueNotifier<String> lang = ValueNotifier('en');

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    lang.value = _p.getString(SPKeys.language) ?? 'en';
    try {
      deviceId = await MobileDeviceIdentifier().getDeviceId();
    } on PlatformException {
      deviceId = null;
    } catch (_) {
      deviceId = null;
    }
  }

  static SharedPreferences get prefs => _p;
  static String get uid => _p.getString(SPKeys.uID) ?? '';
  static bool get loggedIn => (_p.getBool(SPKeys.isLoggedIn) ?? false) && uid.isNotEmpty;

  static Future<void> signIn(String uid, List features) async {
    await _p.setString(SPKeys.uID, uid);
    await _p.setBool(SPKeys.isLoggedIn, true);
    await _p.setString(SPKeys.featureList, jsonEncode(features));
  }

  static Future<void> signOut() async {
    final l = lang.value;
    // Keep per-user workspace layouts and the location choice across logout.
    final keep = <String, Object>{
      for (final k in _p.getKeys())
        if (k.startsWith('ws_u') || k.startsWith('here_'))
          if (_p.get(k) != null) k: _p.get(k)!,
    };
    await _p.clear();
    await _p.setString(SPKeys.language, l);
    for (final e in keep.entries) {
      final v = e.value;
      if (v is String) await _p.setString(e.key, v);
      if (v is bool) await _p.setBool(e.key, v);
      if (v is double) await _p.setDouble(e.key, v);
      if (v is int) await _p.setInt(e.key, v);
      if (v is List) await _p.setStringList(e.key, v.map((x) => '$x').toList());
    }
    client.value = null;
    ClientData.clearAll();
  }

  static Future<void> setLang(String code) async {
    lang.value = code;
    await _p.setString(SPKeys.language, code);
  }

  // Recently opened clients (stored locally, most recent first).
  static List<Client> get recent {
    final raw = _p.getStringList('recentClients') ?? [];
    return raw
        .map((e) {
          try {
            return Client.fromJson(Map<String, dynamic>.from(jsonDecode(e)));
          } catch (_) {
            return null;
          }
        })
        .whereType<Client>()
        .toList();
  }

  static Future<void> open(Client c) async {
    client.value = c;
    await _p.setString(SPKeys.mID, c.mId);
    final list = recent.where((e) => e.mId != c.mId).toList()..insert(0, c);
    await _p.setStringList(
        'recentClients', list.take(6).map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<void> forget(String mId) async {
    final list = recent.where((e) => e.mId != mId).toList();
    await _p.setStringList(
        'recentClients', list.map((e) => jsonEncode(e.toJson())).toList());
  }
}
