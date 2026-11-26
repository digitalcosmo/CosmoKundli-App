import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/astro.dart';
import '../core/client_data.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import 'client_shell.dart';

ClientData get _data => ClientData.of(Session.client.value?.mId ?? '');

String _pct(double v, {bool signed = true}) => '${signed && v > 0 ? '+' : ''}${v.round()}%';

class PredictionsSection extends StatefulWidget {
  const PredictionsSection({super.key});
  @override
  State<PredictionsSection> createState() => _PredictionsSectionState();
}

class _PredictionsSectionState extends State<PredictionsSection> {
  final _month = DateTime(DateTime.now().year, DateTime.now().month);
  late final _f = _data.sentiments(_month);

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Predictions',
        isRoot: true,
        children: [
          const SectionIntro('What the days ahead hold'),
          ModuleCard(
            title: 'Sentiments',
            description: 'How the client will feel inside, day by day',
            icon: Icons.favorite_border_rounded,
            onTap: () => pushModule(context, const SentimentsPage()),
            preview: FutureBuilder<List<MapEntry<DateTime, double>>>(
              future: _f,
              builder: (c, s) {
                final l = s.data ?? [];
                if (l.isEmpty) return const SizedBox(height: 4);
                final today = DateTime.now();
                final start = l.indexWhere((e) => e.key.day == today.day);
                final w = l.skip(start < 0 ? 0 : start).take(14).toList();
                final t = l.where((e) => e.key.day == today.day).toList();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: w.map((e) {
                        final v = e.value.clamp(-100.0, 100.0);
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            alignment: v >= 0 ? Alignment.bottomCenter : Alignment.topCenter,
                            child: Container(
                              height: v.abs() / 100 * 20 + 2,
                              margin: EdgeInsets.only(bottom: v >= 0 ? 22 : 0, top: v < 0 ? 22 : 0),
                              decoration: BoxDecoration(
                                  color: v >= 0 ? CkColors.green : CkColors.red, borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (t.isNotEmpty)
                    Text('Today ${_pct(t.first.value)}', style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
                ]);
              },
            ),
          ),
          ModuleCard(
              index: 1,
              title: 'Situations',
              description: 'How things around the client go · 7 zones',
              icon: Icons.waves_rounded,
              onTap: () => pushModule(context, const SituationsPage())),
          ModuleCard(
              index: 2,
              title: 'Sentiments 5D',
              description: 'Career, Finance, Health, Social, Love',
              icon: Icons.pie_chart_outline_rounded,
              onTap: () => pushModule(context, const Sentiments5DPage())),
        ],
      );
}

class SentimentsPage extends StatefulWidget {
  const SentimentsPage({super.key});
  @override
  State<SentimentsPage> createState() => _SentimentsPageState();
}

class _SentimentsPageState extends State<SentimentsPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<MapEntry<DateTime, double>>> _f = _data.sentiments(_month);
  int? _sel;
  final _chart = GlobalKey<DailyBarChartState>();

  void _setMonth(DateTime m) => setState(() {
        _month = m;
        _sel = null;
        _f = _data.sentiments(m);
      });

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Sentiments',
        children: [
          MonthBar(month: _month, onChanged: _setMonth),
          LoadView<List<MapEntry<DateTime, double>>>(
            future: _f,
            skeleton: Skels.daily(),
            onRetry: () => _setMonth(_month),
            builder: (l) {
              if (l.isEmpty) {
                return const EmptyBox(icon: Icons.event_busy_rounded, title: 'No readings', body: 'There are no Sentiments for this month.');
              }
              final avg = l.fold<double>(0, (a, b) => a + b.value) / l.length;
              final best = l.reduce((a, b) => a.value >= b.value ? a : b);
              final worst = l.reduce((a, b) => a.value <= b.value ? a : b);
              final now = DateTime.now();
              final todayIdx = (_month.year == now.year && _month.month == now.month)
                  ? l.indexWhere((e) => e.key.day == now.day)
                  : -1;
              final sel = _sel ?? (todayIdx >= 0 ? todayIdx : null);
              final weeks = <List<MapEntry<DateTime, double>>>[];
              for (var i = 0; i < l.length; i += 7) {
                weeks.add(l.sublist(i, (i + 7).clamp(0, l.length)));
              }
              String day(MapEntry<DateTime, double> e) => DateFormat('d · EEE').format(e.key);
              return Column(children: [
                const SizedBox(height: 12),
                Row(children: [
                  StatTile('Strongest', _pct(best.value), day(best), color: const Color(0xFF10B981)),
                  const SizedBox(width: 7),
                  StatTile('Weakest', _pct(worst.value), day(worst), color: const Color(0xFFEF4444)),
                  const SizedBox(width: 7),
                  StatTile('Average', _pct(avg), DateFormat('MMMM').format(_month), color: Colors.white),
                ]),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  radius: 18,
                  padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 6, 10),
                      child: Row(children: [
                        Text('DAILY', style: CkText.label),
                        const Spacer(),
                        if (todayIdx >= 0)
                          Pressable(
                            onTap: () {
                              setState(() => _sel = todayIdx);
                              _chart.currentState?.scrollTo(todayIdx);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: CkColors.cyanStroke)),
                              child: Text('TODAY', style: CkText.mono(10.5, color: CkColors.cyan)),
                            ),
                          ),
                      ]),
                    ),
                    DailyBarChart(
                      key: _chart,
                      days: l.map((e) => DayValue(e.key, e.value)).toList(),
                      signed: true,
                      selected: sel,
                      today: todayIdx >= 0 ? todayIdx : null,
                      onSelect: (i) => setState(() => _sel = i),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 8, 6, 0),
                      child: Row(children: [
                        _Key(Color(0xFF10B981), 'Positive'),
                        SizedBox(width: 14),
                        _Key(Color(0xFFEF4444), 'Negative'),
                        Spacer(),
                        Text('Drag to scroll ⇆', style: TextStyle(fontSize: 11, color: CkColors.textDim)),
                      ]),
                    ),
                  ]),
                ),
                if (sel != null && sel < l.length)
                  Glass(
                    margin: const EdgeInsets.only(top: 10),
                    radius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Text(DateFormat('EEE, d MMM').format(l[sel].key), style: CkText.h(15, w: FontWeight.w600)),
                      const Spacer(),
                      Text(_pct(l[sel].value),
                          style: CkText.h(18, color: l[sel].value >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                      const SizedBox(width: 8),
                      Text(l[sel].value >= 0 ? 'Lighter, more confident' : 'Heavier, more unsettled', style: CkText.muted.copyWith(fontSize: 12)),
                    ]),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: weeks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (c, i) {
                      final w = weeks[i];
                      final a = w.fold<double>(0, (s, e) => s + e.value) / w.length;
                      final col = a >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                      return Glass(
                        width: 120,
                        radius: 18,
                        shadow: false,
                        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('WEEK ${i + 1}', style: CkText.label.copyWith(fontSize: 9.5)),
                          Text(_pct(a), style: CkText.h(19, color: col)),
                          Text('${DateFormat('d MMM').format(w.first.key)} – ${DateFormat('d MMM').format(w.last.key)}',
                              style: const TextStyle(fontSize: 10.5, color: CkColors.textSecondary)),
                          const Spacer(),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                                value: (a.abs() / 100).clamp(0, 1), minHeight: 4, color: col, backgroundColor: CkColors.glassFillStrong),
                          ),
                        ]),
                      );
                    },
                  ),
                ),
              ]);
            },
          ),
        ],
      );
}

