import 'dart:async';
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
import '../ui/zoom_chart.dart';
import 'blueprint_pages.dart';
import 'client_shell.dart';
import 'predictions_pages.dart';
import 'traditional_pages.dart';
import 'trajectory_pages.dart';

/// Widget sizes on the 2-column workspace grid.
enum WSize { s, w, t, l }

extension WSizeX on WSize {
  int get cols => this == WSize.w || this == WSize.l ? 2 : 1;
  int get rows => this == WSize.t || this == WSize.l ? 2 : 1;
  String get label => const {WSize.s: 'Small', WSize.w: 'Wide', WSize.t: 'Tall', WSize.l: 'Large'}[this]!;
  static WSize of(int cols, int rows) => cols == 2 ? (rows == 2 ? WSize.l : WSize.w) : (rows == 2 ? WSize.t : WSize.s);
}

/// A card on the grid: module id, size and its top-left cell.
class WItem {
  final String id;
  WSize size;
  int col;
  int row;
  WItem(this.id, this.size, [this.col = -1, this.row = -1]);
  WItem copy() => WItem(id, size, col, row);
  Map<String, dynamic> toJson() => {'id': id, 'size': size.name, 'col': col, 'row': row};
  static WItem? fromJson(dynamic j) {
    if (j is! Map) return null;
    final id = '${j['id']}';
    if (!kWorkspaceModules.containsKey(id)) return null;
    final s = WSize.values.firstWhere((e) => e.name == j['size'], orElse: () => kWorkspaceModules[id]!.defaultSize);
    final c = j['col'], r = j['row'];
    return WItem(id, s, c is int ? c : -1, r is int ? r : -1);
  }
}

/// A module. Every module the app has lives here: the Modules list and the
/// workspace Add sheet both read this, so a new module shows up in both.
class WModule {
  final String id;
  final String title;
  final String sub;
  final String group; // software group
  final WSize defaultSize;
  final Widget Function(String mId, WSize size)? card;
  final Widget Function()? page;
  /// The card handles its own taps (no full page behind it).
  final bool ownTap;
  const WModule(this.id, this.title, this.sub, this.group, this.defaultSize, this.card, this.page, {this.ownTap = false});
  bool get soon => page == null;
  Widget build(String mId, WSize size) => card != null ? card!(mId, size) : _GenericW(this, size);
}

final kWorkspaceModules = <String, WModule>{
  'kundli': WModule('kundli', 'CosmoKundli', 'Birth chart · circle', 'BluePrint', WSize.l, (m, s) => _KundliW(m, s), () => const KundliPage()),
  'degree': WModule('degree', 'Degree', 'Rashi, degree, nakshatra', 'BluePrint', WSize.t, (m, s) => _DegreeW(m, s), () => const CoordinatesPage()),
  'power': WModule('power', 'Power', 'Strength of each GRAH', 'BluePrint', WSize.s, (m, s) => _BarsW(m, s, flavor: false), () => const StrengthPage(flavor: false)),
  'flavor': WModule('flavor', 'Flavor', 'Nature of each GRAH', 'BluePrint', WSize.s, (m, s) => _BarsW(m, s, flavor: true), () => const StrengthPage(flavor: true)),
  'transit': WModule('transit', 'Transit', 'Birth vs any moment', 'Trajectory', WSize.w, (m, s) => _TransitW(m, s), () => const TransitPage()),
  'vibes': const WModule('vibes', 'GRAH Vibes', 'Coming soon', 'Trajectory', WSize.w, null, null),
  'intensity': const WModule('intensity', 'GRAH Intensity', 'Coming soon', 'Trajectory', WSize.w, null, null),
  'sentiments': WModule('sentiments', 'Sentiments', 'Daily, month by month', 'Predictions', WSize.w, (m, s) => _DailyW(m, s, signed: true), () => const SentimentsPage()),
  'situations': WModule('situations', 'Situations', '7 zones, month by month', 'Predictions', WSize.w, (m, s) => _DailyW(m, s, signed: false), () => const SituationsPage()),
  'sentiments5d': WModule('sentiments5d', 'Sentiments 5D', 'Career, Finance, Health, Social, Love', 'Predictions', WSize.w, (m, s) => _FiveDW(m, s), () => const Sentiments5DPage()),
  'panchang': WModule('panchang', 'Panchang', 'At the moment of birth', 'Traditional', WSize.w, (m, s) => _PanchangW(m, s), () => const PanchangPage()),
  'melapak': WModule('melapak', 'Melapak', 'Match with a partner', 'Traditional', WSize.w, (m, s) => _MelapakW(m, s), () => const MelapakPage(), ownTap: true),
};

const kTabCount = 3;

List<WItem> _defaultLayout(int tab) {
  switch (tab) {
    case 1:
      return [WItem('transit', WSize.l, 0, 0)];
    case 2:
      return [WItem('sentiments', WSize.w, 0, 0), WItem('situations', WSize.w, 0, 1)];
    default:
      return [
        WItem('kundli', WSize.l, 0, 0),
        WItem('degree', WSize.t, 0, 2),
        WItem('power', WSize.s, 1, 2),
        WItem('flavor', WSize.s, 1, 3),
        WItem('transit', WSize.w, 0, 4),
      ];
  }
}

/// Layouts are saved per user (kept across logout).
class WorkspaceStore {
  static String get _u => 'ws_u${Session.uid}';
  static int get active => (Session.prefs.getInt('${_u}_active') ?? 0).clamp(0, kTabCount - 1);
  static set active(int v) => Session.prefs.setInt('${_u}_active', v);
  static String name(int i) {
    final n = Session.prefs.getString('${_u}_name_$i');
    return n == null || n.trim().isEmpty ? 'Tab ${i + 1}' : n;
  }

  static void setName(int i, String v) => Session.prefs.setString('${_u}_name_$i', v.trim());

  static List<WItem> load(int tab) {
    final raw = Session.prefs.getString('${_u}_layout_$tab');
    if (raw == null) return _defaultLayout(tab);
    try {
      final l = (jsonDecode(raw) as List).map(WItem.fromJson).whereType<WItem>().toList();
      if (l.any((e) => e.col < 0 || e.row < 0)) _packOld(l);
      return Grid.settle(l);
    } catch (_) {
      return _defaultLayout(tab);
    }
  }

  static void save(int tab, List<WItem> items) =>
      Session.prefs.setString('${_u}_layout_$tab', jsonEncode(items.map((e) => e.toJson()).toList()));

  static bool isDefault(int tab, List<WItem> items) {
    final d = _defaultLayout(tab);
    String sig(List<WItem> l) => (l.map((e) => '${e.id}/${e.size.name}/${e.col}/${e.row}').toList()..sort()).join(',');
    return sig(d) == sig(items);
  }

  /// Old saved layouts had order only: give them cells by first-fit.
  static void _packOld(List<WItem> items) {
    final occ = <List<bool>>[];
    bool free(int r, int c) {
      while (occ.length <= r) {
        occ.add([false, false]);
      }
      return !occ[r][c];
    }

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
            it.col = c;
            it.row = r;
            placed = true;
          }
        }
      }
    }
  }
}

/// Explicit 2-column grid. [settle] puts [pin] exactly where asked, pushes
/// anything in its way down (never sideways), then closes gaps upward.
class Grid {
  static bool _fits(Set<int> occ, int c, int r, WSize s) {
    if (c < 0 || c + s.cols > 2 || r < 0) return false;
    for (var dr = 0; dr < s.rows; dr++) {
      for (var dc = 0; dc < s.cols; dc++) {
        if (occ.contains((r + dr) * 2 + c + dc)) return false;
      }
    }
    return true;
  }

