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
}
