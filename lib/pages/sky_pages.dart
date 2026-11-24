import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../core/sky.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import '../values/app_constants.dart';
import 'clients_page.dart';
import 'reports_pages.dart';

// ───────────────────────── where the user is

/// The user's place for Sky now, Transit and Panchang: device location, or a
/// city they picked.
class Here {
  static double? get lat => Session.prefs.getDouble('here_lat');
  static double? get lng => Session.prefs.getDouble('here_lng');
  static String get name => Session.prefs.getString('here_name') ?? '';
  static bool get known => lat != null && lng != null;
  static bool get asked => Session.prefs.getBool('here_asked') ?? false;
  static final ValueNotifier<int> changed = ValueNotifier(0);

  /// Minutes east of UTC for this phone.
  static int get tzMinutes => DateTime.now().timeZoneOffset.inMinutes;

  static Future<void> _save(double la, double lo, String n) async {
    await Session.prefs.setDouble('here_lat', la);
    await Session.prefs.setDouble('here_lng', lo);
    await Session.prefs.setString('here_name', n);
    await Session.prefs.setBool('here_asked', true);
    changed.value++;
  }

  /// Ask for permission and read the device position. Returns false if denied.
  static Future<bool> useDevice() async {
    await Session.prefs.setBool('here_asked', true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return false;
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.low));
      var n = '';
      try {
        final pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (pm.isNotEmpty) n = pm.first.locality?.isNotEmpty == true ? pm.first.locality! : (pm.first.subAdministrativeArea ?? '');
      } catch (_) {}
      await _save(pos.latitude, pos.longitude, n.isEmpty ? 'Current location' : n);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> useCity(double la, double lo, String n) => _save(la, lo, n);

  /// Refresh the device position quietly if the user chose device location.
  static Future<void> refresh() async {
    if (!(Session.prefs.getBool('here_device') ?? false)) return;
    try {
      final p = await Geolocator.checkPermission();
      if (p == LocationPermission.always || p == LocationPermission.whileInUse) await useDevice();
    } catch (_) {}
  }
}

/// First-open sheet: allow location or choose a city.
Future<void> askLocation(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (s) => const _LocationSheet(),
  );
}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet();
  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) => _Sheet(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(14), border: Border.all(color: CkColors.cyanStroke)),
          child: const Icon(Icons.place_outlined, color: CkColors.cyan),
        ),
        const SizedBox(height: 14),
        Text('Use your location', style: CkText.h(19)),
        const SizedBox(height: 6),
        const Text('Sky now and Panchang are calculated for where you are: Lagna, sunrise and sunset change with place.',
            style: TextStyle(fontSize: 13.5, color: CkColors.textSecondary, height: 1.5)),
        const SizedBox(height: 18),
        _CyanButton(_busy ? 'Locating…' : 'Allow location', onTap: () async {
          setState(() => _busy = true);
          final ok = await Here.useDevice();
          await Session.prefs.setBool('here_device', ok);
          if (!context.mounted) return;
          if (ok) {
            Navigator.pop(context);
          } else {
            setState(() => _busy = false);
            toast(context, 'Location is off or not allowed. Choose a city instead.', error: true);
          }
        }),
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: () async {
              final ok = await Navigator.of(context).push<bool>(CupertinoPageRoute(builder: (_) => const CityPickerPage()));
              if (ok == true && context.mounted) Navigator.pop(context);
            },
            child: const Text('Choose a city instead', style: TextStyle(color: CkColors.textSecondary)),
          ),
        ),
      ]);
}

