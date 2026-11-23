import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/astro.dart';
import '../core/client_data.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
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
                              SizedBox(width: 66, child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
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
            const Text('Pinch to zoom', style: TextStyle(fontSize: 11.5, color: CkColors.textMuted)),
            const Spacer(),
            Pressable(
              onTap: _pick,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: CkColors.orangeTint, borderRadius: BorderRadius.circular(20), border: Border.all(color: CkColors.orangeStroke)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFFFB27A)),
                  const SizedBox(width: 6),
                  Text(DateFormat('dd MMM yyyy · HH:mm').format(_at),
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFFFFB27A))),
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
                return const SizedBox(height: 360, child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)));
              }
              return Column(children: [
                Transform.scale(
                  scale: 1.06,
                  child: InteractiveViewer(minScale: 1, maxScale: 4, child: KundliChart(birth, transit: tr)),
                ),
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
                                    color: st == _step ? CkColors.orangeTint : CkColors.glassFill,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: st == _step ? CkColors.orangeStroke : CkColors.glassStroke),
                                  ),
                                  child: Text(_stepLabel[st]!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                          color: st == _step ? const Color(0xFFFFB27A) : CkColors.text)),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: Pressable(
                      onTap: () {
                        setState(() => _live = true);
                        _set(DateTime.now(), keepLive: true);
                        _startLive();
                      },
                      child: Glass(
                        height: 42,
                        radius: 21,
                        shadow: false,
                        alignment: Alignment.center,
                        stroke: _live ? const Color(0x8010B981) : CkColors.glassStroke,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.circle, size: 9, color: _live ? CkColors.green : CkColors.textMuted),
                          const SizedBox(width: 7),
                          const Text('Real time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Glass(
                      height: 42,
                      radius: 21,
                      shadow: false,
                      child: Row(children: [
                        Expanded(
                            child: IconButton(
                                tooltip: 'Back ${_stepLabel[_step]}',
                                onPressed: () => _set(_move(_at, _step, -1)),
                                icon: const Icon(Icons.chevron_left_rounded))),
                        Text(_stepLabel[_step]!, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Expanded(
                            child: IconButton(
                                tooltip: 'Forward ${_stepLabel[_step]}',
                                onPressed: () => _set(_move(_at, _step, 1)),
                                icon: const Icon(Icons.chevron_right_rounded))),
                      ]),
                    ),
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
          Text('${p.degIn.floor()}°', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          if (p.retro) const RetroBadge(),
        ]);

  @override
  Widget build(BuildContext context) => Glass(
        margin: const EdgeInsets.only(top: 12),
        radius: 24,
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          const CardTitle('GRAH Coordinates', Icons.table_chart_outlined),
          Row(children: [
            const SizedBox(width: 92, child: Text('GRAH', style: CkText.label)),
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
                  width: 92,
                  child: Row(children: [
                    GrahDot(id, size: 8),
                    const SizedBox(width: 7),
                    Flexible(child: Text(kGrahNames[id]!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
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