  static void _take(Set<int> occ, WItem it) {
    for (var dr = 0; dr < it.size.rows; dr++) {
      for (var dc = 0; dc < it.size.cols; dc++) {
        occ.add((it.row + dr) * 2 + it.col + dc);
      }
    }
  }

  static void _drop(Set<int> occ, WItem it) {
    var r = 0;
    while (!_fits(occ, it.col, r, it.size)) {
      r++;
    }
    it.row = r;
    _take(occ, it);
  }

  static int _order(WItem a, WItem b) => a.row != b.row ? a.row.compareTo(b.row) : a.col.compareTo(b.col);

  static List<WItem> settle(List<WItem> items, {WItem? pin}) {
    for (final it in items) {
      it.col = it.col.clamp(0, 2 - it.size.cols);
      if (it.row < 0) it.row = 0;
    }
    final occ = <int>{};
    if (pin != null) _take(occ, pin);
    final rest = items.where((e) => !identical(e, pin)).toList()..sort(_order);
    for (final it in rest) {
      _drop(occ, it);
    }
    // Close gaps: everything (pin included) falls up in reading order.
    final all = [...items]..sort(_order);
    occ.clear();
    for (final it in all) {
      _drop(occ, it);
    }
    return items;
  }

  static List<WItem> clone(List<WItem> l) => [for (final e in l) e.copy()];
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
  late int _tab = WorkspaceStore.active;
  late List<WItem> _items = WorkspaceStore.load(_tab);

  // gesture state: _base is the layout when the gesture began.
  List<WItem>? _base;
  String? _moving;
  Offset _grab = Offset.zero;
  Offset _finger = Offset.zero;
  String? _resizing;
  Offset _drag = Offset.zero; // total drag since the resize began
  int _cornerIdx = 1;
  // undo after remove
  List<WItem>? _undo;
  String _undoName = '';
  Timer? _undoTimer;

  static const double _gap = 14;
  static const double _unit = 228;
  final _stackKey = GlobalKey();
  final _scroll = ScrollController();
  double _width = 0;
  double get _cw => (_width - _gap) / 2;

  @override
  void initState() {
    super.initState();
    workspaceEditing.addListener(_onEdit);
  }

