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

class _CosmicBackgroundState extends State<CosmicBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
  static final List<_Star> _stars = _makeStars();

  static List<_Star> _makeStars() {
    final r = math.Random(11);
    return List.generate(
        90,
        (_) => _Star(r.nextDouble(), r.nextDouble(), .4 + r.nextDouble() * 1.1, r.nextDouble() * math.pi * 2,
            2 + r.nextInt(5)));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    if (still && _c.isAnimating) _c.stop();
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SpacePainter(_c, _stars),
        size: Size.infinite,
        isComplex: true,
      ),
    );
  }
}

class _Star {
  final double x, y, r, phase;
  final int speed; // twinkles per 120 s cycle
  const _Star(this.x, this.y, this.r, this.phase, this.speed);
}

class _SpacePainter extends CustomPainter {
  final Animation<double> t;
  final List<_Star> stars;
  _SpacePainter(this.t, this.stars) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size s) {
    final v = t.value; // 0..1 over 120 s
    final rect = Offset.zero & s;
    canvas.drawRect(
        rect,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-.6, -1.0),
            radius: 1.5,
            colors: [Color(0xFF2159B8), Color(0xFF15408F), Color(0xFF0C2C68), Color(0xFF09214F)],
            stops: [0, .38, .72, 1],
          ).createShader(rect));

    // soft blue nebula glow
    canvas.drawCircle(Offset(s.width * .05, s.height * .25), s.width * .55,
        Paint()..shader = RadialGradient(colors: [const Color(0x441E5BD8), const Color(0x001E5BD8)])
            .createShader(Rect.fromCircle(center: Offset(s.width * .05, s.height * .25), radius: s.width * .55)));

    // orbit rings, slowly turning
    final c = Offset(s.width * .5, s.height * .62);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(v * 2 * math.pi);
    for (final (rx, ry, a) in [(1.15, .44, .22), (.85, .31, .14), (.56, .2, .2)]) {
      ring.color = Color.fromRGBO(150, 190, 255, a);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s.width * rx * 2, height: s.width * ry * 2), ring);
    }
    canvas.drawCircle(Offset(s.width * 1.15, 0), 3.5, Paint()..color = const Color(0xFF9EC2FF));
    canvas.drawCircle(Offset(-s.width * .85, 0), 2.5, Paint()..color = const Color(0xFFF5B66B));
    canvas.restore();

    // large blue sphere, gently bobbing
    final bob = math.sin(v * 2 * math.pi * 6) * 8;
    final pc = Offset(s.width * .02, s.height * .84 + bob);
    final pr = s.width * .24;
    canvas.drawCircle(pc, pr * 1.25,
        Paint()..shader = RadialGradient(colors: [const Color(0x334C8DFF), const Color(0x004C8DFF)])
            .createShader(Rect.fromCircle(center: pc, radius: pr * 1.25)));
    canvas.drawCircle(
        pc,
        pr,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-.36, -.4),
            colors: [Color(0xFF5C8DF0), Color(0xFF2349A8), Color(0xFF0D2464), Color(0xFF061538)],
            stops: [0, .3, .62, 1],
          ).createShader(Rect.fromCircle(center: pc, radius: pr)));

    // small amber planet
    final sc = Offset(s.width * .88, s.height * .28 - bob * .6);
    canvas.drawCircle(sc, 22,
        Paint()..shader = RadialGradient(colors: [const Color(0x55F07E22), const Color(0x00F07E22)])
            .createShader(Rect.fromCircle(center: sc, radius: 22)));
    canvas.drawCircle(
        sc,
        11,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-.3, -.4),
            colors: [Color(0xFFFFD7A8), Color(0xFFF07E22), Color(0xFF7A3208)],
            stops: [0, .45, 1],
          ).createShader(Rect.fromCircle(center: sc, radius: 11)));

    // twinkling stars
    final star = Paint();
    for (final st in stars) {
      final tw = .2 + .8 * (.5 + .5 * math.sin(v * 2 * math.pi * st.speed * 10 + st.phase));
      star.color = Color.fromRGBO(255, 255, 255, tw * .85);
      canvas.drawCircle(Offset(st.x * s.width, st.y * s.height), st.r, star);
    }
  }

  @override
  bool shouldRepaint(_SpacePainter old) => false;
}
