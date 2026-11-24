import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../core/astro.dart';
import '../core/client_data.dart';
import '../core/session.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/kundli_svg.dart';
import '../ui/widgets.dart';
import 'blueprint_pages.dart';
import 'client_shell.dart';
import 'predictions_pages.dart';
import 'trajectory_pages.dart';

/// Widget sizes on the 2-column workspace grid.
enum WSize { s, w, t, l }

extension WSizeX on WSize {
  int get cols => this == WSize.w || this == WSize.l ? 2 : 1;
  int get rows => this == WSize.t || this == WSize.l ? 2 : 1;
  String get label => const {WSize.s: 'Small', WSize.w: 'Wide', WSize.t: 'Tall', WSize.l: 'Large'}[this]!;
  static WSize of(int cols, int rows) => cols == 2 ? (rows == 2 ? WSize.l : WSize.w) : (rows == 2 ? WSize.t : WSize.s);
}

class WItem {
  final String id;
  WSize size;
  WItem(this.id, this.size);
  Map<String, dynamic> toJson() => {'id': id, 'size': size.name};
  static WItem? fromJson(dynamic j) {
    if (j is! Map) return null;
    final id = '${j['id']}';
    if (!kWorkspaceModules.containsKey(id)) return null;
    final s = WSize.values.firstWhere((e) => e.name == j['size'], orElse: () => kWorkspaceModules[id]!.defaultSize);
    return WItem(id, s);
  }
}

/// A module that can live on the workspace.
class WModule {
  final String id;
  final String title;
  final String group; // software group
  final WSize defaultSize;
  final Widget Function(String mId, WSize size) build;
  final Widget Function() page;
  const WModule(this.id, this.title, this.group, this.defaultSize, this.build, this.page);
}

final kWorkspaceModules = <String, WModule>{
  'kundli': WModule('kundli', 'CosmoKundli', 'BluePrint', WSize.l, (m, s) => _KundliW(m, s), () => const KundliPage()),
  'degree': WModule('degree', 'Degree', 'BluePrint', WSize.t, (m, s) => _DegreeW(m, s), () => const CoordinatesPage()),
  'power': WModule('power', 'Power', 'BluePrint', WSize.s, (m, s) => _BarsW(m, s, flavor: false), () => const StrengthPage(flavor: false)),
  'flavor': WModule('flavor', 'Flavor', 'BluePrint', WSize.s, (m, s) => _BarsW(m, s, flavor: true), () => const StrengthPage(flavor: true)),
  'transit': WModule('transit', 'Transit', 'Trajectory', WSize.w, (m, s) => _TransitW(m, s), () => const TransitPage()),
  'sentiments': WModule('sentiments', 'Sentiments', 'Predictions', WSize.w, (m, s) => _SentimentsW(m, s), () => const SentimentsPage()),
};

/// Saved layouts. The first is the default a client opens on.
const kLayouts = ['Live session', 'Preparation', 'Delivery'];

List<WItem> _defaultLayout(String name) {
  switch (name) {
    case 'Preparation':
      return [WItem('kundli', WSize.l), WItem('degree', WSize.t), WItem('power', WSize.s), WItem('flavor', WSize.s), WItem('sentiments', WSize.w)];
    case 'Delivery':
      return [WItem('sentiments', WSize.w), WItem('transit', WSize.w), WItem('kundli', WSize.l)];
    default:
      return [
        WItem('kundli', WSize.l),
        WItem('degree', WSize.t),
        WItem('power', WSize.s),
        WItem('flavor', WSize.s),
        WItem('transit', WSize.w),
        WItem('sentiments', WSize.w),
      ];
  }
}

class WorkspaceStore {
  static String _key(String layout) => 'ws_layout_$layout';
  static String get active => Session.prefs.getString('ws_active') ?? kLayouts.first;
  static set active(String v) => Session.prefs.setString('ws_active', v);

  static List<WItem> load(String layout) {
    final raw = Session.prefs.getString(_key(layout));
    if (raw == null) return _defaultLayout(layout);
    try {
      final l = (jsonDecode(raw) as List).map(WItem.fromJson).whereType<WItem>().toList();
      return l;
    } catch (_) {
      return _defaultLayout(layout);
    }
  }

  static void save(String layout, List<WItem> items) =>
      Session.prefs.setString(_key(layout), jsonEncode(items.map((e) => e.toJson()).toList()));
}

