import 'dart:math' as math;

import '../core/astro.dart';
import 'kundli_assets.dart';

/// Dart port of the CosmoKundli software's circle-kundli renderers
/// (birth-kundli_circle.html and gochar.html). Produces the same SVG markup;
/// text on arcs is laid out per character because flutter_svg has no textPath.
class KundliSvg {
  static const _deg = math.pi / 180;

  static String _f(num v) => v.toStringAsFixed(3);

  static List<double> _p(double cx, double cy, double angleDeg, double r) {
    final rad = (angleDeg - 90) * _deg;
    return [cx + r * math.cos(rad), cy + r * math.sin(rad)];
  }

  static double _charW(String ch, double fs) {
    if (ch == ' ') return fs * 0.28;
    if (RegExp(r'[0-9]').hasMatch(ch)) return fs * 0.56;
    if ('MW'.contains(ch)) return fs * 0.78;
    if (RegExp(r'[A-Z]').hasMatch(ch)) return fs * 0.62;
    if ('ijl'.contains(ch)) return fs * 0.24;
    if ('mw'.contains(ch)) return fs * 0.78;
    if ('frt'.contains(ch)) return fs * 0.34;
    if (RegExp(r'[a-z]').hasMatch(ch)) return fs * 0.53;
    return fs * 0.7; // Devanagari / Gujarati
  }

  /// Text along an arc centred at [midAngle] (0° = top, clockwise), reading
  /// left-to-right for the viewer — same behaviour as the software's textPath.
  static String _arcText(String text, double cx, double cy, double r, double midAngle, bool bottom,
      double fs, String fill, int weight) {
    final chars = text.split('');
    final widths = chars.map((c) => _charW(c, fs)).toList();
    final total = widths.fold<double>(0, (a, b) => a + b);
    final spanDeg = total / r / _deg;
    final b = StringBuffer();
    var acc = 0.0;
    for (var i = 0; i < chars.length; i++) {
      final centre = (acc + widths[i] / 2) / r / _deg;
      acc += widths[i];
      final a = bottom ? midAngle + spanDeg / 2 - centre : midAngle - spanDeg / 2 + centre;
      final pt = _p(cx, cy, a, r);
      final rot = bottom ? a + 180 : a;
      final esc = chars[i].replaceAll('&', '&amp;').replaceAll('<', '&lt;');
      b.write('<text x="${_f(pt[0])}" y="${_f(pt[1])}" fill="$fill" font-size="$fs" font-weight="$weight" '
          'text-anchor="middle" transform="rotate(${_f(rot)}, ${_f(pt[0])}, ${_f(pt[1])})">$esc</text>');
    }
    return b.toString();
  }

  static String _zodiacLabels(double cx, double cy, double rTop, double rBottom, double fs, String lang) {
    final b = StringBuffer('<g>');
    for (var i = 0; i < 12; i++) {
      final mid = i * -30.0;
      final bottom = i >= 4 && i <= 8;
      // Same as the software's textPath: the baseline sits on the arc. On
      // top the glyphs rise outward; on the bottom (reversed arc) they rise
      // inward, so rBottom is already the outer edge of the text.
      final r = bottom ? rBottom : rTop;
      b.write(_arcText('${i + 1} ${rashiName(i + 1, lang)}', cx, cy, r, mid, bottom, fs, 'white', 600));
    }
    b.write('</g>');
    return b.toString();
  }

