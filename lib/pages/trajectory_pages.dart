import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// "Today · 18:53", "8 Dec '26 · 18:53".
  String get whenText {
    final now = DateTime.now();
    final same = _at.year == now.year && _at.month == now.month && _at.day == now.day;
    return '${same ? 'Today' : DateFormat("d MMM ''yy").format(_at)} · ${DateFormat('HH:mm').format(_at)}';
  }

  /// How far the shown moment is from now: "+3 days", "−2 months".
  String get _fromNow {
    if (_live) return 'Now';
    final m = _at.difference(DateTime.now()).inMinutes;
    if (m.abs() < 1) return 'Now';
    final sign = m > 0 ? '+' : '−';
    final a = m.abs();
    String u(int n, String w) => '$sign$n $w${n == 1 ? '' : 's'}';
    if (a < 60) return u(a, 'min');
    if (a < 60 * 24) return u((a / 60).round(), 'hour');
    if (a < 60 * 24 * 28) return u((a / 1440).round(), 'day');
    if (a < 60 * 24 * 365) return u((a / 43200).round(), 'month');
    return u((a / 525600).round(), 'year');
  }

  static const _stepName = {_Step.h1: '1 hour', _Step.d1: '1 day', _Step.w1: '1 week', _Step.m1: '1 month', _Step.y1: '1 year', _Step.y10: '10 years'};

  Future<void> _openStep(BuildContext anchor) async {
    final v = await showCkMenu<String>(
      anchor,
      minWidth: 220,
      selected: _step.name,
      items: [
        for (final s in _Step.values) CkMenuItem(s.name, _stepName[s]!, trailing: _stepLabel[s]),
        const CkMenuItem('pick', 'Pick date and time…', icon: Icons.calendar_today_outlined, divider: true),
      ],
    );
    if (v == null || !mounted) return;
    if (v == 'pick') return pickTime();
    setState(() => _step = _Step.values.byName(v));
  }

  /// One line: ‹  [date · step ▾]  ›  Live. The middle opens the step
  /// menu (and the date picker); the arrows move by the step and repeat
  /// while held; Live follows the clock, any move turns it into "Now".
  Widget _controls(BuildContext context) => Glass(
        frost: false,
        radius: 16,
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          _HoldArrow(icon: Icons.chevron_left_rounded, label: 'Back ${_stepName[_step]}', onStep: () => _set(_move(_at, _step, -1))),
          const SizedBox(width: 8),
          Expanded(
            child: Builder(
              builder: (anchor) => Semantics(
                button: true,
                label: 'Time $whenText, step ${_stepName[_step]}. Change step or pick a date',
                excludeSemantics: true,
                child: Pressable(
                  onTap: () => _openStep(anchor),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(color: const Color(0x2E000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: CkColors.panelStroke)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      FittedBox(fit: BoxFit.scaleDown, child: Text(whenText.replaceAll(' · ', ' '), maxLines: 1, style: CkText.mono(15, color: CkColors.text))),
                      const SizedBox(height: 1),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: 'Step ${_stepLabel[_step]}', style: const TextStyle(color: CkColors.cyan)),
                            TextSpan(text: ' · $_fromNow '),
                            const TextSpan(text: '▾', style: TextStyle(color: CkColors.cyan)),
                          ]),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _HoldArrow(icon: Icons.chevron_right_rounded, label: 'Forward ${_stepName[_step]}', onStep: () => _set(_move(_at, _step, 1))),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: _live ? 'Live, following the clock' : 'Back to now',
            excludeSemantics: true,
            child: Pressable(
              onTap: () => _set(DateTime.now(), live: true),
              child: AnimatedContainer(
                duration: CkMotion.fast,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _live ? const Color(0x9910B981) : CkColors.panelStroke),
                  color: const Color(0x14FFFFFF),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _live ? const Color(0xFF10B981) : CkColors.labelMono,
                      boxShadow: _live ? const [BoxShadow(color: Color(0xFF10B981), blurRadius: 8)] : null,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(_live ? 'Live' : 'Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _live ? CkColors.text : CkColors.textSecondary)),
                ]),
              ),
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DataBuilder<List<dynamic>>(
        future: Future.wait<List<GrahPos>>([_transit ?? Future.value(<GrahPos>[]), _birth ?? Future.value(<GrahPos>[])]),
        builder: (c, s) {
          if (_srcId == null) {
            return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Add a client first to read the sky.', style: CkText.muted)));
          }
          if (s.hasError && _last == null) {
            return ErrorBox(message: 'Couldn\'t load the sky for this moment. Check your connection and try again.', onRetry: () => setState(_load));
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
            _controls(context),
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

/// A 44 px step arrow: one step per tap; held, it keeps stepping, faster
/// the longer it is held, with a light tick per step.
class _HoldArrow extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onStep;
  const _HoldArrow({required this.icon, required this.label, required this.onStep});
  @override
  State<_HoldArrow> createState() => _HoldArrowState();
}

class _HoldArrowState extends State<_HoldArrow> {
  Timer? _t;
  int _n = 0;
  bool _down = false;

  void _go() {
    widget.onStep();
    HapticFeedback.selectionClick();
    _n++;
    _t = Timer(Duration(milliseconds: (380 - _n * 40).clamp(70, 380)), _go);
  }

  void _stop() {
    _t?.cancel();
    _t = null;
    if (_down) setState(() => _down = false);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: widget.label,
        onTap: widget.onStep,
        excludeSemantics: true,
        child: Listener(
          onPointerDown: (_) {
            setState(() => _down = true);
            _n = 0;
            _t?.cancel();
            widget.onStep();
            HapticFeedback.selectionClick();
            _t = Timer(const Duration(milliseconds: 420), _go);
          },
          onPointerUp: (_) => _stop(),
          onPointerCancel: (_) => _stop(),
          child: AnimatedScale(
            scale: _down ? .94 : 1,
            duration: CkMotion.fast,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _down ? CkColors.cyanTint : const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _down ? CkColors.cyanStroke : CkColors.panelStroke),
              ),
              child: Icon(widget.icon, size: 22, color: CkColors.text),
            ),
          ),
        ),
      );
}
