import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import '../core/astro.dart';
import '../core/client_data.dart';
import 'clients_page.dart';
import 'modules_page.dart';
import 'reports_pages.dart';
import 'workspace.dart';

class _Tab {
  final String label;
  final IconData icon;
  final Widget Function() root;
  const _Tab(this.label, this.icon, this.root);
}

final _tabs = <_Tab>[
  _Tab('Workspace', Icons.dashboard_customize_outlined, () => const WorkspacePage()),
  _Tab('Modules', Icons.track_changes_rounded, () => const ModulesPage()),
  _Tab('Reports', Icons.description_outlined, () => const ClientReportsPage()),
];

/// Inside a client: Workspace · Modules · Reports. Each tab keeps its own
/// navigation stack so the dock stays visible on module pages.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});
  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;
  final _keys = List.generate(_tabs.length, (_) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    workspaceEditing.value = false;
    clientTabRequest.addListener(_onRequest);
  }

  @override
  void dispose() {
    clientTabRequest.removeListener(_onRequest);
    super.dispose();
  }

  void _onRequest() {
    final i = clientTabRequest.value;
    if (i != null && mounted) {
      clientTabRequest.value = null;
      _keys[i].currentState?.popUntil((r) => r.isFirst);
      setState(() => _index = i);
    }
  }

  void _select(int i) {
    if (i == _index) {
      _keys[i].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _keys[_index].currentState;
        if (workspaceEditing.value) {
          workspaceEditing.value = false;
        } else if (nav != null && nav.canPop()) {
          nav.pop();
        } else {
          Get.back();
        }
      },
      child: CkScaffold(
        body: Stack(children: [
          IndexedStack(
            index: _index,
            children: List.generate(_tabs.length, (i) {
              return RepaintBoundary(
                child: HeroControllerScope.none(
                  child: Navigator(
                    key: _keys[i],
                    onGenerateRoute: (s) => PageRouteBuilder(
                        pageBuilder: (_, __, ___) => _tabs[i].root(),
                        transitionDuration: Duration.zero),
                  ),
                ),
              );
            }),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: RepaintBoundary(child: _Dock(index: _index, onTap: _select))),
        ]),
      ),
    );
  }
}

/// Lets other screens switch the client dock tab (e.g. ⋮ → Edit modules).
final ValueNotifier<int?> clientTabRequest = ValueNotifier(null);

class _Dock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _Dock({required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottom > 0 ? bottom : 14),
      child: Glass(
        radius: 20,
        blur: 22,
        liquid: true,
        tint: const Color(0x40081840),
        height: 66,
        padding: const EdgeInsets.all(5),
        child: LayoutBuilder(builder: (c, box) {
          final w = box.maxWidth / _tabs.length;
          return Stack(children: [
            AnimatedPositioned(
              duration: CkMotion.slow,
              curve: kEase,
              left: w * index,
              top: 0,
              bottom: 0,
              width: w,
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
            Row(
              children: List.generate(_tabs.length, (i) {
                final sel = i == index;
                return Expanded(
                  child: Semantics(
                    selected: sel,
                    button: true,
                    label: _tabs[i].label,
                    child: Pressable(
                      scale: .92,
                      onTap: () => onTap(i),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_tabs[i].icon, size: 22, color: sel ? CkColors.cyan : CkColors.textSecondary),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(_tabs[i].label,
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: sel ? Colors.white : CkColors.textSecondary)),
                        ),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ]);
        }),
      ),
    );
  }
}

/// Base page used for section roots and module pages inside a client.
class ClientPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isRoot;
  final Future<void> Function()? onRefresh;
  final EdgeInsets padding;
  final bool animate;
  const ClientPage(
      {super.key,
      required this.title,
      required this.children,
      this.isRoot = false,
      this.onRefresh,
      this.animate = true,
      this.padding = const EdgeInsets.fromLTRB(14, 0, 14, 120)});

  Future<void> _details(BuildContext context) async {
    final r = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (s) => const _DetailsSheet(),
    );
    if (!context.mounted) return;
    if (r == 'switch') {
      await _switch(context);
    } else if (r == 'edit') {
      final c = Session.client.value;
      if (c != null) await editClient(context, c);
    }
  }

  Future<void> _menu(BuildContext context) async {
    final c = Session.client.value;
    if (c == null) return;
    final r = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      builder: (s) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0x4DFFFFFF), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: CkColors.cyan),
              title: const Text('Edit client'),
              onTap: () => Navigator.pop(s, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_customize_outlined, color: CkColors.cyan),
              title: const Text('Edit modules'),
              subtitle: const Text('Add, move and resize workspace modules', style: TextStyle(fontSize: 12, color: CkColors.textSecondary)),
              onTap: () => Navigator.pop(s, 'modules'),
            ),
          ]),
        ),
      ),
    );
    if (!context.mounted) return;
    if (r == 'edit') {
      await editClient(context, c);
    } else if (r == 'modules') {
      clientTabRequest.value = 0;
      workspaceEditing.value = true;
    }
  }

  Future<void> _switch(BuildContext context) async {
    final c = await showModalBottomSheet<Client>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (s) => _SwitchSheet(),
    );
    if (c != null) {
      Session.open(c);
      Get.off(() => const ClientShell(), preventDuplicates: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: padding,
      children: [
        for (var i = 0; i < children.length; i++) animate && i < 7 ? FadeSlideIn(index: i, child: children[i]) : children[i],
      ],
    );
    return CkBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            ClientHeader(
              title: title,
              onBack: () {
                if (isRoot) {
                  Get.back();
                } else {
                  Navigator.of(context).pop();
                }
              },
              onSwitch: () => _details(context),
              onMore: () => _menu(context),
            ),
            Expanded(child: onRefresh == null ? list : RefreshIndicator(onRefresh: onRefresh!, child: list)),
          ]),
        ),
      ),
    );
  }
}