  static String _ticks(double cx, double cy, double rFrom, double len, Set<int> skip) {
    final b = StringBuffer();
    final major = <int>{...skip};
    for (var d = 0; d < 360; d += 5) {
      if (skip.contains(d)) continue;
      major.add(d);
      final o = _p(cx, cy, d.toDouble(), rFrom);
      final i = _p(cx, cy, d.toDouble(), rFrom + len);
      b.write('<line x1="${_f(o[0])}" y1="${_f(o[1])}" x2="${_f(i[0])}" y2="${_f(i[1])}" stroke="white" stroke-width="0.8" stroke-opacity="0.9"/>');
    }
    for (var d = 0; d < 360; d++) {
      if (major.contains(d)) continue;
      final o = _p(cx, cy, d.toDouble(), rFrom);
      final i = _p(cx, cy, d.toDouble(), rFrom + len * 0.5);
      b.write('<line x1="${_f(o[0])}" y1="${_f(o[1])}" x2="${_f(i[0])}" y2="${_f(i[1])}" stroke="white" stroke-width="0.6" stroke-opacity="0.8"/>');
    }
    return b.toString();
  }

  static double _angle(GrahPos p) => 15 - p.longitude;

  static String _tokens(double cx, double cy, List<GrahPos> planets, double r, double offset, double tickLen,
      double tipLen, bool inward) {
    const width = 2.0;
    const radius = width / 2;
    final shoulder = tickLen - tipLen;
    final shape = 'M 0 -$radius A $radius $radius 0 0 0 0 $radius L $shoulder $radius L $tickLen 0 L $shoulder -$radius Z';
    final b = StringBuffer('<g>');
    for (final p in planets) {
      final a = _angle(p);
      final p1 = _p(cx, cy, a, r + offset);
      final p2 = _p(cx, cy, a, inward ? r - tickLen : r + tickLen);
      final rot = math.atan2(p2[1] - p1[1], p2[0] - p1[0]) * 180 / math.pi - 180;
      b.write('<path d="$shape" fill="${kGrahHex[p.id]}" transform="translate(${p1[0].toStringAsFixed(2)}, ${p1[1].toStringAsFixed(2)}) rotate(${rot.toStringAsFixed(2)})"/>');
    }
    b.write('</g>');
    return b.toString();
  }

  static String _labels(double cx, double cy, List<GrahPos> planets, double baseRadius, double fs,
      double ringGap, double gapFactor, bool outward, String lang, bool colored) {
    final minGap = (fs * gapFactor) / baseRadius * (180 / math.pi);
    final items = planets.where((p) => p.id != 'As').toList()
      ..sort((a, b) => (kGrahSeq[a.id] ?? 0).compareTo(kGrahSeq[b.id] ?? 0));
    final rings = <List<double>>[[]];
    final ringOf = <String, int>{};
    for (final it in items) {
      final norm = ((_angle(it) % 360) + 360) % 360;
      var assigned = false;
      for (var r = 0; r < rings.length; r++) {
        final overlap = rings[r].any((a) {
          var d = (norm - a).abs();
          if (d > 180) d = 360 - d;
          return d < minGap;
        });
        if (!overlap) {
          ringOf[it.id] = r;
          rings[r].add(norm);
          assigned = true;
          break;
        }
      }
      if (!assigned) {
        ringOf[it.id] = rings.length;
        rings.add([norm]);
      }
    }
    final b = StringBuffer('<g>');
    for (final it in items) {
      final ring = ringOf[it.id] ?? 0;
      final radius = outward ? baseRadius + ring * ringGap : baseRadius - ring * ringGap;
      final a = _angle(it);
      final pos = _p(cx, cy, a, radius);
      final norm = ((a % 360) + 360) % 360;
      var rot = a;
      if (norm > 90 && norm < 270) rot += 180;
      final label = _label(it.id, lang) + (it.retro ? '℞' : '');
      final fill = colored ? kGrahHex[it.id] : 'white';
      b.write('<text x="${pos[0].toStringAsFixed(2)}" y="${(pos[1]).toStringAsFixed(2)}" dy="${(fs * 0.35).toStringAsFixed(2)}" fill="$fill" font-size="$fs" font-weight="600" '
          'text-anchor="middle" transform="rotate(${rot.toStringAsFixed(2)}, ${pos[0].toStringAsFixed(2)}, ${pos[1].toStringAsFixed(2)})">$label</text>');
    }
    b.write('</g>');
    return b.toString();
  }

