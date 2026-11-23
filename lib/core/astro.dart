import 'package:flutter/material.dart';

import '../ui/ck_theme.dart';

/// GRAH ids in the software's display order.
const kGrahOrder = ['Su', 'Mo', 'Ra', 'Ke', 'Ju', 'Sa', 'Ma', 'Ve', 'Me', 'As'];
const kGrahNames = {
  'Su': 'Sun', 'Mo': 'Moon', 'Ma': 'Mars', 'Me': 'Mercury', 'Ju': 'Jupiter',
  'Ve': 'Venus', 'Sa': 'Saturn', 'Ra': 'Rahu', 'Ke': 'Ketu', 'As': 'Ascendant',
};
const kGrahSeq = {'Su': 1, 'Mo': 2, 'Ra': 3, 'Ke': 4, 'Ju': 5, 'Sa': 6, 'Ma': 7, 'Ve': 8, 'Me': 9, 'As': 10};

const kGrahColors = {
  'Su': CkColors.sun, 'Mo': CkColors.moon, 'Ma': CkColors.mars, 'Me': CkColors.mercury,
  'Ju': CkColors.jupiter, 'Ve': CkColors.venus, 'Sa': CkColors.saturn,
  'Ra': CkColors.rahu, 'Ke': CkColors.ketu, 'As': CkColors.ascendant,
};
const kGrahHex = {
  'Su': '#E85D2A', 'Mo': '#B4EFFC', 'Ma': '#FF3B3B', 'Me': '#10B981', 'Ju': '#F59E0B',
  'Ve': '#EC4899', 'Sa': '#8B84FF', 'Ra': '#A9AEB8', 'Ke': '#D0607F', 'As': '#D9B38C',
};

Color grahColor(String id) => kGrahColors[id] ?? Colors.white;

