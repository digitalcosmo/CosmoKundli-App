import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
import '../core/client_data.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import 'client_form_page.dart';
import 'client_shell.dart';
import 'clients_page.dart';
import 'sky_pages.dart';
import '../core/sky.dart';

ClientData get _data => ClientData.of(Session.client.value?.mId ?? '');

class TraditionalSection extends StatelessWidget {
  const TraditionalSection({super.key});
  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Traditional',
        isRoot: true,
        children: [
          const SectionIntro('Classical tools'),
          ModuleCard(
            title: 'Panchang',
            description: 'Tithi, nakshatra, yog and karan for any moment',
            icon: Icons.light_mode_outlined,
            onTap: () => pushModule(context, const PanchangPage()),
          ),
          ModuleCard(
            index: 1,
            title: 'Melapak',
            description: 'Ashtakoot match with another person',
            icon: Icons.join_inner_rounded,
            onTap: () => pushModule(context, const MelapakPage()),
          ),
        ],
      );
}

// ───────────────────────── Panchang

/// Birth-moment Panchang of a client at the birth place (shared by the
/// Panchang page and the workspace card). Cached per client.
class ClientPanchang {
  final Map<String, dynamic> raw;
  final DateTime? at;
  final double lat, lng;
  final String place;
  ClientPanchang(this.raw, this.at, this.lat, this.lng, this.place);
  PanchangData get data => PanchangData.parse(raw, at: at, lat: lat, lng: lng);

  static final _cache = <String, Future<ClientPanchang>>{};
  static Future<ClientPanchang> of(String mId, {bool refresh = false}) {
    if (refresh) _cache.remove(mId);
    final hit = _cache[mId];
    if (hit != null) return hit;
    final f = _load(mId);
    _cache[mId] = f;
    f.then((_) {}, onError: (Object _) {
      if (identical(_cache[mId], f)) _cache.remove(mId);
    });
    return f;
  }

  static DateTime? _birthOf(Map<String, dynamic> d) {
    final dob = (d['dob'] ?? '').toString().trim();
    DateTime? day;
    for (final f in ['yyyy-MM-dd', 'dd-MM-yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd HH:mm:ss', 'dd-MM-yyyy HH:mm:ss']) {
      try {
        day = DateFormat(f).parseStrict(dob);
        break;
      } catch (_) {}
    }
    if (day == null) return null;
    int n(String k) => int.tryParse('${d[k] ?? ''}'.trim()) ?? 0;
    return DateTime(day.year, day.month, day.day, n('btime_hrs'), n('btime_min'), n('btime_sec'));
  }

  static Future<ClientPanchang> _load(String mId) async {
    final d = await ClientData.of(mId).details();
    DateTime? fallback;
    final c = Session.client.value;
    if (c != null && c.mId == mId) {
      try {
        fallback = DateFormat('dd-MM-yyyy HH:mm:ss').parseStrict(c.dobRaw);
      } catch (_) {}
    }
    final at = _birthOf(d) ?? fallback ?? DateTime.now();
    final lat = double.tryParse('${d['latitude']}') ?? 0;
    final lng = double.tryParse('${d['longitude']}') ?? 0;
    final la = _dms(lat), lo = _dms(lng);
    final r = await Api.postKept(Endpoints.panchang, {
      'LongDeg': lo[0], 'LongMnt': lo[1], 'LongSec': lo[2], 'LongDirection': lng >= 0 ? 'E' : 'W',
      'LatDeg': la[0], 'LatMnt': la[1], 'LatSec': la[2], 'LatDirection': lat >= 0 ? 'N' : 'S',
      'timezone': '${d['timm_diff'] ?? '330'}',
      'dob': DateFormat('yyyy-MM-dd').format(at),
      'birthhour': '${at.hour}', 'birthmin': '${at.minute}', 'birthsec': '${at.second}',
    }, owner: 'm$mId');
    return ClientPanchang(r, at, lat, lng, (d['birth_place'] ?? '').toString());
  }
}

