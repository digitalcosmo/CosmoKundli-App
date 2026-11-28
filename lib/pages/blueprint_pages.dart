import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/astro.dart';
import '../core/client_data.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/kundli_svg.dart';
import '../ui/widgets.dart';
import '../ui/zoom_chart.dart';
import 'client_shell.dart';

const _powerOrder = ['Su', 'Mo', 'Ra', 'Ke', 'Ju', 'Sa', 'Ma', 'Ve', 'Me'];
const _flavorOrder = ['Su', 'Mo', 'Ju', 'Sa', 'Ma', 'Ve', 'Me'];

ClientData get _data => ClientData.of(Session.client.value?.mId ?? '');

List<MapEntry<String, double>> _ordered(Map<String, double> m, List<String> order) =>
    [for (final id in order) if (m.containsKey(id)) MapEntry(id, m[id]!)];

/// The software's circle CosmoKundli chart, rendered from the same SVG recipe.
class KundliChart extends StatelessWidget {
  final List<GrahPos> planets;
  final List<GrahPos>? transit;
  const KundliChart(this.planets, {super.key, this.transit});

  // Building the SVG string is the expensive part; keep the last few.
  static final _cache = <String, String>{};
  static String _key(List<GrahPos> l) =>
      l.map((p) => '${p.id}${p.longitude.toStringAsFixed(3)}${p.retro ? 'R' : ''}').join();

  String _svg(String lang) {
    final k = '$lang|${_key(planets)}|${transit == null ? '' : _key(transit!)}';
    final hit = _cache[k];
    if (hit != null) return hit;
    final s = transit == null
        ? KundliSvg.birth(planets, lang: lang)
        : KundliSvg.transit(planets, transit!, lang: lang);
    if (_cache.length > 24) _cache.remove(_cache.keys.first);
    return _cache[k] = s;
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: Session.lang,
        builder: (c, lang, _) => AspectRatio(
          aspectRatio: 1,
          child: RepaintBoundary(child: SvgPicture.string(_svg(lang), fit: BoxFit.contain)),
        ),
      );
}

GrahPos? _find(List<GrahPos> l, String id) {
  for (final p in l) {
    if (p.id == id) return p;
  }
  return null;
}

class SunMoonLagna extends StatelessWidget {
  final List<GrahPos> planets;
  const SunMoonLagna(this.planets, {super.key});
  String _v(GrahPos? p) {
    if (p == null) return '—';
    return [rashiName(p.rashi), if (p.nakshatra.isNotEmpty) p.nakshatra].join(' · ');
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        InfoPill('Sun', _v(_find(planets, 'Su')), const Color(0xFFFF9A6B)),
        const SizedBox(width: 6),
        InfoPill('Moon', _v(_find(planets, 'Mo')), CkColors.moon),
        const SizedBox(width: 6),
        InfoPill('Lagna', _v(_find(planets, 'As')), const Color(0xFFE8C9A6)),
      ]);
}

// ───────────────────────── section

class BlueprintSection extends StatefulWidget {
  const BlueprintSection({super.key});
  @override
  State<BlueprintSection> createState() => _BlueprintSectionState();
}

class _BlueprintSectionState extends State<BlueprintSection> {
  late Future<List<GrahPos>> _chart = _data.chart();
  late Future<Map<String, double>> _bal = _data.shadbal();

  Future<void> _refresh() async {
    setState(() {
      _chart = _data.chart(refresh: true);
      _bal = _data.shadbal(refresh: true);
    });
    await Future.wait([_chart, _bal]);
  }

