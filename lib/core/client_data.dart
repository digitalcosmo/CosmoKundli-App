import 'package:intl/intl.dart';

import 'api.dart';
import 'astro.dart';

/// Per-client data cache so moving between sections doesn't refetch.
class ClientData {
  final String mId;
  ClientData(this.mId);

  static ClientData? _current;
  static ClientData of(String mId) {
    if (_current?.mId != mId) _current = ClientData(mId);
    return _current!;
  }

  Future<List<GrahPos>>? _chart;
  Future<List<GrahPos>>? _info;
  Future<Map<String, double>>? _shadbal;
  Future<Map<String, dynamic>>? _details;

  /// Birth chart positions (BirthChart) merged with nakshatra / retro data
  /// from BithPlanetInfo.
  Future<List<GrahPos>> chart({bool refresh = false}) {
    if (refresh) {
      _chart = null;
      _info = null;
    }
    return _chart ??= () async {
      final r = await Api.post(Endpoints.birthChart, {'mID': mId});
      var list = GrahPos.listFrom(Api.list(r, ['planets', 'list']));
      List<GrahPos> info = [];
      try {
        info = await planetInfo();
      } catch (_) {}
      if (list.isEmpty) list = info;
      return list.map((p) {
        final i = info.where((e) => e.id == p.id).toList();
        if (i.isEmpty) return p;
        final x = i.first;
        return GrahPos(p.id, p.rashi == 0 ? x.rashi : p.rashi, p.degIn == 0 ? x.degIn : p.degIn,
            nakshatra: x.nakshatra, retro: p.retro || x.retro);
      }).toList();
    }();
  }

  Future<List<GrahPos>> planetInfo() => _info ??= () async {
        final r = await Api.post(Endpoints.birthPlanetInfo, {'mID': mId});
        return GrahPos.listFrom(Api.list(r, ['planets', 'list']));
      }();

  /// Shadbal (used for Power and Flavor until their own APIs exist).
  Future<Map<String, double>> shadbal({bool refresh = false}) {
    if (refresh) _shadbal = null;
    return _shadbal ??= () async {
      final r = await Api.post(Endpoints.shadbal, {'mID': mId});
      final out = <String, double>{};
      for (final e in Api.list(r, ['list', 'data'])) {
        final id = parseGrah(e['title'] ?? e['planet']);
        if (id.isEmpty) continue;
        final v = e['value'];
        out[id] = v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
      }
      return out;
    }();
  }

  Future<Map<String, dynamic>> details() => _details ??= Api.post(Endpoints.memberDetails, {'mID': mId});

  /// Transit positions for a moment (GocharAnimated).
  Future<List<GrahPos>> transit(DateTime at) async {
    final r = await Api.post(Endpoints.gocharAnimated, {'mID': mId, 'Datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(at)});
    return GrahPos.listFrom(Api.list(r, ['planets', 'list']));
  }

  /// Sentiments for a month (Star_Power_Daily).
  Future<List<MapEntry<DateTime, double>>> sentiments(DateTime month) async {
    final r = await Api.post(Endpoints.starPowerDaily, {'mID': mId, 'Month': DateFormat('yyyy-MM').format(month)});
    final out = <MapEntry<DateTime, double>>[];
    var day = 1;
    for (final e in Api.list(r, ['list'])) {
      final raw = (e['Date'] ?? e['date'] ?? '').toString();
      DateTime? d;
      for (final f in ['yyyy-MM-dd', 'dd-MM-yyyy', 'dd/MM/yyyy', 'd']) {
        try {
          d = DateFormat(f).parseStrict(raw);
          if (f == 'd') d = DateTime(month.year, month.month, d.day);
          break;
        } catch (_) {}
      }
      d ??= DateTime(month.year, month.month, day);
      final v = e['Value'] ?? e['value'];
      out.add(MapEntry(d, v is num ? v.toDouble() : double.tryParse('$v') ?? 0));
      day++;
    }
    out.sort((a, b) => a.key.compareTo(b.key));
    return out;
  }

  /// Situations for a month (Cosmo_Power_Daily): {Date: "01 Aug", Value: 62.7}, 0..100.
  Future<List<MapEntry<DateTime, double>>> situations(DateTime month) async {
    final r = await Api.post(Endpoints.cosmoPowerDaily, {'mID': mId, 'Month': DateFormat('yyyy-MM').format(month)});
    final out = <MapEntry<DateTime, double>>[];
    var day = 1;
    for (final e in Api.list(r, ['list'])) {
      final raw = (e['Date'] ?? e['date'] ?? '').toString().trim();
      final n = int.tryParse(RegExp(r'^\d{1,2}').firstMatch(raw)?.group(0) ?? '');
      DateTime? d;
      try {
        d = DateFormat('yyyy-MM-dd').parseStrict(raw);
      } catch (_) {}
      d ??= DateTime(month.year, month.month, n ?? day);
      final v = e['Value'] ?? e['value'];
      out.add(MapEntry(d, v is num ? v.toDouble() : double.tryParse('$v') ?? 0));
      day++;
    }
    out.sort((a, b) => a.key.compareTo(b.key));
    return out;
  }

  static const kDims = ['Career', 'Finance', 'Health', 'Social', 'Love'];
  final _fiveD = <String, Future<Map<DateTime, Map<String, double>>>>{};

  /// Sentiments 5D for a whole month, built from Star_Power_Report, which
  /// gives one dimension for one ISO week per call (5 dimensions x ~5 weeks).
  Future<Map<DateTime, Map<String, double>>> sentiments5D(DateTime month) {
    final k = '${month.year}-${month.month}';
    return _fiveD[k] ??= _load5D(month).catchError((Object e) {
      _fiveD.remove(k);
      throw e;
    });
  }

  Future<Map<DateTime, Map<String, double>>> _load5D(DateTime month) async {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final mondays = <DateTime>[];
    for (var m = first.subtract(Duration(days: first.weekday - 1)); !m.isAfter(last); m = m.add(const Duration(days: 7))) {
      mondays.add(m);
    }
    (int, int) isoWeek(DateTime monday) {
      final thu = monday.add(const Duration(days: 3));
      final jan1 = DateTime(thu.year, 1, 1);
      final week = ((thu.difference(jan1).inDays) ~/ 7) + 1;
      return (week, thu.year);
    }

    const keys = ['Moday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const alt = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final out = <DateTime, Map<String, double>>{};
    final calls = <Future<void>>[];
    for (final dim in kDims) {
      for (final mon in mondays) {
        final w = isoWeek(mon);
        calls.add(() async {
          final Map<String, dynamic> r;
          try {
            r = await Api.post(Endpoints.starPowerReport, {'mID': mId, 'Type': dim, 'Weeknumber': '${w.$1}', 'Year': '${w.$2}'});
          } catch (_) {
            return;
          }
          final l = Api.list(r, ['list']);
          if (l.isEmpty) return;
          final row = l.first;
          for (var k = 0; k < 7; k++) {
            final d = mon.add(Duration(days: k));
            if (d.month != month.month) continue;
            final v = row[keys[k]] ?? row[alt[k]];
            final n = v is num ? v.toDouble() : double.tryParse('$v');
            if (n == null) continue;
            out.putIfAbsent(DateTime(d.year, d.month, d.day), () => {})[dim] = n;
          }
        }());
      }
    }
    await Future.wait(calls);
    if (out.isEmpty) throw Exception('No 5D data');
    return out;
  }
}
