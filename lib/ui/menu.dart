// The one dropdown of the app (Controls family). Every menu, picker and
// "▾" list opens through [showCkMenu] or [CkMenuButton]; the build check
// fails on PopupMenuButton / MenuAnchor / showMenu / DropdownButton anywhere
// else. One look and one motion for all of them:
// - frosted glass panel, rounded 16, hairline stroke, soft shadow;
// - anchored to what was tapped: below it when there is room, above it
//   otherwise, never under the dock, the status bar or the screen edges;
// - long lists scroll inside the panel, opened at the picked item;
// - opens in 220 ms (fade, scale .94 -> 1 and a 6 px drift from the anchor),
//   closes in 150 ms; reduced motion: instant;
// - picked item in cyan with a check; a light haptic on pick.
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ck_theme.dart';
import 'glass.dart' show kEase;
import 'widgets.dart' show CkText;

class CkMenuItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final String? trailing; // a count or a hint, right-aligned
  final bool divider; // a hairline above this item
  /// Multi choice: an "All" item. Picking it clears the others; picking any
  /// other item unticks it; an empty pick ticks it again.
  final bool exclusive;
  const CkMenuItem(this.value, this.label, {this.icon, this.trailing, this.divider = false, this.exclusive = false});
}

/// Room kept free at the bottom for the floating dock (66 + 14 gap + air).
const double kDockClearance = 92;
const double _row = 44;

/// Opens the menu under (or over) [anchor]'s widget. Single choice: returns
/// the picked value (null if dismissed). Multi choice ([multi] true): the
/// menu stays open, [onToggle] fires with the new set on every tap.
Future<T?> showCkMenu<T>(
  BuildContext anchor, {
  required List<CkMenuItem<T>> items,
  T? selected,
  Set<T>? multi,
  ValueChanged<Set<T>>? onToggle,
  double minWidth = 168,
  double maxWidth = 280,
}) {
  final box = anchor.findRenderObject() as RenderBox;
  final rect = box.localToGlobal(Offset.zero) & box.size;
  return Navigator.of(anchor).push<T>(_MenuRoute<T>(
    rect: rect,
    items: items,
    selected: selected,
    multi: multi,
    onToggle: onToggle,
    minWidth: math.max(minWidth, rect.width),
    maxWidth: math.max(maxWidth, rect.width),
    still: MediaQuery.maybeDisableAnimationsOf(anchor) ?? false,
  ));
}

/// A tappable [child] that opens the menu and reports the pick.
class CkMenuButton<T> extends StatelessWidget {
  final List<CkMenuItem<T>> items;
  final T? value;
  final ValueChanged<T> onSelected;
  final Widget child;
  final double minWidth;
  const CkMenuButton({super.key, required this.items, required this.value, required this.onSelected, required this.child, this.minWidth = 168});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final v = await showCkMenu<T>(context, items: items, selected: value, minWidth: minWidth);
            if (v != null) onSelected(v);
          },
          // at least a 44 px touch target, whatever the child's size
          child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 44), child: Center(widthFactor: 1, child: child)),
        ),
      );
}

class _MenuRoute<T> extends PopupRoute<T> {
  final Rect rect;
  final List<CkMenuItem<T>> items;
  final T? selected;
  final Set<T>? multi;
  final ValueChanged<Set<T>>? onToggle;
  final double minWidth, maxWidth;
  final bool still;
  _MenuRoute({required this.rect, required this.items, this.selected, this.multi, this.onToggle, required this.minWidth, required this.maxWidth, required this.still});

  @override
  Color? get barrierColor => null;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Close menu';
  @override
  Duration get transitionDuration => still ? Duration.zero : const Duration(milliseconds: 220);
  @override
  Duration get reverseTransitionDuration => still ? Duration.zero : const Duration(milliseconds: 150);