class CityPickerPage extends StatefulWidget {
  const CityPickerPage({super.key});
  @override
  State<CityPickerPage> createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) => CkScaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 30), children: [
            _Header('Your city', sub: 'Used for Sky now and Panchang'),
            const SizedBox(height: 10),
            AddressAutocompleteTextFormField(
              mapsApiKey: AppConstants.googleMapApiKey,
              controller: _c,
              types: const [AutoCompleteType.cities],
              style: const TextStyle(color: CkColors.text, fontSize: 15),
              decoration: const InputDecoration(hintText: 'Start typing a city…', prefixIcon: Icon(Icons.place_outlined, size: 19)),
              elevation: 12,
              suggestionsOverlayDecoration: BoxDecoration(color: const Color(0xFF1C4590), borderRadius: BorderRadius.circular(12)),
              buildItem: (sg, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text(sg.description ?? '', style: const TextStyle(fontSize: 13.5, color: CkColors.text)),
              ),
              onSuggestionClick: (p) async {
                final la = p.lat, lo = p.lng;
                if (la == null || lo == null) return;
                await Session.prefs.setBool('here_device', false);
                await Here.useCity(la, lo, p.city ?? p.formattedAddress ?? _c.text);
                if (context.mounted) Navigator.pop(context, true);
              },
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                final ok = await Here.useDevice();
                await Session.prefs.setBool('here_device', ok);
                if (!context.mounted) return;
                if (ok) {
                  Navigator.pop(context, true);
                } else {
                  toast(context, 'Location is off or not allowed.', error: true);
                }
              },
              icon: const Icon(Icons.my_location_rounded, color: CkColors.cyan, size: 18),
              label: const Text('Use my current location', style: TextStyle(color: CkColors.cyan)),
            ),
          ]),
        ),
      );
}

// ───────────────────────── Panchang data

List<String> dms(double v) {
  final a = v.abs();
  final d = a.floor();
  final m = ((a - d) * 60).floor();
  final s = (((a - d) * 60 - m) * 60).round().clamp(0, 59);
  return ['$d', '$m', '$s'];
}

Future<Map<String, dynamic>> fetchPanchang(DateTime at, double lat, double lng, int tzMinutes) {
  final la = dms(lat), lo = dms(lng);
  return Api.post(Endpoints.panchang, {
    'LongDeg': lo[0], 'LongMnt': lo[1], 'LongSec': lo[2], 'LongDirection': lng >= 0 ? 'E' : 'W',
    'LatDeg': la[0], 'LatMnt': la[1], 'LatSec': la[2], 'LatDirection': lat >= 0 ? 'N' : 'S',
    'timezone': '$tzMinutes',
    'dob': DateFormat('yyyy-MM-dd').format(at),
    'birthhour': '${at.hour}', 'birthmin': '${at.minute}', 'birthsec': '${at.second}',
  });
}

Map<String, String> _flat(Map<String, dynamic> m, [String prefix = '']) {
  final out = <String, String>{};
  m.forEach((k, v) {
    if (k == 'status' || k == 'msg' || k == 'message') return;
    final key = prefix.isEmpty ? k : '$prefix·$k';
    if (v is Map) {
      out.addAll(_flat(Map<String, dynamic>.from(v), key));
    } else if (v is List) {
      for (var i = 0; i < v.length; i++) {
        final e = v[i];
        if (e is Map) {
          // {Name: Nakshatra, Value: Chitra} style rows
          final mm = Map<String, dynamic>.from(e);
          final n = mm['Name'] ?? mm['name'] ?? mm['Title'] ?? mm['title'];
          final val = mm['Value'] ?? mm['value'];
          if (n != null && val != null) {
            out['$n'] = '$val';
          } else {
            out.addAll(_flat(mm, '$key${i + 1}'));
          }
        }
      }
    } else if (v != null && '$v'.trim().isNotEmpty && '$v' != 'null') {
      out[key] = '$v'.trim();
    }
  });
  return out;
}

/// Panchang in the software's fixed order: 1 Nakshatra, 2 Tithi, 3 Karan,
/// 4 Yog, 5 Day, 6 Rashi, then extras.
class PanchangData {
  final List<(String, String)> rows;
  PanchangData(this.rows);
  String get(String k) => rows.firstWhere((e) => e.$1 == k, orElse: () => (k, '')).$2;

