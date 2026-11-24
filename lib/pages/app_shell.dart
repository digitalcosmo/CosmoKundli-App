import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/api.dart';
import '../core/astro.dart';
import '../core/client_data.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/kundli_svg.dart';
import '../ui/widgets.dart';
import '../ui/zoom_chart.dart';
import 'account_pages.dart';
import 'blueprint_pages.dart';
import 'client_form_page.dart';
import 'client_shell.dart';
import 'clients_page.dart';
import 'reports_pages.dart';
import 'sky_pages.dart';
import 'traditional_pages.dart';
import 'workspace.dart';

/// Lets screens switch the app dock tab (e.g. Home search → Clients).
final ValueNotifier<int?> appTabRequest = ValueNotifier(null);

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _built = <int>{0};

  @override
  void initState() {
    super.initState();
    appTabRequest.addListener(_onReq);
    if (searchTools.isEmpty) {
      registerSearchTool('Transit', 'Sky now · step through time', Icons.public_rounded, (c) => Get.to(() => const SkyNowPage()));
      registerSearchTool('Panchang now', 'Today at your location', Icons.light_mode_outlined, (c) => Get.to(() => const PanchangNowPage()));
      registerSearchTool('Melapak', 'Match two people', Icons.join_inner_rounded, (c) => Get.to(() => const MelapakToolPage()));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Here.asked && mounted) askLocation(context);
    });
  }

  @override
  void dispose() {
    appTabRequest.removeListener(_onReq);
    super.dispose();
  }

  void _onReq() {
    final i = appTabRequest.value;
    if (i != null && mounted) {
      appTabRequest.value = null;
      _go(i);
    }
  }

  void _go(int i) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _index = i;
      _built.add(i);
    });
  }

  static const _items = [
    (Icons.space_dashboard_outlined, 'Home'),
    (Icons.people_outline_rounded, 'Clients'),
    (Icons.description_outlined, 'Reports'),
    (Icons.person_outline_rounded, 'Account'),
  ];

  Widget _page(int i) {
    if (!_built.contains(i)) return const SizedBox();
    switch (i) {
      case 0:
        return const HomePage();
      case 1:
        return const ClientsPage(embedded: true);
      case 2:
        return const AllReportsPage();
      default:
        return const AccountPage(embedded: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (did, _) {
        if (!did) _go(0);
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(children: [
        IndexedStack(index: _index, children: [for (var i = 0; i < 4; i++) RepaintBoundary(child: _page(i))]),
        Positioned(
          left: 12,
          right: 12,
          bottom: bottom > 0 ? bottom : 14,
          child: RepaintBoundary(
            child: Glass(
              radius: 20,
              blur: 22,
              liquid: true,
              tint: const Color(0x40081840),
              height: 66,
              padding: const EdgeInsets.all(5),
              child: Row(children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: Semantics(
                      selected: i == _index,
                      button: true,
                      label: _items[i].$2,
                      child: Pressable(
                        scale: .92,
                        onTap: () => _go(i),
                        child: Stack(alignment: Alignment.center, children: [
                          AnimatedOpacity(
                            duration: CkMotion.base,
                            opacity: i == _index ? 1 : 0,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 24,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: CkColors.cyan,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: const [BoxShadow(color: Color(0xCC5CE1FF), blurRadius: 10)],
                                ),
                              ),
                            ),
                          ),
                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(_items[i].$1, size: 22, color: i == _index ? CkColors.cyan : CkColors.textSecondary),
                            const SizedBox(height: 3),
                            Text(_items[i].$2,
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: i == _index ? Colors.white : CkColors.textSecondary)),
                          ]),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ]),
      ),
    );
  }
}

// ───────────────────────── Home dashboard

/// The client whose mID is used for client-free sky data until a
/// location-based transit API exists.
Future<Client?> skySource() async {
  final r = Session.recent;
  if (r.isNotEmpty) return r.first;
  try {
    final l = await fetchClients();
    return l.isEmpty ? null : l.first;
  } catch (_) {
    return null;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<GrahPos>?> _sky = _loadSky();
  late Future<Map<String, dynamic>> _credits = Api.post(Endpoints.credits, {'uID': Session.uid});
  late Future<List<ReportItem>> _reports = fetchReports();
  late Future<List<Client>> _clients = fetchClients();
  Timer? _tick;
  DateTime _now = DateTime.now();

  Future<List<GrahPos>?> _loadSky() async {
    final c = await skySource();
    if (c == null) return null;
    return ClientData(c.mId).transit(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    // Keep the greeting name current from the profile.
    Api.post(Endpoints.profileDetails, {'uID': Session.uid}).then((r) {
      final n = '${r['Name'] ?? ''}'.trim();
      if (n.isNotEmpty && n != 'null' && n != Session.prefs.getString('ck_user_name')) {
        Session.prefs.setString('ck_user_name', n);
        if (mounted) setState(() {});
      }
    }).catchError((_) {});
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _sky = _loadSky();
      _credits = Api.post(Endpoints.credits, {'uID': Session.uid});
      _reports = fetchReports();
      _clients = fetchClients();
    });
  }

  String get _greeting {
    final h = _now.hour;
    return h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final name = (Session.prefs.getString('ck_user_name') ?? '').split(' ').first;
    return CkScaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 74),
        child: _NewClientButton(onDone: _refresh),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 170),
            children: [
              Text(DateFormat('EEE · d MMM yyyy · HH:mm').format(_now).toUpperCase(), style: CkText.label),
              const SizedBox(height: 6),
              Text(name.isEmpty ? _greeting : '$_greeting, $name', style: CkText.h(26)),
              const SizedBox(height: 16),
              FadeSlideIn(
                child: Pressable(
                  scale: .985,
                  onTap: () => Get.to(() => const SearchPage(), transition: Transition.fadeIn),
                  child: Glass(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: const Row(children: [
                      Icon(Icons.search_rounded, size: 19, color: CkColors.labelMono),
                      SizedBox(width: 10),
                      Text('Search clients, reports, tools', style: TextStyle(fontSize: 14.5, color: CkColors.textSecondary)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(index: 1, child: _skyCard()),
              const SizedBox(height: 12),
              const FadeSlideIn(index: 2, child: PanchangNowCard()),
              const SizedBox(height: 18),
              FadeSlideIn(index: 3, child: _recent()),
              const SizedBox(height: 18),
              FadeSlideIn(index: 4, child: _reportsCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skyCard() => Pressable(
        scale: .985,
        onTap: () => Get.to(() => const SkyNowPage()),
        child: Glass(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: FutureBuilder<List<GrahPos>?>(
            future: _sky,
            builder: (c, s) {
              final l = s.data;
              GrahPos? f(String id) => l?.where((e) => e.id == id).firstOrNull;
              Widget read(String k, GrahPos? p, bool first) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
                      decoration: BoxDecoration(border: first ? null : const Border(left: BorderSide(color: Color(0x248CBEFF)))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(k.toUpperCase(), style: CkText.label),
                          if (p?.retro ?? false) const RetroBadge(),
                        ]),
                        const SizedBox(height: 4),
                        Text(p == null ? '—' : rashiName(p.rashi), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(p == null ? '' : fmtDegMin(p.degIn), style: CkText.mono(11, color: CkColors.textSecondary)),
                      ]),
                    ),
                  );
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('SKY NOW', style: CkText.label),
                  const Spacer(),
                  Text('● LIVE', style: CkText.mono(10.5, color: CkColors.cyan)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  SizedBox(
                    width: 104,
                    height: 104,
                    child: l == null
                        ? Center(
                            child: s.connectionState == ConnectionState.done
                                ? const Icon(Icons.public_rounded, color: CkColors.labelMono)
                                : const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: CkColors.cyan)))
                        : KundliChart(const [], transit: l),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l == null ? (s.connectionState == ConnectionState.done ? 'Add a client to see the sky' : 'Reading the sky…') : 'Transit at ${DateFormat('HH:mm').format(_now)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      if (l != null)
                        Text(
                          ['Ra', 'Ju', 'Sa'].map((id) => f(id)).whereType<GrahPos>().map((p) => '${kGrahNames[p.id]} in ${rashiName(p.rashi)}${p.retro ? ' (R)' : ''}').join(' · '),
                          style: const TextStyle(fontSize: 12.5, height: 1.4, color: CkColors.textSecondary),
                        ),
                      const SizedBox(height: 8),
                      const Row(children: [
                        Text('Open transit', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: CkColors.cyan)),
                        Icon(Icons.chevron_right_rounded, size: 16, color: CkColors.cyan),
                      ]),
                    ]),
                  ),
                ]),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: -14),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x248CBEFF)))),
                  child: Row(children: [read('Sun', f('Su'), true), read('Moon', f('Mo'), false), read('Jupiter', f('Ju'), false)]),
                ),
              ]);
            },
          ),
        ),
      );

  Widget _recent() => FutureBuilder<List<Client>>(
        future: _clients,
        builder: (c, s) {
          final all = s.data ?? [];
          var rec = Session.recent.where((r) => all.isEmpty || all.any((a) => a.mId == r.mId)).toList();
          if (rec.isEmpty) rec = all.take(5).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('RECENT CLIENTS', style: CkText.label),
              const Spacer(),
              GestureDetector(
                onTap: () => appTabRequest.value = 1,
                child: Text(all.isEmpty ? 'All clients' : 'All ${all.length}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: CkColors.cyan)),
              ),
            ]),
            const SizedBox(height: 10),
            if (rec.isEmpty)
              Glass(
                padding: const EdgeInsets.all(14),
                child: Text(s.connectionState == ConnectionState.done ? 'No clients yet.' : 'Loading…', style: CkText.muted),
              )
            else
              SizedBox(
                height: 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: rec.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final cl = all.firstWhere((a) => a.mId == rec[i].mId, orElse: () => rec[i]);
                    return Pressable(
                      onTap: () => openClient(cl),
                      child: Glass(
                        width: 156,
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x598CBEFF))),
                            child: Text(cl.initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          const Spacer(),
                          Text(cl.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 3),
                          Text(cl.birth == null ? cl.dateText : DateFormat('dd-MM-yyyy').format(cl.birth!),
                              style: CkText.mono(11, color: CkColors.textSecondary)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
          ]);
        },
      );

  Widget _reportsCard() => Glass(
        padding: const EdgeInsets.all(14),
        child: FutureBuilder<List<ReportItem>>(
          future: _reports,
          builder: (c, s) {
            final l = s.data ?? [];
            final weekAgo = DateTime.now().subtract(const Duration(days: 7));
            final gen = l.where((e) => e.pending).length;
            final week = l.where((e) => e.ready && (e.created?.isAfter(weekAgo) ?? false)).length;
            final latest = l.where((e) => e.ready).firstOrNull;
            Widget stat(String v, String label, Color col, {VoidCallback? onTap}) => Expanded(
                  child: GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      s.hasData || label == 'Credits' ? Text(v, style: CkText.mono(22, color: col)) : const Skeleton(height: 22, width: 36),
                      const SizedBox(height: 2),
                      Text(label, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                    ]),
                  ),
                );
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('REPORTS', style: CkText.label),
                const Spacer(),
                GestureDetector(
                  onTap: () => appTabRequest.value = 2,
                  child: const Text('History', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: CkColors.cyan)),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                stat('$gen', 'Generating', CkColors.cyan, onTap: () => appTabRequest.value = 2),
                stat('$week', 'Ready this week', const Color(0xFF10B981), onTap: () => appTabRequest.value = 2),
                FutureBuilder<Map<String, dynamic>>(
                  future: _credits,
                  builder: (c, cs) {
                    final v = num.tryParse('${cs.data?['Remaining_Credit'] ?? ''}');
                    final txt = v == null ? '—' : v >= 100000 ? '${(v / 100000).toStringAsFixed(1)}L' : NumberFormat.decimalPattern('en_IN').format(v);
                    return stat(txt, 'Credits', Colors.white, onTap: () => Get.to(() => const CreditsPage()));
                  },
                ),
              ]),
              if (latest != null) ...[
                const SizedBox(height: 12),
                ReportRow(latest, showClient: true, compact: true),
              ],
            ]);
          },
        ),
      );
}

