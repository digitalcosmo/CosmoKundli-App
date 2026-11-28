// Frame recorder: plays a widget over time and saves a contact sheet of
// frames, so motion, colour timing, skeletons and blur can be reviewed
// frame by frame without a phone. Run: flutter test test/frames
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final _key = GlobalKey();

/// Overflow warnings are recorded (the test font is wider than the app's),
/// not treated as failures; anything else still fails.
final overflows = <String>[];
void tolerateOverflow() {
  final prev = FlutterError.onError;
  FlutterError.onError = (d) {
    final m = d.exceptionAsString();
    if (m.contains('overflowed')) {
      overflows.add(m);
      return;
    }
    prev?.call(d);
  };
}

Widget stage(Widget child, {Size size = const Size(390, 300)}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Material(type: MaterialType.transparency, child: RepaintBoundary(
        key: _key,
        child: Container(
          color: const Color(0xFF070B1E),
          alignment: Alignment.topLeft,
          child: SizedBox(width: size.width, height: size.height, child: child),
        ),
      ),
    ));

class Sheet {
  final String name;
  final List<(String, ui.Image)> frames = [];
  Sheet(this.name);

  Future<void> grab(WidgetTester t, String label) async {
    final b = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await t.runAsync(() => b.toImage(pixelRatio: 1));
    frames.add((label, img!));
  }

  /// pump [ms] in [step] ms steps, grabbing a frame at each step
  Future<void> play(WidgetTester t, String tag, int ms, {int step = 100}) async {
    for (var at = 0; at <= ms; at += step) {
      if (at > 0) await t.pump(Duration(milliseconds: step));
      await grab(t, '$tag ${at}ms');
    }
  }

  Future<void> save() async {
    if (frames.isEmpty) return;
    final w = frames.first.$2.width, h = frames.first.$2.height;
    const cols = 4, lab = 18;
    final rows = (frames.length / cols).ceil();
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.drawRect(Rect.fromLTWH(0, 0, cols * (w + 6.0), rows * (h + lab + 6.0)), Paint()..color = Colors.black);
    for (var i = 0; i < frames.length; i++) {
      final x = (i % cols) * (w + 6.0), y = (i ~/ cols) * (h + lab + 6.0);
      c.drawImage(frames[i].$2, Offset(x, y + lab), Paint());
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 12))
        ..pushStyle(ui.TextStyle(color: Colors.yellow))
        ..addText(frames[i].$1);
      final p = pb.build()..layout(ui.ParagraphConstraints(width: w.toDouble()));
      c.drawParagraph(p, Offset(x + 2, y + 2));
    }
    final pic = rec.endRecording();
    final out = await pic.toImage(cols * (w + 6), rows * (h + lab + 6));
    final bytes = await out.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/frames')..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  }
}