  @override
  void dispose() {
    workspaceEditing.removeListener(_onEdit);
    _undoTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _onEdit() {
    if (!workspaceEditing.value) _save();
    setState(() {});
  }

  bool get _edit => workspaceEditing.value;

  /// After edit mode opens, scroll so card [id] sits at screen y [y] again.
  void _keepAt(String id, double y) {
    void fix([int tries = 0]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scroll.hasClients) {
          if (tries < 3) fix(tries + 1);
          return;
        }
        final i = _items.indexWhere((e) => e.id == id);
        final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
        if (i < 0 || box == null || !box.hasSize) return;
        final now = box.localToGlobal(_rect(_items[i]).topLeft).dy;
        final p = _scroll.position;
        p.jumpTo((p.pixels + now - y).clamp(p.minScrollExtent, p.maxScrollExtent));
      });
    }
    fix();
  }
  void _save() => WorkspaceStore.save(_tab, _items);

  void _switchTab(int t) {
    if (t == _tab) return;
    HapticFeedback.selectionClick();
    _save();
    setState(() {
      _tab = t;
      WorkspaceStore.active = t;
      _items = WorkspaceStore.load(t);
      _undo = null;
    });
  }

  Future<void> _rename(int t) async {
    HapticFeedback.mediumImpact();
    final ctl = TextEditingController(text: WorkspaceStore.name(t));
    final v = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (c) => AlertDialog(
        backgroundColor: CkColors.navySheet,
        title: const Text('Rename tab'),
        content: TextField(controller: ctl, autofocus: true, maxLength: 16, decoration: const InputDecoration(hintText: 'Tab name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, ctl.text), child: const Text('Save')),
        ],
      ),
    );
    if (v != null) setState(() => WorkspaceStore.setName(t, v));
  }

  Rect _rect(WItem it) => Rect.fromLTWH(
      it.col * (_cw + _gap), it.row * (_unit + _gap), it.size.cols * _cw + (it.size.cols - 1) * _gap, it.size.rows * _unit + (it.size.rows - 1) * _gap);

  Offset _toStack(Offset global) {
    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    return box == null ? global : box.globalToLocal(global);
  }

  void _autoScroll(Offset global) {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    final h = MediaQuery.of(context).size.height;
    const edge = 120.0;
    double dy = 0;
    if (global.dy < edge + 60) dy = -(edge + 60 - global.dy) / 6;
    if (global.dy > h - edge - 80) dy = (global.dy - (h - edge - 80)) / 6;
    if (dy != 0) pos.jumpTo((pos.pixels + dy).clamp(pos.minScrollExtent, pos.maxScrollExtent));
  }

  // ── move

  void _moveStart(WItem it, Offset global) {
    HapticFeedback.mediumImpact();
    final local = _toStack(global);
    setState(() {
      _base = Grid.clone(_items);
      _moving = it.id;
      _grab = local - _rect(it).topLeft;
      _finger = local;
    });
  }

  void _moveUpdate(Offset global) {
    final base = _base;
    if (base == null || _moving == null) return;
    _autoScroll(global);
    final local = _toStack(global);
    final next = Grid.clone(base);
    final it = next.firstWhere((e) => e.id == _moving);
    final tl = local - _grab;
    it.col = (tl.dx / (_cw + _gap)).round().clamp(0, 2 - it.size.cols);
    it.row = math.max(0, (tl.dy / (_unit + _gap)).round());
    Grid.settle(next, pin: it);
    final cur = _items.firstWhere((e) => e.id == _moving);
    if (cur.col != it.col || cur.row != it.row) HapticFeedback.selectionClick();
    setState(() {
      _finger = local;
      _items = next;
    });
  }

  void _moveEnd() {
    setState(() {
      _moving = null;
      _base = null;
      _save();
    });
  }

  // ── resize: the edge you don't drag stays put

  void _resizeStart(WItem it) {
    HapticFeedback.selectionClick();
    setState(() {
      _base = Grid.clone(_items);
      _resizing = it.id;
    });
  }

  /// Free resize from any edge or corner, like an image crop handle.
  /// [sx]: -1 left edge, 1 right edge, 0 neither; [sy]: -1 top, 1 bottom, 0
  /// neither. The opposite edges stay put.
  void _resizeUpdate(int sx, int sy, Offset total) {
    final base = _base;
    if (base == null || _resizing == null) return;
    final next = Grid.clone(base);
    final it = next.firstWhere((e) => e.id == _resizing);
    var cols = it.size.cols, rows = it.size.rows, col = it.col, row = it.row;
    final hx = _cw / 2, hy = _unit / 2;
    if (sx < 0) {
      if (cols == 2 && total.dx > hx) {
        cols = 1;
        col = 1;
      } else if (cols == 1 && col == 1 && total.dx < -hx) {
        cols = 2;
        col = 0;
      }
    } else if (sx > 0) {
      if (cols == 2 && total.dx < -hx) {
        cols = 1;
        col = 0;
      } else if (cols == 1 && col == 0 && total.dx > hx) {
        cols = 2;
      }
    }
    if (sy > 0) {
      if (rows == 1 && total.dy > hy) rows = 2;
      if (rows == 2 && total.dy < -hy) rows = 1;
    } else if (sy < 0) {
      if (rows == 1 && row > 0 && total.dy < -hy) {
        rows = 2;
        row -= 1;
      } else if (rows == 2 && total.dy > hy) {
        rows = 1;
        row += 1;
      }
    }
    final ns = WSizeX.of(cols, rows);
    final cur = _items.firstWhere((e) => e.id == _resizing);
    if (ns != cur.size) HapticFeedback.selectionClick();
    it.size = ns;
    it.col = col;
    it.row = row;
    Grid.settle(next, pin: it);
    setState(() => _items = next);
  }

  void _resizeEnd() => setState(() {
        _resizing = null;
        _base = null;
        _save();
      });

  // ── add / remove / reset

  void _remove(WItem it) {
    HapticFeedback.selectionClick();
    _undoTimer?.cancel();
    setState(() {
      _undo = Grid.clone(_items);
      _undoName = kWorkspaceModules[it.id]!.title;
      _items.removeWhere((e) => e.id == it.id);
      Grid.settle(_items);
      _save();
    });
    _undoTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _undo = null);
    });
  }

  void _restore() {
    _undoTimer?.cancel();
    setState(() {
      _items = _undo ?? _items;
      _undo = null;
      _save();
    });
  }

  Future<void> _reset() async {
    final ok = await confirm(context, 'Reset ${WorkspaceStore.name(_tab)}?',
        'Cards, places and sizes go back to the default for this tab. Other tabs stay as they are.',
        ok: 'Reset');
    if (!ok) return;
    setState(() {
      _items = _defaultLayout(_tab);
      _undo = null;
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
        final bottom = _items.fold<int>(0, (m, e) => math.max(m, e.row + e.size.rows));
        _items.add(WItem(id, kWorkspaceModules[id]!.defaultSize, 0, bottom));
      }
      Grid.settle(_items);
      _save();
    });
  }

  // ── build

  Widget _tabs() => SizedBox(
        height: 38,
        child: Row(children: [
          for (var t = 0; t < kTabCount; t++) ...[
            if (t > 0) const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onLongPress: () => _rename(t),
                // editing: each pill carries a pencil, and tapping the open
                // tab renames it
                child: _Chip(WorkspaceStore.name(t),
                    selected: t == _tab,
                    edit: _edit,
                    dot: !_edit && !WorkspaceStore.isDefault(t, t == _tab ? _items : WorkspaceStore.load(t)),
                    onTap: () => _edit && t == _tab ? _rename(t) : _switchTab(t)),
              ),
            ),
          ],
        ]),
      );

  Widget _grid(String mId) => LayoutBuilder(builder: (ctx, box) {
        _width = box.maxWidth;
        if (_items.isEmpty) {
          return Glass(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text('This tab is empty', style: CkText.h(15)),
              const SizedBox(height: 6),
              const Text('Add the modules you use most.', style: CkText.muted),
              const SizedBox(height: 12),
              _Chip('+ Add module', filled: true, onTap: () {
                workspaceEditing.value = true;
                _add();
              }),
            ]),
          );
        }
        final rects = {for (final it in _items) it.id: _rect(it)};
        // card-group family: cards rise in reading order (row by row, left
        // to right), like the Dashboard
        final order = [..._items]..sort((a, b) {
            final ra = rects[a.id]!, rb = rects[b.id]!;
            return ra.top != rb.top ? ra.top.compareTo(rb.top) : ra.left.compareTo(rb.left);
          });
        final wave = {for (var i = 0; i < order.length; i++) order[i].id: i};
        final h = rects.values.map((r) => r.bottom).reduce(math.max);
        final moving = _moving == null ? null : _items.firstWhere((e) => e.id == _moving);
        return SizedBox(
          key: _stackKey,
          height: h + (_edit ? _unit * .5 : 0),
          child: Stack(clipBehavior: Clip.none, children: [
            // drop target
            if (moving != null)
              Positioned.fromRect(
                rect: rects[moving.id]!,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: const Color(0x1A5CE1FF),
                      border: Border.all(color: CkColors.cyan, width: 2),
                    ),
                  ),
                ),
              ),
            for (final it in _items)
              AnimatedPositioned(
                key: ValueKey(it.id),
                duration: const Duration(milliseconds: 260),
                curve: kEase,
                left: rects[it.id]!.left,
                top: rects[it.id]!.top,
                width: rects[it.id]!.width,
                height: rects[it.id]!.height,
                child: Opacity(
                  opacity: it.id == _moving ? 0 : 1,
                  child: _edit ? _tile(it, mId) : FadeSlideIn(index: wave[it.id]!, child: _tile(it, mId)),
                ),
              ),
            if (moving != null)
              Positioned(
                left: _finger.dx - _grab.dx,
                top: _finger.dy - _grab.dy,
                width: rects[moving.id]!.width,
                height: rects[moving.id]!.height,
                child: IgnorePointer(
                  child: Transform.rotate(
                    angle: -.02,
                    child: Transform.scale(
                      scale: 1.03,
                      child: DecoratedBox(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: const [
                          BoxShadow(color: Color(0x73000000), blurRadius: 40, offset: Offset(0, 18)),
                        ]),
                        child: Opacity(opacity: .94, child: _tile(moving, mId, floating: true)),
                      ),
                    ),
                  ),
                ),
              ),
            if (_resizing != null)
              Positioned.fromRect(
                rect: rects[_resizing]!,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: CkColors.navySheet, borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.cyan)),
                      child: Text(_items.firstWhere((e) => e.id == _resizing).size.label.toUpperCase(), style: CkText.mono(12, color: CkColors.cyan)),
                    ),
                  ),
                ),
              ),
          ]),
        );
      });

  @override
  Widget build(BuildContext context) {
    final c = Session.client.value;
    final mId = c?.mId ?? '';
    if (_edit) return _editScreen(mId);
    return ClientPage(
      title: 'Workspace',
      isRoot: true,
      animate: false,
      pinned: _tabs(),
      onRefresh: () async {
        final d = ClientData.of(mId);
        d.chart(refresh: true);
        d.shadbal(refresh: true);
        d.drop('');
        setState(() {});
      },
      children: [
        const SizedBox(height: 4),
        // swipe left / right: next / previous tab
        SwipeArea(
          canSwipe: (d) => _tab + d >= 0 && _tab + d < kTabCount,
          onSwipe: (d) => _switchTab(_tab + d),
          child: _grid(mId),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _editScreen(String mId) {
    final pad = MediaQuery.of(context).padding;
    return CkBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Column(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, pad.top + 12, 16, 0),
              child: Column(children: [
                _tabs(),
                const SizedBox(height: 8),
                Text('DRAG ⋮⋮ TO MOVE · DRAG A CORNER TO RESIZE · LONG-PRESS A TAB TO RENAME',
                    textAlign: TextAlign.center, style: CkText.label),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                physics: _moving != null || _resizing != null ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 18, 16, 120 + pad.bottom),
                child: _grid(mId),
              ),
            ),
          ]),
          if (_undo != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 86 + pad.bottom,
              child: Glass(
                tint: const Color(0x33000000),
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                child: Row(children: [
                  Expanded(child: Text('$_undoName removed', style: const TextStyle(fontSize: 13.5))),
                  TextButton(onPressed: _restore, child: const Text('UNDO', style: TextStyle(color: CkColors.cyan, fontWeight: FontWeight.w700))),
                ]),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 14 + pad.bottom),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xF50A1E50), Color(0x000A1E50)], stops: [.7, 1]),
              ),
              child: Row(children: [
                Expanded(flex: 5, child: _BarBtn(Icons.restart_alt_rounded, 'Reset', outlined: true, onTap: _reset)),
                const SizedBox(width: 8),
                Expanded(flex: 5, child: _BarBtn(Icons.add_rounded, 'Add', tinted: true, onTap: _add)),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: _BarBtn(null, 'Done', filled: true, onTap: () {
                    _save();
                    workspaceEditing.value = false;
                  }),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  /// Invisible touch area on an edge or corner of a card in edit mode; the
  /// two bottom corners also show the thick cyan L.
  Widget _handle(WItem it, int sx, int sy) {
    const c = 44.0, e = 20.0; // corner square, edge strip
    final active = it.id == _resizing && _cornerIdx == sx * 3 + sy;
    const side = BorderSide(color: CkColors.cyan, width: 4.5);
    final corner = sx != 0 && sy != 0;
    final Widget mark = corner && sy > 0
        ? Align(
            alignment: sx < 0 ? Alignment.bottomLeft : Alignment.bottomRight,
            child: AnimatedContainer(
              duration: CkMotion.fast,
              width: active ? 30 : 24,
              height: active ? 30 : 24,
              decoration: BoxDecoration(
                border: Border(left: sx < 0 ? side : BorderSide.none, right: sx > 0 ? side : BorderSide.none, bottom: side),
                borderRadius: BorderRadius.only(
                  bottomLeft: sx < 0 ? const Radius.circular(12) : Radius.zero,
                  bottomRight: sx > 0 ? const Radius.circular(12) : Radius.zero,
                ),
              ),
            ),
          )
        : const SizedBox.expand();
    return Positioned(
      // Inside the card: touches outside a widget's box never reach it.
      left: sx < 0 ? 0 : (sx == 0 ? c : null),
      right: sx > 0 ? 0 : (sx == 0 ? c : null),
      top: sy < 0 ? 0 : (sy == 0 ? c : null),
      bottom: sy > 0 ? 0 : (sy == 0 ? c : null),
      width: sx == 0 ? null : (corner ? c : e),
      height: sy == 0 ? null : (corner ? c : e),
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          _EagerPan: GestureRecognizerFactoryWithHandlers<_EagerPan>(
            () => _EagerPan(),
            (r) => r
              ..onStart = (_) {
                _drag = Offset.zero;
                _cornerIdx = sx * 3 + sy;
                _resizeStart(it);
              }
              ..onUpdate = (d) {
                _drag += d.delta;
                _resizeUpdate(sx, sy, _drag);
              }
              ..onEnd = (_) {
                _resizeEnd();
              }
              ..onCancel = _resizeEnd,
          ),
        },
        child: mark,
      ),
    );
  }

  Widget _tile(WItem it, String mId, {bool floating = false}) {
    final m = kWorkspaceModules[it.id]!;
    final body = RepaintBoundary(
      child: Glass(
        padding: const EdgeInsets.all(12),
        shadow: !floating && !_edit,
        child: _edit ? Opacity(opacity: .72, child: IgnorePointer(child: m.build(mId, it.size))) : m.build(mId, it.size),
      ),
    );
    if (!_edit) {
      return Builder(builder: (tc) => GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          // keep this card where it is on screen when edit mode opens
          final box = tc.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize) _keepAt(it.id, box.localToGlobal(Offset.zero).dy);
          workspaceEditing.value = true;
        },
        child: Pressable(scale: .985, onTap: m.page == null || m.ownTap ? null : () => pushModule(context, m.page!()), child: body),
      ));
    }
    final active = it.id == _resizing;
    return Stack(clipBehavior: Clip.none, children: [
      Positioned.fill(child: body),
      // glowing edit border
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedContainer(
            duration: CkMotion.fast,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: CkColors.cyan, width: active ? 2.5 : 1.5),
              boxShadow: [BoxShadow(color: CkColors.cyan.withValues(alpha: active ? .55 : .35), blurRadius: active ? 16 : 10)],
            ),
          ),
        ),
      ),
      if (!floating) ...[
        // long-press anywhere also picks the card up
        Positioned.fill(
          child: RawGestureDetector(
            behavior: HitTestBehavior.translucent,
            gestures: {
              LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(duration: const Duration(milliseconds: 260)),
                (r) => r
                  ..onLongPressStart = (d) {
                    _moveStart(it, d.globalPosition);
                  }
                  ..onLongPressMoveUpdate = (d) {
                    _moveUpdate(d.globalPosition);
                  }
                  ..onLongPressEnd = (_) {
                    _moveEnd();
                  }
                  ..onLongPressCancel = () {
                    if (_moving != null) _moveEnd();
                  },
              ),
            },
          ),
        ),
        // resize from all 4 edges and 4 corners; the grip and − below sit
        // on top, so the top edge gives way to them
        for (final (sx, sy) in const [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, -1), (-1, 1), (1, 1)]) _handle(it, sx, sy),
        // grip: drag right away
        Positioned(
          top: 2,
          right: 2,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _EagerPan: GestureRecognizerFactoryWithHandlers<_EagerPan>(
                () => _EagerPan(),
                (r) => r
                  ..onStart = (d) {
                    _moveStart(it, d.globalPosition);
                  }
                  ..onUpdate = (d) {
                    _moveUpdate(d.globalPosition);
                  }
                  ..onEnd = (_) {
                    _moveEnd();
                  }
                  ..onCancel = _moveEnd,
              ),
            },
            child: const SizedBox(width: 44, height: 40, child: Icon(Icons.drag_indicator_rounded, size: 20, color: CkColors.cyan)),
          ),
        ),
        // remove: small mark, big tap area
        Positioned(
          top: 0,
          left: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _remove(it),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: CkColors.deepSpace, shape: BoxShape.circle, border: Border.all(color: const Color(0x99FFFFFF))),
                  child: const Icon(Icons.remove_rounded, size: 15, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    ]);
  }
}