  Widget _card({required String title, required IconData icon, required VoidCallback onTap, required Widget child, int i = 0}) =>
      FadeSlideIn(
        index: i,
        child: Pressable(
          scale: .985,
          onTap: onTap,
          child: Glass(
            margin: const EdgeInsets.only(top: 12),
            radius: 18,
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CardTitle(title, icon, trailing: const Icon(Icons.chevron_right_rounded, color: CkColors.textMuted)),
              child,
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'BluePrint',
        isRoot: true,
        onRefresh: _refresh,
        children: [
          LoadView<List<GrahPos>>(
            future: _chart,
            skeleton: Skels.kundli(),
            onRetry: _refresh,
            builder: (planets) => Column(children: [
              FadeSlideIn(
                child: Pressable(
                  scale: .985,
                  onTap: () => pushModule(context, const KundliPage()),
                  child: Glass(
                    radius: 28,
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(children: [
                          Expanded(child: Text('CosmoKundli', style: CkText.h(16, w: FontWeight.w600))),
                          const Icon(Icons.chevron_right_rounded, color: CkColors.textMuted),
                        ]),
                      ),
                      KundliChart(planets),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: SunMoonLagna(planets)),
                    ]),
                  ),
                ),
              ),
              _card(
                i: 1,
                title: 'GRAH Coordinates',
                icon: Icons.table_chart_outlined,
                onTap: () => pushModule(context, const CoordinatesPage()),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 4.6,
                  children: planets
                      .map((p) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(color: CkColors.field, borderRadius: BorderRadius.circular(10)),
                            child: Row(children: [
                              GrahDot(p.id, size: 7),
                              const SizedBox(width: 6),
                              SizedBox(
                                  width: 30,
                                  child: Row(children: [
                                    Text(p.id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                                    if (p.retro) const RetroBadge(),
                                  ])),
                              Expanded(child: Text(rashiShort(p.rashi), style: const TextStyle(fontSize: 12.5, color: CkColors.textSecondary))),
                              Text(fmtDeg(p.degIn), style: CkText.mono(12)),
                            ]),
                          ))
                      .toList(),
                ),
              ),
            ]),
          ),
          LoadView<Map<String, double>>(
            future: _bal,
            skeleton: Column(children: [Skels.bars(height: 120), Skels.bars(height: 120)]),
            minHeight: 120,
            onRetry: _refresh,
            builder: (m) => Column(children: [
              _card(
                  i: 2,
                  title: 'Power',
                  icon: Icons.bolt_rounded,
                  onTap: () => pushModule(context, const StrengthPage(flavor: false)),
                  child: GrahBarChart(values: _ordered(m, _powerOrder), height: 150, axis: false)),
              _card(
                  i: 3,
                  title: 'Flavor',
                  icon: Icons.water_drop_outlined,
                  onTap: () => pushModule(context, const StrengthPage(flavor: true)),
                  child: GrahBarChart(values: _ordered(m, _flavorOrder), height: 150, axis: false)),
            ]),
          ),
        ],
      );
}

// ───────────────────────── CosmoKundli

class KundliPage extends StatefulWidget {
  const KundliPage({super.key});
  @override
  State<KundliPage> createState() => _KundliPageState();
}

class _KundliPageState extends State<KundliPage> {
  late Future<List<GrahPos>> _f = _data.chart();
  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'CosmoKundli',
        children: [
          LoadView<List<GrahPos>>(
            future: _f,
            skeleton: Column(children: [Skels.kundli(), Skels.table(10)]),
            onRetry: () => setState(() => _f = _data.chart()),
            builder: (planets) {
              final ordered = [for (final id in kGrahOrder) ...planets.where((p) => p.id == id)];
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Glass(
                  padding: const EdgeInsets.all(6),
                  child: Stack(children: [
                    ZoomChart(child: KundliChart(planets)),
                  ]),
                ),
                const SizedBox(height: 10),
                SunMoonLagna(planets),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: Row(children: [
                        Expanded(child: Text('GRAH IN RASHI · TAP FOR DETAILS', style: CkText.label)),
                        GestureDetector(
                          onTap: () => pushModule(context, const CoordinatesPage()),
                          child: const Text('Coordinates ›', style: TextStyle(fontSize: 12.5, color: CkColors.cyan)),
                        ),
                      ]),
                    ),
                    for (var i = 0; i < ordered.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Pressable(
                          scale: .98,
                          onTap: () => showPlanetSheet(context, ordered[i], all: ordered),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(color: CkColors.field, borderRadius: BorderRadius.circular(11), border: Border.all(color: CkColors.panelStroke)),
                            child: Row(children: [
                              SizedBox(
                                width: 54,
                                child: Row(children: [
                                  GrahDot(ordered[i].id),
                                  const SizedBox(width: 6),
                                  Text(ordered[i].id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  if (ordered[i].retro) const RetroBadge(),
                                ]),
                              ),
                              Expanded(child: Text(rashiName(ordered[i].rashi), style: const TextStyle(fontSize: 13, color: CkColors.textTertiary))),
                              Text(fmtDegMin(ordered[i].degIn), style: CkText.mono(12.5)),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right_rounded, size: 18, color: CkColors.labelMono),
                            ]),
                          ),
                        ),
                      ),
                  ]),
                ),
              ]);
            },
          ),
        ],
      );
}