class _Key extends StatelessWidget {
  final Color c;
  final String t;
  const _Key(this.c, this.t);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(t, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
      ]);
}

// ───────────────────────── Situations (Cosmo_Power_Daily, 0–100, 7 zones)

class SituationsPage extends StatefulWidget {
  const SituationsPage({super.key});
  @override
  State<SituationsPage> createState() => _SituationsPageState();
}

class _SituationsPageState extends State<SituationsPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<MapEntry<DateTime, double>>> _f = _data.situations(_month);
  int? _sel;
  final _chart = GlobalKey<DailyBarChartState>();

  void _setMonth(DateTime m) => setState(() {
        _month = m;
        _sel = null;
        _f = _data.situations(m);
      });

  Widget _stat(String label, double v, String sub) {
    final z = zoneOf(v);
    return Expanded(
      child: Glass(
        radius: 14,
        shadow: false,
        padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: CkText.label.copyWith(fontSize: 9.5)),
          const SizedBox(height: 3),
          Row(children: [
            ZoneArrows(z, size: 13),
            const SizedBox(width: 4),
            Text('${v.round()}%', style: CkText.mono(16, color: z.color)),
          ]),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: CkColors.textSecondary)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Situations',
        children: [
          MonthBar(month: _month, onChanged: _setMonth),
          LoadView<List<MapEntry<DateTime, double>>>(
            future: _f,
            skeleton: Skels.daily(signed: false),
            onRetry: () => _setMonth(_month),
            builder: (l) {
              if (l.isEmpty) {
                return const EmptyBox(icon: Icons.event_busy_rounded, title: 'No readings', body: 'There are no Situations for this month.');
              }
              final avg = l.fold<double>(0, (a, b) => a + b.value) / l.length;
              final best = l.reduce((a, b) => a.value >= b.value ? a : b);
              final worst = l.reduce((a, b) => a.value <= b.value ? a : b);
              final now = DateTime.now();
              final todayIdx = (_month.year == now.year && _month.month == now.month) ? l.indexWhere((e) => e.key.day == now.day) : -1;
              final sel = _sel ?? (todayIdx >= 0 ? todayIdx : 0);
              final d = l[sel.clamp(0, l.length - 1)];
              final z = zoneOf(d.value);
              String day(MapEntry<DateTime, double> e) => DateFormat('d · EEE').format(e.key);
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const SizedBox(height: 12),
                Row(children: [
                  _stat('Best', best.value, day(best)),
                  const SizedBox(width: 7),
                  _stat('Weakest', worst.value, day(worst)),
                  const SizedBox(width: 7),
                  _stat('Average', avg, DateFormat('MMMM').format(_month)),
                ]),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 6, 10),
                      child: Row(children: [
                        Text('DAILY · 0–100', style: CkText.label),
                        const Spacer(),
                        if (todayIdx >= 0)
                          Pressable(
                            onTap: () {
                              setState(() => _sel = todayIdx);
                              _chart.currentState?.scrollTo(todayIdx);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: CkColors.cyanStroke)),
                              child: Text('TODAY', style: CkText.mono(10.5, color: CkColors.cyan)),
                            ),
                          ),
                      ]),
                    ),
                    RepaintBoundary(
                      child: DailyBarChart(
                        key: _chart,
                        days: l.map((e) => DayValue(e.key, e.value)).toList(),
                        signed: false,
                        selected: sel,
                        today: todayIdx >= 0 ? todayIdx : null,
                        onSelect: (i) => setState(() => _sel = i),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 8, 6, 0),
                      child: Align(alignment: Alignment.centerRight, child: Text('Drag to scroll ⇆', style: TextStyle(fontSize: 11, color: CkColors.textDim))),
                    ),
                  ]),
                ),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(DateFormat('EEE · d MMM').format(d.key).toUpperCase() + (sel == todayIdx ? ' · TODAY' : ''), style: CkText.label),
                        const SizedBox(height: 6),
                        Row(children: [
                          ZoneArrows(z, size: 18),
                          const SizedBox(width: 6),
                          Text(z.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: z.color)),
                        ]),
                        const SizedBox(height: 2),
                        Text(z.advice, style: const TextStyle(fontSize: 12.5, color: CkColors.textSecondary)),
                      ]),
                    ),
                    Text('${d.value.round()}%', style: CkText.mono(30, color: z.color)),
                  ]),
                ),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('7 ZONES', style: CkText.label),
                    for (final zz in kZones)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(children: [
                          ZoneArrows(zz, size: 16),
                          const SizedBox(width: 8),
                          SizedBox(width: 76, child: Text(zz.name, style: const TextStyle(fontSize: 12.5))),
                          SizedBox(width: 56, child: Text('${zz.min}–${zz.max}', style: CkText.mono(11, color: CkColors.labelMono))),
                          Expanded(child: Text(zz.advice, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary))),
                        ]),
                      ),
                  ]),
                ),
              ]);
            },
          ),
        ],
      );
}