/// Opens the workspace in edit mode (from the client ⋮ menu).
final ValueNotifier<bool> workspaceEditing = ValueNotifier(false);

// ───────────────────────── page

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});
  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  late String _layout = WorkspaceStore.active;
  late List<WItem> _items = WorkspaceStore.load(_layout);

  // drag-to-move
  int? _dragging;
  Offset _dragPos = Offset.zero;
  Offset _grab = Offset.zero;
  // drag-to-resize
  int? _resizing;
  Rect? _resizeRect;

  static const double _gap = 10;
  static const double _unit = 228;

  @override
  void initState() {
    super.initState();
    workspaceEditing.addListener(_onEdit);
  }

  @override
  void dispose() {
    workspaceEditing.removeListener(_onEdit);
    super.dispose();
  }

  void _onEdit() => setState(() {});
  bool get _edit => workspaceEditing.value;

  void _save() => WorkspaceStore.save(_layout, _items);

  void _switchLayout(String l) {
    if (l == _layout) return;
    HapticFeedback.selectionClick();
    setState(() {
      _layout = l;
      WorkspaceStore.active = l;
      _items = WorkspaceStore.load(l);
    });
  }

  /// First-fit packing on a 2-column grid.
  List<Rect> _pack(List<WItem> items, double width) {
    final cw = (width - _gap) / 2;
    final occ = <List<bool>>[];
    bool free(int r, int c) {
      while (occ.length <= r) {
        occ.add([false, false]);
      }
      return !occ[r][c];
    }

    final out = <Rect>[];
    for (final it in items) {
      final cols = it.size.cols, rows = it.size.rows;
      var placed = false;
      for (var r = 0; !placed; r++) {
        for (var c = 0; c + cols <= 2 && !placed; c++) {
          var ok = true;
          for (var dr = 0; dr < rows && ok; dr++) {
            for (var dc = 0; dc < cols && ok; dc++) {
              ok = free(r + dr, c + dc);
            }
          }
          if (ok) {
            for (var dr = 0; dr < rows; dr++) {
              for (var dc = 0; dc < cols; dc++) {
                occ[r + dr][c + dc] = true;
              }
            }
            out.add(Rect.fromLTWH(c * (cw + _gap), r * (_unit + _gap), cols * cw + (cols - 1) * _gap, rows * _unit + (rows - 1) * _gap));
            placed = true;
          }
        }
      }
    }
    return out;
  }

  final _stackKey = GlobalKey();
  double _stackWidth = 0;

  Offset _toStack(Offset global) {
    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    return box == null ? global : box.globalToLocal(global);
  }

  void _autoScroll(Offset global) {
    final pos = Scrollable.maybeOf(_stackKey.currentContext ?? context)?.position;
    if (pos == null) return;
    final h = MediaQuery.of(context).size.height;
    const edge = 110.0;
    double dy = 0;
    if (global.dy < edge) dy = -(edge - global.dy) / 6;
    if (global.dy > h - edge) dy = (global.dy - (h - edge)) / 6;
    if (dy != 0) pos.jumpTo((pos.pixels + dy).clamp(pos.minScrollExtent, pos.maxScrollExtent));
  }

  DateTime _lastSwap = DateTime(0);

  void _moveTo(Offset p, List<Rect> rects) {
    if (_dragging == null) return;
    if (DateTime.now().difference(_lastSwap) < const Duration(milliseconds: 280)) return;
    for (var i = 0; i < rects.length; i++) {
      // Only swap once the finger is past the middle of the target tile, so
      // the order doesn't flip back and forth on the boundary.
      final core = rects[i].deflate(rects[i].shortestSide * .22);
      if (i != _dragging && core.contains(p)) {
        _lastSwap = DateTime.now();
        final it = _items.removeAt(_dragging!);
        _items.insert(i, it);
        _dragging = i;
        HapticFeedback.selectionClick();
        break;
      }
    }
  }

  Future<void> _reset() async {
    final ok = await confirm(context, 'Reset $_layout?',
        'Modules, order and sizes go back to the default for this layout. Other layouts stay as they are.',
        ok: 'Reset');
    if (!ok) return;
    setState(() {
      _items = _defaultLayout(_layout);
      _save();
    });
  }

  Future<void> _add() async {
    final id = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (c) => _AddSheet(on: _items.map((e) => e.id).toSet()),
    );
    if (id == null) return;
    setState(() {
      final i = _items.indexWhere((e) => e.id == id);
      if (i >= 0) {
        _items.removeAt(i);
      } else {
        _items.add(WItem(id, kWorkspaceModules[id]!.defaultSize));
      }
      _save();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Session.client.value;
    final mId = c?.mId ?? '';
    return ClientPage(
      title: 'Workspace',
      isRoot: true,
      animate: false,
      pinned: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: 36,
          child: Row(children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final l in kLayouts)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _Chip(l, selected: l == _layout, onTap: () => _switchLayout(l)),
                    ),
                ],
              ),
            ),
            if (_edit) ...[
              const SizedBox(width: 6),
              Semantics(
                button: true,
                label: 'Add module',
                child: Pressable(
                  onTap: _add,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.cyanStroke)),
                    child: const Icon(Icons.add_rounded, size: 20, color: CkColors.cyan),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _Chip('Done', filled: true, onTap: () {
                _save();
                workspaceEditing.value = false;
              }),
            ],
          ]),
        ),
        if (_edit)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              Expanded(child: Text('HOLD TO MOVE · DRAG ANY EDGE OR CORNER TO RESIZE', style: CkText.label.copyWith(fontSize: 9.5))),
              GestureDetector(
                onTap: _reset,
                child: const Row(children: [
                  Icon(Icons.restart_alt_rounded, size: 15, color: CkColors.textSecondary),
                  SizedBox(width: 3),
                  Text('Reset', style: TextStyle(fontSize: 12.5, color: CkColors.textSecondary)),
                ]),
              ),
            ]),
          ),
      ]),
      onRefresh: () async {
        ClientData.of(mId).chart(refresh: true);
        ClientData.of(mId).shadbal(refresh: true);
        setState(() {});
      },
      children: [
        const SizedBox(height: 4),
        LayoutBuilder(builder: (ctx, box) {
          _stackWidth = box.maxWidth;
          final rects = _pack(_items, box.maxWidth);
          final h = rects.isEmpty ? 120.0 : rects.map((r) => r.bottom).reduce(math.max);
          if (_items.isEmpty) {
            return Glass(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text('Your workspace is empty', style: CkText.h(15)),
                const SizedBox(height: 6),
                const Text('Add the modules you use most.', style: CkText.muted),
                const SizedBox(height: 12),
                _Chip('+ Add module', filled: true, onTap: _add),
              ]),
            );
          }
          return SizedBox(
            key: _stackKey,
            height: h,
            child: Stack(clipBehavior: Clip.none, children: [
              for (var i = 0; i < _items.length; i++)
                AnimatedPositioned(
                    key: ValueKey(_items[i].id),
                    duration: const Duration(milliseconds: 320),
                    curve: kEase,
                    left: rects[i].left,
                    top: rects[i].top,
                    width: rects[i].width,
                    height: rects[i].height,
                    // The tile being dragged stays in the tree as a faded
                    // placeholder, so its gesture recognizer keeps tracking.
                    child: AnimatedOpacity(
                      duration: CkMotion.fast,
                      opacity: i == _dragging ? .22 : 1,
                      child: _tile(i, mId, rects),
                    ),
                  ),
              if (_resizing != null && _resizeRect != null)
                Positioned.fromRect(
                  rect: _resizeRect!,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CkColors.cyan, width: 1.5),
                        color: CkColors.cyanTint,
                      ),
                      alignment: Alignment.center,
                      child: Text(_items[_resizing!].size.label.toUpperCase(), style: CkText.mono(12, color: CkColors.cyan)),
                    ),
                  ),
                ),
              if (_dragging != null)
                Positioned(
                  left: _dragPos.dx - _grab.dx,
                  top: _dragPos.dy - _grab.dy,
                  width: rects[_dragging!].width,
                  height: rects[_dragging!].height,
                  child: IgnorePointer(
                    child: Transform.scale(
                      scale: 1.03,
                      child: Opacity(opacity: .92, child: _tile(_dragging!, mId, rects, floating: true)),
                    ),
                  ),
                ),
            ]),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  /// A resize handle at side (dx, dy): -1/0/1 for left/centre/right and
  /// top/middle/bottom. Edges move only their own side of the tile.
  Widget _handle(int i, List<Rect> rects, int dx, int dy) {
    final corner = dx != 0 && dy != 0;
    const hit = 34.0;
    final bar = corner
        ? Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              border: Border(
                left: dx < 0 ? const BorderSide(color: CkColors.cyan, width: 2.5) : BorderSide.none,
                right: dx > 0 ? const BorderSide(color: CkColors.cyan, width: 2.5) : BorderSide.none,
                top: dy < 0 ? const BorderSide(color: CkColors.cyan, width: 2.5) : BorderSide.none,
                bottom: dy > 0 ? const BorderSide(color: CkColors.cyan, width: 2.5) : BorderSide.none,
              ),
              borderRadius: BorderRadius.only(
                topLeft: dx < 0 && dy < 0 ? const Radius.circular(7) : Radius.zero,
                topRight: dx > 0 && dy < 0 ? const Radius.circular(7) : Radius.zero,
                bottomLeft: dx < 0 && dy > 0 ? const Radius.circular(7) : Radius.zero,
                bottomRight: dx > 0 && dy > 0 ? const Radius.circular(7) : Radius.zero,
              ),
            ),
          )
        : Container(
            width: dx == 0 ? 28 : 5,
            height: dy == 0 ? 28 : 5,
            decoration: BoxDecoration(
              color: CkColors.cyan,
              borderRadius: BorderRadius.circular(3),
              boxShadow: const [BoxShadow(color: Color(0x995CE1FF), blurRadius: 8)],
            ),
          );
    return Positioned(
      left: dx < 0 ? -hit / 2 + 3 : (dx == 0 ? 0 : null),
      right: dx > 0 ? -hit / 2 + 3 : (dx == 0 ? 0 : null),
      top: dy < 0 ? -hit / 2 + 3 : (dy == 0 ? 0 : null),
      bottom: dy > 0 ? -hit / 2 + 3 : (dy == 0 ? 0 : null),
      child: Align(
        child: RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: {
            _EagerPan: GestureRecognizerFactoryWithHandlers<_EagerPan>(
              () => _EagerPan(),
              (r) => r
                ..onStart = (_) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _resizing = i;
                    _resizeRect = rects[i];
                  });
                }
                ..onUpdate = (d) {
                  final r = _resizeRect!;
                  final nr = Rect.fromLTRB(
                    r.left + (dx < 0 ? d.delta.dx : 0),
                    r.top + (dy < 0 ? d.delta.dy : 0),
                    r.right + (dx > 0 ? d.delta.dx : 0),
                    r.bottom + (dy > 0 ? d.delta.dy : 0),
                  );
                  final cw = (_stackWidth - _gap) / 2;
                  final cols = dx == 0 ? _items[i].size.cols : (nr.width > cw * 1.45 ? 2 : 1);
                  final rows = dy == 0 ? _items[i].size.rows : (nr.height > _unit * 1.45 ? 2 : 1);
                  final ns = WSizeX.of(cols, rows);
                  setState(() {
                    _resizeRect = nr;
                    if (ns != _items[i].size) {
                      HapticFeedback.selectionClick();
                      _items[i].size = ns;
                    }
                  });
                }
                ..onEnd = (_) {
                  setState(() {
                    _resizing = null;
                    _resizeRect = null;
                    _save();
                  });
                },
            ),
          },
          child: SizedBox(width: dx == 0 ? 56 : hit, height: dy == 0 ? 56 : hit, child: Center(child: bar)),
        ),
      ),
    );
  }

  Widget _tile(int i, String mId, List<Rect> rects, {bool floating = false}) {
    final it = _items[i];
    final m = kWorkspaceModules[it.id]!;
    final body = RepaintBoundary(
      child: Glass(
        padding: const EdgeInsets.all(12),
        shadow: !floating,
        stroke: _edit ? CkColors.cyanStroke : CkColors.panelStroke,
        child: m.build(mId, it.size),
      ),
    );
    if (!_edit) {
      return GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          workspaceEditing.value = true;
        },
        child: Pressable(scale: .985, onTap: () => pushModule(context, m.page()), child: body),
      );
    }
    return Stack(clipBehavior: Clip.none, children: [
      Positioned.fill(child: body),
      // Move: press and hold briefly, then drag. A quick swipe still scrolls
      // the page, so long boards stay reachable in edit mode.
      Positioned.fill(
        child: RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: {
            LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(duration: const Duration(milliseconds: 220)),
              (r) => r
                ..onLongPressStart = (d) {
                  HapticFeedback.mediumImpact();
                  final local = _toStack(d.globalPosition);
                  setState(() {
                    _dragging = i;
                    _grab = local - rects[i].topLeft;
                    _dragPos = local;
                  });
                }
                ..onLongPressMoveUpdate = (d) {
                  _autoScroll(d.globalPosition);
                  setState(() {
                    _dragPos = _toStack(d.globalPosition);
                    _moveTo(_dragPos, _pack(_items, _stackWidth));
                  });
                }
                ..onLongPressEnd = (_) {
                  setState(() {
                    _dragging = null;
                    _save();
                  });
                }
                ..onLongPressCancel = () {
                  setState(() => _dragging = null);
                },
            ),
          },
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: Icon(Icons.drag_indicator_rounded, size: 18, color: CkColors.textSecondary.withValues(alpha: .8)),
      ),
      // remove
      Positioned(
        top: -8,
        left: -8,
        child: Pressable(
          onTap: () => setState(() {
            _items.removeAt(i);
            _save();
          }),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: CkColors.deepSpace,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x99FFFFFF)),
            ),
            child: const Icon(Icons.remove_rounded, size: 15, color: Colors.white),
          ),
        ),
      ),
      // resize handles: four edges and four corners
      // (top-left corner is the remove button)
      for (final h in const [
        (0, -1), (1, -1),
        (-1, 0), (1, 0),
        (-1, 1), (0, 1), (1, 1),
      ])
        _handle(i, rects, h.$1, h.$2),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final bool filled;
  final VoidCallback onTap;
  const _Chip(this.text, {this.selected = false, this.filled = false, required this.onTap});
  @override
  Widget build(BuildContext context) => Pressable(
        scale: .95,
        onTap: onTap,
        child: AnimatedContainer(
          duration: CkMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: filled ? CkColors.cyan : selected ? CkColors.cyanTint : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: filled ? CkColors.cyan : selected ? CkColors.cyanStroke : CkColors.panelStroke),
          ),
          child: Text(text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: filled || selected ? FontWeight.w600 : FontWeight.w500,
                color: filled ? const Color(0xFF06204F) : selected ? Colors.white : CkColors.textSecondary,
              )),
        ),
      );
}