class _NewClientButton extends StatelessWidget {
  final VoidCallback onDone;
  const _NewClientButton({required this.onDone});
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: () async {
          final r = await Get.to(() => const ClientFormPage());
          if (r != null) onDone();
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF07E22)]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Color(0x66F07E22), blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_rounded, color: Colors.white),
            SizedBox(width: 6),
            Text('New client', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ),
      );
}

// ───────────────────────── Sky now (transit with no client)

enum _Step { h, d, w, m, y, y10 }

class SkyNowPage extends StatefulWidget {
  const SkyNowPage({super.key});
  @override
  State<SkyNowPage> createState() => _SkyNowPageState();
}

class _SkyNowPageState extends State<SkyNowPage> {
  DateTime _at = DateTime.now();
  bool _live = true;
  _Step _step = _Step.d;
  Client? _src;
  Future<List<GrahPos>>? _f;
  List<GrahPos>? _last;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    skySource().then((c) {
      if (!mounted) return;
      setState(() {
        _src = c;
        _load();
      });
    });
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
    if (_src == null) return;
    _f = ClientData(_src!.mId).transit(_at)..then((v) => _last = v).catchError((_) => <GrahPos>[]);
  }

  void _set(DateTime t, {bool live = false}) => setState(() {
        _at = t;
        _live = live;
        _load();
      });

  DateTime _shift(int dir) {
    final a = _at;
    switch (_step) {
      case _Step.h:
        return a.add(Duration(hours: dir));
      case _Step.d:
        return a.add(Duration(days: dir));
      case _Step.w:
        return a.add(Duration(days: 7 * dir));
      case _Step.m:
        return DateTime(a.year, a.month + dir, a.day, a.hour, a.minute);
      case _Step.y:
        return DateTime(a.year + dir, a.month, a.day, a.hour, a.minute);
      case _Step.y10:
        return DateTime(a.year + 10 * dir, a.month, a.day, a.hour, a.minute);
    }
  }

  Future<void> _pick() async {
    final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(1900), lastDate: DateTime(2200));
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    _set(DateTime(d.year, d.month, d.day, t?.hour ?? _at.hour, t?.minute ?? _at.minute));
  }

  Client? _cmp;
  Future<List<GrahPos>>? _birth;

  Future<void> _compare() async {
    final all = await fetchClients();
    if (!mounted) return;
    final c = await showModalBottomSheet<Client>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (s) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .6,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 8), child: Text('Compare with a client', style: CkText.h(18))),
            Expanded(
              child: ListView(children: [
                for (final cl in all)
                  ListTile(
                    title: Text(cl.name),
                    subtitle: Text(cl.subtitle, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                    onTap: () => Navigator.pop(s, cl),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
    if (c == null || !mounted) return;
    // Stay on Transit: draw this client's birth chart with the transit on it.
    setState(() {
      _cmp = c;
      _birth = ClientData(c.mId).chart();
    });
  }

  @override
  Widget build(BuildContext context) {
    const steps = {_Step.h: '1H', _Step.d: '1D', _Step.w: '1W', _Step.m: '1M', _Step.y: '1Y', _Step.y10: '10Y'};
    final now = DateTime.now();
    final sameDay = _at.year == now.year && _at.month == now.month && _at.day == now.day;
    final when = '${sameDay ? 'Today' : DateFormat('d MMM yyyy').format(_at)} · ${DateFormat('HH:mm').format(_at)}';
    return CkScaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            Row(children: [
              CircleBtn(Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: () => Get.back()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Transit', style: CkText.h(19)),
                  const SizedBox(height: 2),
                  Text(_cmp == null ? 'Sky now${Here.name.isEmpty ? '' : ' · ${Here.name}'}' : 'With ${_cmp!.name}\'s chart',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                ]),
              ),
              Pressable(
                onTap: _pick,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: CkColors.orangeTint, borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.orangeStroke)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFFFD08A)),
                    const SizedBox(width: 6),
                    Text(when, style: CkText.mono(12, color: const Color(0xFFFFD08A))),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            FutureBuilder<List<GrahPos>>(
              future: _f,
              builder: (c, s) {
                final t = s.data ?? _last;
                if (_src == null && _f == null) {
                  return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Add a client first to read the sky.', style: CkText.muted)));
                }
                if (t == null) return const SkeletonCard(height: 340);
                return Column(children: [
                  Glass(
                    padding: const EdgeInsets.all(6),
                    child: Stack(children: [
                      FutureBuilder<List<GrahPos>>(
                        future: _birth,
                        builder: (c, b) => ZoomChart(child: KundliChart(b.data ?? const [], transit: t)),
                      ),
                      const Positioned(left: 10, top: 8, child: Text('Pinch to zoom', style: TextStyle(fontSize: 11, color: CkColors.textSecondary))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    for (final e in steps.entries)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: Pressable(
                            onTap: () => setState(() => _step = e.key),
                            child: AnimatedContainer(
                              duration: CkMotion.fast,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _step == e.key ? CkColors.orangeTint : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: _step == e.key ? CkColors.orangeStroke : CkColors.panelStroke),
                              ),
                              child: Text(e.value, style: CkText.mono(12.5, color: _step == e.key ? const Color(0xFFFFD08A) : CkColors.textTertiary)),
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
                      flex: 13,
                      child: Glass(
                        height: 46,
                        radius: 13,
                        child: Row(children: [
                          IconButton(onPressed: () => _set(_shift(-1)), icon: const Icon(Icons.chevron_left_rounded), tooltip: 'Step back'),
                          Expanded(child: Text('STEP ${steps[_step]}', textAlign: TextAlign.center, style: CkText.mono(12, color: CkColors.textSecondary))),
                          IconButton(onPressed: () => _set(_shift(1)), icon: const Icon(Icons.chevron_right_rounded), tooltip: 'Step forward'),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Pressable(
                    onTap: _compare,
                    child: Glass(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(children: [
                        const Icon(Icons.people_outline_rounded, size: 19, color: CkColors.cyan),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('Compare with a client', style: TextStyle(fontSize: 14))),
                        Text(_cmp == null ? 'Choose ▾' : '${_cmp!.name} ▾', style: const TextStyle(fontSize: 12.5, color: CkColors.textSecondary)),
                        if (_cmp != null)
                          GestureDetector(
                            onTap: () => setState(() {
                              _cmp = null;
                              _birth = null;
                            }),
                            child: const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.close_rounded, size: 18, color: CkColors.textSecondary)),
                          ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Glass(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('GRAH POSITIONS', style: CkText.label),
                      const SizedBox(height: 4),
                      for (final id in kGrahOrder)
                        if (id != 'As' && t.any((p) => p.id == id))
                          () {
                            final p = t.firstWhere((x) => x.id == id);
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1F8CBEFF)))),
                              child: Row(children: [
                                SizedBox(
                                  width: 52,
                                  child: Row(children: [
                                    GrahDot(p.id),
                                    const SizedBox(width: 6),
                                    Text(p.id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ]),
                                ),
                                Expanded(child: Text(rashiName(p.rashi), style: const TextStyle(fontSize: 13, color: CkColors.textTertiary))),
                                SizedBox(
                                  width: 90,
                                  child: Text(p.nakshatra, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                                ),
                                Text(fmtDegMin(p.degIn), style: CkText.mono(12.5)),
                                SizedBox(width: 9, child: p.retro ? const RetroBadge() : null),
                              ]),
                            );
                          }(),
                    ]),
                  ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Arrow(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        child: Glass(width: 64, height: 40, radius: 12, alignment: Alignment.center, child: Icon(icon, size: 22)),
      );
}

String svgForSky(List<GrahPos> t) => KundliSvg.transit(const [], t);