/// Picks a partner for [c] from their Melapak list (opposite gender first)
/// and returns the match result, or null if cancelled.
Future<Map<String, dynamic>?> pickMelapakMatch(BuildContext context, Client c) async {
  final m = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .7,
        child: _PickList<Map<String, dynamic>>(
          title: 'Match ${c.name} with',
          load: () async {
            final l = Api.list(await Api.post(Endpoints.melapakOppList, {'mID': c.mId}), ['members', 'list']);
            final want = c.isFemale ? 'm' : 'f';
            final f = l.where((e) => (e['Gender'] ?? '').toString().toLowerCase().startsWith(want)).toList();
            return f.isEmpty ? l : f;
          },
          name: (e) => '${e['Name'] ?? ''}',
          sub: (e) => '${e['Gender'] ?? ''}',
        ),
      ),
    ),
  );
  if (m == null) return null;
  final r = await Api.post(Endpoints.melapakExisting, {'mID': c.mId, 'oID': '${m['oID']}'});
  LastMatch.save(c.mId, r);
  return r;
}

/// Last Melapak result per client, kept on the device for the workspace card.
class LastMatch {
  static String _k(String mId) => 'melapak_last_$mId';
  static void save(String mId, Map<String, dynamic> r) {
    if (mId.isEmpty) return;
    try {
      Session.prefs.setString(_k(mId), jsonEncode(r));
    } catch (_) {}
  }

  static void remove(String mId) => Session.prefs.remove(_k(mId));

  static Map<String, dynamic>? of(String mId) {
    final raw = Session.prefs.getString(_k(mId));
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }
}


List<String> _dms(double v) {
  final a = v.abs();
  final d = a.floor();
  final m = ((a - d) * 60).floor();
  final s = (((a - d) * 60 - m) * 60).round().clamp(0, 59);
  return ['$d', '$m', '$s'];
}

class PanchangPage extends StatefulWidget {
  const PanchangPage({super.key});
  @override
  State<PanchangPage> createState() => _PanchangPageState();
}

class _PanchangPageState extends State<PanchangPage> {
  DateTime? _at;
  late Future<Map<String, dynamic>> _f = _load();
  String _place = '';
  double _lat = 0, _lng = 0;

  Future<Map<String, dynamic>> _load({bool refresh = false}) async {
    final p = await ClientPanchang.of(Session.client.value?.mId ?? '', refresh: refresh);
    _at = p.at;
    _lat = p.lat;
    _lng = p.lng;
    _place = p.place;
    if (mounted) setState(() {});
    return p.raw;
  }

  @override
  Widget build(BuildContext context) {
    final at = _at;
    final st = at == null ? null : Sky.sunTimes(at, _lat, _lng);
    String note = '';
    if (at != null && st?.$1 != null) {
      final d = at.difference(st!.$1!).inMinutes;
      note = d >= 0 && (st.$2 == null || at.isBefore(st.$2!))
          ? 'Born ${d ~/ 60 > 0 ? '${d ~/ 60}h ' : ''}${d % 60} min after sunrise'
          : 'Born at night';
    }
    return ClientPage(
      title: 'Panchang',
      children: [
        Glass(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('AT BIRTH', style: CkText.label),
              const Spacer(),
              Text(at == null ? '' : DateFormat('dd-MM-yyyy · HH:mm').format(at), style: CkText.mono(11.5, color: CkColors.textSecondary)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text(at == null ? '—' : DateFormat('EEEE').format(at), style: CkText.h(20)),
              const SizedBox(width: 8),
              const Icon(Icons.place_outlined, size: 13, color: CkColors.textSecondary),
              const SizedBox(width: 3),
              Expanded(child: Text(_place, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: CkColors.textSecondary))),
            ]),
            if (at != null && (_lat != 0 || _lng != 0)) ...[
              const SizedBox(height: 6),
              SkyArc(at: at, lat: _lat, lng: _lng, height: 90),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(st?.$1 == null ? '' : '↑ ${DateFormat('HH:mm').format(st!.$1!)}', style: CkText.mono(11, color: CkColors.textSecondary)),
                Text(note, style: CkText.mono(11, color: const Color(0xFFF5D29A))),
                Text(st?.$2 == null ? '' : '${DateFormat('HH:mm').format(st!.$2!)} ↓', style: CkText.mono(11, color: CkColors.textSecondary)),
              ]),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        LoadView<Map<String, dynamic>>(
          future: _f,
          skeleton: Skels.table(8, mid: false),
          onRetry: () => setState(() => _f = _load(refresh: true)),
          builder: (r) {
            final d = PanchangData.parse(r, at: _at, lat: _lat, lng: _lng);
            if (d.rows.isEmpty) return EmptyBox(icon: Icons.light_mode_outlined, title: 'No Panchang', body: Api.msg(r, 'Nothing returned for this moment.'));
            return PanchangTable(d);
          },
        ),
      ],
    );
  }
}

// ───────────────────────── Melapak

