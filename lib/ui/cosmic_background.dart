import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Deep-space scene behind every page: navy depth, slowly turning orbit
/// rings, a large blue sphere and a small amber planet drifting, and a
/// twinkling starfield. One painter, one controller; Flutter mutes the
/// ticker of routes that are covered, so only the visible page animates.
class CosmicBackground extends StatefulWidget {
  const CosmicBackground({super.key});
  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with TickerProviderStateMixin {
  // Every background runs on one shared clock, so two pages show the scene
  // in exactly the same position and swapping pages never makes it jump.
  static final _clock = Stopwatch()..start();
  static double _phase(int periodMs) => (_clock.elapsedMilliseconds % periodMs) / periodMs;

  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 120), value: _phase(120000))..repeat();
  // Slow breathing auras behind the glass: 18 s out, 18 s back.
  late final AnimationController _aura =
      AnimationController(vsync: this, duration: const Duration(seconds: 36), value: _phase(36000))..repeat();
  static final List<_Star> _stars = _makeStars();
  late final _painter = _SpacePainter(_c, _stars, _AuraPainter(_aura), Listenable.merge([_c, _aura]));

  static List<_Star> _makeStars() {
    final r = math.Random(11);
    return List.generate(
        90,
        (_) => _Star(r.nextDouble(), r.nextDouble(), .4 + r.nextDouble() * 1.1, r.nextDouble() * math.pi * 2,
            2 + r.nextInt(5)));
  }

  // Coming back on screen (tab switched back, page above popped): jump to
  // the shared clock so this page matches the one it replaces.
  bool _was = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final on = TickerMode.of(context);
    if (on && !_was) {
      _c.value = _phase(120000);
      _aura.value = _phase(36000);
      _c.repeat();
      _aura.repeat();
    }
    _was = on;
  }

  @override
  void dispose() {
    _c.dispose();
    _aura.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    if (still && _c.isAnimating) _c.stop();
    if (still && _aura.isAnimating) _aura.stop();
    return Stack(fit: StackFit.expand, children: [
      const RepaintBoundary(child: CustomPaint(painter: _StaticSpacePainter(), size: Size.infinite, isComplex: true, willChange: false)),
      RepaintBoundary(
        child: CustomPaint(
          painter: _painter,
          size: Size.infinite,
          isComplex: true,
        ),
      ),
    ]);
  }
}

class _Star {
  final double x, y, r, phase;
  final int speed; // twinkles per 120 s cycle
  const _Star(this.x, this.y, this.r, this.phase, this.speed);
}

/// The parts that never move (base gradient, nebula): drawn once, cached in
/// their own layer, never repainted.
class _StaticSpacePainter extends CustomPainter {
  const _StaticSpacePainter();
  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;
    canvas.drawRect(
        rect,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-.6, -1.0),
            radius: 1.5,
            colors: [Color(0xFF2563C4), Color(0xFF164292), Color(0xFF0E2E6C), Color(0xFF0A2252)],
            stops: [0, .38, .72, 1],
          ).createShader(rect));
    canvas.drawCircle(Offset(s.width * .05, s.height * .25), s.width * .55,
        Paint()..shader = RadialGradient(colors: [const Color(0x441E5BD8), const Color(0x001E5BD8)])
            .createShader(Rect.fromCircle(center: Offset(s.width * .05, s.height * .25), radius: s.width * .55)));
  }

  @override
  bool shouldRepaint(covariant _StaticSpacePainter old) => false;
}

/// The moving parts (rings, bobbing planets, twinkling stars). Paints and
/// gradients are built once per size and reused every frame.
class _SpacePainter extends CustomPainter {
  final Animation<double> t;
  final List<_Star> stars;
  final _AuraPainter aura;
  _SpacePainter(this.t, this.stars, this.aura, Listenable repaint) : super(repaint: repaint);

  Size? _size;
  late Paint _bigHalo, _big, _smallHalo, _small;
  late double _pr;
  final _ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final _dotBlue = Paint()..color = const Color(0xFF9EC2FF);
  final _dotAmber = Paint()..color = const Color(0xFFF5B66B);
  final _star = Paint();

