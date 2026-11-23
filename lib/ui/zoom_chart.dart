import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Claims every pointer that lands on the chart straight away, so the page's
/// ListView never steals a two-finger pinch. Page scrolling is not lost:
/// [ZoomChart] hands one-finger drags back to the parent scrollable itself.
class _EagerScale extends ScaleGestureRecognizer {
  _EagerScale({super.debugOwner});
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolvePointer(event.pointer, GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'eager scale';
}

/// Pinch-zoom / pan chart that lives inside a scrolling page.
///
/// * Two fingers: zoom around the fingers' midpoint (1×–5×) and pan.
/// * One finger, zoomed in: pan the chart.
/// * One finger, not zoomed: scrolls the page exactly like a normal drag,
///   with the same fling, because the drag is forwarded to the parent
///   [Scrollable]'s position.
/// * Long-press (not zoomed): an iPhone-style loupe follows the finger.
/// * Double-tap: zoom to 2.5× at that point, or back to fit.
class ZoomChart extends StatefulWidget {
  final Widget child;
  const ZoomChart({super.key, required this.child});

  @override
  State<ZoomChart> createState() => _ZoomChartState();
}

class _ZoomChartState extends State<ZoomChart> with SingleTickerProviderStateMixin {
  double _scale = 1;
  Offset _offset = Offset.zero; // translation in local pixels, applied after scaling
  Size _size = Size.zero;

  // gesture bookkeeping
  double _startScale = 1;
  Drag? _scroll;
  bool _pinching = false;
  Timer? _pressTimer;
  Offset _downPos = Offset.zero;
  double _moved = 0;
  Offset? _loupe; // local position while the loupe is shown
  DateTime _lastTap = DateTime(0);
  Offset _lastTapPos = Offset.zero;

  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  double _fromScale = 1, _toScale = 1;
  Offset _fromOffset = Offset.zero, _toOffset = Offset.zero;

  bool get _zoomed => _scale > 1.01;

  @override
  void initState() {
    super.initState();
    _anim.addListener(() {
      final t = Curves.easeOutCubic.transform(_anim.value);
      setState(() {
        _scale = _fromScale + (_toScale - _fromScale) * t;
        _offset = Offset.lerp(_fromOffset, _toOffset, t)!;
      });
    });
  }

  @override
  void dispose() {
    _pressTimer?.cancel();
    _endScroll(Velocity.zero);
    _anim.dispose();
    super.dispose();
  }

  void _animateTo(double scale, Offset offset) {
    _fromScale = _scale;
    _fromOffset = _offset;
    _toScale = scale;
    _toOffset = _clamp(offset, scale);
    _anim.forward(from: 0);
  }

  Offset _clamp(Offset o, double s) {
    final maxX = (_size.width * (s - 1)) / 2;
    final maxY = (_size.height * (s - 1)) / 2;
    return Offset(o.dx.clamp(-maxX, maxX), o.dy.clamp(-maxY, maxY));
  }

  // ---- scrolling the page with one finger ----
  void _scrollBy(ScaleUpdateDetails d) {
    final pos = Scrollable.maybeOf(context)?.position;
    if (pos == null) return;
    _scroll ??= pos.drag(
        DragStartDetails(globalPosition: d.focalPoint, localPosition: d.localFocalPoint),
        () => _scroll = null);
    final dy = d.focalPointDelta.dy;
    _scroll?.update(DragUpdateDetails(
        globalPosition: d.focalPoint, delta: Offset(0, dy), primaryDelta: dy));
  }

  void _endScroll(Velocity v) {
    final s = _scroll;
    _scroll = null;
    s?.end(DragEndDetails(
        velocity: Velocity(pixelsPerSecond: Offset(0, v.pixelsPerSecond.dy)),
        primaryVelocity: v.pixelsPerSecond.dy));
  }

  // ---- gesture callbacks ----
  void _onStart(ScaleStartDetails d) {
    _anim.stop();
    _startScale = _scale;
    _downPos = d.localFocalPoint;
    _moved = 0;
    _pinching = d.pointerCount >= 2;
    _pressTimer?.cancel();
    if (!_pinching && !_zoomed) {
      _pressTimer = Timer(const Duration(milliseconds: 380), () {
        if (_moved < 10 && !_pinching && mounted) {
          HapticFeedback.selectionClick();
          setState(() => _loupe = _downPos);
        }
      });
    }
  }

