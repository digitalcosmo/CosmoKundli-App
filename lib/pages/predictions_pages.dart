import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          const ModuleCard(
              index: 1, comingSoon: true, title: 'Situations', description: 'How things around the client go · 7 zones', icon: Icons.waves_rounded),
          const ModuleCard(
              index: 2, comingSoon: true, title: 'Sentiments 5D', description: 'Career, Finance, Health, Social, Love', icon: Icons.pie_chart_outline_rounded),
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
