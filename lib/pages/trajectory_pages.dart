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
import 'clients_page.dart';

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
            preview: DataBuilder<List<GrahPos>>(
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

/// Client Transit: the same screen as the Transit tool, opened with this
/// client already chosen.
class TransitPage extends StatelessWidget {
  const TransitPage({super.key});
  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Transit',
        children: [TransitBody(client: Session.client.value, lockClient: true)],
      );
}

/// Transit controls, chart and table, shared by the Transit tool (no client,
/// optional compare) and a client's Transit page (client fixed).
class TransitBody extends StatefulWidget {
  final Client? client;
  final bool lockClient;
  final String? subtitleHint;
  final Future<Client?> Function()? source; // mID used for the sky when no client
  final ValueChanged<String>? onSubtitle;
  const TransitBody({super.key, this.client, this.lockClient = false, this.subtitleHint, this.source, this.onSubtitle});
  @override
  State<TransitBody> createState() => TransitBodyState();
}

class TransitBodyState extends State<TransitBody> {
  DateTime _at = DateTime.now();
  _Step _step = _Step.d1;
  bool _live = true;
  Timer? _timer;
  Client? _cmp;
  String? _srcId;
  Future<List<GrahPos>>? _transit;
  Future<List<GrahPos>>? _birth;
  List<GrahPos>? _last;

  DateTime get at => _at;

  @override
  void initState() {
    super.initState();
    _cmp = widget.client;
    if (_cmp != null) {
      _srcId = _cmp!.mId;
      _birth = ClientData.of(_cmp!.mId).chart();
      _load();
    } else if (widget.source != null) {
      widget.source!().then((c) {
        if (!mounted || c == null) return;
        setState(() {
          _srcId = c.mId;
          _load();
        });
      });
    }
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_live && mounted) _set(DateTime.now(), live: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _load() {
    if (_srcId == null) return;
    _transit = ClientData.of(_srcId!).transit(_at)..then((v) => _last = v).catchError((_) => <GrahPos>[]);
  }

  void _set(DateTime t, {bool live = false}) => setState(() {
        _at = t;
        _live = live;
        _load();
      });

  Future<void> pickTime() async {
    final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(1900), lastDate: DateTime(2200));
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    _set(DateTime(d.year, d.month, d.day, t?.hour ?? _at.hour, t?.minute ?? _at.minute));
  }

  Future<void> _compare() async {
    final c = await pickClientSheet(context);
    if (c == null || !mounted) return;
    setState(() {
      _cmp = c;
      _birth = ClientData.of(c.mId).chart();
    });
  }