  void _onUpdate(ScaleUpdateDetails d) {
    _moved += d.focalPointDelta.distance;
    if (_moved > 10) _pressTimer?.cancel();

    if (_loupe != null) {
      setState(() => _loupe = Offset(
          d.localFocalPoint.dx.clamp(0.0, _size.width), d.localFocalPoint.dy.clamp(0.0, _size.height)));
      return;
    }

    if (d.pointerCount >= 2) {
      if (!_pinching) {
        // second finger arrived mid-gesture: stop scrolling, start zooming
        _pinching = true;
        _endScroll(Velocity.zero);
        _startScale = _scale / d.scale;
      }
      final newScale = (_startScale * d.scale).clamp(1.0, 5.0);
      // keep the content under the fingers' midpoint still while scaling
      final c = Offset(_size.width / 2, _size.height / 2);
      final focal = d.localFocalPoint - c;
      final k = newScale / _scale;
      final o = focal - (focal - _offset) * k + d.focalPointDelta;
      setState(() {
        _scale = newScale;
        _offset = _clamp(o, newScale);
      });
      return;
    }

    if (_zoomed) {
      setState(() => _offset = _clamp(_offset + d.focalPointDelta, _scale));
    } else if (!_pinching && _moved > 4) {
      _scrollBy(d);
    }
  }

  void _onEnd(ScaleEndDetails d) {
    _pressTimer?.cancel();
    if (_loupe != null) {
      setState(() => _loupe = null);
      return;
    }
    if (_scroll != null) {
      _endScroll(d.velocity);
    } else if (_zoomed && d.pointerCount == 0 && !_pinching) {
      // gentle inertia for panning
      final v = d.velocity.pixelsPerSecond;
      if (v.distance > 200) _animateTo(_scale, _offset + v * 0.12);
    }
    if (d.pointerCount == 0) {
      if (_scale < 1.05 && _scale != 1) _animateTo(1, Offset.zero);
      if (_moved < 8 && !_pinching) _maybeDoubleTap();
      _pinching = false;
    }
  }

  void _maybeDoubleTap() {
    final now = DateTime.now();
    final quick = now.difference(_lastTap) < const Duration(milliseconds: 300) &&
        (_downPos - _lastTapPos).distance < 40;
    if (quick) {
      _lastTap = DateTime(0);
      HapticFeedback.lightImpact();
      if (_zoomed) {
        _animateTo(1, Offset.zero);
      } else {
        const s = 2.5;
        final c = Offset(_size.width / 2, _size.height / 2);
        _animateTo(s, -(_downPos - c) * (s - 1));
      }
    } else {
      _lastTap = now;
      _lastTapPos = _downPos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      _size = Size(box.maxWidth, box.maxWidth);
      const loupeSize = 116.0;
      return SizedBox.fromSize(
        size: _size,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _EagerScale: GestureRecognizerFactoryWithHandlers<_EagerScale>(
                  () => _EagerScale(debugOwner: this),
                  (r) => r
                    ..onStart = _onStart
                    ..onUpdate = _onUpdate
                    ..onEnd = _onEnd,
                ),
              },
              child: ClipRect(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..scale(_scale, _scale),
                  child: RepaintBoundary(child: widget.child),
                ),
              ),
            ),
          ),
            if (_loupe != null)
              Positioned(
                left: _loupe!.dx - loupeSize / 2,
                top: _loupe!.dy - loupeSize - 34,
                child: IgnorePointer(
                  child: RawMagnifier(
                    size: const Size(loupeSize, loupeSize),
                    magnificationScale: 2.2,
                    focalPointOffset: const Offset(0, loupeSize / 2 + 34),
                    decoration: const MagnifierDecoration(
                      shape: CircleBorder(side: BorderSide(color: Color(0xCCFFFFFF), width: 1.5)),
                      shadows: [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
                    ),
                  ),
                ),
              ),
            if (_zoomed)
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: () => _animateTo(1, Offset.zero),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x99091A3A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x40FFFFFF)),
                    ),
                    child: Text('${(_scale * 10).round() / 10}×  Reset',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
        ]),
      );
    });
  }
}
