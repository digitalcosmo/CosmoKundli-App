import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Deep-space scene behind every page: navy depth, slowly turning orbit
/// rings, a large blue sphere and a small amber planet drifting, and a
/// twinkling starfield. Drawn once for the whole app (glass.dart CkSky).
///
/// Speed (Build 2): the scene moves so slowly that 30 updates a second look
/// the same as 120, so it updates on a 30 per second timer instead of
/// every screen refresh; between updates nothing is redrawn. On each update
/// it also makes [SkyFrost]: a small pre-blurred copy of the scene that
/// frosted cards show instead of blurring the screen live.
class CosmicBackground extends StatefulWidget {
  const CosmicBackground({super.key});
  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

/// The pre-blurred sky that frosted cards show (glass.dart). [scale] is its
/// size against the screen; it is blurred as a 14 px frost would be.
class SkyFrost {
  static final image = ValueNotifier<ui.Image?>(null);
  static const double scale = .25;
  static const double sigma = 24;
}

class _SkyTime extends ChangeNotifier {
  double v = 0; // 0..1 over 120 s
  double aura = 0; // 0..1 over 36 s
  void set(double a, double b) {
    v = a;
    aura = b;
    notifyListeners();
  }
}

class _CosmicBackgroundState extends State<CosmicBackground> with WidgetsBindingObserver {
  static final _clock = Stopwatch()..start();
  static double _phase(int periodMs) => (_clock.elapsedMilliseconds % periodMs) / periodMs;

  final _time = _SkyTime();
  static final List<_Star> _stars = _makeStars();
  late final _painter = _SpacePainter(_time, _stars, _AuraPainter(_time));
  Timer? _timer;
  Size? _size;

  static List<_Star> _makeStars() {
    final r = math.Random(11);
    return List.generate(
        90,
        (_) => _Star(r.nextDouble(), r.nextDouble(), .4 + r.nextDouble() * 1.1, r.nextDouble() * math.pi * 2,
            2 + r.nextInt(5)));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _time.set(_phase(120000), _phase(36000));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) => _sync();

  void _sync() {
    final still = !mounted || MediaQuery.of(context).disableAnimations;
    final awake = SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed ||
        SchedulerBinding.instance.lifecycleState == null;
    if (!still && awake) {
      _timer ??= Timer.periodic(const Duration(milliseconds: 33), (_) => _step());
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _step() {
    _time.set(_phase(120000), _phase(36000));
    _makeFrost();
  }

  /// Draws the scene small, blurred, into [SkyFrost.image].
  void _makeFrost() {
    final s = _size;
    if (s == null || s.isEmpty) return;
    const k = SkyFrost.scale;
    final w = (s.width * k).ceil(), h = (s.height * k).ceil();
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.saveLayer(
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
              sigmaX: SkyFrost.sigma * k, sigmaY: SkyFrost.sigma * k, tileMode: TileMode.clamp));
    c.scale(k);
    const _StaticSpacePainter().paint(c, s);
    _painter.paint(c, s);
    c.restore();
    final pic = rec.endRecording();
    final img = pic.toImageSync(w, h);
    pic.dispose();
    final old = SkyFrost.image.value;
    SkyFrost.image.value = img;
    old?.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size != _size) {
      _size = size;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _makeFrost();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
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
  final _SkyTime t;
  final List<_Star> stars;
  final _AuraPainter aura;
  _SpacePainter(this.t, this.stars, this.aura) : super(repaint: t);

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
    final v = t.v; // 0..1 over 120 s

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
  final _SkyTime t;
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
    final a = t.aura;
    final tri = a < .5 ? a * 2 : 2 - a * 2; // there and back
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
