import 'package:flutter/material.dart';

import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';
import 'blueprint_pages.dart';
import 'client_shell.dart';
import 'predictions_pages.dart';
import 'traditional_pages.dart';
import 'trajectory_pages.dart';

class _Mod {
  final String title;
  final String sub;
  final Widget Function()? page;
  const _Mod(this.title, this.sub, [this.page]);
}

/// Every module, under the software's group names. Tapping one opens it
/// full screen.
final _groups = <String, List<_Mod>>{
  'BluePrint': [
    _Mod('CosmoKundli', 'Birth chart · circle', () => const KundliPage()),
    _Mod('GRAH Coordinates', 'Rashi, degree, nakshatra', () => const CoordinatesPage()),
    _Mod('Power', 'Strength of each GRAH', () => const StrengthPage(flavor: false)),
    _Mod('Flavor', 'Nature of each GRAH', () => const StrengthPage(flavor: true)),
  ],
  'Trajectory': [
    _Mod('Transit', 'Birth vs any moment', () => const TransitPage()),
    _Mod('GRAH Vibes', 'Coming soon'),
    _Mod('GRAH Intensity', 'Coming soon'),
  ],
  'Predictions': [
    _Mod('Sentiments', 'Daily, month by month', () => const SentimentsPage()),
    _Mod('Situations', 'Coming soon'),
    _Mod('Sentiments 5D', 'Coming soon'),
  ],
  'Traditional': [
    _Mod('Panchang', 'At the moment of birth', () => const PanchangPage()),
    _Mod('Melapak', 'Match with a partner', () => const MelapakPage()),
  ],
};

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

  Widget _row(BuildContext context, _Mod m, {bool first = false}) {
    final soon = m.page == null;
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