void pushModule(BuildContext context, Widget page) =>
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));

class _SwitchSheet extends StatefulWidget {
  @override
  State<_SwitchSheet> createState() => _SwitchSheetState();
}

class _SwitchSheetState extends State<_SwitchSheet> {
  final _f = fetchClients();
  String _q = '';
  @override
  Widget build(BuildContext context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .72,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: CkColors.glassStroke, borderRadius: BorderRadius.circular(3)))),
              const SizedBox(height: 12),
              Text('Switch client', style: CkText.h(18)),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => setState(() => _q = v.toLowerCase()),
                decoration: const InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search_rounded)),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: FutureBuilder<List<Client>>(
                  future: _f,
                  builder: (c, s) {
                    if (!s.hasData) return const SkeletonList(rows: 7);
                    final l = s.data!.where((e) => e.name.toLowerCase().contains(_q)).toList();
                    return ListView.builder(
                      itemCount: l.length,
                      itemBuilder: (c, i) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(l[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(l[i].subtitle, style: CkText.muted.copyWith(fontSize: 12)),
                        trailing: Session.client.value?.mId == l[i].mId
                            ? const Icon(Icons.check_rounded, color: CkColors.cyan)
                            : null,
                        onTap: () => Navigator.pop(context, l[i]),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      );
}

class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet();

  Widget _row(String k, String v, {bool mono = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1A8CBEFF)))),
        child: Row(children: [
          SizedBox(width: 120, child: Text(k, style: const TextStyle(fontSize: 14, color: CkColors.textSecondary))),
          Expanded(child: Text(v.isEmpty ? '—' : v, textAlign: TextAlign.right, style: mono ? CkText.mono(13.5) : const TextStyle(fontSize: 14))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final c = Session.client.value;
    if (c == null) return const SizedBox();
    final data = ClientData.of(c.mId);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0x4DFFFFFF), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Row(children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x668CBEFF))),
              child: Text(c.initials, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: CkText.h(18)),
                const SizedBox(height: 3),
                FutureBuilder<List<GrahPos>>(
                  future: data.chart(),
                  builder: (_, s) {
                    if (!s.hasData) return const SizedBox(height: 14);
                    String r(String id) => rashiName(s.data!.where((e) => e.id == id).firstOrNull?.rashi ?? 0).toUpperCase();
                    return Text('SUN ${r('Su')} · MOON ${r('Mo')} · LAGNA ${r('As')}', style: CkText.label.copyWith(fontSize: 10));
                  },
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Glass(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: FutureBuilder<Map<String, dynamic>>(
              future: data.details(),
              builder: (_, s) {
                final d = s.data ?? const {};
                String f(List<String> keys) {
                  for (final k in keys) {
                    final v = '${d[k] ?? ''}'.trim();
                    if (v.isNotEmpty && v != 'null') return v;
                  }
                  return '';
                }
                final tz = f(['timm_diff', 'time_diff', 'timezone']);
                final tzText = tz.isEmpty
                    ? ''
                    : () {
                        final m = int.tryParse(tz) ?? 0;
                        final sign = m < 0 ? '-' : '+';
                        final a = m.abs();
                        return 'UTC $sign${(a ~/ 60).toString().padLeft(2, '0')}:${(a % 60).toString().padLeft(2, '0')}';
                      }();
                final lat = f(['latitude', 'lat']), lng = f(['longitude', 'lng']);
                return Column(children: [
                  _row('Gender', c.genderText),
                  _row('Date of birth', c.birth == null ? c.dateText : DateFormat('dd-MM-yyyy').format(c.birth!), mono: true),
                  _row('Time of birth', c.birth == null ? c.timeText : DateFormat('HH:mm:ss').format(c.birth!), mono: true),
                  _row('Place', f(['birth_place', 'City', 'city']).isEmpty ? c.city : f(['birth_place', 'City', 'city'])),
                  if (lat.isNotEmpty) _row('Coordinates', '${double.tryParse(lat)?.toStringAsFixed(4) ?? lat} · ${double.tryParse(lng)?.toStringAsFixed(4) ?? lng}', mono: true),
                  if (tzText.isNotEmpty) _row('Time zone', tzText, mono: true),
                  if (f(['mobile', 'Mobile']).isNotEmpty) _row('Mobile', f(['mobile', 'Mobile']), mono: true),
                ]);
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: GhostButton('Edit', icon: Icons.edit_outlined, onTap: () => Navigator.pop(context, 'edit'))),
            const SizedBox(width: 10),
            Expanded(child: GhostButton('Switch client', icon: Icons.people_outline_rounded, onTap: () => Navigator.pop(context, 'switch'))),
          ]),
        ]),
      ),
    );
  }
}
