import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Gesture arbitration for charts (Gestures family): one finger belongs to
/// the page (tap opens, swipe switches tabs, drag scrolls); two fingers
/// belong to the chart. The recognizer stays in the arena quietly with one
/// finger and claims the gesture the moment a second finger lands, before
/// the page's scroll can take it. Once zoomed in, one finger pans the chart.
class _PinchScale extends ScaleGestureRecognizer {
  _PinchScale({super.debugOwner, required this.zoomed});
  final bool Function() zoomed;
  int _down = 0;
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _down++;
    if (_down >= 2 || zoomed()) resolve(GestureDisposition.accepted);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _down = 0;
    super.didStopTrackingLastPointer(pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) _down = (_down - 1).clamp(0, 10);
    super.handleEvent(event);
  }

  @override
  String get debugDescription => 'pinch scale';
}

/// Pinch-zoom / pan chart that lives inside a scrolling page.
///
/// * Two fingers: zoom around the fingers' midpoint (1×–5×) and pan.
/// * One finger, zoomed in: pan the chart.
/// * One finger, not zoomed: the page's own gestures win (tap, swipe
///   between tabs, scroll).
/// * Long-press (not zoomed): an iPhone-style loupe follows the finger.
/// * Double-tap ([doubleTapZoom]): zoom to 2.5× at that point, or back to
///   fit. Off on cards that open a page on tap, so the tap is not delayed.
class ZoomChart extends StatefulWidget {
  final Widget child;
  final bool doubleTapZoom;
  const ZoomChart({super.key, required this.child, this.doubleTapZoom = true});

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
      _pinching = false;
    }
  }

  void _doubleTap() {
    HapticFeedback.lightImpact();
    if (_zoomed) {
      _animateTo(1, Offset.zero);
    } else {
      const s = 2.5;
      final c = Offset(_size.width / 2, _size.height / 2);
      _animateTo(s, -(_downPos - c) * (s - 1));
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
                _PinchScale: GestureRecognizerFactoryWithHandlers<_PinchScale>(
                  () => _PinchScale(debugOwner: this, zoomed: () => _zoomed),
                  (r) => r
                    ..onStart = _onStart
                    ..onUpdate = _onUpdate
                    ..onEnd = _onEnd,
                ),
                LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                  () => LongPressGestureRecognizer(debugOwner: this, duration: const Duration(milliseconds: 380)),
                  (r) => r
                    ..onLongPressStart = (d) {
                      if (_zoomed) return;
                      HapticFeedback.selectionClick();
                      setState(() => _loupe = d.localPosition);
                    }
                    ..onLongPressMoveUpdate = (d) {
                      if (_loupe == null) return;
                      setState(() => _loupe = Offset(d.localPosition.dx.clamp(0.0, _size.width), d.localPosition.dy.clamp(0.0, _size.height)));
                    }
                    ..onLongPressEnd = (_) => setState(() => _loupe = null),
                ),
                if (widget.doubleTapZoom)
                  DoubleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
                    () => DoubleTapGestureRecognizer(debugOwner: this),
                    (r) => r
                      ..onDoubleTapDown = ((d) => _downPos = d.localPosition)
                      ..onDoubleTap = _doubleTap,
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
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
        ]),
      );
    });
  }
}
