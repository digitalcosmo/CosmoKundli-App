import 'dart:async';
import 'package:flutter/foundation.dart';
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

  final _memo = <String, Future<dynamic>>{};

  /// Caches a call under [key]; a failed call is dropped so Retry refetches.
  Future<T> _m<T>(String key, Future<T> Function() f) {
    final hit = _memo[key];
    if (hit != null) return hit as Future<T>;
    final fut = f();
    _memo[key] = fut;
    fut.then((_) {}, onError: (Object _) {
      if (identical(_memo[key], fut)) _memo.remove(key);
    });
    return fut;
  }

  /// Drops cached calls whose key starts with [prefix] (per-module Retry).
  void drop(String prefix) => _memo.removeWhere((k, _) => k.startsWith(prefix));

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
    if (_chart == null) {
      final f = _chartLoad();
      _chart = f;
      f.then((_) {}, onError: (Object _) {
        if (identical(_chart, f)) _chart = null;
      });
    }
    return _chart!;
  }

  Future<List<GrahPos>> _chartLoad() async {
    return () async {
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
    if (_shadbal == null) {
      final f = _shadbalLoad();
      _shadbal = f;
      f.then((_) {}, onError: (Object _) {
        if (identical(_shadbal, f)) _shadbal = null;
      });
    }
    return _shadbal!;
  }

  Future<Map<String, double>> _shadbalLoad() async {
    return () async {
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

  Future<Map<String, dynamic>> details({bool refresh = false}) {
    if (refresh) _details = null;
    final hit = _details;
    if (hit != null) return hit;
    final f = Api.post(Endpoints.memberDetails, {'mID': mId});
    _details = f;
    f.then((_) {}, onError: (Object _) {
      if (identical(_details, f)) _details = null;
    });
    return f;
  }

  /// Transit positions for a moment (GocharAnimated).
  Future<List<GrahPos>> transit(DateTime at) =>
      _m('transit:${DateFormat('yyyy-MM-dd HH:mm').format(at)}', () => _transit(at));

  Future<List<GrahPos>> _transit(DateTime at) async {
    final r = await Api.post(Endpoints.gocharAnimated, {'mID': mId, 'Datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(at)});
    return GrahPos.listFrom(Api.list(r, ['planets', 'list']));
  }

  /// Sentiments for a month (Star_Power_Daily).
  Future<List<MapEntry<DateTime, double>>> sentiments(DateTime month) =>
      _m('sent:${DateFormat('yyyy-MM').format(month)}', () => _sentiments(month));

  Future<List<MapEntry<DateTime, double>>> _sentiments(DateTime month) async {
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
  Future<List<MapEntry<DateTime, double>>> situations(DateTime month) =>
      _m('sit:${DateFormat('yyyy-MM').format(month)}', () => _situations(month));

  /// Daily values from [from] to [to] (inclusive), fetching every month the
  /// window touches. [kind] is 'sent' or 'sit'.
  Future<List<MapEntry<DateTime, double>>> window(String kind, DateTime from, DateTime to) async {
    final a = DateTime(from.year, from.month, from.day), b = DateTime(to.year, to.month, to.day);
    final months = <DateTime>[];
    for (var m = DateTime(a.year, a.month); !m.isAfter(DateTime(b.year, b.month)); m = DateTime(m.year, m.month + 1)) {
      months.add(m);
    }
    final parts = await Future.wait(months.map((m) => kind == 'sent' ? sentiments(m) : situations(m)));
    return [
      for (final l in parts)
        for (final e in l)
          if (!e.key.isBefore(a) && !e.key.isAfter(b)) e
    ];
  }

  Future<List<MapEntry<DateTime, double>>> _situations(DateTime month) async {
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
  final _fiveD = <String, FiveDLoad>{};

  /// Sentiments 5D for a whole month, built from Star_Power_Report, which
  /// gives one dimension for one ISO week per call (5 dimensions x ~5 weeks).
  /// Streams: the page shows each week as it arrives, with progress.
  FiveDLoad sentiments5DLive(DateTime month, {bool retryFailed = false}) {
    final k = '${month.year}-${month.month}';
    final cur = _fiveD[k];
    if (cur != null && !(retryFailed && cur.failed.isNotEmpty)) return cur;
    final l = cur ?? FiveDLoad(month);
    _fiveD[k] = l;
    _run5D(l, only: cur?.failed.toList());
    return l;
  }

  Future<Map<DateTime, Map<String, double>>> sentiments5D(DateTime month) async {
    final l = sentiments5DLive(month);
    await l.done;
    if (l.data.isEmpty) {
      _fiveD.remove('${month.year}-${month.month}');
      throw Exception('No 5D data');
    }
    return l.data;
  }

  Future<void> _run5D(FiveDLoad l, {List<(String, DateTime)>? only}) async {
    final month = l.month;
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
    final jobs = only ?? [for (final dim in kDims) for (final mon in mondays) (dim, mon)];
    l.total = only == null ? jobs.length : l.total;
    if (only != null) {
      l.failed.clear();
      l.finished -= jobs.length;
    }
    l.loading = true;
    l.notify();
    await Future.wait(jobs.map((j) async {
      final (dim, mon) = j;
      final w = isoWeek(mon);
      try {
        final r = await Api.post(Endpoints.starPowerReport, {'mID': mId, 'Type': dim, 'Weeknumber': '${w.$1}', 'Year': '${w.$2}'});
        final rows = Api.list(r, ['list']);
        if (rows.isNotEmpty) {
          final row = rows.first;
          for (var k = 0; k < 7; k++) {
            final d = mon.add(Duration(days: k));
            if (d.month != month.month) continue;
            final v = row[keys[k]] ?? row[alt[k]];
            final n = v is num ? v.toDouble() : double.tryParse('$v');
            if (n == null) continue;
            l.data.putIfAbsent(DateTime(d.year, d.month, d.day), () => {})[dim] = n;
          }
        }
      } catch (_) {
        l.failed.add(j);
      }
      l.finished++;
      l.notify();
    }));
    l.loading = false;
    l.notify();
    if (!l._done.isCompleted) l._done.complete();
  }
}

/// One month of Sentiments 5D loading in pieces.
class FiveDLoad extends ChangeNotifier {
  final DateTime month;
  FiveDLoad(this.month);
  final data = <DateTime, Map<String, double>>{};
  final failed = <(String, DateTime)>{};
  int total = 0, finished = 0;
  bool loading = true;
  final _done = Completer<void>();
  Future<void> get done => _done.future;
  void notify() => notifyListeners();
}
