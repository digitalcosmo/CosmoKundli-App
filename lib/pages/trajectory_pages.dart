import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/astro.dart';
import '../core/client_data.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import '../ui/zoom_chart.dart';
import 'blueprint_pages.dart';
import 'client_shell.dart';

ClientData get _data => ClientData.of(Session.client.value?.mId ?? '');

class TrajectorySection extends StatefulWidget {
  const TrajectorySection({super.key});
  @override
  State<TrajectorySection> createState() => _TrajectorySectionState();
}

class _TrajectorySectionState extends State<TrajectorySection> {
  late Future<List<GrahPos>> _now = _data.transit(DateTime.now());

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Trajectory',
        isRoot: true,
        onRefresh: () async {
          setState(() => _now = _data.transit(DateTime.now()));
          await _now;
        },
        children: [
          const SectionIntro('How the GRAH are moving for this client'),
          ModuleCard(
            title: 'Transit',
            description: 'Today\'s GRAH over the birth chart',
            icon: Icons.track_changes_rounded,
            onTap: () => pushModule(context, const TransitPage()),
            preview: FutureBuilder<List<GrahPos>>(
              future: _now,
              builder: (c, s) {
                final l = (s.data ?? []).where((p) => ['Sa', 'Ju', 'Ra'].contains(p.id)).toList();
                if (l.isEmpty) return const SizedBox(height: 4);
                return Column(
                  children: l
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(children: [
                              GrahDot(p.id, size: 8),
                              const SizedBox(width: 8),
                              SizedBox(width: 66, child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                              Text('${rashiName(p.rashi)} ${fmtDeg(p.degIn)}', style: const TextStyle(fontSize: 12.5, color: CkColors.textSecondary)),
                              if (p.retro) const RetroBadge(),
                            ]),
                          ))
                      .toList(),
                );
              },
            ),
          ),
          const ModuleCard(index: 1, comingSoon: true, title: 'GRAH Vibes Weekly', description: 'Week-by-week vibe of each GRAH', icon: Icons.graphic_eq_rounded),
          const ModuleCard(index: 2, comingSoon: true, title: 'GRAH Vibes Monthly', description: 'Month-by-month vibe of each GRAH', icon: Icons.graphic_eq_rounded),
          const ModuleCard(index: 3, comingSoon: true, title: 'GRAH Trigger', description: 'Trigger points', icon: Icons.adjust_rounded),
        ],
      );
}

enum _Step { h1, d1, w1, m1, y1, y10 }

const _stepLabel = {_Step.h1: '1H', _Step.d1: '1D', _Step.w1: '1W', _Step.m1: '1M', _Step.y1: '1Y', _Step.y10: '10Y'};

DateTime _move(DateTime t, _Step s, int dir) {
  switch (s) {
    case _Step.h1:
      return t.add(Duration(hours: dir));
    case _Step.d1:
      return t.add(Duration(days: dir));
    case _Step.w1:
      return t.add(Duration(days: 7 * dir));
    case _Step.m1:
      return DateTime(t.year, t.month + dir, t.day, t.hour, t.minute);
    case _Step.y1:
      return DateTime(t.year + dir, t.month, t.day, t.hour, t.minute);
    case _Step.y10:
      return DateTime(t.year + 10 * dir, t.month, t.day, t.hour, t.minute);
  }
}

class TransitPage extends StatefulWidget {
  const TransitPage({super.key});
  @override
  State<TransitPage> createState() => _TransitPageState();
}

class _TransitPageState extends State<TransitPage> {
  final _birth = _data.chart();
  DateTime _at = DateTime.now();
  _Step _step = _Step.d1;
  bool _live = true;
  Timer? _timer;
  late Future<List<GrahPos>> _transit = _data.transit(_at);
  List<GrahPos>? _last;

  @override
  void initState() {
    super.initState();
    _startLive();
  }

  void _startLive() {
    _timer?.cancel();
    if (_live) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _set(DateTime.now(), keepLive: true));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _set(DateTime t, {bool keepLive = false}) {
    setState(() {
      _at = t;
      if (!keepLive) _live = false;
      _transit = _data.transit(t)..then((v) => _last = v);
    });
    if (!keepLive) _timer?.cancel();
  }