  static PanchangData parse(Map<String, dynamic> r, {DateTime? at, double? lat, double? lng}) {
    final f = _flat(r);
    bool skip(String k) {
      final l = k.toLowerCase();
      return l.contains('long') || l.contains('lat') || l.contains('deg') || l.contains('zone');
    }

    String find(List<String> keys, {List<String> not = const []}) {
      for (final want in keys) {
        for (final e in f.entries) {
          final l = e.key.toLowerCase().split('·').last;
          if (skip(l) || not.any(l.contains)) continue;
          if (l == want || l.contains(want)) return e.value;
        }
      }
      return '';
    }

    var tithi = find(['tithi']);
    final paksha = find(['paksha']);
    if (paksha.isNotEmpty && tithi.isNotEmpty && !tithi.toLowerCase().contains(paksha.toLowerCase())) tithi = '$paksha - $tithi';
    final rows = <(String, String)>[
      ('Nakshatra', find(['nakshatra'])),
      ('Tithi', tithi),
      ('Karan', find(['karan'])),
      ('Yog', find(['yog'])),
      ('Day', find(['day', 'vaar', 'var'], not: ['today'])),
      ('Rashi', find(['moon rashi', 'moon_rashi', 'moonrashi', 'rashi'], not: ['sun'])),
    ];
    var rise = find(['sunrise', 'sun_rise', 'sun rise']), set = find(['sunset', 'sun_set', 'sun set']);
    if (at != null && lat != null && lng != null) {
      final st = Sky.sunTimes(at, lat, lng);
      if (rise.isEmpty && st.$1 != null) rise = DateFormat('HH:mm').format(st.$1!);
      if (set.isEmpty && st.$2 != null) set = DateFormat('HH:mm').format(st.$2!);
      final mt = Sky.moonTimes(at, lat, lng);
      rows
        ..add(('Sunrise', rise))
        ..add(('Sunset', set))
        ..add(('Moonrise', mt.$1 == null ? 'None today' : DateFormat('HH:mm').format(mt.$1!)))
        ..add(('Moonset', mt.$2 == null ? 'None today' : DateFormat('HH:mm').format(mt.$2!)));
    } else {
      rows
        ..add(('Sunrise', rise))
        ..add(('Sunset', set));
    }
    return PanchangData(rows.where((e) => e.$2.isNotEmpty).toList());
  }
}

// ───────────────────────── sky arc (sun + moon at their real place)

class SkyArc extends StatelessWidget {
  final DateTime at;
  final double lat, lng;
  final double height;
  final ValueChanged<DateTime>? onTime; // shows a 00–24 handle when set
  const SkyArc({super.key, required this.at, required this.lat, required this.lng, this.height = 120, this.onTime});

  @override
  Widget build(BuildContext context) {
    final sun = Sky.arcPos(at, (d) => Sky.sunTimes(d, lat, lng));
    final moon = Sky.arcPos(at, (d) => Sky.moonTimes(d, lat, lng));
    final ph = Sky.moonPhase(at);
    final arc = CustomPaint(
      size: Size(double.infinity, height),
      painter: _ArcPainter(sun: sun, moon: moon, fraction: ph.$1, waxing: ph.$2 < .5),
    );
    if (onTime == null) return SizedBox(height: height, child: arc);
    return LayoutBuilder(builder: (c, b) {
      final w = b.maxWidth;
      final mins = at.hour * 60 + at.minute;
      void set(double x) {
        final m = ((x / w).clamp(0.0, 1.0) * 1439).round();
        final snapped = (m / 5).round() * 5;
        onTime!(DateTime(at.year, at.month, at.day, snapped ~/ 60 % 24, snapped % 60));
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => set(d.localPosition.dx),
        onTapDown: (d) {
          if (d.localPosition.dy > height) set(d.localPosition.dx);
        },
        child: SizedBox(
          height: height + 44,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(left: 0, right: 0, top: 0, height: height, child: arc),
            Positioned(
              left: 0,
              right: 0,
              top: height + 6,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                for (final h in ['00', '06', '12', '18', '24']) Text(h, style: CkText.mono(9.5, color: CkColors.labelMono)),
              ]),
            ),
            Positioned(left: 0, right: 0, top: height + 26, child: Container(height: 2, color: const Color(0x338CBEFF))),
            Positioned(
              left: (w * mins / 1440) - 9,
              top: height + 18,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: CkColors.cyan,
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Color(0x995CE1FF), blurRadius: 10)],
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }
}

class _ArcPainter extends CustomPainter {
  final double? sun, moon;
  final double fraction;
  final bool waxing;
  _ArcPainter({this.sun, this.moon, required this.fraction, required this.waxing});

  Offset _q(Offset a, Offset c, Offset b, double t) =>
      a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);