class _BarBtn extends StatelessWidget {
  final IconData? icon;
  final String text;
  final bool outlined, tinted, filled;
  final VoidCallback onTap;
  const _BarBtn(this.icon, this.text, {this.outlined = false, this.tinted = false, this.filled = false, required this.onTap});
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: filled ? CkColors.cyan : tinted ? CkColors.cyanTint : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: filled ? CkColors.cyan : tinted ? CkColors.cyanStroke : const Color(0x8CFFFFFF), width: 1.5),
            boxShadow: filled ? [BoxShadow(color: CkColors.cyan.withValues(alpha: .35), blurRadius: 18)] : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18, color: tinted ? CkColors.cyan : Colors.white), const SizedBox(width: 6)],
            Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: filled ? const Color(0xFF06204F) : Colors.white)),
          ]),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final bool filled;
  final bool dot;
  final bool edit;
  final VoidCallback onTap;
  const _Chip(this.text, {this.selected = false, this.filled = false, this.dot = false, this.edit = false, required this.onTap});
  @override
  Widget build(BuildContext context) => Pressable(
        scale: .95,
        onTap: onTap,
        child: AnimatedContainer(
          duration: CkMotion.fast,
          curve: kEase,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: filled ? CkColors.cyan : selected ? CkColors.cyanTint : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: filled ? CkColors.cyan : selected ? CkColors.cyanStroke : CkColors.panelStroke),
            boxShadow: selected || filled ? [BoxShadow(color: CkColors.cyan.withValues(alpha: .22), blurRadius: 14)] : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: filled || selected ? FontWeight.w600 : FontWeight.w500,
                    color: filled ? const Color(0xFF06204F) : selected ? Colors.white : CkColors.textSecondary,
                  )),
            ),
            if (dot) ...[
              const SizedBox(width: 5),
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: CkColors.cyan, shape: BoxShape.circle)),
            ],
            if (edit) ...[
              const SizedBox(width: 6),
              Icon(Icons.edit_rounded, size: 13, color: selected ? CkColors.cyan : CkColors.textSecondary),
            ],
          ]),
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
      child: SingleChildScrollView(
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
                onTap: m.soon ? null : () => Navigator.pop(context, m.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                  child: Row(children: [
                    _ModIcon(m.title, 24),
                    const SizedBox(width: 12),
                    Expanded(child: Opacity(opacity: m.soon ? .5 : 1, child: Text(m.soon ? '${m.title} · soon' : m.title, style: const TextStyle(fontSize: 14.5)))),
                    if (!m.soon) Icon(on.contains(m.id) ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
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

/// Loads one card's data. On failure only this card shows Retry, and
/// Retry refetches only this card's API (failed calls aren't cached).
class _Load<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(T) builder;
  final Widget? skel;
  const _Load(this.load, this.builder, {super.key, this.skel});
  @override
  State<_Load<T>> createState() => _LoadState<T>();
}

class _LoadState<T> extends State<_Load<T>> {
  // Every loader here reads the data layer, which hands back the same
  // request for the same question, so asking on each build is free and a
  // new question (another day range) is picked up at once: the card keeps
  // its last data and its stats glide to the new values.
  @override
  Widget build(BuildContext context) => FastFuture<T>(
        future: widget.load(),
        builder: widget.builder,
        loading: widget.skel ?? const _Loading(),
        error: () => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Couldn\'t load', style: CkText.muted),
                const SizedBox(height: 6),
                Pressable(
                  onTap: () => setState(() {}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.cyanStroke)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.refresh_rounded, size: 15, color: CkColors.cyan),
                      SizedBox(width: 5),
                      Text('Retry', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
            ),
      );
}

Widget _future<T>(Future<T> Function() load, Widget Function(T) b, {Widget? skel, Key? key}) => _Load<T>(load, b, skel: skel, key: key);

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
          child: _future<List<GrahPos>>(() => ClientData.of(mId).chart(), skel: _skelKundli(size), (planets) {
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
                  Expanded(child: Center(child: ZoomChart(doubleTapZoom: false, child: chart))),
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
          child: _future<List<GrahPos>>(() => ClientData.of(mId).chart(), skel: _skelRows(10, twoCols: size == WSize.w, mid: size != WSize.s), (l) {
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
          child: _future<Map<String, double>>(() => ClientData.of(mId).shadbal(), skel: _skelBars(), (m) {
            final v = [for (final id in flavor ? _flavor : _power) if (m[id] != null) MapEntry(id, m[id]!)];
            return LayoutBuilder(
              builder: (c, box) => GrahBarChart(values: v, height: math.max(40, box.maxHeight - 24), axis: size != WSize.s),
            );
          }),
        ),
      ]);
}

class _TransitW extends StatefulWidget {
  final String mId;
  final WSize size;
  const _TransitW(this.mId, this.size);
  @override
  State<_TransitW> createState() => _TransitWState();
}

class _TransitWState extends State<_TransitW> {
  DateTime? _at; // picked moment; null: now
  int _step = 1; // index into _steps
  static const _steps = <(String, Duration?, int)>[
    ('1 Hour', Duration(hours: 1), 0),
    ('1 Day', Duration(days: 1), 0),
    ('1 Week', Duration(days: 7), 0),
    ('1 Month', null, 1),
    ('1 Year', null, 12),
    ('10 Years', null, 120),
  ];

  String get mId => widget.mId;
  WSize get size => widget.size;

  DateTime _move(DateTime t, int dir) {
    final (_, d, months) = _steps[_step];
    if (d != null) return t.add(d * dir);
    return DateTime(t.year, t.month + months * dir, t.day, t.hour, t.minute);
  }

  Future<void> _pick() async {
    final cur = _at ?? DateTime.now();
    final d = await showDatePicker(context: context, initialDate: cur, firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(cur));
    if (!mounted) return;
    final tt = t ?? TimeOfDay.fromDateTime(cur);
    setState(() => _at = DateTime(d.year, d.month, d.day, tt.hour, tt.minute));
  }

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

  Widget _arrow(IconData i, VoidCallback onTap) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), child: Icon(i, size: 22, color: CkColors.cyan)),
      );

  /// ‹ STEP 1 Day ▾ › — arrows move the moment by the step; the dropdown
  /// shows about four steps at a time and scrolls.
  Widget _stepper() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _arrow(Icons.chevron_left_rounded, () => setState(() => _at = _move(_at ?? DateTime.now(), -1))),
        CkMenuButton<int>(
          value: _step,
          minWidth: 140,
          items: [for (var i = 0; i < _steps.length; i++) CkMenuItem(i, _steps[i].$1)],
          onSelected: (v) => setState(() => _step = v),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('STEP ', style: CkText.label),
              Text('${_steps[_step].$1} ▾', style: CkText.mono(12, color: CkColors.cyan)),
            ]),
          ),
        ),
        _arrow(Icons.chevron_right_rounded, () => setState(() => _at = _move(_at ?? DateTime.now(), 1))),
      ]);

  @override
  Widget build(BuildContext context) {
    final at = _at ?? DateTime.now();
    final sameDay = DateUtils.isSameDay(at, DateTime.now());
    final label = _at == null ? '● ${DateFormat('HH:mm').format(at)}' : DateFormat(sameDay ? 'HH:mm' : (size == WSize.s ? 'd MMM yy' : 'd MMM yy · HH:mm')).format(at);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _WHead('Transit',
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pick,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Text('$label ▾', style: CkText.mono(10.5, color: CkColors.cyan)),
              ),
            ),
            if (_at != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _at = null),
                child: const Padding(padding: EdgeInsets.fromLTRB(10, 6, 4, 6), child: Icon(Icons.restart_alt_rounded, size: 16, color: CkColors.cyan)),
              ),
          ])),
      const SizedBox(height: 6),
      Expanded(
        child: _future<List<GrahPos>>(key: ValueKey(DateFormat('yyyyMMddHHmm').format(at)), () => ClientData.of(mId).transit(at),
            skel: size == WSize.l ? _skelCircle() : size == WSize.s ? _skelRows(5, mid: false) : _skelRows(10, twoCols: size == WSize.w), (t) {
          final ps = _ordered(t);
          if (size == WSize.l) {
            return _future<List<GrahPos>>(() => ClientData.of(mId).chart(), skel: _skelCircle(),
                (b) => Center(child: ZoomChart(doubleTapZoom: false, child: KundliChart(b, transit: t))));
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
      if (size == WSize.l) _stepper(),
    ]);
  }
}