  void _prepare(Size s) {
    if (_size == s) return;
    _size = s;
    _pr = s.width * .24;
    // gradients centred on the origin; the canvas is moved to each planet
    _bigHalo = Paint()
      ..shader = RadialGradient(colors: [const Color(0x334C8DFF), const Color(0x004C8DFF)])
          .createShader(Rect.fromCircle(center: Offset.zero, radius: _pr * 1.25));
    _big = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-.36, -.4),
        colors: [Color(0xFF5C8DF0), Color(0xFF2349A8), Color(0xFF0D2464), Color(0xFF061538)],
        stops: [0, .3, .62, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: _pr));
    _smallHalo = Paint()
      ..shader = RadialGradient(colors: [const Color(0x55F07E22), const Color(0x00F07E22)])
          .createShader(Rect.fromCircle(center: Offset.zero, radius: 22));
    _small = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-.3, -.4),
        colors: [Color(0xFFFFD7A8), Color(0xFFF07E22), Color(0xFF7A3208)],
        stops: [0, .45, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 11));
  }

  @override
  void paint(Canvas canvas, Size s) {
    _prepare(s);
    final v = t.value; // 0..1 over 120 s

    // orbit rings, slowly turning
    final c = Offset(s.width * .5, s.height * .62);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(v * 2 * math.pi);
    for (final (rx, ry, a) in const [(1.15, .44, .22), (.85, .31, .14), (.56, .2, .2)]) {
      _ring.color = Color.fromRGBO(150, 190, 255, a);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s.width * rx * 2, height: s.width * ry * 2), _ring);
    }
    canvas.drawCircle(Offset(s.width * 1.15, 0), 3.5, _dotBlue);
    canvas.drawCircle(Offset(-s.width * .85, 0), 2.5, _dotAmber);
    canvas.restore();

    // large blue sphere, gently bobbing
    final bob = math.sin(v * 2 * math.pi * 6) * 8;
    canvas.save();
    canvas.translate(s.width * .02, s.height * .84 + bob);
    canvas.drawCircle(Offset.zero, _pr * 1.25, _bigHalo);
    canvas.drawCircle(Offset.zero, _pr, _big);
    canvas.restore();

    // small amber planet
    canvas.save();
    canvas.translate(s.width * .88, s.height * .28 - bob * .6);
    canvas.drawCircle(Offset.zero, 22, _smallHalo);
    canvas.drawCircle(Offset.zero, 11, _small);
    canvas.restore();

    // twinkling stars
    final star = _star;
    for (final st in stars) {
      final tw = .2 + .8 * (.5 + .5 * math.sin(v * 2 * math.pi * st.speed * 10 + st.phase));
      star.color = Color.fromRGBO(255, 255, 255, tw * .85);
      canvas.drawCircle(Offset(st.x * s.width, st.y * s.height), st.r, star);
    }
    aura.paint(canvas, s);
  }

  @override
  bool shouldRepaint(_SpacePainter old) => false;
}


/// Three large soft colour glows that drift and breathe; they are what the
/// see-through cards show behind them. Gradients built once, moved by
/// translating the canvas.
class _AuraPainter {
  final Animation<double> t;
  _AuraPainter(this.t);
  final _p = <Paint>[];

  static const _blobs = [(190.0, Color(0xFF2E6BFF), .42), (170.0, Color(0xFF14A6B8), .34), (120.0, Color(0xFF5CE1FF), .14)];

  void paint(Canvas canvas, Size s) {
    if (_p.isEmpty) {
      for (final (r, col, a) in _blobs) {
        _p.add(Paint()
          ..shader = RadialGradient(colors: [col.withValues(alpha: a), col.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: Offset.zero, radius: r)));
      }
    }
    final tri = t.value < .5 ? t.value * 2 : 2 - t.value * 2; // there and back
    final v = Curves.easeInOut.transform(tri);
    final at = [
      Offset(80 + 40 * v, 110 + 60 * v),
      Offset(s.width + 20 - 30 * v, s.height * .62 + 50 * v),
      Offset(s.width * .45 + 30 * v, s.height * .38 - 30 * v),
    ];
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(at[i].dx, at[i].dy);
      canvas.drawCircle(Offset.zero, _blobs[i].$1, _p[i]);
      canvas.restore();
    }
  }
}