  /// Port of gochar.html renderGocharPlanetLabels: transit labels stay on a
  /// single ring just outside the belt. Crowded labels are pushed apart
  /// sideways (never across their rashi's border), spread evenly inside the
  /// rashi, and joined to their real position by a thin dotted leader.
  static String _gocharLabels(double cx, double cy, List<GrahPos> planets, double zOut, String lang) {
    const tickLen = 10.0, fs = 7.0, minGap = 4.0;
    final radius = zOut + tickLen + 8;
    int rashiOf(_Lbl l) => (l.p.longitude ~/ 30) % 12 + 1;
    final items = planets.where((p) => p.id != 'As').map((p) => _Lbl(p, _angle(p))).toList()
      ..sort((a, b) => b.placed.compareTo(a.placed));
    var changed = true;
    var it = 0;
    while (changed && it < 50) {
      changed = false;
      it++;
      for (var i = 1; i < items.length; i++) {
        final gap = items[i - 1].placed - items[i].placed;
        if (gap < minGap) {
          final overlap = minGap - gap;
          final highPrev = 15.0 - (rashiOf(items[i - 1]) - 1) * 30;
          final lowI = 15.0 - rashiOf(items[i]) * 30;
          var up = overlap / 2, down = overlap / 2;
          if (items[i - 1].placed + up > highPrev) {
            up = highPrev - items[i - 1].placed;
            down = overlap - up;
          }
          if (items[i].placed - down < lowI) {
            down = items[i].placed - lowI;
            up = overlap - down;
          }
          items[i - 1].placed += up;
          items[i].placed -= down;
          changed = true;
        }
      }
    }
    final groups = <int, List<_Lbl>>{};
    for (final l in items) {
      groups.putIfAbsent(rashiOf(l), () => []).add(l);
    }
    for (final g in groups.values) {
      if (g.length < 2) continue;
      final max = g.first.placed, min = g.last.placed;
      final gap = (max - min) / (g.length - 1.1);
      for (var i = 0; i < g.length; i++) {
        g[i].placed = max - i * gap;
      }
    }
    for (final entry in groups.entries) {
      final g = entry.value;
      if (g.length < 2) continue;
      final high = 15.0 - (entry.key - 1) * 30, low = high - 30;
      final hitsHigh = g.any((l) => l.placed >= high - 0.01);
      final hitsLow = g.any((l) => l.placed <= low + 0.01);
      if (!hitsHigh && !hitsLow) continue;
      final centre = g.fold<double>(0, (a, l) => a + l.placed) / g.length;
      final shift = centre < high - 15 ? 1.0 : -1.0;
      for (final l in g) {
        l.placed += shift;
      }
    }
    final b = StringBuffer('<g>');
    for (final l in items) {
      final pos = _p(cx, cy, l.placed, radius);
      final norm = ((l.placed % 360) + 360) % 360;
      var rot = l.placed;
      if (norm > 90 && norm < 270) rot += 180;
      if ((l.placed - l.angle).abs() > 0.5) {
        final s = _p(cx, cy, l.angle, zOut + 9.5);
        final e = _p(cx, cy, l.placed, radius - 3);
        b.write('<line x1="${_f(s[0])}" y1="${_f(s[1])}" x2="${_f(e[0])}" y2="${_f(e[1])}" stroke="${kGrahHex[l.p.id]}" '
            'stroke-width="0.4" stroke-dasharray="1.5 1" opacity="0.7"/>');
      }
      final label = _label(l.p.id, lang) + (l.p.retro ? '℞' : '');
      b.write('<text x="${_f(pos[0])}" y="${_f(pos[1])}" dy="${(fs * 0.35).toStringAsFixed(2)}" fill="white" font-size="$fs" font-weight="600" '
          'text-anchor="middle" transform="rotate(${_f(rot)}, ${_f(pos[0])}, ${_f(pos[1])})">$label</text>');
    }
    b.write('</g>');
    return b.toString();
  }

