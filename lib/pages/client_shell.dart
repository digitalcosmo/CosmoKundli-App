import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import 'blueprint_pages.dart';
import 'clients_page.dart';
import 'predictions_pages.dart';
import 'reports_pages.dart';
import 'traditional_pages.dart';
import 'trajectory_pages.dart';

class _Tab {
  final String label;
  final IconData icon;
  final Widget Function() root;
  final String? art; // software Menu_* icon
  const _Tab(this.label, this.icon, this.root, [this.art]);
}

final _tabs = <_Tab>[
  _Tab('BluePrint', Icons.blur_circular_rounded, () => const BlueprintSection(), 'blueprint'),
  _Tab('Trajectory', Icons.timeline_rounded, () => const TrajectorySection(), 'menu_transit'),
  _Tab('Predictions', Icons.auto_awesome_rounded, () => const PredictionsSection(), 'menu_sentiments'),
  _Tab('Reports', Icons.description_outlined, () => const ReportsSection(), 'menu_ck_planner'),
  _Tab('Traditional', Icons.light_mode_outlined, () => const TraditionalSection()),
];

/// Inside a client: five sections in a floating dock; each section keeps its
/// own navigation stack so the dock stays visible on module pages.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});
  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;
  final _keys = List.generate(_tabs.length, (_) => GlobalKey<NavigatorState>());

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
        if (nav != null && nav.canPop()) {
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
        radius: 22,
        blur: 22,
        tint: const Color(0x99081840),
        height: 68,
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
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x2478AAFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x38A0C3FF)),
                ),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 3),
                child: Container(
                  width: 14,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF07E22),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [BoxShadow(color: Color(0xCCF07E22), blurRadius: 8)],
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
                        _tabs[i].art != null
                            ? CkMenuIcon(_tabs[i].art!, size: 22, color: sel ? Colors.white : CkColors.textSecondary)
                            : Icon(_tabs[i].icon, size: 21, color: sel ? Colors.white : CkColors.textSecondary),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(_tabs[i].label,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: sel ? FontWeight.w600 : FontWeight.w600,
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
  const ClientPage(
      {super.key,
      required this.title,
      required this.children,
      this.isRoot = false,
      this.onRefresh,
      this.padding = const EdgeInsets.fromLTRB(14, 0, 14, 120)});

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
        for (var i = 0; i < children.length; i++) i < 7 ? FadeSlideIn(index: i, child: children[i]) : children[i],
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
              onSwitch: () => _switch(context),
              onMore: () {
                final c = Session.client.value;
                if (c != null) clientMenu(context, c, fromShell: true, onChanged: () {});
              },
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
                    if (!s.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
                    final l = s.data!.where((e) => e.name.toLowerCase().contains(_q)).toList();
                    return ListView.builder(
                      itemCount: l.length,
                      itemBuilder: (c, i) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(l[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(l[i].subtitle, style: CkText.muted.copyWith(fontSize: 12)),
                        trailing: Session.client.value?.mId == l[i].mId
                            ? const Icon(Icons.check_rounded, color: CkColors.orangeSoft)
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