/// Sentiments (signed, software green/red) or Situations (0–100, 7 zones
/// with arrows) for days around today, each bar with its value.
/// Small: yesterday · today · tomorrow. Tall: 5 days. Wide: 10 days.
/// Large: 14 days plus strongest / weakest / average.
/// Month shown in a card header: plain text + ▾ (no border), tap to pick a
/// month; ⟲ appears once a month is picked and goes back to "around today".
class _MonthChip extends StatelessWidget {
  final DateTime shown;
  final bool picked;
  final bool short;
  final ValueChanged<DateTime?> onChanged;
  const _MonthChip({required this.shown, required this.picked, required this.short, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final m = await pickMonth(context, shown);
            if (m != null) onChanged(m);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Text('${DateFormat(short ? 'MMM yy' : 'MMM yyyy').format(shown).toUpperCase()} ▾', style: CkText.mono(10.5, color: CkColors.cyan)),
          ),
        ),
        if (picked)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(null),
            child: const Padding(padding: EdgeInsets.fromLTRB(10, 6, 4, 6), child: Icon(Icons.restart_alt_rounded, size: 16, color: CkColors.cyan)),
          ),
      ]);
}

class _DailyW extends StatefulWidget {
  final String mId;
  final WSize size;
  final bool signed;
  const _DailyW(this.mId, this.size, {required this.signed});
  @override
  State<_DailyW> createState() => _DailyWState();
}