class _AddSheet extends StatelessWidget {
  final Set<String> on;
  const _AddSheet({required this.on});
  @override
  Widget build(BuildContext context) {
    final groups = <String, List<WModule>>{};
    for (final m in kWorkspaceModules.values) {
      groups.putIfAbsent(m.group, () => []).add(m);
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0x4DFFFFFF), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Text('Workspace modules', style: CkText.h(18)),
          const SizedBox(height: 4),
          const Text('Tap to add or remove. ✓ = on this workspace.', style: CkText.muted),
          for (final g in groups.entries) ...[
            const SizedBox(height: 14),
            Text(g.key.toUpperCase(), style: CkText.label),
            const SizedBox(height: 6),
            for (final m in g.value)
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.pop(context, m.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                  child: Row(children: [
                    _ModIcon(m.title, 24),
                    const SizedBox(width: 12),
                    Expanded(child: Text(m.title, style: const TextStyle(fontSize: 14.5))),
                    Icon(on.contains(m.id) ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                        color: on.contains(m.id) ? CkColors.cyan : CkColors.textSecondary),
                  ]),
                ),
              ),
          ],
        ]),
      ),
    );
  }
}

class _ModIcon extends StatelessWidget {
  final String title;
  final double size;
  const _ModIcon(this.title, this.size);
  @override
  Widget build(BuildContext context) {
    final a = ckIconAsset(title);
    return a == null
        ? Icon(Icons.blur_on_rounded, size: size, color: CkColors.cyan)
        : Image.asset(a, width: size, height: size, filterQuality: FilterQuality.medium);
  }
}