const kRashiEn = ['', 'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
const kRashiHi = ['', 'मेष', 'वृषभ', 'मिथुन', 'कर्क', 'सिंह', 'कन्या', 'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुम्भ', 'मीन'];
const kRashiGu = ['', 'મેષ', 'વૃષભ', 'મિથુન', 'કર્ક', 'સિંહ', 'કન્યા', 'તુલા', 'વૃશ્ચિક', 'ધનુ', 'મકર', 'કુંભ', 'મીન'];
const kSwami = ['', 'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter'];
const kTatva = ['Agni', 'Pruthvi', 'Vayu', 'Jal'];
const kSwabhav = ['Char', 'Sthir', 'Dwi'];

String tatva(int rashi) => rashi < 1 ? '—' : kTatva[(rashi - 1) % 4];
String swabhav(int rashi) => rashi < 1 ? '—' : kSwabhav[(rashi - 1) % 3];
String swami(int rashi) => rashi < 1 || rashi > 12 ? '—' : kSwami[rashi];
String rashiName(int rashi, [String lang = 'en']) {
  if (rashi < 1 || rashi > 12) return '—';
  return (lang == 'hi' ? kRashiHi : lang == 'gu' ? kRashiGu : kRashiEn)[rashi];
}

String rashiShort(int rashi, [int n = 3]) {
  final s = rashiName(rashi);
  return s.length <= n ? s : s.substring(0, n);
}

const _rashiAliases = {
  'aries': 1, 'mesh': 1, 'mesha': 1, 'taurus': 2, 'vrishabh': 2, 'vrushabh': 2, 'vrishabha': 2,
  'gemini': 3, 'mithun': 3, 'mithuna': 3, 'cancer': 4, 'kark': 4, 'karka': 4, 'leo': 5, 'simha': 5, 'sinh': 5,
  'virgo': 6, 'kanya': 6, 'libra': 7, 'tula': 7, 'scorpio': 8, 'vrishchik': 8, 'vrushchik': 8, 'vrischik': 8,
  'sagittarius': 9, 'dhanu': 9, 'dhanus': 9, 'capricorn': 10, 'makar': 10, 'makara': 10,
  'aquarius': 11, 'kumbh': 11, 'kumbha': 11, 'pisces': 12, 'meen': 12, 'mina': 12, 'meena': 12,
};

/// Rashi number 1–12 from "7", "07", "Libra", "Tula", "तुला" …
int parseRashi(dynamic v) {
  if (v == null) return 0;
  final s = v.toString().trim();
  final n = int.tryParse(s);
  if (n != null) return (n >= 1 && n <= 12) ? n : 0;
  final low = s.toLowerCase().replaceAll(RegExp(r'[^a-zऀ-૿]'), '');
  if (_rashiAliases.containsKey(low)) return _rashiAliases[low]!;
  for (final e in _rashiAliases.entries) {
    if (low.startsWith(e.key)) return e.value;
  }
  for (var i = 1; i <= 12; i++) {
    if (s.contains(kRashiHi[i]) || s.contains(kRashiGu[i])) return i;
  }
  return 0;
}

/// Decimal degrees from "15° 20' 33\"", "15:20:33", "15-20-33", "15.342" …
double parseDegree(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  final nums = RegExp(r'\d+(?:\.\d+)?').allMatches(v.toString()).map((m) => double.parse(m.group(0)!)).toList();
  if (nums.isEmpty) return 0;
  if (nums.length == 1) return nums[0];
  return nums[0] + nums[1] / 60 + (nums.length > 2 ? nums[2] / 3600 : 0);
}

String fmtDeg(double d) {
  final deg = d.floor();
  final min = ((d - deg) * 60).round().clamp(0, 59);
  return '${deg.toString().padLeft(2, '0')}° ${min.toString().padLeft(2, '0')}′';
}

/// GRAH id from "Su", "Sun", "Surya", "Lagan", "सूर्य (R)" …
String parseGrah(dynamic v) {
  final s = (v ?? '').toString().toLowerCase().replaceAll(RegExp(r'\(.*?\)|\*'), '').trim();
  const m = {
    'su': 'Su', 'sun': 'Su', 'surya': 'Su', 'sury': 'Su', 'सूर्य': 'Su', 'सू': 'Su',
    'mo': 'Mo', 'moon': 'Mo', 'chandra': 'Mo', 'चंद्र': 'Mo', 'चं': 'Mo',
    'ma': 'Ma', 'mars': 'Ma', 'mangal': 'Ma', 'मंगल': 'Ma', 'मं': 'Ma',
    'me': 'Me', 'mercury': 'Me', 'budh': 'Me', 'budha': 'Me', 'बुध': 'Me', 'बु': 'Me',
    'ju': 'Ju', 'jupiter': 'Ju', 'guru': 'Ju', 'brihaspati': 'Ju', 'गुरु': 'Ju', 'गु': 'Ju',
    've': 'Ve', 'venus': 'Ve', 'shukra': 'Ve', 'शुक्र': 'Ve', 'शु': 'Ve',
    'sa': 'Sa', 'saturn': 'Sa', 'shani': 'Sa', 'sani': 'Sa', 'शनि': 'Sa', 'श': 'Sa',
    'ra': 'Ra', 'rahu': 'Ra', 'राहु': 'Ra', 'रा': 'Ra',
    'ke': 'Ke', 'ketu': 'Ke', 'केतु': 'Ke', 'के': 'Ke',
    'as': 'As', 'asc': 'As', 'ascendant': 'As', 'lagan': 'As', 'lagna': 'As', 'la': 'As', 'लग्न': 'As', 'ल': 'As',
  };
  if (m.containsKey(s)) return m[s]!;
  for (final e in m.entries) {
    if (e.key.length > 2 && s.startsWith(e.key)) return e.value;
  }
  if (s.length >= 2 && m.containsKey(s.substring(0, 2))) return m[s.substring(0, 2)]!;
  return '';
}

bool _retroFlag(Map<String, dynamic> j) {
  for (final k in ['retro', 'Retro', 'is_retro', 'isRetro', 'retrograde', 'Retrograde', 'vakri', 'Vakri']) {
    final v = j[k];
    if (v == true || v == 1 || v == '1' || v.toString().toLowerCase() == 'true' || v.toString().toUpperCase() == 'R') return true;
  }
  final p = (j['planet'] ?? '').toString();
  return RegExp(r'\(R\)|\bR\b|\*|vakri|retro', caseSensitive: false).hasMatch(p.replaceFirst(RegExp(r'^[A-Za-z]{2}'), ''));
}

/// One GRAH position.
class GrahPos {
  final String id;
  final int rashi; // 1..12
  final double degIn; // degree within rashi 0..30
  final String nakshatra;
  final bool retro;

  const GrahPos(this.id, this.rashi, this.degIn, {this.nakshatra = '', this.retro = false});

  double get longitude => (rashi - 1) * 30 + degIn;
  Color get color => grahColor(id);
  String get name => kGrahNames[id] ?? id;

  static GrahPos? fromJson(Map<String, dynamic> j) {
    final id = parseGrah(j['planet'] ?? j['Planet'] ?? j['grah'] ?? j['title']);
    if (id.isEmpty) return null;
    var rashi = parseRashi(j['rashi'] ?? j['Rashi']);
    var deg = parseDegree(j['degree'] ?? j['Degree']);
    final lon = j['longitute'] ?? j['longitude'] ?? j['Longitude'];
    if (lon != null && lon.toString().trim().isNotEmpty) {
      final l = parseDegree(lon);
      if (l > 0 || rashi == 0) {
        rashi = (l ~/ 30) % 12 + 1;
        deg = l % 30;
      }
    } else if (deg >= 30) {
      rashi = (deg ~/ 30) % 12 + 1;
      deg = deg % 30;
    }
    final retro = _retroFlag(j); // true nodes: Ra/Ke only when the API says so
    return GrahPos(id, rashi, deg, nakshatra: (j['nakshatra'] ?? j['Nakshatra'] ?? '').toString(), retro: retro);
  }

  static List<GrahPos> listFrom(List<Map<String, dynamic>> raw) {
    final out = raw.map(GrahPos.fromJson).whereType<GrahPos>().toList();
    out.sort((a, b) => (kGrahSeq[a.id] ?? 99).compareTo(kGrahSeq[b.id] ?? 99));
    return out;
  }
}

/// The 7 zones of Situations (CK reports).
class Zone {
  final int min;
  final int max;
  final String name;
  final String advice;
  final Color color;
  final int arrows; // 1..3, 0 = flat
  final int dir; // 1 up, -1 down, 0 flat
  const Zone(this.min, this.max, this.name, this.advice, this.color, this.arrows, this.dir);
}

const kZones = [
  Zone(86, 100, 'Optimal', 'Make the most of it', Color(0xFF5EE38A), 3, 1),
  Zone(66, 85, 'Strong', 'Move ahead', Color(0xFF4C8DFF), 2, 1),
  Zone(56, 65, 'Stable', 'Carry on as usual', Color(0xFF3FD4F0), 1, 1),
  Zone(46, 55, 'Moderate', 'Proceed with care', Color(0xFFC9D2E3), 0, 0),
  Zone(36, 45, 'Sensitive', 'Go slow, double-check', Color(0xFFF5D90A), 1, -1),
  Zone(16, 35, 'Severe', 'Delay what can wait', Color(0xFFF59E0B), 2, -1),
  Zone(0, 15, 'Critical', 'Do only what is essential', Color(0xFFEF4444), 3, -1),
];

Zone zoneOf(double v) {
  final r = v.round();
  for (final z in kZones) {
    if (r >= z.min) return z;
  }
  return kZones.last;
}