Future<void> showPlanetSheet(BuildContext context, GrahPos p, {List<GrahPos>? all}) async {
  Map<String, double> bal = {};
  try {
    bal = await _data.shadbal();
  } catch (_) {}
  if (!context.mounted) return;
  final list = all ?? [p];
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (c) => _GrahSheet(list: list, start: list.indexWhere((e) => e.id == p.id).clamp(0, list.length - 1), bal: bal),
  );
}

class _GrahSheet extends StatefulWidget {
  final List<GrahPos> list;
  final int start;
  final Map<String, double> bal;
  const _GrahSheet({required this.list, required this.start, required this.bal});
  @override
  State<_GrahSheet> createState() => _GrahSheetState();
}

class _GrahSheetState extends State<_GrahSheet> {
  late int _i = widget.start;
  @override
  Widget build(BuildContext context) {
    final p = widget.list[_i];
    final pw = widget.bal[p.id];
    final n = widget.list.length;
    GrahPos at(int k) => widget.list[(k + n) % n];
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 18, 22 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xF82856AA), Color(0xFC0E2860)]),
        border: Border(top: BorderSide(color: Color(0x4DA0C8FF))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0x4DFFFFFF), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: p.color.withValues(alpha: .15), border: Border.all(color: p.color, width: 1.5)),
            child: Text(p.id, style: TextStyle(fontWeight: FontWeight.w700, color: p.color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(p.name, style: CkText.h(19)), if (p.retro) const RetroBadge()]),
              const SizedBox(height: 2),
              Text('${rashiName(p.rashi)} · ${fmtDegMin(p.degIn)}', style: CkText.mono(12, color: CkColors.textSecondary)),
            ]),
          ),
          if (pw != null) StatText('${pw.round()}%', style: CkText.mono(22, color: p.color)),
        ]),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.9,
          children: [
            _cell('Rashi', '${p.rashi.toString().padLeft(2, '0')} · ${rashiName(p.rashi)}'),
            _cell('Swami', swami(p.rashi)),
            _cell('Nakshatra', p.nakshatra.isEmpty ? '—' : p.nakshatra),
            _cell('Tatva', tatva(p.rashi)),
            _cell('Swabhav', swabhav(p.rashi)),
            _cell('Power', pw == null ? '—' : '${pw.round()}%'),
          ],
        ),
        if (n > 1) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _nav('‹ ${at(_i - 1).name}', () => setState(() => _i = (_i - 1 + n) % n))),
            const SizedBox(width: 8),
            Expanded(child: _nav('${at(_i + 1).name} ›', () => setState(() => _i = (_i + 1) % n))),
          ]),
        ],
      ]),
    );
  }

  Widget _nav(String t, VoidCallback onTap) => Pressable(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: CkColors.panelStroke)),
          child: Text(t, style: const TextStyle(fontSize: 13.5)),
        ),
      );
}

Widget _cell(String l, String v) => Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(color: CkColors.field, borderRadius: BorderRadius.circular(11), border: Border.all(color: CkColors.panelStroke)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(upper(l), style: CkText.label.copyWith(fontSize: 9.5)),
        const SizedBox(height: 3),
        Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.h(14.5, w: FontWeight.w600)),
      ]),
    );

// ───────────────────────── GRAH Coordinates

class CoordinatesPage extends StatefulWidget {
  const CoordinatesPage({super.key});
  @override
  State<CoordinatesPage> createState() => _CoordinatesPageState();
}

class _CoordinatesPageState extends State<CoordinatesPage> {
  late Future<List<GrahPos>> _f = _data.chart();
  bool _abs = false;

