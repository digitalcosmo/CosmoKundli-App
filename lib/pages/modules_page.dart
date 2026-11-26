import 'package:flutter/material.dart';

import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import 'client_shell.dart';
import 'workspace.dart';

/// Every module, under the software's group names, from the one registry
/// the workspace also uses. Tapping one opens it full screen.
Map<String, List<WModule>> get _groups {
  final g = <String, List<WModule>>{};
  for (final m in kWorkspaceModules.values) {
    g.putIfAbsent(m.group, () => []).add(m);
  }
  return g;
}

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text('TAP A MODULE TO OPEN IT FULL SCREEN', style: CkText.label.copyWith(fontSize: 9.5)),
    ];
    for (final g in _groups.entries) {
      children.add(Padding(padding: const EdgeInsets.only(top: 16, bottom: 7), child: Text(g.key.toUpperCase(), style: CkText.label)));
      children.add(Glass(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Column(children: [
          for (var i = 0; i < g.value.length; i++)
            _row(context, g.value[i], first: i == 0),
        ]),
      ));
    }
    return ClientPage(title: 'Modules', isRoot: true, children: children);
  }

  Widget _row(BuildContext context, WModule m, {bool first = false}) {
    final soon = m.soon;
    final icon = ckIconAsset(m.title);
    return Opacity(
      opacity: soon ? .5 : 1,
      child: Pressable(
        scale: .985,
        onTap: soon ? null : () => pushModule(context, m.page!()),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0x1A8CBEFF)))),
          child: Row(children: [
            icon == null
                ? const Icon(Icons.blur_on_rounded, color: CkColors.cyan, size: 26)
                : Image.asset(icon, width: 26, height: 26, filterQuality: FilterQuality.medium),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(m.sub, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
              ]),
            ),
            if (!soon) const Icon(Icons.chevron_right_rounded, color: CkColors.labelMono),
          ]),
        ),
      ),
    );
  }
}
