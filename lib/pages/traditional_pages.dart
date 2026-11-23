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

  Future<Map<String, dynamic>> _load() async {
    final d = await _data.details();
    // Panchang of the client's birth moment, at the birth place.
    final at = _birthOf(d) ?? _clientBirth() ?? DateTime.now();
    _at = at;
    final lat = double.tryParse('${d['latitude']}') ?? 0;
    final lng = double.tryParse('${d['longitude']}') ?? 0;
    _place = (d['birth_place'] ?? '').toString();
    final la = _dms(lat), lo = _dms(lng);
    final r = await Api.post(Endpoints.panchang, {
      'LongDeg': lo[0], 'LongMnt': lo[1], 'LongSec': lo[2], 'LongDirection': lng >= 0 ? 'E' : 'W',
      'LatDeg': la[0], 'LatMnt': la[1], 'LatSec': la[2], 'LatDirection': lat >= 0 ? 'N' : 'S',
      'timezone': '${d['timm_diff'] ?? '330'}',
      'dob': DateFormat('yyyy-MM-dd').format(at),
      'birthhour': '${at.hour}', 'birthmin': '${at.minute}', 'birthsec': '${at.second}',
    });
    if (mounted) setState(() {});
    return r;
  }

  DateTime? _clientBirth() {
    final c = Session.client.value;
    if (c == null) return null;
    try {
      return DateFormat('dd-MM-yyyy HH:mm:ss').parseStrict(c.dobRaw);
    } catch (_) {
      return null;
    }
  }

  // Only what the software's Panchang shows, in its order. Raw longitudes
  // and other internals are left out.
  static const _featured = ['paksha', 'sunrise', 'sunset', 'tithi', 'nakshatra', 'yog', 'karan', 'sun rashi', 'sun_rashi', 'sunrashi', 'moon rashi', 'moon_rashi', 'moonrashi', 'rashi', 'var', 'day'];
  static bool _wanted(String k) {
    final l = k.toLowerCase();
    if (l.contains('long') || l.contains('lat') || l.contains('deg') || l.contains('time_zone') || l.contains('timezone')) return false;
    return _featured.any((f) => l.contains(f));
  }

  String _pretty(String k) => k.replaceAll('_', ' ').replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}').trim();

  Map<String, String> _flatten(Map<String, dynamic> m, [String prefix = '']) {
    final out = <String, String>{};
    m.forEach((k, v) {
      if (k == 'status' || k == 'msg' || k == 'message') return;
      final key = prefix.isEmpty ? k : '$prefix · $k';
      if (v is Map) {
        out.addAll(_flatten(Map<String, dynamic>.from(v), key));
      } else if (v is List) {
        if (v.isNotEmpty && v.first is Map) {
          for (var i = 0; i < v.length; i++) {
            out.addAll(_flatten(Map<String, dynamic>.from(v[i] as Map), '$key ${i + 1}'));
          }
        } else {
          out[key] = v.join(', ');
        }
      } else if (v != null && '$v'.trim().isNotEmpty) {
        out[key] = '$v';
      }
    });
    return out;
  }

  IconData _icon(String k) {
    final l = k.toLowerCase();
    if (l.contains('sunrise') || l.contains('sun')) return Icons.wb_sunny_outlined;
    if (l.contains('moon') || l.contains('tithi') || l.contains('paksha')) return Icons.nightlight_outlined;
    if (l.contains('nakshatra')) return Icons.auto_awesome_outlined;
    if (l.contains('rashi')) return Icons.public_rounded;
    return Icons.brightness_5_outlined;
  }

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Panchang',
        children: [
          Glass(
            radius: 18,
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('AT BIRTH', style: CkText.label),
                  const SizedBox(height: 4),
                  Text(_at == null ? '—' : DateFormat('EEEE, d MMM yyyy').format(_at!), style: CkText.h(19)),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.place_outlined, size: 14, color: CkColors.textSecondary),
                    const SizedBox(width: 4),
                    Flexible(
                        child: Text(_place.isEmpty ? 'Client\'s birth place' : _place,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.muted)),
                  ]),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: CkColors.orangeTint, borderRadius: BorderRadius.circular(20), border: Border.all(color: CkColors.orangeStroke)),
                child: Text(_at == null ? '--:--' : DateFormat('hh:mm a').format(_at!),
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFFB27A))),
              ),
            ]),
          ),
          LoadView<Map<String, dynamic>>(
            future: _f,
            onRetry: () => setState(() => _f = _load()),
            builder: (r) {
              final flat = _flatten(r)..removeWhere((k, _) => !_wanted(k));
              if (flat.isEmpty) {
                return EmptyBox(icon: Icons.light_mode_outlined, title: 'No Panchang', body: Api.msg(r, 'Nothing returned for this moment.'));
              }
              final keys = flat.keys.toList()
                ..sort((a, b) {
                  int rank(String k) {
                    final i = _featured.indexWhere((f) => k.toLowerCase().contains(f));
                    return i < 0 ? 99 : i;
                  }

                  return rank(a).compareTo(rank(b));
                });
              return Glass(
                margin: const EdgeInsets.only(top: 12),
                radius: 18,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                child: Column(children: [
                  const CardTitle('Astronomical values', Icons.blur_on_rounded),
                  ...keys.map((k) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x14FFFFFF)))),
                        child: Row(children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                                color: CkColors.orangeTint, borderRadius: BorderRadius.circular(11), border: Border.all(color: CkColors.orangeStroke)),
                            child: Icon(_icon(k), size: 17, color: const Color(0xFFFFB27A)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(_pretty(k).toUpperCase(), style: CkText.label.copyWith(fontSize: 9.5)),
                              const SizedBox(height: 2),
                              Text(flat[k]!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ]),
                          ),
                        ]),
                      )),
                ]),
              );
            },
          ),
        ],
      );
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
                      CupertinoPageRoute(builder: (_) => _NewPersonPage(clientId: _client.mId)));
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

  double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Melapak result',
        children: [
          LoadView<Map<String, dynamic>>(
            future: future,
            builder: (r) {
              if (!Api.ok(r) && !r.containsKey('Total_Gun_Match')) {
                return ErrorBox(message: Api.msg(r, 'Couldn\'t calculate this match.'));
              }
              final total = _n(r['Total_Gun_Match']);
              final verdict = total >= 28 ? 'Excellent match' : total >= 18 ? 'Good match' : 'Below the usual threshold';
              final vc = total >= 18 ? const Color(0xFF74E2B7) : const Color(0xFFFF8A8A);
              return Column(children: [
                Row(children: [
                  _person('GROOM', '${r['Var_Name'] ?? ''}', '${r['Var_Rashi'] ?? ''}'),
                  const SizedBox(width: 10),
                  _person('BRIDE', '${r['Vadhu_Name'] ?? ''}', '${r['Vadhu_Rashi'] ?? ''}'),
                ]),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  radius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      SizedBox(
                        width: 104,
                        height: 104,
                        child: CustomPaint(
                          painter: _Ring(total / 36),
                          child: Center(
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Text(total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(1), style: CkText.h(26)),
                              const Text('of 36', style: TextStyle(fontSize: 10, color: CkColors.textSecondary)),
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(verdict, style: CkText.h(18, color: vc)),
                          const SizedBox(height: 4),
                          Text(
                              '18 or more is generally accepted.${_n(r['Naadi_Points']) == 0 ? ' Nadi score is 0 — check for Nadi dosha.' : ''}',
                              style: CkText.muted),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    ..._rows.map((row) {
                      final pts = _n(r[row.$3]);
                      final max = row.$4.toDouble();
                      final good = pts / max >= .5;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x14FFFFFF)))),
                        child: Column(children: [
                          Row(children: [
                            SizedBox(width: 96, child: Text(row.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                    value: (pts / max).clamp(0, 1),
                                    minHeight: 8,
                                    color: good ? CkColors.green : CkColors.red,
                                    backgroundColor: CkColors.glassFillStrong),
                              ),
                            ),
                            SizedBox(
                                width: 46,
                                child: Text('${pts % 1 == 0 ? pts.toInt() : pts}/${row.$4}',
                                    textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5))),
                          ]),
                          if (r['Var_${row.$2}'] != null || r['Vadhu_${row.$2}'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 3, left: 96),
                              child: Row(children: [
                                Expanded(
                                    child: Text('${r['Var_${row.$2}'] ?? '—'}  ·  ${r['Vadhu_${row.$2}'] ?? '—'}',
                                        style: const TextStyle(fontSize: 11, color: CkColors.textMuted))),
                              ]),
                            ),
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

  Widget _person(String role, String name, String rashi) => Expanded(
        child: Glass(
          radius: 16,
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text(role, style: CkText.label.copyWith(fontSize: 9.5)),
            const SizedBox(height: 4),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (rashi.isNotEmpty) Text('Moon $rashi', style: CkText.muted.copyWith(fontSize: 11)),
          ]),
        ),
      );
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
          ..shader = const SweepGradient(colors: [Color(0xFFEB4B36), Color(0xFFF59E0B), Color(0xFFEB4B36)])
              .createShader(Rect.fromCircle(center: o, radius: r))
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 10);
  }

  @override
  bool shouldRepaint(_Ring old) => old.p != p;
}