// ───────────────────────── Sentiments 5D (month calendar per dimension)

class Sentiments5DPage extends StatefulWidget {
  const Sentiments5DPage({super.key});
  @override
  State<Sentiments5DPage> createState() => _Sentiments5DPageState();
}

class _Sentiments5DPageState extends State<Sentiments5DPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late FiveDLoad _l = _data.sentiments5DLive(_month);
  String _dim = ClientData.kDims.first;
  DateTime? _sel;

  void _setMonth(DateTime m) => setState(() {
        _month = m;
        _sel = null;
        _l = _data.sentiments5DLive(m);
      });

  bool get _signed => _l.data.values.any((d) => d.values.any((v) => v < 0));
  String _pct(double v) => '${_signed && v > 0 ? '+' : ''}${v.round()}%';

  Widget _stat(String label, MapEntry<DateTime, double>? e) => Expanded(
        child: Glass(
          radius: 18,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(), style: CkText.label.copyWith(fontSize: 9.5)),
            const SizedBox(height: 3),
            if (e == null)
              const Skeleton(width: 70, height: 16, radius: 4)
            else
              CountUpText('${_pct(e.value)} · ${e.key.day}', style: CkText.mono(15, color: fiveDColor(e.value, signed: _signed))),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'Sentiments 5D',
        children: [
          MonthBar(month: _month, onChanged: _setMonth),
          const SizedBox(height: 10),
          Segmented<String>(values: ClientData.kDims, selected: _dim, label: (d) => d, onChanged: (d) => setState(() => _dim = d), height: 40),
          ListenableBuilder(
            listenable: _l,
            builder: (c, _) {
              final l = _l;
              final m = l.data;
              final days = m.keys.toList()..sort();
              final series = [for (final d in days) if (m[d]![_dim] != null) MapEntry(d, m[d]![_dim]!)];
              final best = series.isEmpty || l.loading ? null : series.reduce((a, b) => a.value >= b.value ? a : b);
              final worst = series.isEmpty || l.loading ? null : series.reduce((a, b) => a.value <= b.value ? a : b);
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final sel = _sel ?? (m.containsKey(today) ? today : (days.isEmpty ? null : days.first));
              final first = DateTime(_month.year, _month.month, 1);
              final count = DateTime(_month.year, _month.month + 1, 0).day;
              final lead = first.weekday - 1;
              final signed = _signed;
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // progress while weeks stream in
                AnimatedSize(
                  duration: CkMotion.base,
                  curve: kEase,
                  child: l.loading
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: l.total == 0 ? null : l.finished / l.total,
                                  minHeight: 3,
                                  color: CkColors.cyan,
                                  backgroundColor: const Color(0x14FFFFFF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Loading… ${l.finished} of ${l.total}', style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                          ]),
                        )
                      : l.failed.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(children: [
                                Expanded(child: Text('${l.failed.length} of ${l.total} pieces didn\'t load', style: const TextStyle(fontSize: 12, color: CkColors.textSecondary))),
                                Pressable(
                                  onTap: () => setState(() => _l = _data.sentiments5DLive(_month, retryFailed: true)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.cyanStroke)),
                                    child: const Text('Retry missing', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ]),
                            )
                          : const SizedBox(width: double.infinity),
                ),
                const SizedBox(height: 12),
                Row(children: [_stat('Best day', best), const SizedBox(width: 8), _stat('Weakest', worst)]),
                SwipeArea(
                  canSwipe: (_) => true,
                  onSwipe: (d) => _setMonth(DateTime(_month.year, _month.month + d)),
                  child: Glass(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text('${_dim.toUpperCase()} · DAY BY DAY', style: CkText.label),
                      const SizedBox(height: 10),
                      GridView.count(
                        key: ValueKey('${_month.year}-${_month.month}-$_dim'),
                        crossAxisCount: 7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        children: [
                          for (final w in const ['M', 'T', 'W', 'T', 'F', 'S', 'S']) Center(child: Text(w, style: CkText.label)),
                          for (var i = 0; i < lead; i++) const SizedBox(),
                          for (var dd = 1; dd <= count; dd++)
                            () {
                              final date = DateTime(_month.year, _month.month, dd);
                              final v = m[date]?[_dim];
                              final isToday = date == today;
                              final isSel = date == sel;
                              if (v == null) {
                                // still loading: shimmer; loaded but empty: dim
                                return Stack(children: [
                                  if (l.loading) const Positioned.fill(child: Skeleton(height: 40, radius: 11)),
                                  Center(child: Text('$dd', style: CkText.mono(10.5, color: CkColors.textDim))),
                                ]);
                              }
                              final col = fiveDColor(v, signed: signed);
                              return PopIn(
                                delay: Duration(milliseconds: 12 * dd),
                                child: Pressable(
                                  onTap: () => setState(() => _sel = date),
                                  child: AnimatedContainer(
                                    duration: CkMotion.base,
                                    decoration: BoxDecoration(
                                      color: col.withValues(alpha: .9),
                                      borderRadius: BorderRadius.circular(11),
                                      border: isSel
                                          ? Border.all(color: Colors.white, width: 2)
                                          : isToday
                                              ? Border.all(color: Colors.white.withValues(alpha: .6), width: 1.2)
                                              : null,
                                      boxShadow: isSel ? [BoxShadow(color: col.withValues(alpha: .6), blurRadius: 12)] : null,
                                    ),
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Text('$dd', style: CkText.mono(11, w: FontWeight.w700, color: const Color(0xFF06204F))),
                                      Text(_pct(v), style: CkText.mono(9, color: const Color(0xCC06204F))),
                                    ]),
                                  ),
                                ),
                              );
                            }(),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const FiveDLegend(),
                    ]),
                  ),
                ),
                if (sel != null && m[sel] != null)
                  Glass(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${DateFormat('EEE · d MMM').format(sel).toUpperCase()}${sel == today ? ' · TODAY' : ''} · ALL 5', style: CkText.label),
                      const SizedBox(height: 6),
                      for (var i = 0; i < ClientData.kDims.length; i++)
                        if (m[sel]![ClientData.kDims[i]] != null)
                          () {
                            final d = ClientData.kDims[i];
                            final v = m[sel]![d]!;
                            final col = fiveDColor(v, signed: signed);
                            final frac = signed ? ((v + 100) / 200) : v / 100;
                            return Padding(
                              key: ValueKey('$sel$d'),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(children: [
                                SizedBox(width: 66, child: Text(d, style: TextStyle(fontSize: 13.5, fontWeight: d == _dim ? FontWeight.w600 : FontWeight.w400))),
                                Expanded(
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(5)),
                                    child: GrowIn(
                                      value: frac.clamp(0.0, 1.0),
                                      delay: Duration(milliseconds: 90 * i),
                                      builder: (t) => FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: t,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            gradient: LinearGradient(colors: [col.withValues(alpha: .6), col]),
                                            boxShadow: [BoxShadow(color: col.withValues(alpha: .35), blurRadius: 8)],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 48, child: Align(alignment: Alignment.centerRight, child: CountUpText(_pct(v), style: CkText.mono(13)))),
                              ]),
                            );
                          }(),
                    ]),
                  ),
              ]);
            },
          ),
        ],
      );
}