class _DailyWState extends State<_DailyW> {
  DateTime? _month; // picked month: the whole month; null: days around today
  String get mId => widget.mId;
  WSize get size => widget.size;
  bool get signed => widget.signed;

  (int, int) get _span => switch (size) { WSize.s => (1, 1), WSize.t => (2, 2), WSize.w => (6, 3), WSize.l => (10, 3) };

  static String _fmt(double v, bool signed) {
    final r = v.round();
    return signed && r > 0 ? '+$r%' : '$r%';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final (back, ahead) = _span;
    final m = _month;
    final from = m ?? today.subtract(Duration(days: back));
    final to = m == null ? today.add(Duration(days: ahead)) : DateTime(m.year, m.month + 1, 0);
    final title = signed ? 'Sentiments' : 'Situations';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _WHead(title,
          trailing: _MonthChip(shown: m ?? now, picked: m != null, short: size == WSize.s, onChanged: (v) => setState(() => _month = v))),
      const SizedBox(height: 8),
      Expanded(
        child: _future<List<MapEntry<DateTime, double>>>(() => ClientData.of(mId).window(signed ? 'sent' : 'sit', from, to), skel: _skelDaily(to.difference(from).inDays + 1, signed), (l) {
          if (l.isEmpty) return const Center(child: Text('No data for these days', style: CkText.muted));
          final chart = _bars(l, today);
          if (size != WSize.l) return chart;
          final best = l.reduce((a, b) => b.value > a.value ? b : a);
          final worst = l.reduce((a, b) => b.value < a.value ? b : a);
          final avg = l.map((e) => e.value).reduce((a, b) => a + b) / l.length;
          Color col(double v) => signed ? (v >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)) : zoneOf(v).color;
          Widget stat(String k, double v) => Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
                  decoration: BoxDecoration(color: const Color(0x0FFFFFFF), borderRadius: BorderRadius.circular(9)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(k.toUpperCase(), style: CkText.label.copyWith(fontSize: 9.5)),
                    const SizedBox(height: 2),
                    StatText(_fmt(v, signed), style: CkText.mono(14, color: signed && k == 'Average' ? Colors.white : col(v))),
                  ]),
                ),
              );
          return Column(children: [
            Row(children: [
              stat(signed ? 'Strongest' : 'Best', best.value),
              const SizedBox(width: 6),
              stat('Weakest', worst.value),
              const SizedBox(width: 6),
              stat('Average', avg),
            ]),
            const SizedBox(height: 10),
            Expanded(child: chart),
          ]);
        }),
      ),
    ]);
  }

  Widget _bars(List<MapEntry<DateTime, double>> l, DateTime today) => LayoutBuilder(builder: (c, box) {
        const lab = 16.0;
        final few = l.length <= 3;
        final dense = box.maxWidth / l.length < 16; // whole month on a narrow card
        final fs = few ? 11.0 : (dense ? 0.0 : 9.0);
        final bw = few ? 18.0 : (l.length <= 5 ? 14.0 : (dense ? math.max(2.0, box.maxWidth / l.length - 3) : 10.0));
        final h = box.maxHeight - lab;
        final maxAbs = signed ? l.map((e) => e.value.abs()).fold<double>(1, math.max) : 100.0;
        final topPad = signed ? 20.0 : (few ? 32.0 : 28.0);
        return Column(children: [
          SizedBox(
            height: h,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < l.length; i++)
                Expanded(
                  // a stat: rises with the card, glides to new days' values
                  child: StatValue(
                    value: l[i].value,
                    index: i,
                    // colour comes from the final value, so it never shifts while growing
                    builder: (x) => _bar(MapEntry(l[i].key, x), today, h, maxAbs, topPad, bw, fs, 1, l[i].value),
                  ),
                ),
            ]),
          ),
          SizedBox(
            height: lab,
            child: Row(children: [
              for (final e in l)
                Expanded(
                  child: Center(
                    child: Text(
                      dense && e.key.day != 1 && e.key.day % 5 != 0 && e.key != today ? '' : few && e.key == today ? 'Today' : '${e.key.day}',
                      style: CkText.mono(9.5, color: e.key == today ? CkColors.cyan : CkColors.labelMono),
                    ),
                  ),
                ),
            ]),
          ),
        ]);
      });

  Widget _bar(MapEntry<DateTime, double> e, DateTime today, double h, double maxAbs, double topPad, double bw, double fs, double k, double end) {
    final isToday = e.key == today;
    final v = e.value * k;
    final Widget inner;
    if (signed) {
      final half = h / 2;
      final bh = (half - topPad) * (v.abs() / maxAbs);
      final glowC = v >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
      final up = v >= 0;
      final grad = up
          ? const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF73F4C4), Color(0xFF10B981)])
          : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF6B8B8), Color(0xFFEF4444)]);
      inner = Stack(children: [
        Positioned(left: 0, right: 0, top: half - .5, child: Container(height: 1, color: const Color(0x338CBEFF))),
        Positioned(
          left: 0,
          right: 0,
          top: up ? half - bh : half,
          height: bh,
          child: Center(child: Container(width: bw, decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(3), boxShadow: [BoxShadow(color: glowC.withValues(alpha: .35), blurRadius: 8)]))),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: up ? half - bh - fs - 5 : half + bh + 2,
          child: fs == 0 ? const SizedBox() : Text(_fmt(v, true), textAlign: TextAlign.center, style: CkText.mono(fs, color: Colors.white)),
        ),
      ]);
    } else {
      final z = zoneOf(end);
      final bh = (h - topPad) * (v.clamp(0, 100) / 100);
      inner = Stack(children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: bh,
          child: Center(
            child: Container(
              width: bw,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [z.color, z.color.withValues(alpha: .35)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3), bottom: Radius.circular(1)),
                boxShadow: [BoxShadow(color: z.color.withValues(alpha: .35), blurRadius: 8)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bh + 2,
          child: fs == 0
              ? const SizedBox()
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  ZoneArrows(z, size: fs + 1),
                  Text(_fmt(v, false), style: CkText.mono(fs, color: Colors.white)),
                ]),
        ),
      ]);
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: isToday
          ? BoxDecoration(
              color: const Color(0x145CE1FF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0x595CE1FF)),
            )
          : null,
      child: inner,
    );
  }
}

Widget _skelDaily(int n, bool signed) => LayoutBuilder(builder: (c, b) {
      final h = b.maxHeight - 16;
      return Column(children: [
        SizedBox(
          height: h,
          child: Row(children: [
            for (var i = 0; i < n; i++)
              Expanded(
                child: signed
                    ? Column(children: [
                        SizedBox(height: h / 2, child: Align(alignment: Alignment.bottomCenter, child: i % 3 != 2 ? Skeleton(width: n <= 3 ? 18 : 10, height: (h / 2 - 16) * (.35 + (i * 37 % 55) / 100), radius: 3) : null)),
                        SizedBox(height: h / 2, child: Align(alignment: Alignment.topCenter, child: i % 3 == 2 ? Skeleton(width: n <= 3 ? 18 : 10, height: (h / 2 - 16) * (.3 + (i * 23 % 45) / 100), radius: 3) : null)),
                      ])
                    : Align(alignment: Alignment.bottomCenter, child: Skeleton(width: n <= 3 ? 18 : 10, height: (h - 30) * (.4 + (i * 29 % 50) / 100), radius: 3)),
              ),
          ]),
        ),
        SizedBox(height: 16, child: Row(children: [for (var i = 0; i < n; i++) const Expanded(child: Center(child: Skeleton(width: 12, height: 7, radius: 3)))])),
      ]);
    });