  @override
  void paint(Canvas canvas, Size s) {
    final base = s.height - 10;
    final sa = Offset(12, base), sb = Offset(s.width - 12, base), sc = Offset(s.width / 2, -s.height * .55);
    final ma = Offset(s.width * .14, base), mb = Offset(s.width - 4, base), mc = Offset(s.width * .58, -s.height * .25);
    // horizon
    canvas.drawLine(Offset(0, base), Offset(s.width, base), Paint()
      ..color = const Color(0x408CBEFF)
      ..strokeWidth = 1);
    // day glow
    final day = Path()
      ..moveTo(sa.dx, sa.dy)
      ..quadraticBezierTo(sc.dx, sc.dy, sb.dx, sb.dy)
      ..close();
    canvas.drawPath(
        day,
        Paint()
          ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x26F5B66B), Color(0x00F5B66B)])
              .createShader(Offset.zero & s));
    canvas.drawPath(
        Path()
          ..moveTo(sa.dx, sa.dy)
          ..quadraticBezierTo(sc.dx, sc.dy, sb.dx, sb.dy),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0x99F5B66B));
    // moon path, dashed
    final mp = Path()
      ..moveTo(ma.dx, ma.dy)
      ..quadraticBezierTo(mc.dx, mc.dy, mb.dx, mb.dy);
    for (final metric in mp.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 8) {
        canvas.drawPath(
            metric.extractPath(d, d + 3),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = const Color(0x73B4EFFC));
      }
    }
    for (final p in [sa, sb]) {
      canvas.drawCircle(p, 3, Paint()..color = const Color(0xFFF5B66B));
    }
    if (moon != null) {
      final c = _q(ma, mc, mb, moon!.clamp(0.0, 1.0));
      const r = 8.0;
      canvas.drawCircle(c, r, Paint()..color = const Color(0xFFB4EFFC));
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
      final shift = 2 * r * fraction;
      canvas.drawCircle(c + Offset(waxing ? -shift : shift, 0), r, Paint()..color = const Color(0xFF1A3F86));
      canvas.restore();
    }
    if (sun != null) {
      final c = _q(sa, sc, sb, sun!.clamp(0.0, 1.0));
      canvas.drawCircle(c, 17, Paint()..color = const Color(0x33F5B66B));
      canvas.drawCircle(c, 10, Paint()..color = const Color(0xFFF5B66B));
    }
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.sun != sun || o.moon != moon || o.fraction != fraction || o.waxing != waxing;
}

// ───────────────────────── shared bits

class _Sheet extends StatelessWidget {
  final List<Widget> children;
  const _Sheet({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xF82856AA), Color(0xFC0E2860)]),
          border: Border(top: BorderSide(color: Color(0x4DA0C8FF))),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0x4DFFFFFF), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 18),
          ...children,
        ]),
      );
}

class _CyanButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _CyanButton(this.text, {required this.onTap});
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: CkColors.cyan, borderRadius: BorderRadius.circular(15)),
          child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF06204F))),
        ),
      );
}

class _Header extends StatelessWidget {
  final String title;
  final String sub;
  final Widget? trailing;
  const _Header(this.title, {this.sub = '', this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [
        CircleBtn(Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: CkText.h(18)),
            if (sub.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
            ],
          ]),
        ),
        if (trailing != null) trailing!,
      ]);
}

/// Numbered Panchang table in the fixed order.
class PanchangTable extends StatelessWidget {
  final PanchangData d;
  const PanchangTable(this.d, {super.key});
  @override
  Widget build(BuildContext context) => Glass(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Column(children: [
          for (var i = 0; i < d.rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0x1F8CBEFF)))),
              child: Row(children: [
                SizedBox(width: 26, child: Text('${i + 1}', style: CkText.mono(11, color: CkColors.textDim))),
                SizedBox(width: 100, child: Text(d.rows[i].$1.toUpperCase(), style: CkText.label)),
                Expanded(child: Text(d.rows[i].$2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              ]),
            ),
        ]),
      );
}

// ───────────────────────── Home: Panchang now card

class PanchangNowCard extends StatefulWidget {
  const PanchangNowCard({super.key});
  @override
  State<PanchangNowCard> createState() => _PanchangNowCardState();
}