class MelapakPage extends StatefulWidget {
  const MelapakPage({super.key});
  @override
  State<MelapakPage> createState() => _MelapakPageState();
}

class _MelapakPageState extends State<MelapakPage> {
  final _client = Session.client.value!;
  late final Future<List<Map<String, dynamic>>> _f = _load();
  String _q = '';

  Future<List<Map<String, dynamic>>> _load() async {
    final r = await Api.post(Endpoints.melapakOppList, {'mID': _client.mId});
    final l = Api.list(r, ['members', 'list']);
    final want = _client.isFemale ? 'm' : 'f';
    final filtered = l.where((e) => (e['Gender'] ?? '').toString().toLowerCase().startsWith(want)).toList();
    return filtered.isEmpty ? l : filtered;
  }

  bool get _female => _client.isFemale;

  void _open(Future<Map<String, dynamic>> f) => pushModule(context, MelapakResultPage(future: f));

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Melapak',
        children: [
          Glass(
            radius: 22,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(gradient: CkColors.cta, borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: Text(_client.initials, style: CkText.h(15)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${_female ? 'BRIDE' : 'GROOM'} · THIS CLIENT', style: CkText.label.copyWith(fontSize: 9.5)),
                  Text(_client.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(_client.subtitle, style: CkText.muted.copyWith(fontSize: 11.5)),
                ]),
              ),
              const Icon(Icons.lock_outline_rounded, size: 16, color: CkColors.textMuted),
            ]),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: CkColors.navySheet, shape: BoxShape.circle, border: Border.all(color: CkColors.glassStroke)),
              child: const Icon(Icons.join_inner_rounded, size: 17, color: Color(0xFFFFB27A)),
            ),
          ),
          Glass(
            radius: 22,
            stroke: CkColors.orangeStroke,
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_female ? 'GROOM' : 'BRIDE'} · MATCH WITH', style: CkText.label.copyWith(fontSize: 9.5)),
              const SizedBox(height: 6),
              TextField(
                onChanged: (v) => setState(() => _q = v.toLowerCase()),
                decoration: InputDecoration(
                    hintText: 'Search ${_female ? 'male' : 'female'} clients', prefixIcon: const Icon(Icons.search_rounded)),
              ),
              LoadView<List<Map<String, dynamic>>>(
                future: _f,
                minHeight: 120,
                builder: (l) {
                  final f = l.where((e) => (e['Name'] ?? '').toString().toLowerCase().contains(_q)).toList();
                  if (f.isEmpty) {
                    return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('No matching clients', style: CkText.muted)));
                  }
                  return Column(
                    children: f
                        .take(50)
                        .map((e) => InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _open(Api.post(Endpoints.melapakExisting, {'mID': _client.mId, 'oID': '${e['oID']}'})),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                                decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x14FFFFFF)))),
                                child: Row(children: [
                                  Expanded(
                                      child: Text('${e['Name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                                  Text('${e['Gender'] ?? ''}', style: CkText.muted.copyWith(fontSize: 12)),
                                  const Icon(Icons.chevron_right_rounded, color: CkColors.textMuted),
                                ]),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text('Only ${_female ? 'male' : 'female'} clients are listed.', style: const TextStyle(fontSize: 11, color: CkColors.textMuted)),
              const SizedBox(height: 10),
              Pressable(
                onTap: () async {
                  final f = await Navigator.of(context).push<Future<Map<String, dynamic>>>(
                      CkRoute(builder: (_) => _NewPersonPage(clientId: _client.mId)));
                  if (f != null) _open(f);
                },
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: CkColors.orangeStroke)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_rounded, color: Color(0xFFFFB27A), size: 19),
                    SizedBox(width: 6),
                    Text('Enter new birth details', style: TextStyle(color: Color(0xFFFFB27A), fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),
        ],
      );
}

class _NewPersonPage extends StatefulWidget {
  final String clientId;
  const _NewPersonPage({required this.clientId});
  @override
  State<_NewPersonPage> createState() => _NewPersonPageState();
}

class _NewPersonPageState extends State<_NewPersonPage> {
  final _name = TextEditingController();
  final _birth = BirthInput();