  @override
  Widget buildPage(BuildContext context, Animation<double> a, Animation<double> b) {
    final mq = MediaQuery.of(context);
    final top = mq.padding.top + 8;
    final bottom = mq.size.height - mq.padding.bottom - kDockClearance;
    final h = items.length * _row + 12.0;
    final below = bottom - rect.bottom - 6;
    final above = rect.top - 6 - top;
    final down = below >= math.min(h, 4.5 * _row) || below >= above;
    final room = math.max(_row * 2.5, down ? below : above);
    final height = math.min(h, room);
    final panelW = math.min(math.min(minWidth, maxWidth), mq.size.width - 24);
    final left = (rect.center.dx - panelW / 2).clamp(12.0, mq.size.width - 12 - panelW);
    final y = down ? rect.bottom + 6 : rect.top - 6 - height;
    final curve = CurvedAnimation(parent: a, curve: kEase, reverseCurve: Curves.easeIn);
    return Stack(children: [
      Positioned(
        left: left,
        top: y,
        width: panelW,
        height: height,
        child: AnimatedBuilder(
          animation: curve,
          builder: (c, k) => Opacity(
            opacity: curve.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - curve.value) * (down ? -6 : 6)),
              child: Transform.scale(
                scale: .94 + .06 * curve.value,
                alignment: down ? Alignment.topCenter : Alignment.bottomCenter,
                child: k,
              ),
            ),
          ),
          child: _Panel<T>(route: this),
        ),
      ),
    ]);
  }
}

class _Panel<T> extends StatefulWidget {
  final _MenuRoute<T> route;
  const _Panel({super.key, required this.route});
  @override
  State<_Panel<T>> createState() => _PanelState<T>();
}

class _PanelState<T> extends State<_Panel<T>> {
  late final Set<T>? _set = widget.route.multi == null ? null : {...widget.route.multi!};
  late final ScrollController _sc;

  @override
  void initState() {
    super.initState();
    final i = widget.route.items.indexWhere((e) => e.value == widget.route.selected);
    // open at the picked item, a row of context above it
    _sc = ScrollController(initialScrollOffset: i <= 1 ? 0 : (i - 1) * _row);
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  bool _on(T v) => _set != null ? _set!.contains(v) : v == widget.route.selected;

  void _tap(CkMenuItem<T> e) {
    HapticFeedback.selectionClick();
    if (_set == null) {
      Navigator.of(context).pop(e.value);
      return;
    }
    final all = widget.route.items.where((x) => x.exclusive).map((x) => x.value).toSet();
    setState(() {
      if (e.exclusive) {
        _set!
          ..clear()
          ..add(e.value);
      } else {
        _set!.removeAll(all);
        if (!_set!.remove(e.value)) _set!.add(e.value);
        if (_set!.isEmpty) _set!.addAll(all);
      }
    });
    widget.route.onToggle?.call({..._set!});
  }

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(16);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: r, boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 12))]),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xE61A3E86), Color(0xEB102B66)]),
              border: Border.all(color: CkColors.panelStroke),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: ListView(
                controller: _sc,
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  for (final e in widget.route.items) ...[
                    if (e.divider) const Divider(height: 9, thickness: 1, indent: 12, endIndent: 12, color: CkColors.panelStroke),
                    _Row(item: e, on: _on(e.value), multi: _set != null, onTap: () => _tap(e)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final CkMenuItem item;
  final bool on, multi;
  final VoidCallback onTap;
  const _Row({required this.item, required this.on, required this.multi, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: const Color(0x225CE1FF),
        highlightColor: const Color(0x145CE1FF),
        child: Container(
          height: _row,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: on && !multi ? const Color(0x1A5CE1FF) : null, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            if (multi) ...[
              AnimatedContainer(
                duration: CkMotion.fast,
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: on ? CkColors.cyan : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: on ? CkColors.cyan : const Color(0x808CBEFF), width: 1.5),
                ),
                child: on ? const Icon(Icons.check_rounded, size: 13, color: Color(0xFF06204F)) : null,
              ),
              const SizedBox(width: 10),
            ] else if (item.icon != null) ...[
              Icon(item.icon, size: 17, color: on ? CkColors.cyan : CkColors.labelMono),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.5, fontWeight: on ? FontWeight.w600 : FontWeight.w400, color: on ? (multi ? Colors.white : CkColors.cyan) : CkColors.textTertiary)),
            ),
            if (item.trailing != null) Text(item.trailing!, style: CkText.mono(11, color: CkColors.labelMono)),
            if (!multi && on) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_rounded, size: 17, color: CkColors.cyan)),
          ]),
        ),
      );
}