class _PanchangNowCardState extends State<PanchangNowCard> {
  Future<PanchangData>? _f;
  DateTime _now = DateTime.now();
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _load();
    Here.changed.addListener(_load);
    _t = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    Here.changed.removeListener(_load);
    super.dispose();
  }

  void _load() {
    if (!Here.known) return setState(() => _f = null);
    final now = DateTime.now();
    setState(() {
      _now = now;
      _f = fetchPanchang(now, Here.lat!, Here.lng!, Here.tzMinutes).then((r) => PanchangData.parse(r, at: now, lat: Here.lat, lng: Here.lng));
    });
  }

  @override
  Widget build(BuildContext context) {
    final known = Here.known;
    return Pressable(
      scale: .985,
      onTap: () async {
        if (!known) {
          await askLocation(context);
          return;
        }
        Get.to(() => const PanchangNowPage());
      },
      child: Glass(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('PANCHANG NOW', style: CkText.label),
            const Spacer(),
            if (known) ...[
              const Icon(Icons.place_outlined, size: 13, color: CkColors.textSecondary),
              const SizedBox(width: 3),
              Text(Here.name, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
            ],
          ]),
          if (!known)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(children: [
                Expanded(child: Text('Set your location to see today\'s Panchang', style: TextStyle(fontSize: 14))),
                Text('Set ›', style: TextStyle(fontSize: 13, color: CkColors.cyan, fontWeight: FontWeight.w500)),
              ]),
            )
          else
            FutureBuilder<PanchangData>(
              future: _f,
              builder: (c, s) {
                final d = s.data;
                Widget cell(int i) {
                  final k = const ['Nakshatra', 'Tithi', 'Karan', 'Yog'][i];
                  return Container(
                    padding: EdgeInsets.only(top: 9, bottom: 9, left: i.isOdd ? 12 : 0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: i > 1 ? const BorderSide(color: Color(0x1F8CBEFF)) : BorderSide.none,
                        left: i.isOdd ? const BorderSide(color: Color(0x1F8CBEFF)) : BorderSide.none,
                      ),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(k.toUpperCase(), style: CkText.label),
                      const SizedBox(height: 3),
                      d == null
                          ? const Skeleton(height: 14, width: 80)
                          : Text(d.get(k).isEmpty ? '—' : d.get(k), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ]),
                  );
                }

                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text(d?.get('Day').isNotEmpty == true ? d!.get('Day') : DateFormat('EEEE').format(_now), style: CkText.h(17)),
                    const SizedBox(width: 8),
                    if (d != null && d.get('Rashi').isNotEmpty) Text('Rashi · ${d.get('Rashi')}', style: const TextStyle(fontSize: 12.5, color: CkColors.textSecondary)),
                    const Spacer(),
                    const Text('Open ›', style: TextStyle(fontSize: 12.5, color: CkColors.cyan, fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 4),
                  SkyArc(at: _now, lat: Here.lat!, lng: Here.lng!, height: 70),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('↑ ${d?.get('Sunrise') ?? ''}', style: CkText.mono(10.5, color: CkColors.labelMono)),
                    Text('${d?.get('Sunset') ?? ''} ↓', style: CkText.mono(10.5, color: CkColors.labelMono)),
                  ]),
                  const SizedBox(height: 4),
                  if (s.hasError)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Couldn\'t load Panchang', style: CkText.muted))
                  else
                    Column(children: [
                      Row(children: [Expanded(child: cell(0)), Expanded(child: cell(1))]),
                      Row(children: [Expanded(child: cell(2)), Expanded(child: cell(3))]),
                    ]),
                ]);
              },
            ),
        ]),
      ),
    );
  }
}

// ───────────────────────── Panchang full screen (any time)

class PanchangNowPage extends StatefulWidget {
  const PanchangNowPage({super.key});
  @override
  State<PanchangNowPage> createState() => _PanchangNowPageState();
}

class _PanchangNowPageState extends State<PanchangNowPage> {
  DateTime _at = DateTime.now();
  Future<PanchangData>? _f;
  Timer? _debounce;
  PanchangData? _last;

  @override
  void initState() {
    super.initState();
    _load();
    Here.changed.addListener(_load);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    Here.changed.removeListener(_load);
    super.dispose();
  }

  void _load() {
    if (!Here.known) return;
    final at = _at;
    setState(() {
      _f = fetchPanchang(at, Here.lat!, Here.lng!, Here.tzMinutes).then((r) {
        final d = PanchangData.parse(r, at: at, lat: Here.lat, lng: Here.lng);
        _last = d;
        return d;
      });
    });
  }