  static String _label(String id, String lang) {
    const hi = {'Su': 'सू', 'Mo': 'चं', 'Ma': 'मं', 'Me': 'बु', 'Ju': 'गु', 'Ve': 'शु', 'Sa': 'श', 'Ra': 'रा', 'Ke': 'के', 'As': 'ल'};
    const gu = {'Su': 'સૂ', 'Mo': 'ચં', 'Ma': 'મં', 'Me': 'બુ', 'Ju': 'ગુ', 'Ve': 'શુ', 'Sa': 'શ', 'Ra': 'રા', 'Ke': 'કે', 'As': 'લ'};
    if (lang == 'hi') return hi[id] ?? id;
    if (lang == 'gu') return gu[id] ?? id;
    return id;
  }

  /// Birth chart (CosmoKundli) — config identical to birth-kundli_circle.html.
  static String birth(List<GrahPos> planets, {String lang = 'en'}) {
    const cx = 250.0, cy = 250.0, zOut = 156.0, zIn = 138.0, asOuter = 33.0, logoCircle = 20.0, tick = 6.0, logoScale = 0.015;
    final band = (zOut + zIn) / 2;
    final bandW = (zOut - zIn) - 1.1;
    final asc = planets.where((p) => p.id == 'As').toList();
    final ascPos = asc.isEmpty ? 1 : (asc.first.longitude ~/ 30) + 1;
    final parts = StringBuffer();
    parts.write('<defs>$kGradientDefs$kAsRingClipDefs</defs>');
    parts.write(kGradientCircles);
    parts.write(kRedDiamond);
    parts.write('<circle cx="$cx" cy="$cy" r="$zOut" stroke="#437FD7" fill="none"/>');
    parts.write('<circle cx="$cx" cy="$cy" r="$band" fill="none" stroke="white" stroke-width="$bandW" opacity="0.1"/>');
    parts.write('<circle cx="$cx" cy="$cy" r="$zIn" stroke="#437FD7" fill="none"/>');
    final radial = <int>{};
    for (var i = 0; i < 12; i++) {
      final a = i * 30 + 15;
      radial.add(a);
      final o = _p(cx, cy, a.toDouble(), zOut);
      final n = _p(cx, cy, a.toDouble(), asOuter);
      parts.write('<line x1="${_f(o[0])}" y1="${_f(o[1])}" x2="${_f(n[0])}" y2="${_f(n[1])}" stroke="#437FD7" stroke-opacity="0.5" stroke-width="1"/>');
    }
    parts.write(_ticks(cx, cy, zIn + 0.5, tick, radial));
    parts.write(_zodiacLabels(cx, cy, zOut - 9, zOut - 3, 8, lang));
    parts.write('<circle cx="$cx" cy="$cy" r="$asOuter" stroke="#437FD7" fill="none"/>');
    // rotating As ring
    final rotDeg = -(ascPos - 1) * 30;
    const figmaCenter = 48.0, figmaRadius = 35.5;
    final target = asOuter + logoCircle / 2;
    final scale = target / figmaRadius / 1.65;
    final tx = cx - figmaCenter * scale, ty = cy - figmaCenter * scale;
    final asText = math.min(10.0, asOuter - logoCircle - 3);
    const asX = figmaCenter, asY = figmaCenter - figmaRadius;
    parts.write('<g transform="translate(${_f(tx)}, ${_f(ty)}) scale(${scale.toStringAsFixed(4)})">');
    parts.write('<g transform="rotate($rotDeg, $figmaCenter, $figmaCenter)">');
    parts.write(kAsRingPath);
    parts.write('<text x="$asX" y="${asY - 1}" dy="${(asText * 0.35).toStringAsFixed(2)}" text-anchor="middle" fill="white" font-size="$asText" font-weight="700" transform="rotate(${-rotDeg}, $asX, $asY)">As</text>');
    parts.write('</g></g>');
    parts.write('<circle cx="$cx" cy="$cy" r="$logoCircle" stroke="#437FD7" stroke-width="0.5" fill="none"/>');
    parts.write('<g transform="translate(${(cx - 851 * logoScale).toStringAsFixed(2)}, ${(cy - 750 * logoScale).toStringAsFixed(2)}) scale($logoScale)" opacity="0.7">$kLogoPaths</g>');
    parts.write(_tokens(cx, cy, planets, zIn, -9.5, 10, 4, true));
    parts.write(_labels(cx, cy, planets, zIn - 3 - 10 - 4, 9, 11, 1.5, false, lang, false));
    return '<svg viewBox="92 92 316 316" fill="none" xmlns="http://www.w3.org/2000/svg">$parts</svg>';
  }

