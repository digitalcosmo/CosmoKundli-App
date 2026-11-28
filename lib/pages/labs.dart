import 'dart:developer' show Timeline;
import 'dart:ui' show FramePhase, FrameTiming;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/widgets.dart';
import 'app_shell.dart' show appTabRequest;
import 'client_shell.dart' show clientTabRequest;
import 'clients_page.dart' show openClient;

/// Adds the speed lab to the hidden speed sheet (long-press "Log out").
void registerLabs() {
  if (perfLabs.isNotEmpty) return;
  perfLabs.add(('Speed lab: measure frames', (c) => runSpeedLab()));
}

// ───────────────────────── Speed lab

class _Result {
  final String name;
  final bool allOff;
  final List<FrameTiming> frames;
  _Result(this.name, this.allOff, this.frames);

  List<double> _ms(Duration Function(FrameTiming) f) =>
      [for (final t in frames) f(t).inMicroseconds / 1000]..sort();
  static double _avg(List<double> l) => l.isEmpty ? 0 : l.reduce((a, b) => a + b) / l.length;
  static double _p90(List<double> l) => l.isEmpty ? 0 : l[((l.length - 1) * .9).round()];

  String line(double budget) {
    final r = _ms((t) => t.rasterDuration);
    final b = _ms((t) => t.buildDuration);
    final slow = frames.where((t) => t.totalSpan.inMicroseconds / 1000 > budget).length;
    String f(double v) => v.toStringAsFixed(1);
    return 'draw ${f(_avg(r))} / ${f(_p90(r))} / ${f(r.isEmpty ? 0 : r.last)}   '
        'build ${f(_avg(b))} / ${f(b.isEmpty ? 0 : b.last)}   '
        'slow $slow of ${frames.length}';
  }
}

bool _labRunning = false;

/// Runs fixed scenarios by itself, first with every effect on and then
/// with every effect off, and shows the frame times of each.
Future<void> runSpeedLab() async {
  if (_labRunning) return;
  _labRunning = true;
  final all = <FrameTiming>[];
  void collect(List<FrameTiming> l) => all.addAll(l);
  SchedulerBinding.instance.addTimingsCallback(collect);
  Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));
  final saved = perfFlags.value;
  final results = <_Result>[];

  Future<void> measure(String name, bool off, Future<void> Function() act) async {
    final from = Timeline.now;
    await act();
    final to = Timeline.now;
    // frame times arrive in batches about once a second
    await wait(1200);
    results.add(_Result(name, off, [
      for (final t in all)
        if (t.timestampInMicroseconds(FramePhase.vsyncStart) >= from &&
            t.timestampInMicroseconds(FramePhase.vsyncStart) <= to)
          t
    ]));
  }

  try {
    Get.until((r) => r.isFirst);
    await wait(900);
    for (final off in [false, true]) {
      perfFlags.value = off ? 63 : 0;
      await WidgetsBinding.instance.reassembleApplication();
      await wait(1200);
      await measure('Main tabs', off, () async {
        for (final i in [1, 2, 3, 0]) {
          appTabRequest.value = i;
          await wait(900);
        }
      });
      final recent = Session.recent;
      if (recent.isNotEmpty) {
        await measure('Open a client', off, () async {
          openClient(recent.first);
          await wait(1500);
        });
        await measure('Client tabs', off, () async {
          for (final i in [1, 2, 0]) {
            clientTabRequest.value = i;
            await wait(900);
          }
        });
        await measure('Back to main', off, () async {
          Get.back();
          await wait(1200);
        });
      }
      await measure('Standing still', off, () => wait(2000));
    }
  } finally {
    SchedulerBinding.instance.removeTimingsCallback(collect);
    perfFlags.value = saved;
    await WidgetsBinding.instance.reassembleApplication();
    _labRunning = false;
  }
  final ctx = Get.context;
  if (ctx == null || !ctx.mounted) return;
  final displays = WidgetsBinding.instance.platformDispatcher.displays;
  final hz = displays.isEmpty ? 60.0 : displays.first.refreshRate;
  final budget = 1000 / (hz <= 0 ? 60 : hz);
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: const Color(0xF2101634),
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Speed lab', style: CkText.h(18)),
            const SizedBox(height: 4),
            Text('Screen ${hz.round()} Hz, budget ${budget.toStringAsFixed(1)} ms a frame. '
                'Draw: average / 90% / worst ms. Please send a screenshot.',
                style: CkText.muted),
            for (final off in [false, true]) ...[
              const SizedBox(height: 14),
              Text(off ? 'EVERY EFFECT OFF' : 'EVERY EFFECT ON', style: CkText.label),
              for (final r in results.where((r) => r.allOff == off)) ...[
                const SizedBox(height: 8),
                Text(r.name, style: CkText.h(13.5)),
                Text(r.line(budget), style: CkText.mono(11, color: CkColors.textSecondary)),
              ],
            ],
            if (Session.recent.isEmpty) ...[
              const SizedBox(height: 12),
              const Text('Open any client once, then run it again to include the client steps.', style: CkText.muted),
            ],
          ]),
        ),
      ),
    ),
  );
}