/// Sentiments 5D for days around today, one dimension at a time (picked
/// from the small chip in the header, remembered per user).
/// Small: yesterday · today · tomorrow. Tall: 5 days. Wide: 10. Large: 17 + stats.
class _FiveDW extends StatefulWidget {
  final String mId;
  final WSize size;
  const _FiveDW(this.mId, this.size);
  @override
  State<_FiveDW> createState() => _FiveDWState();
}

class _FiveDWState extends State<_FiveDW> {
  static String get _key => 'ws_u${Session.uid}_5ddim';
  late String _dim = Session.prefs.getString(_key) ?? ClientData.kDims.first;
  late final DateTime _today = () {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }();

  (int, int) get _span => switch (widget.size) { WSize.s => (1, 1), WSize.t => (2, 2), WSize.w => (6, 3), WSize.l => (13, 3) };
  DateTime? _month; // picked month: the whole month; null: days around today

  (DateTime, DateTime) get _range {
    final m = _month;
    if (m != null) return (m, DateTime(m.year, m.month + 1, 0));
    final (b, a) = _span;
    return (_today.subtract(Duration(days: b)), _today.add(Duration(days: a)));
  }

  List<FiveDLoad> _loads() {
    final (from, to) = _range;
    final d = ClientData.of(widget.mId);
    final out = <FiveDLoad>[];
    for (var m = DateTime(from.year, from.month); !m.isAfter(DateTime(to.year, to.month)); m = DateTime(m.year, m.month + 1)) {
      out.add(d.sentiments5DLive(m));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final loads = _loads();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _WHead('Sentiments 5D',
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            _MonthChip(shown: _month ?? _today, picked: _month != null, short: true, onChanged: (v) => setState(() => _month = v)),
            const SizedBox(width: 6),
            CkMenuButton<String>(
              value: _dim,
              items: [for (final d in ClientData.kDims) CkMenuItem(d, d)],
              onSelected: (v) => setState(() {
                _dim = v;
                Session.prefs.setString(_key, v);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: CkColors.cyanStroke)),
                child: Text('${_dim.toUpperCase()} ▾', style: CkText.mono(10, color: CkColors.cyan)),
              ),
            ),
          ])),
      const SizedBox(height: 8),
      Expanded(
        child: ListenableBuilder(
          listenable: Listenable.merge(loads),
          builder: (c, _) {
            final (from, to) = _range;
            final days = [for (var d = from; !d.isAfter(to); d = DateTime(d.year, d.month, d.day + 1)) d];
            final vals = <MapEntry<DateTime, double?>>[];
            var signed = false;
            for (final l in loads) {
              for (final v in l.data.values) {
                if (v.values.any((x) => x < 0)) signed = true;
              }
            }
            for (final d in days) {
              double? v;
              for (final l in loads) {
                v ??= l.data[d]?[_dim];
              }
              vals.add(MapEntry(d, v));
            }
            final loading = loads.any((l) => l.loading);
            if (vals.every((e) => e.value == null)) {
              if (loading) return _skelDaily(days.length, false);
              return const Center(child: Text('No data for these days', style: CkText.muted));
            }
            String pct(double v) => '${signed && v > 0 ? '+' : ''}${v.round()}%';
            final chart = LayoutBuilder(builder: (c, box) {
              const lab = 16.0, top = 18.0;
              final few = days.length <= 3;
              final dense = box.maxWidth / days.length < 16;
              final h = box.maxHeight - lab;
              final bw = few ? 18.0 : (days.length <= 5 ? 14.0 : (dense ? math.max(2.0, box.maxWidth / days.length - 3) : 10.0));
              return Column(children: [
                SizedBox(
                  height: h,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (var i = 0; i < vals.length; i++)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: vals[i].key == _today
                              ? BoxDecoration(color: const Color(0x145CE1FF), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0x595CE1FF)))
                              : null,
                          // a stat: always mounted, so a day that loads late
                          // grows from 0 and a new range glides
                          child: StatValue(
                                  value: vals[i].value,
                                  index: i,
                                  builder: (v) {
                                    if (vals[i].value == null) {
                                      return loading
                                          ? const Align(alignment: Alignment.bottomCenter, child: Skeleton(width: 10, height: 30, radius: 3))
                                          : const SizedBox();
                                    }
                                    const k = 1.0;
                                    final frac = signed ? (v + 100) / 200 : v / 100;
                                    final bh = (h - top - 4) * frac.clamp(0.0, 1.0) * k;
                                    final col = fiveDColor(vals[i].value!, signed: signed); // final value's colour, fixed while it grows
                                    return Stack(children: [
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        height: math.max(bh, 3),
                                        child: Center(
                                          child: Container(
                                            width: bw,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [col, col.withValues(alpha: .35)]),
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(3), bottom: Radius.circular(1)),
                                              boxShadow: [BoxShadow(color: col.withValues(alpha: .35), blurRadius: 8)],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: bh + 2,
                                        child: dense ? const SizedBox() : Text(pct(v * k), textAlign: TextAlign.center, style: CkText.mono(few ? 11 : 9, color: Colors.white)),
                                      ),
                                    ]);
                                  },
                                ),
                        ),
                      ),
                  ]),
                ),
                SizedBox(
                  height: lab,
                  child: Row(children: [
                    for (final e in vals)
                      Expanded(
                        child: Center(
                          child: Text(dense && e.key.day != 1 && e.key.day % 5 != 0 && e.key != _today ? '' : few && e.key == _today ? 'Today' : '${e.key.day}',
                              style: CkText.mono(9.5, color: e.key == _today ? CkColors.cyan : CkColors.labelMono)),
                        ),
                      ),
                  ]),
                ),
              ]);
            });
            if (widget.size != WSize.l) return chart;
            final known = [for (final e in vals) if (e.value != null) MapEntry(e.key, e.value!)];
            final best = known.reduce((x, y) => y.value > x.value ? y : x);
            final worst = known.reduce((x, y) => y.value < x.value ? y : x);
            final avg = known.map((e) => e.value).reduce((x, y) => x + y) / known.length;
            Widget stat(String k, double v) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
                    decoration: BoxDecoration(color: const Color(0x0FFFFFFF), borderRadius: BorderRadius.circular(9)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(k.toUpperCase(), style: CkText.label.copyWith(fontSize: 9.5)),
                      const SizedBox(height: 2),
                      StatText(pct(v), style: CkText.mono(14, color: fiveDColor(v, signed: signed))),
                    ]),
                  ),
                );
            return Column(children: [
              Row(children: [stat('Best', best.value), const SizedBox(width: 6), stat('Weakest', worst.value), const SizedBox(width: 6), stat('Average', avg)]),
              const SizedBox(height: 10),
              Expanded(child: chart),
            ]);
          },
        ),
      ),
    ]);
  }
}

/// Birth-moment Panchang (client's birth place).
class _PanchangW extends StatelessWidget {
  final String mId;
  final WSize size;
  const _PanchangW(this.mId, this.size);

