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
                            decoration: BoxDecoration(color: CkColors.glassFill, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              GrahDot(p.id, size: 8),
                              const SizedBox(width: 6),
                              SizedBox(width: 22, child: Text(p.id, style: TextStyle(fontWeight: FontWeight.w600, color: p.color, fontSize: 12.5))),
                              Expanded(child: Text(rashiShort(p.rashi), style: const TextStyle(fontSize: 12.5))),
                              Text(fmtDeg(p.degIn).split(' ').first, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                              if (p.retro) const RetroBadge(),
                            ]),
                          ))
                      .toList(),
                ),
              ),
            ]),
          ),
          LoadView<Map<String, double>>(
            future: _bal,
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
  final _f = _data.chart();
  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'CosmoKundli',
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
        children: [
          LoadView<List<GrahPos>>(
            future: _f,
            builder: (planets) => Column(children: [
              ZoomChart(child: KundliChart(planets)),
              const Text('Pinch to zoom · double-tap · long-press to magnify', style: TextStyle(fontSize: 11.5, color: CkColors.textMuted)),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: SunMoonLagna(planets),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 84,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: planets
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Pressable(
                              onTap: () => showPlanetSheet(context, p),
                              child: Container(
                                width: 62,
                                decoration: BoxDecoration(
                                    color: CkColors.glassFill,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: CkColors.glassStroke)),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(center: const Alignment(-.3, -.4), colors: [Colors.white, p.color]),
                                      boxShadow: [BoxShadow(color: p.color.withOpacity(.45), blurRadius: 12)],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(p.id, style: TextStyle(fontWeight: FontWeight.w600, color: p.color, fontSize: 12)),
                                  Text('${rashiShort(p.rashi, 2)} ${p.degIn.floor()}°',
                                      style: const TextStyle(fontSize: 10, color: CkColors.textSecondary)),
                                ]),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ]),
          ),
        ],
      );
}

Future<void> showPlanetSheet(BuildContext context, GrahPos p) async {
  Map<String, double> bal = {};
  try {
    bal = await _data.shadbal();
  } catch (_) {}
  if (!context.mounted) return;
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: CkColors.glassStroke, borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 14),
          Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(center: const Alignment(-.3, -.4), colors: [Colors.white, p.color]),
                boxShadow: [BoxShadow(color: p.color.withOpacity(.55), blurRadius: 26)],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('${p.name} ', style: CkText.h(22)),
                  Text(p.id, style: CkText.h(22, color: p.color)),
                  if (p.retro) const RetroBadge(),
                ]),
                Text('${rashiName(p.rashi)} ${fmtDeg(p.degIn)} · ${p.longitude.toStringAsFixed(2)}°', style: CkText.muted.copyWith(fontSize: 13)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.9,
            children: [
              _cell('Rashi', rashiName(p.rashi)),
              _cell('Swami', swami(p.rashi)),
              _cell('Nakshatra', p.nakshatra.isEmpty ? '—' : p.nakshatra),
              _cell('Tatva', tatva(p.rashi)),
              _cell('Swabhav', swabhav(p.rashi)),
              _cell('Power', bal[p.id] == null ? '—' : '${bal[p.id]!.round()}%'),
            ],
          ),
        ]),
      ),
    ),
  );
}

Widget _cell(String l, String v) => Container(
      padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
      decoration: BoxDecoration(
          color: CkColors.glassFill, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.12))),
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
  final _f = _data.chart();
  bool _abs = false;

  static const _cols = [('Rashi', 100.0), ('Degree', 108.0), ('Tatva', 80.0), ('Swabhav', 88.0), ('Swami', 88.0)];
  static const _rowH = 50.0;

  @override
  Widget build(BuildContext context) => ClientPage(
        title: 'GRAH Coordinates',
        children: [
          Segmented<bool>(
            values: const [false, true],
            selected: _abs,
            label: (v) => v ? '0–360°' : 'Rashi + degree',
            onChanged: (v) => setState(() => _abs = v),
            height: 42,
          ),
          LoadView<List<GrahPos>>(
            future: _f,
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
                              Text(p.id, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: p.color)),
                            ]),
                          )),
                    ]),
                  ),
                  Container(width: 1, height: 30 + _rowH * planets.length, color: Colors.white.withOpacity(.12), margin: const EdgeInsets.only(right: 12)),
                  Expanded(
                    child: SingleChildScrollView(
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
                              Row(children: [
                                Text(deg, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()])),
                                if (p.retro) const RetroBadge(),
                              ]),
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
                ]),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 10, 4, 0),
                child: Row(children: [
                  RetroBadge(),
                  SizedBox(width: 6),
                  Text('Retrograde (vakri)', style: TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
                  Spacer(),
                  Text('Swipe for Tatva, Swabhav, Swami', style: TextStyle(fontSize: 11.5, color: CkColors.textSecondary)),
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
  final _f = _data.shadbal();
  @override
  Widget build(BuildContext context) => ClientPage(
        title: widget.flavor ? 'Flavor' : 'Power',
        children: [
          LoadView<Map<String, double>>(
            future: _f,
            builder: (m) {
              final v = _ordered(m, widget.flavor ? _flavorOrder : _powerOrder);
              if (v.isEmpty) {
                return const EmptyBox(icon: Icons.bar_chart_rounded, title: 'No values yet', body: 'This client has no strength data.');
              }
              final sorted = [...v]..sort((a, b) => b.value.compareTo(a.value));
              return Column(children: [
                Glass(
                  radius: 18,
                  padding: const EdgeInsets.fromLTRB(8, 14, 14, 12),
                  child: GrahBarChart(values: v, height: 340),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  InfoPill(widget.flavor ? 'Highest' : 'Strongest', '${kGrahNames[sorted.first.key]} · ${sorted.first.value.round()}%', CkColors.jupiter),
                  const SizedBox(width: 8),
                  InfoPill(widget.flavor ? 'Lowest' : 'Weakest', '${kGrahNames[sorted.last.key]} · ${sorted.last.value.round()}%', const Color(0xFFFF9A6B)),
                ]),
              ]);
            },
          ),
        ],
      );
}