// ───────────────────────── widget chrome

class _WHead extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _WHead(this.title, {this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [
        _ModIcon(title, 20),
        const SizedBox(width: 8),
        Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
        if (trailing != null) trailing!,
      ]);
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.only(top: 4), child: Skeleton(height: double.infinity, radius: 10));
}

// Shaped skeletons: each one mirrors the module it stands in for.

Widget _skelCircle() => LayoutBuilder(builder: (c, b) {
      final d = math.min(b.maxWidth, b.maxHeight) * .92;
      return Center(child: Skeleton(width: d, height: d, radius: d / 2));
    });

Widget _skelPill() => const Skeleton(height: 46, radius: 11);

Widget _skelKundli(WSize size) {
  switch (size) {
    case WSize.s:
      return _skelCircle();
    case WSize.w:
      return Row(children: [
        Expanded(child: _skelCircle()),
        const SizedBox(width: 10),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_skelPill(), _skelPill(), _skelPill()])),
      ]);
    case WSize.t:
      return Column(children: [
        Expanded(child: _skelCircle()),
        for (var i = 0; i < 3; i++) Padding(padding: const EdgeInsets.only(top: 6), child: _skelPill()),
      ]);
    case WSize.l:
      return Column(children: [
        Expanded(child: _skelCircle()),
        const SizedBox(height: 8),
        Row(children: [
          for (var i = 0; i < 3; i++) ...[if (i > 0) const SizedBox(width: 6), Expanded(child: _skelPill())]
        ]),
      ]);
  }
}

