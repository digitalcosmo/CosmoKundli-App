import 'dart:async';

import 'package:cosmo_kundali/ui/glass.dart';
import 'package:cosmo_kundali/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recorder.dart';

Widget cards(String tag, int n) => ListView(padding: const EdgeInsets.all(12), children: [
      for (var i = 0; i < n; i++)
        FadeSlideIn(
          index: i,
          child: Glass(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            child: SizedBox(height: 50, child: Row(children: [Text('$tag $i'), const Spacer(), Meter(value: .2 + i * .15, color: Colors.teal, index: i)].sublist(0, 2))),
          ),
        ),
    ]);

void main() {
  testWidgets('page push and back', (t) async {
    tolerateOverflow();
    await t.binding.setSurfaceSize(const Size(390, 420));
    final nav = GlobalKey<NavigatorState>();
    final s = Sheet('page_push_back');
    await t.pumpWidget(stage(Navigator(key: nav, onGenerateRoute: (_) => CkRoute(builder: (_) => cards('Home', 5))), size: const Size(390, 420)));
    await s.play(t, 'first', 600, step: 150);
    nav.currentState!.push(CkRoute(builder: (_) => cards('Detail', 5)));
    await s.play(t, 'push', 900, step: 100);
    nav.currentState!.pop();
    await s.play(t, 'back', 900, step: 100);
    await t.runAsync(s.save);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 3));
  });

  testWidgets('skeleton then data, then refresh', (t) async {
    tolerateOverflow();
    await t.binding.setSurfaceSize(const Size(390, 300));
    final s = Sheet('skeleton_data');
    var c = Completer<int>();
    final k = GlobalKey<_FState>();
    await t.pumpWidget(stage(_F(key: k, f: c.future), size: const Size(390, 300)));
    await s.play(t, 'loading', 450, step: 150);
    c.complete(1);
    await s.play(t, 'data', 900, step: 150);
    c = Completer<int>();
    k.currentState!.set(c.future);
    await s.play(t, 'refresh', 300, step: 150);
    c.complete(2);
    await s.play(t, 'refreshed', 600, step: 150);
    await t.runAsync(s.save);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 3));
  });
}

class _F extends StatefulWidget {
  final Future<int> f;
  const _F({super.key, required this.f});
  @override
  State<_F> createState() => _FState();
}

class _FState extends State<_F> {
  late Future<int> f = widget.f;
  void set(Future<int> n) => setState(() {
        f = n;
      });
  @override
  Widget build(BuildContext context) => FastFuture<int>(
        future: f,
        loading: Skels.table(3),
        builder: (d) => cards('Data v$d', 3),
      );
}
