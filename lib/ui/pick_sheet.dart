// The one "pick a person" sheet (Pickers and sheets family). Switch client,
// Compare transits, the Melapak card and both Melapak people in Tools all
// open this sheet; only the title, subtitle and extras differ. The build
// check fails on a client list drawn anywhere else.
//
// Same everywhere: grabber, title and one line of context, the search box
// (kit), optional filter chips, rows like the Clients page (initials, name,
// date of birth and place), a check on the current one, row skeletons while
// loading, a short message when nothing matches, an optional footer action,
// a light haptic on pick.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ck_theme.dart';
import 'glass.dart' show Pressable;
import 'widgets.dart';

/// A filter chip: its label and which items it keeps.
class PickFilter<T> {
  final String label;
  final bool Function(T) keep;
  const PickFilter(this.label, this.keep);
}

/// What the sheet returns: the picked item, or the footer action.
class Picked<T> {
  final T? item;
  final bool footer;
  const Picked.item(this.item) : footer = false;
  const Picked.footer() : item = null, footer = true;
}

Future<Picked<T>?> showPickSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Future<List<T>> Function() load,
  required String Function(T) name,
  required String Function(T) sub,
  String Function(T)? searchText,
  bool Function(T)? isCurrent,
  List<PickFilter<T>> filters = const [],
  String? footer,
  String countLabel = 'CLIENTS',
}) =>
    showModalBottomSheet<Picked<T>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _PickSheet<T>(
        title: title,
        subtitle: subtitle,
        load: load,
        name: name,
        sub: sub,
        searchText: searchText,
        isCurrent: isCurrent,
        filters: filters,
        footer: footer,
        countLabel: countLabel,
      ),
    );

class _PickSheet<T> extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Future<List<T>> Function() load;
  final String Function(T) name, sub;
  final String Function(T)? searchText;
  final bool Function(T)? isCurrent;
  final List<PickFilter<T>> filters;
  final String? footer;
  final String countLabel;
  const _PickSheet(
      {super.key,
      required this.title,
      this.subtitle,
      required this.load,
      required this.name,
      required this.sub,
      this.searchText,
      this.isCurrent,
      required this.filters,
      this.footer,
      required this.countLabel});
  @override
  State<_PickSheet<T>> createState() => _PickSheetState<T>();
}

class _PickSheetState<T> extends State<_PickSheet<T>> {
  late Future<List<T>> _f = widget.load();
  String _q = '';
  int _filter = 0;

  static const _hues = [Color(0xFFFF9F6B), Color(0xFF7CC5FF), Color(0xFFB69CFF), Color(0xFF6BE3B5), Color(0xFFFFCF6B), Color(0xFFFF8DB8)];

  String _initials(String n) {
    final p = n.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    return (p.first[0] + (p.length > 1 ? p[1][0] : '')).toUpperCase();
  }

  void _pick(T e) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(Picked<T>.item(e));
  }

  Widget _row(T e, int i) {
    final n = widget.name(e);
    final cur = widget.isCurrent?.call(e) ?? false;
    final hue = _hues[n.hashCode.abs() % _hues.length];
    return InkWell(
      onTap: () => _pick(e),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(color: cur ? const Color(0x1A5CE1FF) : null, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: hue.withValues(alpha: .16), border: Border.all(color: hue.withValues(alpha: .45))),
            child: Text(_initials(n), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              if (widget.sub(e).isNotEmpty)
                Text(widget.sub(e), maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.mono(11.5, color: CkColors.textSecondary)),
            ]),
          ),
          if (cur) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_rounded, color: CkColors.cyan, size: 20)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          height: mq.size.height * .78 - mq.viewInsets.bottom * .5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SheetGrabber(),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.h(19)),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(widget.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: CkColors.textSecondary)),
                    ],
                  ]),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20, color: CkColors.textSecondary),
                ),
              ]),
              const SizedBox(height: 10),
              CkSearchField(
                onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                decoration: const InputDecoration(hintText: 'Search name, year, place'),
              ),
              if (widget.filters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(spacing: 6, children: [
                    for (var i = 0; i < widget.filters.length; i++)
                      Pressable(
                        onTap: () => setState(() => _filter = i),
                        child: AnimatedContainer(
                          duration: CkMotion.fast,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: i == _filter ? CkColors.cyanTint : CkColors.glassFill,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: i == _filter ? CkColors.cyanStroke : CkColors.panelStroke),
                          ),
                          child: Text(widget.filters[i].label,
                              style: TextStyle(fontSize: 12.5, color: i == _filter ? CkColors.cyan : CkColors.textSecondary)),
                        ),
                      ),
                  ]),
                ),
              Expanded(
                child: FastFuture<List<T>>(
                  future: _f,
                  loading: const SkeletonList(rows: 7),
                  onRetry: () => setState(() => _f = widget.load()),
                  builder: (all) {
                    var l = all;
                    if (widget.filters.isNotEmpty) l = l.where(widget.filters[_filter].keep).toList();
                    if (_q.isNotEmpty) {
                      l = l.where((e) => (widget.searchText?.call(e) ?? '${widget.name(e)} ${widget.sub(e)}').toLowerCase().contains(_q)).toList();
                    }
                    return ListView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        Padding(padding: const EdgeInsets.only(top: 14, bottom: 4), child: Text('${l.length} ${widget.countLabel}', style: CkText.label)),
                        if (l.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Text(_q.isEmpty ? 'Nobody here yet.' : 'No one matches “$_q”.',
                                textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: CkColors.textSecondary)),
                          )
                        else
                          for (var i = 0; i < l.length; i++) _row(l[i], i),
                      ],
                    );
                  },
                ),
              ),
              if (widget.footer != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: CkColors.panelStroke))),
                  child: Pressable(
                    onTap: () => Navigator.of(context).pop(Picked<T>.footer()),
                    child: Container(
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(12), border: Border.all(color: CkColors.cyanStroke)),
                      child: Text(widget.footer!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CkColors.cyan)),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