Widget _skelRows(int n, {bool twoCols = false, bool mid = true}) {
  Widget col(int k) => Column(children: [
        for (var i = 0; i < k; i++)
          Expanded(
            child: Row(children: [
              const Skeleton(width: 26, height: 10, radius: 4),
              const SizedBox(width: 12),
              if (mid) const Expanded(child: Align(alignment: Alignment.centerLeft, child: Skeleton(width: 54, height: 9, radius: 4))) else const Spacer(),
              const Skeleton(width: 40, height: 10, radius: 4),
            ]),
          ),
      ]);
  if (!twoCols) return col(n);
  return Row(children: [Expanded(child: col((n + 1) ~/ 2)), const SizedBox(width: 14), Expanded(child: col(n ~/ 2))]);
}

Widget _skelBars() => LayoutBuilder(builder: (c, b) {
      const hs = [.55, .8, .4, .95, .6, .7, .35, .85, .5];
      return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final h in hs)
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Skeleton(width: 8, height: math.max(6, (b.maxHeight - 18) * h), radius: 3),
              const SizedBox(height: 6),
              const Skeleton(width: 12, height: 7, radius: 3),
            ]),
          ),
      ]);
    });

Widget _skelSentiments() => LayoutBuilder(builder: (c, b) {
      final mid = (b.maxHeight - 14) / 2;
      return Column(children: [
        SizedBox(
          height: mid * 2,
          child: Row(children: [
            for (var i = 0; i < 30; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: .8),
                  child: Column(children: [
                    SizedBox(
                        height: mid,
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: i % 3 != 2 ? Skeleton(height: (mid - 4) * (.3 + (i * 37 % 60) / 100), radius: 2) : null)),
                    SizedBox(
                        height: mid,
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: i % 3 == 2 ? Skeleton(height: (mid - 4) * (.25 + (i * 23 % 50) / 100), radius: 2) : null)),
                  ]),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 4),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Skeleton(width: 10, height: 7, radius: 3),
          Skeleton(width: 10, height: 7, radius: 3),
          Skeleton(width: 10, height: 7, radius: 3),
          Skeleton(width: 10, height: 7, radius: 3),
        ]),
      ]);
    });