  String get whenText {
    final now = DateTime.now();
    final same = _at.year == now.year && _at.month == now.month && _at.day == now.day;
    return '${same ? 'Today' : DateFormat('d MMM yyyy').format(_at)} · ${DateFormat('HH:mm').format(_at)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
          child: Text(_cmp == null ? 'Sky now' : 'With ${_cmp!.name}\'s chart',
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, color: CkColors.textSecondary)),
        ),
        Pressable(
          onTap: pickTime,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: CkColors.orangeTint, borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.orangeStroke)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFFFD08A)),
              const SizedBox(width: 6),
              Text(whenText, style: CkText.mono(12, color: const Color(0xFFFFD08A))),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      DataBuilder<List<dynamic>>(
        future: Future.wait<List<GrahPos>>([_transit ?? Future.value(<GrahPos>[]), _birth ?? Future.value(<GrahPos>[])]),
        builder: (c, s) {
          if (_srcId == null) {
            return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Add a client first to read the sky.', style: CkText.muted)));
          }
          final t = s.hasData ? s.data![0] as List<GrahPos> : _last;
          final birth = s.hasData ? s.data![1] as List<GrahPos> : const <GrahPos>[];
          if (t == null || (t.isEmpty && !s.hasData)) return const SkeletonCard(height: 340);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            RepaintBoundary(
              child: Glass(
                frost: false,
                padding: const EdgeInsets.all(6),
                child: Stack(children: [
                  ZoomChart(child: KundliChart(birth, transit: t)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              for (final st in _Step.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Pressable(
                      onTap: () => setState(() => _step = st),
                      child: AnimatedContainer(
                        duration: CkMotion.fast,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _step == st ? CkColors.orangeTint : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: _step == st ? CkColors.orangeStroke : CkColors.panelStroke),
                        ),
                        child: Text(_stepLabel[st]!, style: CkText.mono(12.5, color: _step == st ? const Color(0xFFFFD08A) : CkColors.textTertiary)),
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Pressable(
                  onTap: () => _set(DateTime.now(), live: true),
                  child: Glass(
                    frost: false,
                    height: 46,
                    radius: 13,
                    alignment: Alignment.center,
                    stroke: _live ? const Color(0x8010B981) : CkColors.panelStroke,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _live ? const Color(0xFF10B981) : CkColors.labelMono,
                          boxShadow: _live ? const [BoxShadow(color: Color(0xFF10B981), blurRadius: 8)] : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Real time', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Glass(
                  frost: false,
                  height: 46,
                  radius: 13,
                  child: Row(children: [
                    IconButton(onPressed: () => _set(_move(_at, _step, -1)), icon: const Icon(Icons.chevron_left_rounded), tooltip: 'Step back'),
                    Expanded(child: Text('STEP ${_stepLabel[_step]}', textAlign: TextAlign.center, style: CkText.mono(12, color: CkColors.textSecondary))),
                    IconButton(onPressed: () => _set(_move(_at, _step, 1)), icon: const Icon(Icons.chevron_right_rounded), tooltip: 'Step forward'),
                  ]),
                ),
              ),
            ]),
            if (!widget.lockClient) ...[
              const SizedBox(height: 10),
              Pressable(
                onTap: _compare,
                child: Glass(
                  stroke: _cmp == null ? CkColors.panelStroke : CkColors.cyanStroke,
                  padding: EdgeInsets.fromLTRB(14, _cmp == null ? 12 : 8, _cmp == null ? 14 : 8, _cmp == null ? 12 : 8),
                  child: Row(children: [
                    const Icon(Icons.people_outline_rounded, size: 19, color: CkColors.cyan),
                    const SizedBox(width: 10),
                    if (_cmp == null) ...[
                      const Expanded(child: Text('Compare with a client', style: TextStyle(fontSize: 14))),
                      const Text('Choose ▾', style: TextStyle(fontSize: 12.5, color: CkColors.textSecondary)),
                    ] else ...[
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_cmp!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(_cmp!.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.mono(11, color: CkColors.textSecondary)),
                        ]),
                      ),
                      Pressable(
                        onTap: () => openClient(_cmp!),
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.cyanStroke)),
                          child: const Text('Open client', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Semantics(
                        button: true,
                        label: 'Remove client',
                        child: Pressable(
                          onTap: () => setState(() {
                            _cmp = null;
                            _birth = null;
                          }),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.panelStroke)),
                            child: const Icon(Icons.close_rounded, size: 17, color: CkColors.textTertiary),
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
            CoordTable(birth: birth, transit: t),
          ]);
        },
      ),
    ]);
  }
}

/// Compare: the shared client picker (kit).
Future<Client?> pickClientSheet(BuildContext context) =>
    pickClient(context, title: 'Compare with a client', subtitle: 'Transits over their birth chart');

class CoordTable extends StatelessWidget {
  final List<GrahPos> birth;
  final List<GrahPos> transit;
  const CoordTable({super.key, required this.birth, required this.transit});

  Widget _cell(GrahPos? p, {bool tr = false}) => p == null
      ? const Text('—', style: TextStyle(color: CkColors.textDim))
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rashiName(p.rashi), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: tr ? const Color(0xFFFFD08A) : CkColors.textSecondary)),
          const SizedBox(height: 4),
          Row(children: [
            Text(fmtDegMin(p.degIn), style: CkText.mono(16, w: FontWeight.w600)),
            if (p.retro) const RetroBadge(),
          ]),
        ]);

  Widget _grah(String id) => SizedBox(
        width: 64,
        child: Row(children: [
          GrahDot(id, size: 8),
          const SizedBox(width: 8),
          Text(id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final hasBirth = birth.isNotEmpty;
    GrahPos? find(List<GrahPos> l, String id) {
      for (final p in l) {
        if (p.id == id) return p;
      }
      return null;
    }

    const divider = BoxDecoration(border: Border(top: BorderSide(color: Color(0x1F8CBEFF))));
    return Glass(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(20, 14, 18, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('GRAH Coordinates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(children: [
          const SizedBox(width: 64, child: Text('GRAH', style: CkText.label)),
          const SizedBox(width: 12),
          if (hasBirth) ...[
            const Expanded(child: Text('COSMOKUNDLI', style: CkText.label)),
            const SizedBox(width: 12),
            Expanded(child: Text('TRANSIT', style: CkText.label.copyWith(color: const Color(0xFFFFB27A)))),
          ] else ...[
            Expanded(child: Text('TRANSIT · NAKSHATRA', style: CkText.label.copyWith(color: const Color(0xFFFFB27A)))),
            const Text('DEGREE', style: CkText.label),
          ],
        ]),
        const SizedBox(height: 10),
        for (final id in kGrahOrder)
          if ((hasBirth && (find(birth, id) != null || find(transit, id) != null)) || (!hasBirth && id != 'As' && find(transit, id) != null))
            Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: divider,
              child: Row(children: [
                _grah(id),
                const SizedBox(width: 12),
                if (hasBirth) ...[
                  Expanded(child: _cell(find(birth, id))),
                  const SizedBox(width: 12),
                  Expanded(child: _cell(find(transit, id), tr: true)),
                ] else ...[
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(rashiName(find(transit, id)!.rashi), style: const TextStyle(fontSize: 13, color: Color(0xFFFFD08A))),
                      const SizedBox(height: 3),
                      Text(find(transit, id)!.nakshatra, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
                    ]),
                  ),
                  Row(children: [
                    Text(fmtDegMin(find(transit, id)!.degIn), style: CkText.mono(16, w: FontWeight.w600)),
                    SizedBox(width: 9, child: find(transit, id)!.retro ? const RetroBadge() : null),
                  ]),
                ],
              ]),
            ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: divider,
          child: const Row(children: [
            RetroBadge(),
            SizedBox(width: 6),
            Text('Retrograde (vakri)', style: TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
          ]),
        ),
      ]),
    );
  }
}