  void _set(DateTime t) {
    setState(() => _at = t);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> _pick() async {
    final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(1900), lastDate: DateTime(2200));
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    _set(DateTime(d.year, d.month, d.day, t?.hour ?? _at.hour, t?.minute ?? _at.minute));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isNow = _at.difference(now).inMinutes.abs() < 2;
    final st = Here.known ? Sky.sunTimes(_at, Here.lat!, Here.lng!) : (null, null);
    String left = '';
    if (st.$1 != null && st.$2 != null) {
      if (_at.isAfter(st.$1!) && _at.isBefore(st.$2!)) {
        final d = st.$2!.difference(_at);
        left = 'Day · ${d.inHours}h ${d.inMinutes % 60}m left';
      } else {
        left = 'Night';
      }
    }
    return CkScaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _Header('Panchang',
                sub: Here.known ? Here.name : 'Location not set',
                trailing: Pressable(
                  onTap: () => _set(DateTime.now()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isNow ? CkColors.cyanTint : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: CkColors.cyanStroke),
                    ),
                    child: Text('NOW', style: CkText.mono(11.5, color: CkColors.cyan)),
                  ),
                )),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const CityPickerPage())),
                icon: const Icon(Icons.place_outlined, size: 16, color: CkColors.cyan),
                label: const Text('Change place', style: TextStyle(color: CkColors.cyan, fontSize: 13)),
              ),
            ),
            if (!Here.known)
              Glass(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  const Text('Set your location to see the Panchang.', style: CkText.muted),
                  const SizedBox(height: 12),
                  _CyanButton('Set location', onTap: () => askLocation(context)),
                ]),
              )
            else ...[
              Glass(
                padding: const EdgeInsets.all(6),
                child: Row(children: [
                  IconButton(onPressed: () => _set(_at.subtract(const Duration(days: 1))), icon: const Icon(Icons.chevron_left_rounded)),
                  Expanded(
                    child: Pressable(
                      onTap: _pick,
                      child: Column(children: [
                        Text(DateFormat('EEE, d MMM yyyy').format(_at), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(DateFormat('HH:mm').format(_at), style: CkText.mono(12, color: CkColors.cyan)),
                      ]),
                    ),
                  ),
                  IconButton(onPressed: () => _set(_at.add(const Duration(days: 1))), icon: const Icon(Icons.chevron_right_rounded)),
                ]),
              ),
              const SizedBox(height: 12),
              Glass(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('SKY AT ${DateFormat('HH:mm').format(_at)}', style: CkText.label),
                    const Spacer(),
                    const _Legend(Color(0xFFF5B66B), 'Sun'),
                    const SizedBox(width: 10),
                    const _Legend(Color(0xFFB4EFFC), 'Moon'),
                  ]),
                  const SizedBox(height: 6),
                  SkyArc(at: _at, lat: Here.lat!, lng: Here.lng!, height: 130, onTime: _set),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(st.$1 == null ? '' : '↑ ${DateFormat('HH:mm').format(st.$1!)}', style: CkText.mono(11, color: CkColors.textSecondary)),
                    Text(left, style: CkText.mono(11, color: const Color(0xFFF5D29A))),
                    Text(st.$2 == null ? '' : '${DateFormat('HH:mm').format(st.$2!)} ↓', style: CkText.mono(11, color: CkColors.textSecondary)),
                  ]),
                  const SizedBox(height: 4),
                  const Text('Drag the cyan handle to change the time', style: TextStyle(fontSize: 11, color: CkColors.textDim)),
                ]),
              ),
              const SizedBox(height: 12),
              FutureBuilder<PanchangData>(
                future: _f,
                builder: (c, s) {
                  if (s.hasError && _last == null) return ErrorBox(message: 'Couldn\'t load Panchang.', onRetry: _load);
                  final d = s.data ?? _last;
                  if (d == null) return const SkeletonList(rows: 8, leading: false);
                  return AnimatedOpacity(
                    duration: CkMotion.fast,
                    opacity: s.connectionState == ConnectionState.waiting ? .55 : 1,
                    child: PanchangTable(d),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color c;
  final String t;
  const _Legend(this.c, this.t);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(t, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
      ]);
}

// ───────────────────────── smart search

enum _Kind { all, clients, reports, tools }

class _Tool {
  final String title, sub;
  final IconData icon;
  final void Function(BuildContext) open;
  const _Tool(this.title, this.sub, this.icon, this.open);
}

/// Opens Transit / Panchang / Melapak from the search. Set by app_shell to
/// avoid an import cycle.
final searchTools = <_Tool>[];
void registerSearchTool(String title, String sub, IconData icon, void Function(BuildContext) open) =>
    searchTools.add(_Tool(title, sub, icon, open));

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _c = TextEditingController();
  final _focus = FocusNode();
  String _q = '';
  _Kind _k = _Kind.all;
  late final Future<List<Client>> _clients = fetchClients();
  late final Future<List<ReportItem>> _reports = fetchReports();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _hit(String s) => s.toLowerCase().contains(_q);

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 4), child: Text(t, style: CkText.label));

  Widget _row(Widget lead, String title, String sub, VoidCallback onTap) => InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1F8CBEFF)))),
          child: Row(children: [
            lead,
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.mono(11.5, color: CkColors.textSecondary)),
              ]),
            ),
          ]),
        ),
      );

  Widget _av(String a) => Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x598CBEFF))),
        child: Text(a, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final tools = searchTools.where((t) => _q.isEmpty || _hit('${t.title} ${t.sub}')).toList();
    return CkScaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _c,
                  focusNode: _focus,
                  onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                  decoration: const InputDecoration(hintText: 'Search clients, reports, tools', prefixIcon: Icon(Icons.search_rounded)),
                ),
              ),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: CkColors.cyan))),
            ]),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              children: [
                for (final k in _Kind.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Pressable(
                      onTap: () => setState(() => _k = k),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: _k == k ? CkColors.cyanTint : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _k == k ? CkColors.cyanStroke : CkColors.panelStroke),
                        ),
                        child: Text(const ['All', 'Clients', 'Reports', 'Tools'][k.index],
                            style: CkText.mono(12, color: _k == k ? Colors.white : CkColors.textSecondary)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              children: [
                if (_k == _Kind.all || _k == _Kind.clients)
                  FutureBuilder<List<Client>>(
                    future: _clients,
                    builder: (c, s) {
                      if (!s.hasData) return _q.isEmpty ? const SizedBox() : const Padding(padding: EdgeInsets.only(top: 18), child: SkeletonList(rows: 2));
                      final l = s.data!
                          .where((e) => _q.isNotEmpty && (_hit(e.name) || _hit(e.city) || _hit(e.dobRaw)))
                          .take(_k == _Kind.all ? 5 : 50)
                          .toList();
                      if (l.isEmpty) return const SizedBox();
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('CLIENTS'),
                        for (final e in l) _row(_av(e.initials), e.name, e.subtitle, () => openClient(e)),
                      ]);
                    },
                  ),
                if (_k == _Kind.all || _k == _Kind.reports)
                  FutureBuilder<List<ReportItem>>(
                    future: _reports,
                    builder: (c, s) {
                      if (!s.hasData) return const SizedBox();
                      final l = s.data!.where((e) => _q.isNotEmpty && _hit('${e.name} ${e.title}')).take(_k == _Kind.all ? 4 : 50).toList();
                      if (l.isEmpty) return const SizedBox();
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('REPORTS'),
                        for (final e in l) ReportRow(e, showClient: true),
                      ]);
                    },
                  ),
                if ((_k == _Kind.all || _k == _Kind.tools) && tools.isNotEmpty) ...[
                  _label('TOOLS'),
                  for (final t in tools)
                    _row(
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.cyanStroke)),
                        child: Icon(t.icon, size: 18, color: CkColors.cyan),
                      ),
                      t.title,
                      t.sub,
                      () => t.open(context),
                    ),
                ],
                const Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Text('Search by name, birth year or place. Tools open directly.', style: TextStyle(fontSize: 12, color: CkColors.textDim)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// Small helper so other files can draw the moon phase disk.
double moonFraction(DateTime t) => Sky.moonPhase(t).$1;
int clampInt(int v, int lo, int hi) => math.max(lo, math.min(hi, v));
