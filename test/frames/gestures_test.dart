// Gestures family: one finger is the page's (tap opens, swipe switches
// tabs), two fingers are the chart's (zoom).
import 'package:cosmo_kundali/ui/zoom_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({required VoidCallback onTap, PageController? pc}) => MaterialApp(
        home: Scaffold(
          body: PageView(controller: pc, children: [
            Center(
              child: GestureDetector(
                onTap: onTap,
                child: SizedBox(width: 300, child: ZoomChart(doubleTapZoom: false, child: Container(color: Colors.blue))),
              ),
            ),
            const Center(child: Text('page 2')),
          ]),
        ),
      );

  testWidgets('a single tap on a chart card opens it', (t) async {
    var taps = 0;
    await t.pumpWidget(host(onTap: () => taps++));
    await t.tapAt(const Offset(400, 300));
    await t.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('a one-finger swipe on a chart switches the tab', (t) async {
    final pc = PageController();
    await t.pumpWidget(host(onTap: () {}, pc: pc));
    await t.flingFrom(const Offset(500, 300), const Offset(-300, 0), 1500);
    await t.pumpAndSettle();
    expect(pc.page, 1);
  });

  testWidgets('two fingers zoom the chart instead of swiping', (t) async {
    final pc = PageController();
    await t.pumpWidget(host(onTap: () {}, pc: pc));
    final a = await t.startGesture(const Offset(380, 300), pointer: 1);
    final b = await t.startGesture(const Offset(420, 300), pointer: 2);
    for (var i = 0; i < 10; i++) {
      await a.moveBy(const Offset(-8, 0));
      await b.moveBy(const Offset(8, 0));
      await t.pump(const Duration(milliseconds: 16));
    }
    await a.up();
    await b.up();
    await t.pumpAndSettle();
    expect(pc.page, 0);
    expect(find.textContaining('Reset'), findsOneWidget);
  });
}