  /// Transit (Gochar) chart — config identical to gochar.html: birth GRAH
  /// inside the zodiac belt, transit GRAH outside it.
  static String transit(List<GrahPos> birth, List<GrahPos> transit, {String lang = 'en'}) {
    const cx = 250.0, cy = 250.0, zOut = 130.0, zIn = 114.0, outer = 155.0, logoCircle = 18.0, tick = 4.0, logoScale = 0.015;
    final band = (zOut + zIn) / 2;
    final bandW = (zOut - zIn) - 1.1;
    final parts = StringBuffer();
    parts.write('<circle cx="$cx" cy="$cy" r="$zOut" stroke="#437FD7" fill="none"/>');
    parts.write('<circle cx="$cx" cy="$cy" r="$band" fill="none" stroke="white" stroke-width="$bandW" opacity="0.2"/>');
    parts.write('<circle cx="$cx" cy="$cy" r="$zIn" stroke="#437FD7" fill="none"/>');
    parts.write('<circle cx="$cx" cy="$cy" r="$outer" stroke="#437FD7" stroke-width="1" fill="none"/>');
    parts.write('<circle cx="$cx" cy="$cy" r="$logoCircle" stroke="#437FD7" stroke-width="0.5" fill="none"/>');
    final radial = <int>{};
    for (var i = 0; i < 12; i++) {
      final a = i * 30 + 15;
      radial.add(a);
      final o = _p(cx, cy, a.toDouble(), outer);
      final n = _p(cx, cy, a.toDouble(), logoCircle);
      parts.write('<line x1="${_f(o[0])}" y1="${_f(o[1])}" x2="${_f(n[0])}" y2="${_f(n[1])}" stroke="#437FD7" stroke-opacity="0.5" stroke-width="1"/>');
    }
    parts.write(_ticks(cx, cy, zIn + 0.5, tick, radial));
    parts.write(_ticks(cx, cy, zOut - 0.5, -tick, radial));
    parts.write(_zodiacLabels(cx, cy, zOut - 10, zOut - 6, 6, lang));
    parts.write('<g transform="translate(${(cx - 849 * logoScale).toStringAsFixed(2)}, ${(cy - 750 * logoScale).toStringAsFixed(2)}) scale($logoScale)" opacity="0.7">$kLogoPaths</g>');
    parts.write(_tokens(cx, cy, birth, zIn, -9.5, 10, 3, true));
    parts.write(_tokens(cx, cy, transit.where((p) => p.id != 'As').toList(), zOut, 9.5, 10, 3, false));
    parts.write(_labels(cx, cy, birth, zIn - 8 - 7, 7, 9, 2, false, lang, false));
    parts.write(_gocharLabels(cx, cy, transit, zOut, lang));
    return '<svg viewBox="80 80 340 340" fill="none" xmlns="http://www.w3.org/2000/svg">$parts</svg>';
  }
}

class _Lbl {
  final GrahPos p;
  final double angle;
  double placed;
  _Lbl(this.p, this.angle) : placed = angle;
}