  void _go() {
    if (_name.text.trim().isEmpty || !_birth.complete) {
      return toast(context, 'Add a name, date, time and birth place', error: true);
    }
    Navigator.pop(
        context,
        Api.post(Endpoints.melapakNew, {
          'mID': widget.clientId,
          'opp_name': _name.text.trim(),
          'dob': DateFormat('yyyy-MM-dd').format(_birth.date!),
          'btime_hrs': _birth.time!.hour.toString().padLeft(2, '0'),
          'btime_min': _birth.time!.minute.toString().padLeft(2, '0'),
          'btime_sec': '00',
          'birth_place': _birth.place,
          'latitude': _birth.lat,
          'longitude': _birth.lng,
          'timm_diff': _birth.utc,
        }));
  }

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'New person',
        children: [
          Glass(
            radius: 18,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(children: [
              Field('Name', controller: _name, required: true),
              const SizedBox(height: 12),
              BirthFields(value: _birth, onChanged: () => setState(() {})),
            ]),
          ),
          const SizedBox(height: 14),
          PrimaryButton('Match', icon: Icons.join_inner_rounded, onTap: _go),
        ],
      );
}

class MelapakResultPage extends StatelessWidget {
  final Future<Map<String, dynamic>> future;
  const MelapakResultPage({super.key, required this.future});

  static const _rows = [
    ('Varna', 'Varn', 'Varn_Points', 1),
    ('Vashya', 'Vaishya', 'Vaishya_Points', 2),
    ('Tara', 'Tara', 'Tara_Points', 3),
    ('Yoni', 'Yoni', 'Yoni_Points', 4),
    ('Graha Maitri', 'Rashidhyapati', 'Rashidhyapati_Points', 5),
    ('Gana', 'Gan', 'Gan_Points', 6),
    ('Bhakoot', 'Rashi', 'Bhakoot_Points', 7),
    ('Nadi', 'Naadi', 'Naadi_Points', 8),
  ];

  static const _about = {
    'Varna': 'Work style',
    'Vashya': 'Mutual influence',
    'Tara': 'Destiny & wellbeing',
    'Yoni': 'Physical nature',
    'Graha Maitri': 'Mental wavelength',
    'Gana': 'Temperament',
    'Bhakoot': 'Family & finances',
    'Nadi': 'Health & progeny',
  };

  double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  String _s(Map<String, dynamic> r, List<String> keys) {
    for (final k in keys) {
      final v = r[k];
      if (v != null && '$v'.trim().isNotEmpty && '$v' != 'null') return '$v'.trim();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Melapak',
        children: [
          LoadView<Map<String, dynamic>>(
            future: future,
            skeleton: Skels.match(),
            builder: (r) {
              if (!Api.ok(r) && !r.containsKey('Total_Gun_Match')) {
                return ErrorBox(message: Api.msg(r, 'Couldn\'t calculate this match.'));
              }
              final total = _n(r['Total_Gun_Match']);
              LastMatch.save(Session.client.value?.mId ?? '', r);
              final verdict = total >= 28 ? 'Excellent match' : total >= 18 ? 'Good match' : 'Below the usual 18';
              final vc = total >= 18 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
              final doshas = <(String, String)>[
                if (_n(r['Naadi_Points']) == 0) ('Nadi dosha', '${_s(r, ['Var_Naadi'])} – ${_s(r, ['Vadhu_Naadi'])} · same Nadi · 0 of 8'),
                if (_n(r['Bhakoot_Points']) == 0) ('Bhakoot dosha', '${_s(r, ['Var_Rashi'])} – ${_s(r, ['Vadhu_Rashi'])} · 0 of 7'),
              ];
              return Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _person('VAR', r, 'Var'),
                  const SizedBox(width: 8),
                  _person('VADHU', r, 'Vadhu'),
                ]),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CustomPaint(
                        painter: _Ring(total / 36),
                        child: Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(1), style: CkText.mono(22)),
                            const Text('of 36', style: TextStyle(fontSize: 10, color: CkColors.textSecondary)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('GUNA MILAN', style: CkText.label),
                        const SizedBox(height: 4),
                        Text(verdict, style: CkText.h(18, color: vc)),
                        const SizedBox(height: 4),
                        const Text('18 or more is generally accepted.', style: CkText.muted),
                      ]),
                    ),
                  ]),
                ),
                for (final d in doshas)
                  Glass(
                    margin: const EdgeInsets.only(top: 10),
                    stroke: const Color(0x66EF4444),
                    padding: const EdgeInsets.all(12),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(padding: EdgeInsets.only(top: 3), child: Icon(Icons.circle, size: 10, color: Color(0xFFEF4444))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(d.$2, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                        ]),
                      ),
                    ]),
                  ),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ASHTAKOOT · 8 KOOTA', style: CkText.label),
                    const SizedBox(height: 4),
                    ..._rows.map((row) {
                      final pts = _n(r[row.$3]);
                      final max = row.$4.toDouble();
                      final col = pts >= max ? const Color(0xFF10B981) : pts > 0 ? const Color(0xFFF5B66B) : const Color(0xFFEF4444);
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1F8CBEFF)))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(
                              child: Text.rich(TextSpan(children: [
                                TextSpan(text: row.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                TextSpan(text: '  ${_about[row.$1] ?? ''}', style: const TextStyle(fontSize: 11.5, color: CkColors.labelMono)),
                              ])),
                            ),
                            Text('${pts % 1 == 0 ? pts.toInt() : pts}/${row.$4}', style: CkText.mono(12.5, color: col)),
                          ]),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(value: (pts / max).clamp(0, 1), minHeight: 5, color: col, backgroundColor: const Color(0x268CBEFF)),
                          ),
                          const SizedBox(height: 7),
                          Row(children: [
                            Expanded(child: _kv('Var', _s(r, ['Var_${row.$2}']))),
                            Expanded(child: _kv('Vadhu', _s(r, ['Vadhu_${row.$2}']))),
                          ]),
                        ]),
                      );
                    }),
                  ]),
                ),
              ]);
            },
          ),
        ],
      );

  Widget _kv(String k, String v) => Text.rich(
        TextSpan(children: [
          TextSpan(text: '$k ', style: const TextStyle(color: CkColors.labelMono)),
          TextSpan(text: v.isEmpty ? '—' : v),
        ]),
        style: CkText.mono(11.5, color: CkColors.textTertiary),
      );

  Widget _person(String role, Map<String, dynamic> r, String p) {
    final name = _s(r, ['${p}_Name']);
    final rashi = _s(r, ['${p}_Rashi']);
    final nak = _s(r, ['${p}_Nakshatra', '${p}_Nakshtra', '${p}_Nakshatra_Name']);
    final dob = _s(r, ['${p}_DOB', '${p}_Dob', '${p}_Birth']);
    return Expanded(
      child: Glass(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(role, style: CkText.label),
          const SizedBox(height: 4),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
          if (dob.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 3), child: Text(dob, style: CkText.mono(10.5, color: CkColors.textSecondary))),
          if (rashi.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Moon $rashi', style: const TextStyle(fontSize: 12, color: CkColors.textTertiary))),
          if (nak.isNotEmpty) Text(nak, style: const TextStyle(fontSize: 12, color: CkColors.textTertiary)),
        ]),
      ),
    );
  }
}

