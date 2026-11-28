import 'package:cosmo_kundali/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recorder.dart';

List<DayValue> days(List<double?> v) => [for (var i = 0; i < v.length; i++) DayValue(DateTime(2026, 11, 1 + i), v[i])];

class _Host extends StatefulWidget {
  final Widget Function(int phase) build;
  const _Host(this.build, {super.key});
  @override
  State<_Host> createState() => HostState();
}

class HostState extends State<_Host> {
  int phase = 0;
  void next() => setState(() => phase++);
  @override
  Widget build(BuildContext context) => widget.build(phase);
}

Future<void> run(WidgetTester t, String name, Widget Function(int) b, List<(String, int)> phases, {Size size = const Size(390, 300)}) async {
  tolerateOverflow();
  await t.binding.setSurfaceSize(Size(size.width, size.height));
  final k = GlobalKey<HostState>();
  final s = Sheet(name);
  await t.pumpWidget(stage(_Host(b, key: k), size: size));
  for (var i = 0; i < phases.length; i++) {
    if (i > 0) {
      k.currentState!.next();
    }
    await s.play(t, phases[i].$1, phases[i].$2, step: 150);
  }
  await t.runAsync(s.save);
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 3));
}

void main() {
  testWidgets('sentiments bars', (t) async {
    final List<double?> a = [40, -30, 70, 10, -60, 25, 55], b = [-20, 50, 10, 80, 30, -40, 5], z = List.filled(7, null);
    await run(t, 'sentiments', (p) => DailyBarChart(days: days(p == 0 ? z : p == 1 ? a : p == 2 ? b : z), signed: true, today: 3),
        [('loading', 300), ('data', 1500), ('new period', 1200), ('reload', 600)]);
  });
  testWidgets('situations bars', (t) async {
    final List<double?> a = [20, 90, 50, 66, 10, 40, 75], b = [80, 15, 60, 30, 95, 45, 5], z = List.filled(7, null);
    await run(t, 'situations', (p) => DailyBarChart(days: days(p == 0 ? z : p == 1 ? a : b), signed: false, today: 3),
        [('loading', 300), ('data', 1500), ('new period', 1200)]);
  });
  testWidgets('power flavor', (t) async {
    const ids = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn'];
    final List<double?> a = [60, 40, 80, 20, 70, 50, 30], b = [30, null, 50, 90, null, 20, 60];
    await run(t, 'power', (p) => GrahBarChart(values: [for (var i = 0; i < ids.length; i++) MapEntry(ids[i], (p == 0 ? a : b)[i])], height: 260),
        [('power', 1500), ('flavor', 1500)]);
  });
  testWidgets('meters', (t) async {
    await run(t, 'meters', (p) => Column(children: [
          for (var i = 0; i < 4; i++) Padding(padding: const EdgeInsets.all(8), child: Row(children: [
                Expanded(child: Meter(value: p == 0 ? [.2, .5, .8, .35][i] : [.9, .1, .4, .6][i], color: [Colors.teal, Colors.amber, Colors.pink, Colors.blue][i], index: i)),
                SizedBox(width: 60, child: StatText('${p == 0 ? [20, 50, 80, 35][i] : [90, 10, 40, 60][i]}%', index: i)),
              ])),
        ]), [('first', 1500), ('change', 1300)], size: const Size(390, 200));
  });
}