  static const _cols = [('Rashi', 100.0), ('Degree', 108.0), ('Tatva', 80.0), ('Swabhav', 88.0), ('Swami', 88.0)];
  static const _rowH = 50.0;

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'GRAH Coordinates',
        children: [
          Glass(
            radius: 14,
            padding: const EdgeInsets.fromLTRB(14, 2, 6, 2),
            child: Row(children: [
              const Expanded(child: Text('Show degree as 0–360°', style: TextStyle(fontSize: 13))),
              Transform.scale(scale: .82, child: Switch(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: _abs,
                activeColor: const Color(0xFF06204F),
                activeTrackColor: CkColors.cyan,
                onChanged: (v) => setState(() => _abs = v),
              )),
            ]),
          ),
          LoadView<List<GrahPos>>(
            future: _f,
            skeleton: Skels.table(10),
            onRetry: () => setState(() => _f = _data.chart()),
            builder: (planets) => Column(children: [
              Glass(
                margin: const EdgeInsets.only(top: 12),
                radius: 18,
                padding: const EdgeInsets.fromLTRB(14, 14, 0, 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    width: 64,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 30, child: Text('GRAH', style: CkText.label)),
                      ...planets.map((p) => Container(
                            height: _rowH,
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x14FFFFFF)))),
                            child: Row(children: [
                              GrahDot(p.id, size: 10),
                              const SizedBox(width: 8),
                              Text(p.id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              if (p.retro) const RetroBadge(),
                            ]),
                          )),
                    ]),
                  ),
                  Container(width: 1, height: 30 + _rowH * planets.length, color: Colors.white.withOpacity(.12), margin: const EdgeInsets.only(right: 12)),
                  Expanded(
                    child: HScroll(
                      builder: (sc) => SingleChildScrollView(
                      controller: sc,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(
                            height: 30,
                            child: Row(children: [for (final c in _cols) SizedBox(width: c.$2, child: Text(c.$1.toUpperCase(), style: CkText.label))]),
                          ),
                          ...planets.map((p) {
                            final deg = _abs ? '${p.longitude.toStringAsFixed(2)}°' : fmtDeg(p.degIn);
                            final cells = <Widget>[
                              Text(rashiName(p.rashi), style: const TextStyle(fontSize: 14.5)),
                              Text(deg, style: CkText.mono(14)),
                              Text(tatva(p.rashi), style: const TextStyle(fontSize: 14.5)),
                              Text(swabhav(p.rashi), style: const TextStyle(fontSize: 14.5)),
                              Text(swami(p.rashi), style: const TextStyle(fontSize: 14.5)),
                            ];
                            return Container(
                              height: _rowH,
                              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x14FFFFFF)))),
                              child: Row(children: [for (var i = 0; i < _cols.length; i++) SizedBox(width: _cols[i].$2, child: cells[i])]),
                            );
                          }),
                        ]),
                      ),
                    ),
                    ),
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 10, 4, 0),
                child: Row(children: [
                  RetroBadge(),
                  SizedBox(width: 6),
                  Text('Retrograde (vakri)', style: TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
                ]),
              ),
            ]),
          ),
        ],
      );
}

// ───────────────────────── Power / Flavor

class StrengthPage extends StatefulWidget {
  final bool flavor;
  const StrengthPage({super.key, required this.flavor});
  @override
  State<StrengthPage> createState() => _StrengthPageState();
}

class _StrengthPageState extends State<StrengthPage> {
  late Future<Map<String, double>> _f = _data.shadbal();
  late bool _flavor = widget.flavor;
  @override
  Widget build(BuildContext context) => ClientPage(
        title: _flavor ? 'Flavor' : 'Power',
        children: [
          Segmented<bool>(
            values: const [false, true],
            selected: _flavor,
            label: (v) => v ? 'Flavor' : 'Power',
            onChanged: (v) => setState(() => _flavor = v),
            height: 42,
          ),
          const SizedBox(height: 12),
          LoadView<Map<String, double>>(
            future: _f,
            skeleton: Skels.bars(),
            onRetry: () => setState(() => _f = _data.shadbal()),
            builder: (m) {
              final v = _ordered(m, _flavor ? _flavorOrder : _powerOrder);
              if (v.isEmpty) {
                return const EmptyBox(icon: Icons.bar_chart_rounded, title: 'No values yet', body: 'This client has no strength data.');
              }
              // every planet keeps its bar and its ranking row; switching
              // Power and Flavor glides them instead of redrawing
              final shown = {for (final e in v) e.key: e.value};
              return Column(children: [
                Glass(
                  padding: const EdgeInsets.fromLTRB(8, 16, 12, 12),
                  child: GrahBarChart(values: [for (final id in _powerOrder) if (m.containsKey(id)) MapEntry(id, shown[id])], height: 300),
                ),
                Glass(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_flavor ? 'HIGHEST FIRST' : 'STRONGEST FIRST', style: CkText.label),
                    const SizedBox(height: 4),
                    RankList(items: [
                      for (final e in v)
                        RankItem(
                          id: e.key,
                          label: Row(children: [
                            GrahDot(e.key),
                            const SizedBox(width: 6),
                            Text(e.key, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                          ]),
                          value: e.value,
                          color: grahColor(e.key),
                          text: '${e.value.round()}%',
                        ),
                    ]),
                  ]),
                ),
              ]);
            },
          ),
        ],
      );
}