Widget _fail() => const Center(child: Text('Couldn\'t load', style: CkText.muted));

Widget _future<T>(Future<T> f, Widget Function(T) b, {Widget? skel}) => FutureBuilder<T>(
      future: f,
      builder: (c, s) {
        if (s.hasError) return _fail();
        if (!s.hasData) return skel ?? const _Loading();
        return b(s.data as T);
      },
    );

Widget _grahLabel(GrahPos p, {bool retroOnLabel = true, double size = 12.5}) => Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(color: grahColor(p.id), shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(p.id, style: TextStyle(fontSize: size, fontWeight: FontWeight.w600)),
      if (retroOnLabel && p.retro) const RetroBadge(),
    ]);


List<GrahPos> _ordered(List<GrahPos> l) {
  final m = {for (final p in l) p.id: p};
  return [for (final id in kGrahOrder) if (m[id] != null) m[id]!];
}

// ───────────────────────── module widgets

class _KundliW extends StatelessWidget {
  final String mId;
  final WSize size;
  const _KundliW(this.mId, this.size);

  Widget _pill(String label, GrahPos? p) => Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(color: CkColors.field, borderRadius: BorderRadius.circular(11), border: Border.all(color: CkColors.panelStroke)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text(label.toUpperCase(), style: CkText.label)),
            Text(p == null ? '—' : p.rashi.toString().padLeft(2, '0'), style: CkText.mono(15, color: CkColors.cyan)),
          ]),
          const SizedBox(height: 4),
          Text(p == null ? '—' : tatva(p.rashi), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const _WHead('CosmoKundli'),
        const SizedBox(height: 6),
        Expanded(
          child: _future<List<GrahPos>>(ClientData.of(mId).chart(), skel: _skelKundli(size), (planets) {
            GrahPos? f(String id) => planets.where((e) => e.id == id).firstOrNull;
            final pills = [_pill('Sun', f('Su')), _pill('Moon', f('Mo')), _pill('Lagna', f('As'))];
            final chart = KundliChart(planets);
            switch (size) {
              case WSize.s:
                return Center(child: chart);
              case WSize.w:
                return Row(children: [
                  chart,
                  const SizedBox(width: 10),
                  Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: pills)),
                ]);
              case WSize.t:
                return Column(children: [
                  Expanded(child: Center(child: chart)),
                  for (final p in pills) Padding(padding: const EdgeInsets.only(top: 6), child: p),
                ]);
              case WSize.l:
                return Column(children: [
                  Expanded(child: Center(child: chart)),
                  const SizedBox(height: 8),
                  Row(children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(child: pills[i]),
                    ]
                  ]),
                ]);
            }
          }),
        ),
      ]);
}