class _Ring extends CustomPainter {
  final double p;
  _Ring(this.p);
  @override
  void paint(Canvas c, Size s) {
    final r = s.width / 2 - 6;
    final o = s.center(Offset.zero);
    c.drawCircle(o, r, Paint()
      ..color = Colors.white.withOpacity(.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10);
    c.drawArc(
        Rect.fromCircle(center: o, radius: r),
        -math.pi / 2,
        2 * math.pi * p.clamp(0, 1),
        false,
        Paint()
          ..color = CkColors.cyan
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 10);
  }

  @override
  bool shouldRepaint(_Ring old) => old.p != p;
}

// ───────────────────────── Melapak from Tools (no client open)

/// Melapak opened from Tools: no person is locked. The match APIs need one
/// saved client, so person 1 is picked from clients; person 2 can be a client
/// or typed birth details.
class MelapakToolPage extends StatefulWidget {
  const MelapakToolPage({super.key});
  @override
  State<MelapakToolPage> createState() => _MelapakToolPageState();
}

class _MelapakToolPageState extends State<MelapakToolPage> {
  Client? _a;
  Map<String, dynamic>? _b;

  Future<T?> _sheet<T>(Widget child) => showModalBottomSheet<T>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (_) => SafeArea(child: SizedBox(height: MediaQuery.of(context).size.height * .7, child: child)),
      );

  Future<void> _pickA() async {
    final c = await _sheet<Client>(_PickList<Client>(
      title: 'Choose person 1',
      load: fetchClients,
      name: (e) => e.name,
      sub: (e) => e.subtitle,
    ));
    if (c != null) setState(() {
      _a = c;
      _b = null;
    });
  }

  Future<void> _pickB() async {
    final a = _a;
    if (a == null) return;
    final m = await _sheet<Map<String, dynamic>>(_PickList<Map<String, dynamic>>(
      title: 'Choose person 2',
      load: () async => Api.list(await Api.post(Endpoints.melapakOppList, {'mID': a.mId}), ['members', 'list']),
      name: (e) => '${e['Name'] ?? ''}',
      sub: (e) => '${e['Gender'] ?? ''}',
    ));
    if (m != null) setState(() => _b = m);
  }