  Future<void> _pick() async {
    final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(1900), lastDate: DateTime(2200));
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    _set(DateTime(d.year, d.month, d.day, t?.hour ?? _at.hour, t?.minute ?? _at.minute));
  }

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Transit',
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 120),
        children: [
          Row(children: [
            Expanded(
              child: Pressable(
                onTap: _pick,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(12), border: Border.all(color: CkColors.cyanStroke)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 15, color: CkColors.cyan),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd-MM-yyyy · HH:mm').format(_at), style: CkText.mono(13)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Pressable(
              onTap: () {
                setState(() => _live = true);
                _set(DateTime.now(), keepLive: true);
                _startLive();
              },
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _live ? CkColors.cyanTint : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _live ? CkColors.cyanStroke : CkColors.panelStroke),
                ),
                child: Row(children: [
                  Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: _live ? CkColors.cyan : CkColors.labelMono)),
                  const SizedBox(width: 6),
                  Text('LIVE', style: CkText.mono(12, color: _live ? Colors.white : CkColors.textSecondary)),
                ]),
              ),
            ),
          ]),
          FutureBuilder<List<dynamic>>(
            future: Future.wait([_birth, _transit]),
            builder: (c, s) {
              final birth = s.hasData ? s.data![0] as List<GrahPos> : null;
              final tr = s.hasData ? s.data![1] as List<GrahPos> : _last;
              if (s.hasError) return ErrorBox(message: 'Couldn\'t load the transit.', onRetry: () => _set(_at, keepLive: _live));
              if (birth == null || tr == null) {
                return const SkeletonCard(height: 360);
              }
              return Column(children: [
                // Full-bleed: the chart breaks out of the page padding and
                // uses the screen width minus a small safe margin.
                LayoutBuilder(builder: (ctx, box) {
                  final w = MediaQuery.of(ctx).size.width - 8;
                  return SizedBox(
                    height: w,
                    child: OverflowBox(
                      minWidth: w, maxWidth: w, minHeight: w, maxHeight: w,
                      child: ZoomChart(child: KundliChart(birth, transit: tr)),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Row(
                  children: _Step.values
                      .map((st) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.5),
                              child: Pressable(
                                onTap: () => setState(() => _step = st),
                                child: AnimatedContainer(
                                  duration: CkMotion.fast,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: st == _step ? CkColors.cyanTint : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: st == _step ? CkColors.cyanStroke : CkColors.panelStroke),
                                  ),
                                  child: Text(_stepLabel[st]!,
                                      style: CkText.mono(12, color: st == _step ? Colors.white : CkColors.textSecondary)),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Pressable(
                    onTap: () => _set(_move(_at, _step, -1)),
                    child: const Glass(width: 64, height: 40, radius: 12, alignment: Alignment.center, child: Icon(Icons.chevron_left_rounded, size: 22)),
                  ),
                  const SizedBox(width: 8),
                  Pressable(
                    onTap: () => _set(_move(_at, _step, 1)),
                    child: const Glass(width: 64, height: 40, radius: 12, alignment: Alignment.center, child: Icon(Icons.chevron_right_rounded, size: 22)),
                  ),
                ]),
                _CoordTable(birth: birth, transit: tr),
              ]);
            },
          ),
        ],
      );
}

class _CoordTable extends StatelessWidget {
  final List<GrahPos> birth;
  final List<GrahPos> transit;
  const _CoordTable({required this.birth, required this.transit});

  Widget _pos(GrahPos? p) => p == null
      ? const Text('—')
      : Row(children: [
          Flexible(child: Text(rashiName(p.rashi), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
          const SizedBox(width: 5),
          Text(fmtDeg(p.degIn), style: CkText.mono(12.5)),
          if (p.retro) const RetroBadge(),
        ]);

  @override
  Widget build(BuildContext context) => Glass(
        margin: const EdgeInsets.only(top: 12),
        radius: 18,
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          const CardTitle('GRAH Coordinates', Icons.table_chart_outlined),
          Row(children: [
            const SizedBox(width: 58, child: Text('GRAH', style: CkText.label)),
            const Expanded(child: Text('COSMOKUNDLI', style: CkText.label)),
            Expanded(child: Text('TRANSIT', style: CkText.label.copyWith(color: const Color(0xFFFFB27A)))),
          ]),
          const SizedBox(height: 6),
          ...kGrahOrder.map((id) {
            GrahPos? b, t;
            for (final p in birth) {
              if (p.id == id) b = p;
            }
            for (final p in transit) {
              if (p.id == id) t = p;
            }
            if (b == null && t == null) return const SizedBox();
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x14FFFFFF)))),
              child: Row(children: [
                SizedBox(
                  width: 58,
                  child: Row(children: [
                    GrahDot(id, size: 8),
                    const SizedBox(width: 7),
                    Flexible(child: Text(id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  ]),
                ),
                Expanded(child: _pos(b)),
                Expanded(child: _pos(t)),
              ]),
            );
          }),
          const SizedBox(height: 6),
          const Row(children: [
            RetroBadge(),
            SizedBox(width: 6),
            Text('Retrograde (vakri)', style: TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
          ]),
        ]),
      );
}