  Widget _row(String k, String v, {double fs = 12.5}) => Expanded(
        child: Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1A8CBEFF)))),
          child: Row(children: [
            SizedBox(width: 74, child: Text(k.toUpperCase(), style: CkText.label)),
            Expanded(child: Text(v.isEmpty ? '—' : v, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600))),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const _WHead('Panchang', trailing: Text('AT BIRTH', style: TextStyle(fontSize: 9.5, color: CkColors.cyan, letterSpacing: 1))),
        const SizedBox(height: 6),
        Expanded(
          child: _future<ClientPanchang>(() => ClientPanchang.of(mId), skel: _skelRows(size == WSize.s ? 3 : 6, mid: false), (p) {
            final d = p.data;
            String g(String k) => d.get(k);
            final keys = const ['Nakshatra', 'Tithi', 'Karan', 'Yog', 'Day', 'Rashi'];
            switch (size) {
              case WSize.s:
                return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(g('Nakshatra'), maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.h(16)),
                  const SizedBox(height: 3),
                  Text(g('Tithi'), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(g('Rashi'), style: CkText.mono(10.5, color: CkColors.labelMono)),
                ]);
              case WSize.w:
                return Row(children: [
                  SizedBox(
                    width: 120,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(g('Nakshatra'), maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.h(16)),
                      const SizedBox(height: 3),
                      Text(g('Tithi'), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(children: [for (final k in const ['Karan', 'Yog', 'Day', 'Rashi']) _row(k, g(k), fs: 12)])),
                ]);
              case WSize.t:
              case WSize.l:
                final extra = size == WSize.l ? d.rows.where((r) => !keys.contains(r.$1)).take(4).toList() : const <(String, String)>[];
                return Column(children: [
                  if (size == WSize.l && p.at != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        Text(DateFormat('dd MMM yyyy · HH:mm').format(p.at!), style: CkText.mono(11, color: CkColors.cyan)),
                        const Spacer(),
                        Flexible(child: Text(p.place, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: CkColors.textSecondary))),
                      ]),
                    ),
                  for (final k in keys) _row(k, g(k), fs: size == WSize.t ? 11.5 : 12.5),
                  for (final r in extra) _row(r.$1, r.$2),
                ]);
            }
          }),
        ),
      ]);
}

/// Last Melapak result of this client (saved when a match is opened).
class _MelapakW extends StatefulWidget {
  final String mId;
  final WSize size;
  const _MelapakW(this.mId, this.size);
  @override
  State<_MelapakW> createState() => _MelapakWState();
}

class _MelapakWState extends State<_MelapakW> {
  String get mId => widget.mId;
  WSize get size => widget.size;
  bool _busy = false;

  Future<void> _pick() async {
    final c = Session.client.value;
    if (c == null) return;
    setState(() => _busy = true);
    try {
      await pickMelapakMatch(context, c);
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t match. Try again.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  void _remove() => setState(() => LastMatch.remove(mId));

  void _open(Map<String, dynamic> r) => pushModule(context, MelapakResultPage(future: Future.value(r)));

  Widget _icon(IconData i, Color c, VoidCallback on, String tip) => Tooltip(
        message: tip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: on,
          child: Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x0EFFFFFF), border: Border.all(color: const Color(0x1FFFFFFF))),
            child: Icon(i, size: 15, color: c),
          ),
        ),
      );

  static const _rows = [
    ('Varna', 'Varn_Points', 1),
    ('Vashya', 'Vaishya_Points', 2),
    ('Tara', 'Tara_Points', 3),
    ('Yoni', 'Yoni_Points', 4),
    ('Graha Maitri', 'Rashidhyapati_Points', 5),
    ('Gana', 'Gan_Points', 6),
    ('Bhakoot', 'Bhakoot_Points', 7),
    ('Nadi', 'Naadi_Points', 8),
  ];

  static double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  Widget _ring(double total, double d) {
    final col = total >= 18 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return SizedBox(
      width: d,
      height: d,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: d,
          height: d,
          child: CircularProgressIndicator(value: (total / 36).clamp(0, 1), strokeWidth: 6, color: col, backgroundColor: const Color(0x2E8CBEFF), strokeCap: StrokeCap.round),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(total % 1 == 0 ? '${total.toInt()}' : total.toStringAsFixed(1), style: CkText.mono(d / 4.2)),
          Text('of 36', style: TextStyle(fontSize: d / 9, color: CkColors.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _koota((String, String, int) k, Map<String, dynamic> r, {double label = 84}) {
    final pts = _n(r[k.$2]);
    final col = pts >= k.$3 ? const Color(0xFF10B981) : pts > 0 ? const Color(0xFFF5B66B) : const Color(0xFFEF4444);
    return Expanded(
      child: Row(children: [
        SizedBox(width: label, child: Text(k.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: CkColors.textSecondary))),
        Expanded(
          child: Meter(value: pts / k.$3, color: col, height: 5),
        ),
        SizedBox(width: 38, child: Text('${pts % 1 == 0 ? pts.toInt() : pts}/${k.$3}', textAlign: TextAlign.right, style: CkText.mono(10))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = LastMatch.of(mId);
    final me = Session.client.value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _busy ? null : (r == null ? _pick : () => _open(r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _WHead('Melapak',
          trailing: r == null
              ? null
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  _icon(Icons.autorenew_rounded, CkColors.cyan, _pick, 'Switch partner'),
                  _icon(Icons.close_rounded, const Color(0xFFF6B8B8), _remove, 'Remove match'),
                ])),
      const SizedBox(height: 6),
      Expanded(
        child: _busy
            ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: CkColors.cyan)))
            : r == null
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('No match yet', style: CkText.muted),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: CkColors.cyanStroke)),
                    child: const Text('+ Pick partner', style: TextStyle(fontSize: 12.5, color: CkColors.cyan)),
                  ),
                ]),
              )
            : Builder(builder: (_) {
                final total = _n(r['Total_Gun_Match']);
                final female = me?.isFemale ?? false;
                final partner = '${r[female ? 'Var_Name' : 'Vadhu_Name'] ?? ''}'.trim();
                final good = total >= 18;
                final doshas = [if (_n(r['Naadi_Points']) == 0) 'Nadi dosha', if (_n(r['Bhakoot_Points']) == 0) 'Bhakoot dosha'];
                final verdict = Text(
                  [total >= 28 ? 'Excellent match' : good ? 'Good match' : 'Below 18', ...doshas].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: good ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                );
                final names = Text('× $partner', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));
                switch (size) {
                  case WSize.s:
                    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _ring(total, 78),
                      const SizedBox(height: 6),
                      Text(partner, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.mono(10, color: CkColors.textSecondary)),
                    ]);
                  case WSize.w:
                    return Row(children: [
                      _ring(total, 96),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [names, const SizedBox(height: 4), verdict])),
                    ]);
                  case WSize.t:
                    return Column(children: [
                      _ring(total, 90),
                      const SizedBox(height: 6),
                      names,
                      verdict,
                      const SizedBox(height: 6),
                      Expanded(child: Column(children: [for (final k in _rows.skip(4)) _koota(k, r, label: 62)])),
                    ]);
                  case WSize.l:
                    return Column(children: [
                      Row(children: [
                        _ring(total, 80),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [names, const SizedBox(height: 4), verdict])),
                      ]),
                      const SizedBox(height: 8),
                      Expanded(child: Column(children: [for (final k in _rows) _koota(k, r)])),
                    ]);
                }
              }),
      ),
    ]),
    );
  }
}

/// Any module without its own card: icon, name and what it shows; tap opens.
class _GenericW extends StatelessWidget {
  final WModule m;
  final WSize size;
  const _GenericW(this.m, this.size);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _WHead(m.title),
        Expanded(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _ModIcon(m.title, size == WSize.s ? 40 : 56),
              const SizedBox(height: 10),
              Text(m.sub, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
              const SizedBox(height: 8),
              Text('Open ›', style: CkText.mono(11, color: CkColors.cyan)),
            ]),
          ),
        ),
      ]);
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