  Future<void> _typeB() async {
    final a = _a;
    if (a == null) return;
    final f = await Navigator.of(context)
        .push<Future<Map<String, dynamic>>>(CkRoute(builder: (_) => _NewPersonPage(clientId: a.mId)));
    if (f != null && mounted) pushModule(context, MelapakResultPage(future: f));
  }

  void _match() {
    final a = _a, b = _b;
    if (a == null || b == null) return;
    pushModule(context, MelapakResultPage(future: Api.post(Endpoints.melapakExisting, {'mID': a.mId, 'oID': '${b['oID']}'})));
  }

  Widget _filled(String role, String name, String sub, VoidCallback change) => Glass(
        stroke: CkColors.cyanStroke,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(role, style: CkText.label)),
            GestureDetector(onTap: change, child: const Text('Change', style: TextStyle(fontSize: 12.5, color: CkColors.cyan))),
          ]),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          if (sub.isNotEmpty) Text(sub, style: CkText.mono(11.5, color: CkColors.textSecondary)),
        ]),
      );

  Widget _empty(String role, {required VoidCallback choose, VoidCallback? type, bool enabled = true, String? hint}) => Opacity(
        opacity: enabled ? 1 : .5,
        child: Glass(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(role, style: CkText.label),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _slotBtn(Icons.people_outline_rounded, 'Choose client', enabled ? choose : null, filled: true)),
              if (type != null) ...[const SizedBox(width: 8), Expanded(child: _slotBtn(Icons.add_rounded, 'Enter details', enabled ? type : null))],
            ]),
            if (hint != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(hint, style: const TextStyle(fontSize: 11.5, color: CkColors.textDim))),
          ]),
        ),
      );

  Widget _slotBtn(IconData i, String t, VoidCallback? onTap, {bool filled = false}) => Pressable(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: filled ? CkColors.cyanTint : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: filled ? CkColors.cyanStroke : CkColors.panelStroke),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(i, size: 17, color: filled ? CkColors.cyan : CkColors.text),
            const SizedBox(width: 6),
            Text(t, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => CkScaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), children: [
            Row(children: [
              CircleBtn(Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Melapak', style: CkText.h(18)),
                  const Text('Match two people', style: TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                ]),
              ),
            ]),
            const SizedBox(height: 16),
            _a == null ? _empty('PERSON 1', choose: _pickA) : _filled('PERSON 1', _a!.name, _a!.subtitle, _pickA),
            const SizedBox(height: 10),
            _b == null
                ? _empty('PERSON 2', choose: _pickB, type: _typeB, enabled: _a != null, hint: _a == null ? 'Choose person 1 first' : null)
                : _filled('PERSON 2', '${_b!['Name'] ?? ''}', '${_b!['Gender'] ?? ''}', _pickB),
            const SizedBox(height: 20),
            Opacity(
              opacity: _a != null && _b != null ? 1 : .45,
              child: PrimaryButton('Match', icon: Icons.join_inner_rounded, onTap: _a != null && _b != null ? _match : null),
            ),
            const SizedBox(height: 10),
            const Text('Typed details are matched right away and aren\'t saved as a client.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: CkColors.textDim)),
          ]),
        ),
      );
}

class _PickList<T> extends StatefulWidget {
  final String title;
  final Future<List<T>> Function() load;
  final String Function(T) name;
  final String Function(T) sub;
  const _PickList({super.key, required this.title, required this.load, required this.name, required this.sub});
  @override
  State<_PickList<T>> createState() => _PickListState<T>();
}

class _PickListState<T> extends State<_PickList<T>> {
  late final Future<List<T>> _f = widget.load();
  String _q = '';
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: CkText.h(18)),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _q = v.toLowerCase()),
            decoration: const InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search_rounded)),
          ),
          Expanded(
            child: DataBuilder<List<T>>(
              future: _f,
              builder: (c, s) {
                if (s.hasError) return const Center(child: Text('Couldn\'t load', style: CkText.muted));
                if (!s.hasData) return const SkeletonList(rows: 5);
                final l = s.data!.where((e) => widget.name(e).toLowerCase().contains(_q)).toList();
                return ListView(children: [
                  for (final e in l)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.name(e)),
                      subtitle: Text(widget.sub(e), style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                      onTap: () => Navigator.pop(context, e),
                    ),
                ]);
              },
            ),
          ),
        ]),
      );
}
