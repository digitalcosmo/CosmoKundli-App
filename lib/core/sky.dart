import 'dart:math' as m;

/// Sun and moon positions, rise/set times and moon phase, computed on the
/// device (port of the SunCalc formulas, based on Meeus). Accurate to a few
/// minutes for rise/set; good enough to place the sun and moon on a sky arc.
class Sky {
  static const _rad = m.pi / 180;
  static const _dayMs = 1000 * 60 * 60 * 24;
  static const _j1970 = 2440588;
  static const _j2000 = 2451545;
  static const _e = _rad * 23.4397;

  static double _toJulian(DateTime d) => d.toUtc().millisecondsSinceEpoch / _dayMs - 0.5 + _j1970;
  static DateTime _fromJulian(double j) =>
      DateTime.fromMillisecondsSinceEpoch(((j + 0.5 - _j1970) * _dayMs).round(), isUtc: true).toLocal();
  static double _toDays(DateTime d) => _toJulian(d) - _j2000;

  static double _ra(double l, double b) => m.atan2(m.sin(l) * m.cos(_e) - m.tan(b) * m.sin(_e), m.cos(l));
  static double _dec(double l, double b) => m.asin(m.sin(b) * m.cos(_e) + m.cos(b) * m.sin(_e) * m.sin(l));
  static double _alt(double h, double phi, double dec) => m.asin(m.sin(phi) * m.sin(dec) + m.cos(phi) * m.cos(dec) * m.cos(h));
  static double _sidereal(double d, double lw) => _rad * (280.16 + 360.9856235 * d) - lw;
  static double _refraction(double h) {
    if (h < 0) h = 0;
    return 0.0002967 / m.tan(h + 0.00312536 / (h + 0.08901179));
  }

  static double _solarMeanAnomaly(double d) => _rad * (357.5291 + 0.98560028 * d);
  static double _eclipticLongitude(double mm) {
    final c = _rad * (1.9148 * m.sin(mm) + 0.02 * m.sin(2 * mm) + 0.0003 * m.sin(3 * mm));
    const p = _rad * 102.9372;
    return mm + c + p + m.pi;
  }

  static (double dec, double ra) _sunCoords(double d) {
    final l = _eclipticLongitude(_solarMeanAnomaly(d));
    return (_dec(l, 0), _ra(l, 0));
  }

  /// Sun altitude in degrees.
  static double sunAltitude(DateTime t, double lat, double lng) {
    final lw = _rad * -lng, phi = _rad * lat, d = _toDays(t);
    final c = _sunCoords(d);
    final h = _sidereal(d, lw) - c.$2;
    return _alt(h, phi, c.$1) / _rad;
  }

  // sun times
  static const _j0 = 0.0009;
  static double _julianCycle(double d, double lw) => (d - _j0 - lw / (2 * m.pi)).roundToDouble();
  static double _approxTransit(double ht, double lw, double n) => _j0 + (ht + lw) / (2 * m.pi) + n;
  static double _solarTransitJ(double ds, double mm, double l) => _j2000 + ds + 0.0053 * m.sin(mm) - 0.0069 * m.sin(2 * l);
  static double _hourAngle(double h, double phi, double d) => m.acos((m.sin(h) - m.sin(phi) * m.sin(d)) / (m.cos(phi) * m.cos(d)));

  /// Sunrise and sunset for the local day of [t]. Null at polar day/night.
  static (DateTime? rise, DateTime? set) sunTimes(DateTime t, double lat, double lng) {
    final noonLocal = DateTime(t.year, t.month, t.day, 12);
    final lw = _rad * -lng, phi = _rad * lat;
    final d = _toDays(noonLocal);
    final n = _julianCycle(d, lw);
    final ds = _approxTransit(0, lw, n);
    final mm = _solarMeanAnomaly(ds);
    final l = _eclipticLongitude(mm);
    final dec = _dec(l, 0);
    final jNoon = _solarTransitJ(ds, mm, l);
    const h0 = -0.833 * _rad;
    final x = (m.sin(h0) - m.sin(phi) * m.sin(dec)) / (m.cos(phi) * m.cos(dec));
    if (x.abs() > 1) return (null, null);
    final w = _hourAngle(h0, phi, dec);
    final a = _approxTransit(w, lw, n);
    final jSet = _solarTransitJ(a, mm, l);
    final jRise = jNoon - (jSet - jNoon);
    return (_fromJulian(jRise), _fromJulian(jSet));
  }