class _DegreeW extends StatelessWidget {
  final String mId;
  final WSize size;
  const _DegreeW(this.mId, this.size);

  Widget _row(GrahPos p, {bool rashi = true, bool nak = false}) => Expanded(
        child: Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1A8CBEFF)))),
          child: Row(children: [
            SizedBox(width: 40, child: _grahLabel(p, size: 12)),
            if (rashi) Expanded(child: Text(rashiName(p.rashi), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary))),
            if (nak) Expanded(child: Text(p.nakshatra, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary))),
            if (!rashi && !nak) const Spacer(),
            Text(fmtDegMin(p.degIn), style: CkText.mono(12)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const _WHead('Degree'),
        const SizedBox(height: 6),
        Expanded(
          child: _future<List<GrahPos>>(ClientData.of(mId).chart(), skel: _skelRows(10, twoCols: size == WSize.w, mid: size != WSize.s), (l) {
            final ps = _ordered(l);
            if (size == WSize.w) {
              final a = ps.take(5).toList(), b = ps.skip(5).toList();
              return Row(children: [
                Expanded(child: Column(children: [for (final p in a) _row(p)])),
                const SizedBox(width: 14),
                Expanded(child: Column(children: [for (final p in b) _row(p)])),
              ]);
            }
            return Column(children: [for (final p in ps) _row(p, rashi: size != WSize.s, nak: size == WSize.l)]);
          }),
        ),
      ]);
}

class _BarsW extends StatelessWidget {
  final String mId;
  final WSize size;
  final bool flavor;
  const _BarsW(this.mId, this.size, {required this.flavor});
  static const _power = ['Su', 'Mo', 'Ra', 'Ke', 'Ju', 'Sa', 'Ma', 'Ve', 'Me'];
  static const _flavor = ['Su', 'Mo', 'Ju', 'Sa', 'Ma', 'Ve', 'Me'];
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _WHead(flavor ? 'Flavor' : 'Power'),
        const SizedBox(height: 8),
        Expanded(
          child: _future<Map<String, double>>(ClientData.of(mId).shadbal(), skel: _skelBars(), (m) {
            final v = [for (final id in flavor ? _flavor : _power) if (m[id] != null) MapEntry(id, m[id]!)];
            return LayoutBuilder(
              builder: (c, box) => GrahBarChart(values: v, height: math.max(40, box.maxHeight - 24), axis: size != WSize.s),
            );
          }),
        ),
      ]);
}

class _TransitW extends StatelessWidget {
  final String mId;
  final WSize size;
  const _TransitW(this.mId, this.size);