  // moon
  static (double ra, double dec, double dist) _moonCoords(double d) {
    final l = _rad * (218.316 + 13.176396 * d);
    final mm = _rad * (134.963 + 13.064993 * d);
    final f = _rad * (93.272 + 13.229350 * d);
    final lon = l + _rad * 6.289 * m.sin(mm);
    final b = _rad * 5.128 * m.sin(f);
    final dt = 385001 - 20905 * m.cos(mm);
    return (_ra(lon, b), _dec(lon, b), dt);
  }

  /// Moon altitude in degrees (with refraction).
  static double moonAltitude(DateTime t, double lat, double lng) {
    final lw = _rad * -lng, phi = _rad * lat, d = _toDays(t);
    final c = _moonCoords(d);
    final h = _sidereal(d, lw) - c.$1;
    var a = _alt(h, phi, c.$2);
    a += _refraction(a);
    return a / _rad;
  }

  /// Illuminated fraction 0..1 and phase 0..1 (0 new, .5 full).
  static (double fraction, double phase) moonPhase(DateTime t) {
    final d = _toDays(t);
    final s = _sunCoords(d);
    final mc = _moonCoords(d);
    const sdist = 149598000.0;
    final phi = m.acos(m.sin(s.$1) * m.sin(mc.$2) + m.cos(s.$1) * m.cos(mc.$2) * m.cos(s.$2 - mc.$1));
    final inc = m.atan2(sdist * m.sin(phi), mc.$3 - sdist * m.cos(phi));
    final angle = m.atan2(m.cos(s.$1) * m.sin(s.$2 - mc.$1),
        m.sin(s.$1) * m.cos(mc.$2) - m.cos(s.$1) * m.sin(mc.$2) * m.cos(s.$2 - mc.$1));
    final fraction = (1 + m.cos(inc)) / 2;
    final phase = 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / m.pi;
    return (fraction, phase);
  }

  /// Moonrise and moonset within the local day of [t] (either may be null).
  static (DateTime? rise, DateTime? set) moonTimes(DateTime t, double lat, double lng) {
    final day = DateTime(t.year, t.month, t.day);
    const hc = 0.133;
    double alt(int hours) => moonAltitude(day.add(Duration(hours: hours)), lat, lng) - hc;
    var h0 = alt(0);
    double? rise, set;
    for (var i = 1; i <= 24; i += 2) {
      final h1 = alt(i), h2 = alt(i + 1);
      final a = (h0 + h2) / 2 - h1;
      final b = (h2 - h0) / 2;
      final xe = -b / (2 * a);
      final ye = (a * xe + b) * xe + h1;
      final dd = b * b - 4 * a * h1;
      var roots = 0;
      double x1 = 0, x2 = 0;
      if (dd >= 0) {
        final dx = m.sqrt(dd) / (a.abs() * 2);
        x1 = xe - dx;
        x2 = xe + dx;
        if (x1.abs() <= 1) roots++;
        if (x2.abs() <= 1) roots++;
        if (x1 < -1) x1 = x2;
      }
      if (roots == 1) {
        if (h0 < 0) {
          rise = i + x1;
        } else {
          set = i + x1;
        }
      } else if (roots == 2) {
        rise = i + (ye < 0 ? x2 : x1);
        set = i + (ye < 0 ? x1 : x2);
      }
      if (rise != null && set != null) break;
      h0 = h2;
    }
    DateTime? at(double? h) => h == null ? null : day.add(Duration(minutes: (h * 60).round()));
    return (at(rise), at(set));
  }

  /// Where a body sits on its above-horizon arc at [t]: 0 at rise, 1 at set,
  /// null when it is below the horizon. Finds the rise/set pair around [t].
  static double? arcPos(DateTime t, (DateTime?, DateTime?) Function(DateTime) times) {
    final today = times(t);
    final yday = times(t.subtract(const Duration(days: 1)));
    final tmrw = times(t.add(const Duration(days: 1)));
    final rises = [yday.$1, today.$1, tmrw.$1].whereType<DateTime>().toList()..sort();
    final sets = [yday.$2, today.$2, tmrw.$2].whereType<DateTime>().toList()..sort();
    final r = rises.where((x) => !x.isAfter(t)).lastOrNull;
    if (r == null) return null;
    final s = sets.where((x) => x.isAfter(r)).firstOrNull;
    if (s == null || s.isBefore(t)) return null;
    return t.difference(r).inSeconds / s.difference(r).inSeconds;
  }
}