  Widget _row(GrahPos p, {bool rashi = true}) => Expanded(
        child: Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1A8CBEFF)))),
          child: Row(children: [
            SizedBox(width: 40, child: _grahLabel(p, size: 12)),
            if (rashi) Expanded(child: Text(rashiName(p.rashi), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: CkColors.textSecondary))) else const Spacer(),
            Text(fmtDegMin(p.degIn), style: CkText.mono(12)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _WHead('Transit', trailing: Text('● ${DateFormat('HH:mm').format(now)}', style: CkText.mono(10.5, color: CkColors.cyan))),
      const SizedBox(height: 6),
      Expanded(
        child: _future<List<GrahPos>>(ClientData.of(mId).transit(now),
            skel: size == WSize.l ? _skelCircle() : size == WSize.s ? _skelRows(5, mid: false) : _skelRows(10, twoCols: size == WSize.w), (t) {
          final ps = _ordered(t);
          if (size == WSize.l) {
            return _future<List<GrahPos>>(ClientData.of(mId).chart(), skel: _skelCircle(), (b) => Center(child: KundliChart(b, transit: t)));
          }
          if (size == WSize.s) {
            return Column(children: [for (final p in ps.where((e) => const ['Su', 'Mo', 'Ju', 'Ra', 'Ke'].contains(e.id))) _row(p, rashi: false)]);
          }
          if (size == WSize.w) {
            return Row(children: [
              Expanded(child: Column(children: [for (final p in ps.take(5)) _row(p)])),
              const SizedBox(width: 14),
              Expanded(child: Column(children: [for (final p in ps.skip(5)) _row(p)])),
            ]);
          }
          return Column(children: [for (final p in ps) _row(p)]);
        }),
      ),
    ]);
  }
}

class _SentimentsW extends StatelessWidget {
  final String mId;
  final WSize size;
  const _SentimentsW(this.mId, this.size);
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _WHead('Sentiments', trailing: Text(DateFormat('MMM yyyy').format(now).toUpperCase(), style: CkText.mono(10.5, color: CkColors.cyan))),
      const SizedBox(height: 8),
      Expanded(
        child: _future<List<MapEntry<DateTime, double>>>(ClientData.of(mId).sentiments(DateTime(now.year, now.month)), skel: _skelSentiments(), (l) {
          if (l.isEmpty) return const Center(child: Text('No data for this month', style: CkText.muted));
          final maxAbs = l.map((e) => e.value.abs()).fold<double>(1, math.max);
          return LayoutBuilder(builder: (c, box) {
            const lab = 14.0;
            final mid = (box.maxHeight - lab) / 2;
            final n = l.length;
            final colW = box.maxWidth / n;
            final todayIdx = l.indexWhere((e) => e.key.year == now.year && e.key.month == now.month && e.key.day == now.day);
            final marks = [for (var i = 0; i < n; i++) if (l[i].key.day == 1 || l[i].key.day % 5 == 0) i];
            return Stack(children: [
              Positioned(left: 0, right: 0, top: mid, child: Container(height: 1, color: const Color(0x338CBEFF))),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: mid * 2,
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final e in l)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: .8),
                        child: Column(children: [
                          SizedBox(
                            height: mid,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: e.value > 0
                                  ? Container(height: (mid - 4) * e.value / maxAbs, decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF73F4C4), Color(0xFF10B981)]), borderRadius: BorderRadius.circular(2)))
                                  : null,
                            ),
                          ),
                          SizedBox(
                            height: mid,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: e.value < 0
                                  ? Container(height: (mid - 4) * -e.value / maxAbs, decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF6B8B8), Color(0xFFEF4444)]), borderRadius: BorderRadius.circular(2)))
                                  : null,
                            ),
                          ),
                        ]),
                      ),
                    ),
                ]),
              ),
              if (todayIdx >= 0)
                Positioned(
                  left: colW * todayIdx + colW / 2 - .75,
                  top: 0,
                  bottom: lab,
                  child: Container(width: 1.5, color: CkColors.cyan),
                ),
              for (final i in marks)
                Positioned(
                  left: (colW * i + colW / 2 - 10).clamp(0.0, box.maxWidth - 20),
                  bottom: 0,
                  width: 20,
                  child: Text('${l[i].key.day}',
                      textAlign: TextAlign.center,
                      style: CkText.mono(9, color: i == todayIdx ? CkColors.cyan : CkColors.labelMono)),
                ),
            ]);
          });
        }),
      ),
    ]);
  }
}

/// Rendered chart reused inside widgets (keeps SvgPicture import used here).
Widget svgChart(String svg) => SvgPicture.string(svg, fit: BoxFit.contain);
String transitSvg(List<GrahPos> b, List<GrahPos> t) => KundliSvg.transit(b, t);

/// Pan recognizer that wins immediately, so the page never steals a resize.
class _EagerPan extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolvePointer(event.pointer, GestureDisposition.accepted);
  }
}
