import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/astro.dart';
import '../core/session.dart';
import 'ck_theme.dart';
import 'glass.dart';

// ───────────────────────── basics

class CkText {
  static TextStyle h(double size, {Color color = CkColors.text, FontWeight w = FontWeight.w600}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: color, height: 1.2, letterSpacing: size > 20 ? -.4 : -.1);
  static const label = TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.5, letterSpacing: 1.2, fontWeight: FontWeight.w500, color: CkColors.labelMono);
  static TextStyle mono(double size, {Color color = CkColors.text, FontWeight w = FontWeight.w500}) =>
      TextStyle(fontFamily: 'JetBrainsMono', fontSize: size, fontWeight: w, color: color, height: 1.25);
  static const muted = TextStyle(fontSize: 12.5, color: CkColors.textSecondary);
}

String upper(String s) => s.toUpperCase();

void toast(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [
        Icon(error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: error ? CkColors.red : CkColors.green, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(msg)),
      ]),
    ));
}

Future<bool> confirm(BuildContext context, String title, String body, {String ok = 'Yes', bool danger = false}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title, style: CkText.h(18)),
      content: Text(body, style: const TextStyle(color: CkColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel', style: TextStyle(color: CkColors.text))),
        TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(ok, style: TextStyle(color: danger ? CkColors.red : CkColors.orangeSoft, fontWeight: FontWeight.w600))),
      ],
    ),
  );
  return r ?? false;
}

class CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String label;
  final double size;
  const CircleBtn(this.icon, {super.key, this.onTap, required this.label, this.size = 42});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Pressable(
          onTap: onTap,
          child: Glass(
            width: size,
            height: size,
            radius: size / 2,
            shadow: false,
            alignment: Alignment.center,
            child: Icon(icon, size: size * .48, color: CkColors.text),
          ),
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  final double height;
  const PrimaryButton(this.text, {super.key, this.onTap, this.loading = false, this.icon, this.height = 54});
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: loading ? null : onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: CkColors.cta,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const [BoxShadow(color: Color(0x5AF56720), blurRadius: 30, offset: Offset(0, 10))],
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                  Text(text, style: CkText.h(15.5, w: FontWeight.w600)),
                ]),
        ),
      );
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  const GhostButton(this.text, {super.key, this.onTap, this.icon, this.color = CkColors.text});
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        child: Glass(
          height: 50,
          radius: 16,
          shadow: false,
          stroke: color == CkColors.text ? CkColors.glassStroke : color.withOpacity(.5),
          alignment: Alignment.center,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, color: color, size: 19), const SizedBox(width: 8)],
            Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14.5)),
          ]),
        ),
      );
}

class Field extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool required;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboard;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? formatters;
  const Field(this.label,
      {super.key,
      this.controller,
      this.hint,
      this.icon,
      this.required = false,
      this.obscure = false,
      this.suffix,
      this.keyboard,
      this.maxLines = 1,
      this.readOnly = false,
      this.onTap,
      this.validator,
      this.formatters,
      this.focusNode,
      this.maxLength});
  final FocusNode? focusNode;

  /// Character limit, shown as a live counter (n / max) under the field.
  final int? maxLength;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text.rich(TextSpan(text: upper(label), style: CkText.label, children: [
            if (required) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFFF8A8A))),
          ])),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            keyboardType: keyboard,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            inputFormatters: formatters,
            maxLength: maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            buildCounter: maxLength == null
                ? null
                : (c, {required currentLength, required isFocused, maxLength}) => Text('$currentLength / $maxLength',
                    style: CkText.mono(10.5, color: currentLength >= (maxLength ?? 0) ? const Color(0xFFF5B66B) : CkColors.labelMono)),
            style: const TextStyle(color: CkColors.text, fontSize: 15),
            cursorColor: CkColors.cyan,
            validator: validator ??
                (required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon == null ? null : Icon(icon, size: 19),
              suffixIcon: suffix,
            ),
          ),
        ]),
      );
}

class Segmented<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  final double height;
  const Segmented({super.key, required this.values, required this.selected, required this.label, required this.onChanged, this.height = 44});
  @override
  Widget build(BuildContext context) => Glass(
        height: height,
        radius: 16,
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(builder: (c, box) {
          final w = box.maxWidth / values.length;
          final i = values.indexOf(selected);
          return Stack(children: [
            // the thumb slides to the selected item (MyAcharyaji: 450 ms)
            AnimatedPositioned(
              duration: CkMotion.slow,
              curve: kEase,
              left: w * (i < 0 ? 0 : i),
              top: 0,
              bottom: 0,
              width: w,
              child: AnimatedOpacity(
                duration: CkMotion.fast,
                opacity: i < 0 ? 0 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: CkColors.cyanTint,
                    border: Border.all(color: CkColors.cyanStroke),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: CkColors.cyan.withValues(alpha: .25), blurRadius: 16)],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final v in values)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (v != selected) HapticFeedback.selectionClick();
                        onChanged(v);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: CkMotion.base,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: v == selected ? Colors.white : CkColors.textSecondary),
                          child: Text(label(v)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ]);
        }),
      );
}

class ChoiceChips<T> extends StatelessWidget {
  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  const ChoiceChips({super.key, required this.values, required this.selected, required this.label, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
        children: values
            .map((v) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Pressable(
                      haptic: true,
                      onTap: () => onChanged(v),
                      // selected: lifts 3 px with a glow in its own colour
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: kEase,
                        height: 44,
                        alignment: Alignment.center,
                        transform: Matrix4.translationValues(0, v == selected ? -3 : 0, 0),
                        decoration: BoxDecoration(
                          color: v == selected ? CkColors.orangeTint : CkColors.glassFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: v == selected ? CkColors.orangeStroke : CkColors.glassStroke),
                          boxShadow: [BoxShadow(color: const Color(0xFFF07E22).withValues(alpha: v == selected ? .35 : 0), blurRadius: 18, offset: const Offset(0, 8))],
                        ),
                        child: Text(label(v),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: v == selected ? const Color(0xFFFFB27A) : CkColors.textSecondary)),
                      ),
                    ),
                  ),
                ))
            .toList(),
      );
}

// ───────────────────────── loading / empty / error

/// Results of futures that already finished, so a screen that is rebuilt
/// (tab switched back, page reopened, card resized) draws its data in the
/// first frame instead of flashing a skeleton for one frame.
final Expando<_Done> _done = Expando<_Done>();

class _Done {
  final Object? data;
  final Object? error;
  final bool ok;
  const _Done(this.data, this.error, this.ok);
}

/// Like FutureBuilder, but (motion spec, Phase 1a):
/// - data that is already there shows in the first frame, with no animation;
/// - otherwise the skeleton shows at once (no blank wait), and data or an
///   error then fades in over it (300 ms) inside the card;
/// - a new future for data that is still loading keeps the same skeleton on
///   screen, so it never vanishes and reappears.
class FastFuture<T> extends StatefulWidget {
  final Future<T>? future;
  final Widget Function(T data) builder;
  final Widget loading;
  final Widget Function() error;
  final double? minHeight;
  const FastFuture({super.key, required this.future, required this.builder, required this.loading, required this.error, this.minHeight});
  @override
  State<FastFuture<T>> createState() => _FastFutureState<T>();
}

class _FastFutureState<T> extends State<FastFuture<T>> {
  _Done? _r;
  bool _skel = false; // a skeleton was on screen for this future

  @override
  void initState() {
    super.initState();
    _watch();
  }

  @override
  void didUpdateWidget(FastFuture<T> old) {
    super.didUpdateWidget(old);
    if (!identical(old.future, widget.future)) _watch();
  }

  void _watch() {
    final f = widget.future;
    _r = f == null ? null : _done[f];
    _skel = false;
    if (f == null || _r != null) return;
    // A future that is already done (kept in memory) answers before the
    // next frame: show its data straight away, with no skeleton and no
    // cross-fade. Only a real wait shows the skeleton, from frame two.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(widget.future, f) && _r == null) setState(() => _skel = true);
    });
    f.then((v) {
      final d = _Done(v, null, true);
      _done[f] = d;
      if (mounted && identical(widget.future, f)) setState(() => _r = d);
    }, onError: (Object e) {
      final d = _Done(null, e, false);
      if (mounted && identical(widget.future, f)) setState(() => _r = d);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _r;
    final Widget child;
    if (r == null) {
      child = widget.future == null || !_skel
          ? SizedBox(key: const ValueKey('none'), height: widget.minHeight)
          : KeyedSubtree(key: const ValueKey('skel'), child: widget.loading);
    } else if (!r.ok || (r.data == null && null is! T)) {
      child = KeyedSubtree(key: const ValueKey('err'), child: widget.error());
    } else {
      child = KeyedSubtree(key: const ValueKey('ok'), child: widget.builder(r.data as T));
    }
    if (!_skel) return child;
    // Skeleton -> data, as MyAcharyaji's ResultSwitch: the data fades in
    // over 350 ms. The skeleton leaves at once instead of cross-fading, so
    // the page never shows both at the same time.
    return AnimatedSwitcher(
      duration: _still(context) ? Duration.zero : CkMotion.state,
      switchInCurve: Curves.easeOut,
      transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
      layoutBuilder: (cur, prev) => cur ?? const SizedBox.shrink(),
      child: child,
    );
  }
}

/// The phone's "remove animations" setting (motion spec: honour it).
bool _still(BuildContext c) => MediaQuery.maybeDisableAnimationsOf(c) ?? false;

class LoadView<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final double minHeight;
  final Widget? skeleton;
  const LoadView({super.key, required this.future, required this.builder, this.onRetry, this.minHeight = 220, this.skeleton});
  @override
  Widget build(BuildContext context) => FastFuture<T>(
        future: future,
        builder: builder,
        minHeight: minHeight,
        loading: skeleton ?? (minHeight >= 300 ? SkeletonCard(height: minHeight) : const SkeletonList(rows: 5)),
        error: () => ErrorBox(message: 'Couldn\'t load this. Check your connection and try again.', onRetry: onRetry),
      );
}

/// Loading that belongs to the data, not to the request (MyAcharyaji rule):
/// the first load shows [skeleton]; after that, a new [future] (another
/// month, a refresh) keeps the last data on screen and calls
/// `builder(last, true)` until the answer lands, then `builder(new, false)`
/// in the same widget tree, so bars and numbers glide from where they are.
/// Data already loaded shows at once.
class KeepLoad<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(T data, bool loading) builder;
  final Widget skeleton;
  final VoidCallback? onRetry;
  const KeepLoad({super.key, required this.future, required this.builder, required this.skeleton, this.onRetry});
  @override
  State<KeepLoad<T>> createState() => _KeepLoadState<T>();
}

class _KeepLoadState<T> extends State<KeepLoad<T>> {
  T? _data;
  bool _has = false;
  bool _loading = true;
  Object? _err;

  @override
  void initState() {
    super.initState();
    _watch();
  }

  @override
  void didUpdateWidget(KeepLoad<T> old) {
    super.didUpdateWidget(old);
    if (!identical(old.future, widget.future)) _watch();
  }

  void _watch() {
    final f = widget.future;
    final hit = _done[f];
    if (hit != null && hit.ok) {
      _data = hit.data as T;
      _has = true;
      _loading = false;
      _err = null;
      if (!_first.isCompleted) _first.complete(true);
      return;
    }
    _loading = true;
    _err = null;
    f.then((v) {
      _done[f] = _Done(v, null, true);
      if (mounted && identical(widget.future, f)) {
        setState(() {
          _data = v;
          _has = true;
          _loading = false;
        });
        if (!_first.isCompleted) _first.complete(true);
      }
    }, onError: (Object e) {
      if (mounted && identical(widget.future, f)) setState(() => _err = e);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_err != null && !_has) {
      return ErrorBox(message: 'Couldn\'t load this. Check your connection and try again.', onRetry: widget.onRetry);
    }
    // First load: skeleton, then the data fades and rises in once.
    return FastFuture<bool>(
      future: _firstDone,
      loading: widget.skeleton,
      error: () => const SizedBox.shrink(),
      builder: (_) => widget.builder(_data as T, _loading && _err == null),
    );
  }

  // completes once the first data is in; never changes after that
  final _first = Completer<bool>();
  Future<bool> get _firstDone => _first.future;
}

class ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorBox({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Glass(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          const Icon(Icons.cloud_off_rounded, color: CkColors.textSecondary, size: 30),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: CkText.muted),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Try again')),
          ]
        ]),
      );
}

class EmptyBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const EmptyBox({super.key, required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Glass(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          Icon(icon, color: CkColors.orangeSoft, size: 32),
          const SizedBox(height: 10),
          Text(title, style: CkText.h(16)),
          const SizedBox(height: 4),
          Text(body, textAlign: TextAlign.center, style: CkText.muted),
        ]),
      );
}

// ───────────────────────── client header + sections

/// Single-row header used on every screen inside a client.
class ClientHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onSwitch;
  final VoidCallback? onMore;
  const ClientHeader({super.key, required this.title, this.onBack, this.onSwitch, this.onMore});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Client?>(
        valueListenable: Session.client,
        builder: (c, client, _) => Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Row(children: [
            CircleBtn(Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: onBack ?? () => Navigator.maybePop(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: CkText.h(19)),
                const SizedBox(height: 3),
                GestureDetector(
                  onTap: onSwitch,
                  behavior: HitTestBehavior.opaque,
                  child: Row(children: [
                    Flexible(
                      child: Text(
                        client == null ? '' : [client.name, client.dateText, client.timeText].where((e) => e.isNotEmpty).join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: CkColors.textSecondary),
                      ),
                    ),
                    if (onSwitch != null) const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: CkColors.textSecondary),
                  ]),
                ),
              ]),
            ),
            if (onMore != null) ...[
              const SizedBox(width: 10),
              CircleBtn(Icons.more_horiz_rounded, label: 'Client options', onTap: onMore),
            ],
          ]),
        ),
      );
}

class SectionIntro extends StatelessWidget {
  final String text;
  const SectionIntro(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 2), child: Text(text, style: CkText.muted));
}

/// Card on a section page that opens a module.
class ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? preview;
  final bool comingSoon;
  final int index;
  const ModuleCard(
      {super.key,
      required this.title,
      required this.description,
      required this.icon,
      this.onTap,
      this.preview,
      this.comingSoon = false,
      this.index = 0});
  @override
  Widget build(BuildContext context) => KeyedSubtree(
        child: Pressable(
          onTap: comingSoon ? null : onTap,
          child: Glass(
              margin: const EdgeInsets.only(top: 12),
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: greyed(on: comingSoon, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: comingSoon || ckIconAsset(title) != null ? null : CkColors.cta,
                      color: comingSoon || ckIconAsset(title) != null ? CkColors.glassFill : null,
                      borderRadius: BorderRadius.circular(14),
                      border: ckIconAsset(title) != null ? Border.all(color: CkColors.glassStroke) : null,
                    ),
                    padding: EdgeInsets.all(ckIconAsset(title) != null ? 7 : 0),
                    child: ckIconAsset(title) != null
                        ? Opacity(
                            opacity: comingSoon ? .55 : 1,
                            child: Image.asset(ckIconAsset(title)!, filterQuality: FilterQuality.medium))
                        : Icon(icon, color: comingSoon ? CkColors.textSecondary : Colors.white, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, style: CkText.h(16)),
                      const SizedBox(height: 2),
                      Text(description, style: const TextStyle(fontSize: 12, color: CkColors.textSecondary)),
                    ]),
                  ),
                  if (comingSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: CkColors.glassFillStrong, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Coming soon', style: TextStyle(fontSize: 10.5, color: CkColors.textSecondary)),
                    )
                  else
                    const Icon(Icons.chevron_right_rounded, color: CkColors.textMuted),
                ]),
                if (preview != null && !comingSoon) ...[const SizedBox(height: 10), preview!],
              ])),
            ),
        ),
      );
}

class CardTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  const CardTitle(this.title, this.icon, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: ckIconAsset(title) != null ? null : CkColors.orangeTint,
                borderRadius: BorderRadius.circular(10),
                border: ckIconAsset(title) != null ? null : Border.all(color: CkColors.orangeStroke)),
            child: ckIconAsset(title) != null
                ? Image.asset(ckIconAsset(title)!, filterQuality: FilterQuality.medium)
                : Icon(icon, size: 16, color: const Color(0xFFFFB27A)),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(title, style: CkText.h(16, w: FontWeight.w600))),
          if (trailing != null) trailing!,
        ]),
      );
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  const StatTile(this.label, this.value, this.sub, {super.key, this.color = CkColors.text});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Glass(
          radius: 18,
          shadow: false,
          padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(upper(label), style: CkText.label.copyWith(fontSize: 9.5)),
            const SizedBox(height: 2),
            FittedBox(fit: BoxFit.scaleDown, child: CountUpText(value, style: CkText.h(19, color: color))),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: CkColors.textSecondary)),
          ]),
        ),
      );
}

class InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const InfoPill(this.label, this.value, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          decoration: BoxDecoration(color: CkColors.glassFill, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(upper(label), style: CkText.label.copyWith(fontSize: 9.5)),
            const SizedBox(height: 2),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: color)),
          ]),
        ),
      );
}

/// Month stepper with a picker sheet.
class MonthBar extends StatefulWidget {
  final DateTime month;
  final ValueChanged<DateTime> onChanged;
  const MonthBar({super.key, required this.month, required this.onChanged});
  @override
  State<MonthBar> createState() => _MonthBarState();
}

class _MonthBarState extends State<MonthBar> {
  int _dir = 1; // 1: moved forward (new month comes in from the right)

  @override
  void didUpdateWidget(MonthBar old) {
    super.didUpdateWidget(old);
    if (old.month != widget.month) _dir = widget.month.isAfter(old.month) ? 1 : -1;
  }

  DateTime get month => widget.month;
  ValueChanged<DateTime> get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) => Row(children: [
        CircleBtn(Icons.chevron_left_rounded, size: 40, label: 'Previous month',
            onTap: () => onChanged(DateTime(month.year, month.month - 1))),
        const SizedBox(width: 8),
        Expanded(
          child: Pressable(
            scale: .97,
            onTap: () async {
              final m = await pickMonth(context, month);
              if (m != null) onChanged(m);
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: CkColors.glassFill,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: CkColors.glassStroke),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.calendar_month_rounded, size: 17, color: CkColors.orangeSoft),
                const SizedBox(width: 8),
                // the month name slides in from the side you moved towards
                DirectionalSwitcher(
                  switchKey: month,
                  direction: _dir,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(DateFormat('MMMM').format(month), style: CkText.h(16)),
                    const SizedBox(width: 6),
                    Text('${month.year}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CkColors.textSecondary)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        CircleBtn(Icons.chevron_right_rounded, size: 40, label: 'Next month',
            onTap: () => onChanged(DateTime(month.year, month.month + 1))),
      ]);
}

/// Swaps [child] with a sideways slide in the direction of travel
/// (MyAcharyaji DirectionalSwitcher): 380 ms, new one slides 25% in from
/// the side you moved towards, old one leaves the other way with ease-in.
class DirectionalSwitcher extends StatelessWidget {
  final Widget child;
  final Object switchKey;
  final int direction; // 1 = forward (new content enters from the right)
  const DirectionalSwitcher({super.key, required this.child, required this.switchKey, required this.direction});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: _still(context) ? Duration.zero : const Duration(milliseconds: 380),
        switchInCurve: kEase,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (cur, prev) => Stack(alignment: Alignment.center, children: [...prev, if (cur != null) cur]),
        transitionBuilder: (c, a) {
          final incoming = c.key == ValueKey(switchKey);
          final dx = incoming ? .25 * direction : -.25 * direction;
          return FadeTransition(
            opacity: a,
            child: SlideTransition(position: Tween(begin: Offset(dx, 0), end: Offset.zero).animate(a), child: c),
          );
        },
        child: KeyedSubtree(key: ValueKey(switchKey), child: child),
      );
}

/// Month picker sheet: ‹ year ▾ › above a 4×3 month grid. Tapping a month
/// picks it and closes; tapping the year opens a 12-year grid (‹ › there move
/// 12 years at a time).
Future<DateTime?> pickMonth(BuildContext context, DateTime initial) =>
    showModalBottomSheet<DateTime>(
      useRootNavigator: true,
      context: context,
      builder: (c) => _MonthSheet(initial),
    );

class _MonthSheet extends StatefulWidget {
  final DateTime initial;
  const _MonthSheet(this.initial);
  @override
  State<_MonthSheet> createState() => _MonthSheetState();
}

class _MonthSheetState extends State<_MonthSheet> {
  late int _year = widget.initial.year;
  bool _years = false;
  late int _page = _year - (_year % 12); // first year of the 12-year grid

  Widget _cell(String text, {required bool sel, required bool now, required VoidCallback onTap}) => Pressable(
        scale: .94,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: sel ? CkColors.cta : null,
            color: sel ? null : CkColors.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: now && !sel ? CkColors.orangeStroke : CkColors.glassStroke),
          ),
          child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: sel ? Colors.white : CkColors.text)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final head = _years ? '$_page – ${_page + 11}' : '$_year';
    void step(int d) => setState(() => _years ? _page += 12 * d : _year += d);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(
              child: Container(
                  width: 44, height: 5,
                  decoration: BoxDecoration(color: CkColors.glassStroke, borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Text(_years ? 'Choose year' : 'Choose month', style: CkText.h(18))),
            Pressable(
              onTap: () => Navigator.pop(context, DateTime(now.year, now.month)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: CkColors.orangeTint,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: CkColors.orangeStroke)),
                child: const Text('This month',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFFFB27A))),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            CircleBtn(Icons.chevron_left_rounded, size: 40, label: _years ? 'Previous 12 years' : 'Previous year', onTap: () => step(-1)),
            Expanded(
              child: Pressable(
                scale: .96,
                onTap: () => setState(() {
                  _years = !_years;
                  _page = _year - (_year % 12);
                }),
                child: SizedBox(
                  height: 40,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(head, style: CkText.h(17)),
                    const SizedBox(width: 4),
                    Icon(_years ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 20, color: CkColors.cyan),
                  ]),
                ),
              ),
            ),
            CircleBtn(Icons.chevron_right_rounded, size: 40, label: _years ? 'Next 12 years' : 'Next year', onTap: () => step(1)),
          ]),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: CkMotion.fast,
            child: GridView.count(
              key: ValueKey(_years),
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              physics: const NeverScrollableScrollPhysics(),
              children: _years
                  ? List.generate(12, (i) {
                      final y = _page + i;
                      return _cell('$y', sel: y == _year, now: y == now.year, onTap: () => setState(() {
                            _year = y;
                            _years = false;
                          }));
                    })
                  : List.generate(12, (i) => _cell(
                        DateFormat('MMM').format(DateTime(2000, i + 1)),
                        sel: _year == widget.initial.year && i + 1 == widget.initial.month,
                        now: _year == now.year && i + 1 == now.month,
                        onTap: () => Navigator.pop(context, DateTime(_year, i + 1)),
                      )),
            ),
          ),
        ]),
      ),
    );
  }
}

// ───────────────────────── software icons

/// The CosmoKundli software's own module icons (CK-Icons), by module title.
const kCkIcons = <String, String>{
  'BluePrint': 'blueprint',
  'CK BluePrint': 'blueprint',
  'CosmoKundli': 'cosmokundli',
  'GRAH Coordinates': 'grahcoordinates',
  'Degree': 'grahcoordinates',
  'GRAH Vibes & Intensity': 'situations',
  'GRAH Vibes': 'situations',
  'GRAH Intensity': 'triggerpoint',
  'CK GRAH Vibes': 'situations',
  'CK Planner Plus': 'ck_planner',
  'CK Planner Max': 'ck_planner',
  'Panchang': 'cosmokundli',
  'Melapak': 'cosmoprakruti',
  'Power': 'cosmobal',
  'Flavor': 'cosmoprakruti',
  'Power & Flavor': 'cosmobal',
  'Transit': 'transit',
  'GRAH Vibes Weekly': 'situations',
  'GRAH Vibes Monthly': 'situations',
  'GRAH Trigger': 'triggerpoint',
  'CK Trajectory': 'triggerpoint',
  'Sentiments': 'sentiments',
  'Situations': 'situations',
  'Sentiments 5D': 'sentiments5d',
  'CK Planner': 'ck_planner',
  'CK Profile': 'profile',
};

String? ckIconAsset(String title) {
  final n = kCkIcons[title];
  return n == null ? null : 'assets/icons/$n.png';
}

/// Monochrome software icon (Menu_* set), tinted like an [Icon].
class CkMenuIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  const CkMenuIcon(this.name, {super.key, this.size = 22, this.color = Colors.white});
  @override
  Widget build(BuildContext context) => Image.asset('assets/icons/$name.png',
      width: size, height: size, color: color, colorBlendMode: BlendMode.srcIn, filterQuality: FilterQuality.medium);
}

// ───────────────────────── zones

class ZoneArrows extends StatelessWidget {
  final Zone zone;
  final double size;
  const ZoneArrows(this.zone, {super.key, this.size = 14});
  @override
  // Glow is painted by the same painter (blurred stroke under the sharp one),
  // so there is no extra layer per arrow.
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _ArrowPainter(zone));
}

/// A number that counts up (or down) to [value], fast then settling.
class CountUp extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String Function(double) format;
  final Duration duration;
  const CountUp(this.value, {super.key, this.style, required this.format, this.duration = const Duration(milliseconds: 1100)});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: _still(context) ? Duration.zero : duration,
        curve: kEase,
        builder: (_, v, __) => Text(format(v), style: style),
      );
}

/// Starts at 0 and grows to [value] after [delay] (bars rise as a wave).
class GrowIn extends StatefulWidget {
  final double value;
  final Duration delay;
  final Widget Function(double v) builder;
  const GrowIn({super.key, required this.value, this.delay = Duration.zero, required this.builder});
  @override
  State<GrowIn> createState() => _GrowInState();
}

class _GrowInState extends State<GrowIn> {
  bool _go = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _go = true);
    });
  }

  // Grows from zero once; later value changes glide from the old value.
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _go || _still(context) ? widget.value : 0),
        duration: _still(context) ? Duration.zero : const Duration(milliseconds: 1000),
        curve: kEase,
        builder: (_, v, __) => widget.builder(v),
      );
}

/// Scale + fade pop used by calendar cells.
class PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const PopIn({super.key, required this.child, this.delay = Duration.zero});
  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: kEase);
  bool _decided = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    if (_still(context)) {
      _c.value = 1;
      return;
    }
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _t, child: ScaleTransition(scale: Tween(begin: .6, end: 1.0).animate(_t), child: widget.child));
}

/// Card that follows a sideways swipe with resistance and calls [onSwipe]
/// (-1 previous, 1 next); directions not allowed rubber-band back.
class SwipeArea extends StatefulWidget {
  final Widget child;
  final ValueChanged<int> onSwipe;
  final bool Function(int dir) canSwipe;
  const SwipeArea({super.key, required this.child, required this.onSwipe, required this.canSwipe});
  @override
  State<SwipeArea> createState() => _SwipeAreaState();
}

class _SwipeAreaState extends State<SwipeArea> with SingleTickerProviderStateMixin {
  double _dx = 0, _from = 0;
  late final AnimationController _back = AnimationController(vsync: this, duration: const Duration(milliseconds: 320))
    ..addListener(() => setState(() => _dx = _from * (1 - kEase.transform(_back.value))));
  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _release(double v) {
    final dir = (_dx < -70 || v < -500) ? 1 : (_dx > 70 || v > 500) ? -1 : 0;
    if (dir != 0 && widget.canSwipe(dir)) {
      HapticFeedback.selectionClick();
      widget.onSwipe(dir);
    }
    _from = _dx;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => _back.stop(),
        onHorizontalDragUpdate: (d) {
          final dir = d.delta.dx < 0 ? 1 : -1;
          final k = widget.canSwipe(dir) ? .55 : .15;
          setState(() => _dx = (_dx + d.delta.dx * k).clamp(-120.0, 120.0));
        },
        onHorizontalDragEnd: (d) => _release(d.primaryVelocity ?? 0),
        onHorizontalDragCancel: () => _release(0),
        child: Transform.translate(
          offset: Offset(_dx, 0),
          child: Opacity(opacity: (1 - _dx.abs() / 400).clamp(.6, 1.0), child: widget.child),
        ),
      );
}

/// Horizontal scroller with soft edge fades and a thin muted bar whose end
/// arrows light up when there is more that way (tap an arrow to step).
class HScroll extends StatefulWidget {
  final Widget Function(ScrollController c) builder;
  final ScrollController? controller;
  final double step;
  const HScroll({super.key, required this.builder, this.controller, this.step = 160});
  @override
  State<HScroll> createState() => _HScrollState();
}

class _HScrollState extends State<HScroll> {
  late final ScrollController _c = widget.controller ?? ScrollController();
  // Edges change only when you reach or leave an end: rebuild the fade then,
  // never the scrolled content itself.
  final _edges = ValueNotifier<(bool, bool, bool)>((false, false, false)); // canL, canR, scrollable

  @override
  void initState() {
    super.initState();
    _c.addListener(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() {
    if (!_c.hasClients || !_c.position.hasContentDimensions) return;
    final p = _c.position;
    final e = (p.pixels > 1, p.pixels < p.maxScrollExtent - 1, p.maxScrollExtent > 0);
    if (e != _edges.value) _edges.value = e;
  }

  @override
  void dispose() {
    _c.removeListener(_tick);
    if (widget.controller == null) _c.dispose();
    _edges.dispose();
    super.dispose();
  }

  void _step(int dir) {
    if (!_c.hasClients) return;
    final p = _c.position;
    _c.animateTo((p.pixels + dir * widget.step).clamp(p.minScrollExtent, p.maxScrollExtent), duration: CkMotion.slow, curve: kEase);
  }

  @override
  Widget build(BuildContext context) {
    final content = RepaintBoundary(child: widget.builder(_c));
    Widget arrow(String ch, bool on, int dir) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: on ? () => _step(dir) : null,
          child: SizedBox(
            width: 22,
            height: 18,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: CkMotion.base,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: on ? CkColors.cyan : const Color(0x40FFFFFF)),
                child: Text(ch),
              ),
            ),
          ),
        );
    return ValueListenableBuilder<(bool, bool, bool)>(
      valueListenable: _edges,
      child: content,
      builder: (c, e, content) {
        final (canL, canR, scrollable) = e;
        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => LinearGradient(
              colors: [canL ? Colors.transparent : Colors.white, Colors.white, Colors.white, canR ? Colors.transparent : Colors.white],
              stops: const [0, .06, .94, 1],
            ).createShader(r),
            child: content,
          ),
          if (scrollable)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                arrow('‹', canL, -1),
                Expanded(child: RepaintBoundary(child: CustomPaint(size: const Size(double.infinity, 2), painter: _ThumbPainter(_c)))),
                arrow('›', canR, 1),
              ]),
            ),
        ]);
      },
    );
  }
}

/// The thin bar: repaints itself as you scroll, nothing else does.
class _ThumbPainter extends CustomPainter {
  final ScrollController c;
  _ThumbPainter(this.c) : super(repaint: c);
  static final _track = Paint()..color = const Color(0x14FFFFFF);
  static final _thumb = Paint()..color = const Color(0x59FFFFFF);
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(1)), _track);
    if (!c.hasClients || !c.position.hasContentDimensions) return;
    final p = c.position;
    final max = p.maxScrollExtent;
    if (max <= 0) return;
    final vp = p.viewportDimension;
    final frac = (vp / (vp + max)).clamp(.15, 1.0);
    final pos = (p.pixels / max).clamp(0.0, 1.0);
    final tw = s.width * frac;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH((s.width - tw) * pos, 0, tw, s.height), const Radius.circular(1)), _thumb);
  }

  @override
  bool shouldRepaint(_ThumbPainter old) => old.c != c;
}

class _ArrowPainter extends CustomPainter {
  final Zone z;
  _ArrowPainter(this.z);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = z.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * .12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = s.width;
    final path = Path();
    if (z.dir == 0) {
      path
        ..moveTo(w * .2, w * .5)
        ..lineTo(w * .8, w * .5);
    } else {
      final ys = z.arrows == 1 ? [.5] : z.arrows == 2 ? [.38, .66] : [.24, .5, .76];
      final dy = w * .16 * z.dir;
      for (final y in ys) {
        path
          ..moveTo(w * .2, w * y + dy)
          ..lineTo(w * .5, w * y - dy)
          ..lineTo(w * .8, w * y + dy);
      }
    }
    // soft glow under the sharp arrows (same look as a blurred copy at 75%)
    canvas.drawPath(
        path,
        Paint()
          ..color = z.color.withValues(alpha: .75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s.width * .12
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * .14));
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

void showZonesSheet(BuildContext context) {
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: CkColors.glassStroke, borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 14),
          Text('7 Zones of Situations', style: CkText.h(19)),
          const SizedBox(height: 4),
          const Text('How things around the client go. Higher is smoother.', style: CkText.muted),
          const SizedBox(height: 10),
          ...kZones.map((z) => Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(.08)))),
                child: Row(children: [
                  ZoneArrows(z, size: 18),
                  const SizedBox(width: 10),
                  SizedBox(width: 78, child: Text(z.name, style: TextStyle(color: z.color, fontWeight: FontWeight.w600))),
                  SizedBox(width: 66, child: Text('${z.min}–${z.max}%', style: const TextStyle(fontSize: 12.5))),
                  Expanded(child: Text(z.advice, style: CkText.muted)),
                ]),
              )),
        ]),
      ),
    ),
  );
}

// ───────────────────────── charts

class DayValue {
  final DateTime date;
  /// null while this day's data is loading: the bar sinks to 0 and pulses.
  final double? value;
  const DayValue(this.date, this.value);
}

/// Daily bar chart that shows ~7 days and scrolls sideways, with a fixed
/// y-axis grid and % values. [signed] = −100..+100 (Sentiments);
/// otherwise 0..100 coloured by the 7 zones (Situations).
class DailyBarChart extends StatefulWidget {
  final List<DayValue> days;
  final bool signed;
  final int? selected;
  final int? today;
  final ValueChanged<int>? onSelect;
  final double height;
  const DailyBarChart({super.key, required this.days, required this.signed, this.selected, this.today, this.onSelect, this.height = 240});
  @override
  State<DailyBarChart> createState() => DailyBarChartState();
}

class DailyBarChartState extends State<DailyBarChart> {
  final _sc = ScrollController();
  double _colW = 44;
  double _viewW = 300;

  List<double> get ticks => widget.signed ? [100, 50, 0, -50, -100] : [100, 85, 65, 55, 45, 35, 15, 0];
  double get height => widget.height;
  // Room above and below the plot so the end labels never clip.
  static const double _pt = 34, _pb = 22;
  double get _ph => height - _pt - _pb;
  double _y(double t) => widget.signed ? _pt + (100 - t) / 200 * _ph : _pt + (100 - t) / 100 * _ph;
  String _lab(double t) => widget.signed ? '${t > 0 ? '+' : ''}${t.round()}%' : '${t.round()}%';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollTo(widget.selected ?? widget.today, animate: false));
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  /// Centre day [i] in view.
  void scrollTo(int? i, {bool animate = true}) {
    if (i == null || !_sc.hasClients) return;
    final x = (i * _colW - (_viewW - _colW) / 2).clamp(0.0, _sc.position.maxScrollExtent);
    animate ? _sc.animateTo(x, duration: CkMotion.base, curve: CkMotion.ease) : _sc.jumpTo(x);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (c, box) {
      const axisW = 42.0;
      _viewW = box.maxWidth - axisW;
      _colW = (_viewW / 7).clamp(38.0, 60.0);
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: axisW,
          height: height,
          child: Stack(children: [
            for (final t in ticks)
              Positioned(
                top: _y(t) - 7,
                right: 6,
                child: Text(_lab(t), style: CkText.mono(9.5, color: CkColors.labelMono)),
              ),
          ]),
        ),
        Expanded(
          child: Stack(children: [
            for (final t in ticks)
              Positioned(
                top: _y(t),
                left: 0,
                right: 0,
                child: Container(height: 1, color: Colors.white.withValues(alpha: widget.signed && t == 0 ? .32 : .1)),
              ),
            HScroll(
              controller: _sc,
              step: _colW * 5,
              builder: (sc) => SizedBox(
                height: height + 40,
                child: ListView.builder(
                  controller: sc,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.days.length,
                  itemExtent: _colW,
                  itemBuilder: (c, i) => _bar(i, _colW),
                ),
              ),
            ),
          ]),
        ),
      ]);
    });
  }

  Widget _bar(int i, double w) {
    final d = widget.days[i];
    final signed = widget.signed;
    final raw = d.value;
    final loading = raw == null;
    // Same slot, new value: the bar glides from where it is to the new
    // value (another month already loaded), sinks to 0 while a month loads,
    // and rises when it lands (MyAcharyaji Planner bars).
    final v = (raw ?? 0).clamp(signed ? -100.0 : 0.0, 100.0);
    final sel = widget.selected == i;
    final today = widget.today == i;
    final mid = _pt + _ph / 2, base = _pt + _ph;
    String label(double x) => signed ? '${x > 0.5 ? '+' : ''}${x.round()}%' : '${x.round()}%';
    final bw = math.max(10.0, w * .46);
    return GestureDetector(
      onTap: widget.onSelect == null
          ? null
          : () {
              if (widget.selected != i) HapticFeedback.selectionClick();
              widget.onSelect!(i);
            },
      child: Column(children: [
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: today ? CkColors.cyanTint.withValues(alpha: .3) : sel ? Colors.white.withValues(alpha: .07) : null,
            border: today ? Border.all(color: CkColors.cyanStroke) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          // first time: bars rise from the baseline as a wave (60 ms apart);
          // after that every change glides from the current height
          child: GrowIn(
            value: v,
            delay: Duration(milliseconds: 60 * (i % 12)),
            builder: (x) {
              final up = x >= 0;
              final h = signed ? x.abs() / 100 * _ph / 2 : x / 100 * _ph;
              final zc = signed ? null : zoneOf(x).color;
              // Software: .sps-bar--pos linear-gradient(0deg,#73F4C4,#10B981); .sps-bar--neg linear-gradient(0deg,#EF4444,#F6B8B8)
              final grad = signed
                  ? LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: up ? const [Color(0xFF73F4C4), Color(0xFF10B981)] : const [Color(0xFFEF4444), Color(0xFFF6B8B8)],
                    )
                  : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [zc!, zc.withValues(alpha: .35)]);
              final glow = signed ? (up ? const Color(0xFF10B981) : const Color(0xFFEF4444)) : zc!;
              return Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                // loading: a soft pulse where the bar will be
                Positioned(
                  top: signed ? mid - 6 : base - 12,
                  height: 12,
                  child: _PulseStub(on: loading, width: bw),
                ),
                Positioned(
                  top: signed ? (up ? mid - h : mid) : base - h,
                  height: math.max(h, 3),
                  child: Container(
                    width: bw,
                    decoration: BoxDecoration(
                      gradient: grad,
                      border: sel ? Border.all(color: Colors.white, width: 1.5) : null,
                      boxShadow: perfOff(8) ? null : [BoxShadow(color: glow.withValues(alpha: today || sel ? .6 : .3), blurRadius: today || sel ? 14 : 8)],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(signed && !up ? 2 : 6),
                        bottom: Radius.circular(signed && !up ? 6 : 2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: signed && !up ? mid + h + 3 : null,
                  bottom: signed ? (up ? height - mid + h + 3 : null) : height - base + h + 3,
                  // the number fades out while loading, back in when it lands
                  child: AnimatedOpacity(
                    opacity: loading ? 0 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: signed
                        ? Text(label(x), style: CkText.mono(10, color: Colors.white))
                        : Column(mainAxisSize: MainAxisSize.min, children: [
                            ZoneArrows(zoneOf(x), size: 13),
                            Text(label(x), style: CkText.mono(10, color: Colors.white)),
                          ]),
                  ),
                ),
              ]);
            },
          ),
        ),
        const SizedBox(height: 6),
        Text('${d.date.day}', style: CkText.mono(11.5, color: today ? CkColors.cyan : CkColors.textTertiary)),
        Text(today ? 'Today' : DateFormat('E').format(d.date), style: TextStyle(fontSize: 10, color: today ? CkColors.cyan : CkColors.textMuted)),
      ]),
    );
  }
}

/// Loading stub in a bar slot: opacity 0.15 to 0.45 and back, 900 ms
/// (MyAcharyaji _PulseStub); fades away when the data lands.
class _PulseStub extends StatefulWidget {
  final bool on;
  final double width;
  const _PulseStub({required this.on, required this.width});
  @override
  State<_PulseStub> createState() => _PulseStubState();
}

class _PulseStubState extends State<_PulseStub> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_PulseStub old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.on && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.on && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: widget.on ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: FadeTransition(
          opacity: Tween(begin: .15, end: .45).animate(_c),
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ),
      );
}

/// Planet bars on the software's grid (0,15,35,45,55,65,85,100) with % at the bar end.
class GrahBarChart extends StatelessWidget {
  final List<MapEntry<String, double>> values; // grah id → 0..100
  final double height;
  final bool axis;
  const GrahBarChart({super.key, required this.values, this.height = 300, this.axis = true});
  static const _ticks = [0, 15, 35, 45, 55, 65, 85, 100];
  @override
  Widget build(BuildContext context) {
    final axisW = axis ? 34.0 : 0.0;
    final top = 26.0;
    final h = height - top;
    return Column(children: [
      SizedBox(
        height: height,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (axis)
            SizedBox(
              width: axisW,
              height: height,
              child: Stack(children: [
                for (final t in _ticks)
                  Positioned(
                      bottom: t / 100 * h - 6,
                      right: 4,
                      child: Text('$t%', style: CkText.mono(9, color: CkColors.labelMono))),
              ]),
            ),
          Expanded(
            child: Stack(children: [
              for (final t in _ticks)
                Positioned(
                  bottom: t / 100 * h,
                  left: 0,
                  right: 0,
                  child: Container(height: 1, color: Colors.white.withOpacity(t == 0 || t == 100 ? .18 : .09)),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: values.asMap().entries.map((en) {
                  final e = en.value;
                  final c = grahColor(e.key);
                  final v = e.value.clamp(0.0, 100.0);
                  return Expanded(
                    child: GrowIn(
                      value: v,
                      delay: Duration(milliseconds: 60 * en.key),
                      builder: (t) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${t.round()}%', style: TextStyle(fontSize: axis ? 11 : 9.5, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 3),
                      Container(
                          height: math.max(3, t / 100 * h),
                          margin: EdgeInsets.symmetric(horizontal: axis ? 6 : 3),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(2)),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [c, c.withOpacity(.25)]),
                            boxShadow: perfOff(8) ? null : [BoxShadow(color: c.withOpacity(.35), blurRadius: 10)],
                          ),
                        ),
                    ]),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 6),
      Row(children: [
        SizedBox(width: axisW),
        ...values.map((e) => Expanded(
            child: Text(e.key,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: axis ? 11.5 : 10, fontWeight: FontWeight.w600, color: Colors.white)))),
      ]),
    ]);
  }
}

/// Small "R" retrograde badge.
/// Retrograde mark: a small superscript capital R.
class RetroBadge extends StatelessWidget {
  const RetroBadge({super.key});
  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: const Offset(1, -6),
        child: const Text('R', style: TextStyle(color: CkColors.retro, fontSize: 9, fontWeight: FontWeight.w700, height: 1)),
      );
}

class GrahDot extends StatelessWidget {
  final String id;
  final double size;
  const GrahDot(this.id, {super.key, this.size = 9});
  @override
  Widget build(BuildContext context) {
    final c = grahColor(id);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle, boxShadow: perfOff(8) ? null : [BoxShadow(color: c.withOpacity(.6), blurRadius: 8)]),
    );
  }
}

/// Bootstrap Icons (the software's icon set), in a quiet outlined tile.
class BiIcon extends StatelessWidget {
  final String name;
  final double size;
  const BiIcon(this.name, {super.key, this.size = 18});
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: CkColors.cyanTint.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CkColors.panelStroke),
        ),
        child: SvgPicture.asset('assets/bi/$name.svg',
            width: size, height: size, colorFilter: const ColorFilter.mode(CkColors.cyan, BlendMode.srcIn)),
      );
}

// ───────────────────────── skeletons (MyAcharyaji style)

/// Shimmering placeholder block.
class Skeleton extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;
  const Skeleton({super.key, required this.height, this.width, this.radius = 8});
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value * 2 - .5;
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(-1 + t * 2 - .6, 0),
                end: Alignment(-1 + t * 2 + .6, 0),
                colors: const [Color(0x0FFFFFFF), Color(0x24FFFFFF), Color(0x0FFFFFFF)],
              ),
            ),
          );
        },
      );
}

/// A panel of skeleton rows shaped like a list / table.
class SkeletonList extends StatelessWidget {
  final int rows;
  final bool leading;
  const SkeletonList({super.key, this.rows = 6, this.leading = true});
  @override
  Widget build(BuildContext context) => Glass(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: Column(children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                if (leading) ...[const Skeleton(height: 32, width: 32, radius: 16), const SizedBox(width: 12)],
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Skeleton(height: 11, width: 90.0 + (i % 3) * 30),
                    const SizedBox(height: 7),
                    Skeleton(height: 9, width: 140.0 - (i % 2) * 30),
                  ]),
                ),
                const Skeleton(height: 12, width: 44),
              ]),
            ),
        ]),
      );
}

/// A panel skeleton with a title bar and a large body (charts, cards).
class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 220});
  @override
  Widget build(BuildContext context) => Glass(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        height: height,
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Skeleton(height: 20, width: 20, radius: 6), SizedBox(width: 8), Skeleton(height: 12, width: 110)]),
          SizedBox(height: 14),
          Expanded(child: Skeleton(height: double.infinity, radius: 10)),
        ]),
      );
}

/// Drops keyboard focus on every navigation, so a text field on the page you
/// return to doesn't grab focus and pop the keyboard open.
class UnfocusObserver extends NavigatorObserver {
  void _off() => FocusManager.instance.primaryFocus?.unfocus();
  @override
  void didPush(Route route, Route? previousRoute) => _off();
  @override
  void didPop(Route route, Route? previousRoute) => _off();
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _off();
}

// ───────────────────────── filter & sort bar

class FilterOption<T> {
  final T value;
  final String label;
  final int? count;
  const FilterOption(this.value, this.label, {this.count});
}

/// Multi-select dropdown chip: "Status  Ready ▾". The top "All" row clears
/// the selection; each option toggles a checkbox and the menu stays open.
/// Tinted cyan with ✓ when anything is picked; ✕ on the chip clears it.
class FilterDropdown<T> extends StatelessWidget {
  final String label;
  final List<FilterOption<T>> options;
  final Set<T> values;
  final ValueChanged<Set<T>> onChanged;
  final String allLabel;
  final int? allCount;
  const FilterDropdown({super.key, required this.label, required this.options, required this.values, required this.onChanged, this.allLabel = 'All', this.allCount});

  Widget _row(String text, bool on, {int? count, bool radio = false}) => SizedBox(
        width: 220,
        child: Row(children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: on ? CkColors.cyan : Colors.transparent,
              borderRadius: BorderRadius.circular(radio ? 9 : 5),
              border: Border.all(color: on ? CkColors.cyan : const Color(0x808CBEFF), width: 1.5),
            ),
            child: on ? const Icon(Icons.check_rounded, size: 13, color: Color(0xFF06204F)) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: on ? FontWeight.w600 : FontWeight.w400, color: on ? Colors.white : CkColors.textTertiary)),
          ),
          if (count != null) Text('$count', style: CkText.mono(11, color: CkColors.labelMono)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final on = values.isNotEmpty;
    final picked = options.where((o) => values.contains(o.value)).toList();
    final text = picked.isEmpty ? allLabel : (picked.length == 1 ? picked.first.label : '${picked.length} selected');
    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(CkColors.navySheet),
        maximumSize: const WidgetStatePropertyAll(Size(280, 300)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: CkColors.panelStroke))),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
      ),
      menuChildren: [
        MenuItemButton(
          closeOnActivate: true,
          onPressed: () => onChanged(<T>{}),
          child: _row(allLabel, !on, count: allCount, radio: true),
        ),
        const Divider(height: 8, color: CkColors.panelStroke),
        for (final o in options)
          MenuItemButton(
            closeOnActivate: false,
            onPressed: () {
              final next = {...values};
              if (!next.remove(o.value)) next.add(o.value);
              onChanged(next);
            },
            child: _row(o.label, values.contains(o.value), count: o.count),
          ),
      ],
      builder: (c, ctl, _) => GestureDetector(
        onTap: () => ctl.isOpen ? ctl.close() : ctl.open(),
        child: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 12, right: 8),
          decoration: BoxDecoration(
            color: on ? CkColors.cyanTint : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: on ? CkColors.cyanStroke : CkColors.panelStroke),
            boxShadow: on ? [BoxShadow(color: CkColors.cyan.withValues(alpha: .22), blurRadius: 14)] : null,
          ),
          child: Row(children: [
            // off: just the name; on: "Gender: Female"
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: on ? '$label: ' : label, style: TextStyle(fontSize: 12.5, color: on ? CkColors.labelMono : CkColors.textSecondary)),
                  if (on) TextSpan(text: text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (on)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(<T>{}),
                child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close_rounded, size: 16, color: CkColors.cyan)),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: CkColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}

/// Row of active-filter chips under a filter bar; tapping a chip clears it.
class ActiveFilters extends StatelessWidget {
  final List<(IconData, String, VoidCallback)> chips;
  const ActiveFilters(this.chips, {super.key});
  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(spacing: 6, runSpacing: 6, children: [
        for (final (icon, text, clear) in chips)
          Pressable(
            onTap: clear,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 6, 5),
              decoration: BoxDecoration(color: CkColors.cyanTint, borderRadius: BorderRadius.circular(8), border: Border.all(color: CkColors.cyanStroke)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 13, color: CkColors.cyan),
                const SizedBox(width: 4),
                Text(text, style: CkText.mono(11.5)),
                const SizedBox(width: 4),
                const Icon(Icons.close_rounded, size: 13, color: CkColors.textSecondary),
              ]),
            ),
          ),
      ]),
    );
  }
}

class SortOption<T> {
  final T value;
  final String label;
  final bool ascending;
  const SortOption(this.value, this.label, {required this.ascending});
}

/// Square sort button showing ↑/↓ of the applied sort; menu marks it with ✓.
class SortButton<T> extends StatelessWidget {
  final List<SortOption<T>> options;
  final T value;
  final T? defaultValue;
  final ValueChanged<T> onChanged;
  const SortButton({super.key, required this.options, required this.value, this.defaultValue, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final cur = options.firstWhere((o) => o.value == value, orElse: () => options.first);
    final on = value != (defaultValue ?? options.first.value);
    return PopupMenuButton<T>(
      tooltip: 'Sort',
      position: PopupMenuPosition.under,
      color: CkColors.navySheet,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: CkColors.panelStroke)),
      onSelected: onChanged,
      itemBuilder: (c) => [
        for (final o in options)
          PopupMenuItem<T>(
            value: o.value,
            child: Row(children: [
              Icon(o.ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 16, color: o.value == value ? CkColors.cyan : CkColors.labelMono),
              const SizedBox(width: 10),
              Expanded(
                child: Text(o.label,
                    style: TextStyle(fontSize: 14, fontWeight: o.value == value ? FontWeight.w600 : FontWeight.w400, color: o.value == value ? Colors.white : CkColors.textTertiary)),
              ),
              SizedBox(width: 18, child: o.value == value ? const Icon(Icons.check_rounded, size: 18, color: CkColors.cyan) : null),
            ]),
          ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: on ? CkColors.cyanTint : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: on ? CkColors.cyanStroke : CkColors.panelStroke),
          boxShadow: on ? [BoxShadow(color: CkColors.cyan.withValues(alpha: .22), blurRadius: 14)] : null,
        ),
        child: Icon(cur.ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 18, color: on ? CkColors.cyan : CkColors.text),
      ),
    );
  }
}


// ───────────────────────── shaped skeletons
// Each mirrors the real layout it stands in for, so nothing jumps on load.

class Skels {
  static Widget _glass(Widget child, {EdgeInsets padding = const EdgeInsets.all(14), double top = 12, double radius = 18}) =>
      Glass(margin: EdgeInsets.only(top: top), radius: radius, padding: padding, child: child);

  /// Three stat tiles (Strongest · Weakest · Average).
  static Widget stats() => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 7),
            Expanded(
              child: Glass(
                radius: 14,
                shadow: false,
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Skeleton(width: 54, height: 8, radius: 3),
                  SizedBox(height: 7),
                  Skeleton(width: 46, height: 15, radius: 4),
                  SizedBox(height: 5),
                  Skeleton(width: 40, height: 8, radius: 3),
                ]),
              ),
            ),
          ],
        ]),
      );

  /// Daily bar chart card (signed: bars both sides of a middle line).
  static Widget dailyChart({bool signed = true, double height = 210}) => _glass(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Skeleton(width: 40, height: 9, radius: 3), Spacer(), Skeleton(width: 46, height: 18, radius: 6)]),
          const SizedBox(height: 12),
          SizedBox(
            height: height,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < 9; i++)
                Expanded(
                  child: signed
                      ? Column(children: [
                          Expanded(child: Align(alignment: Alignment.bottomCenter, child: i % 3 != 2 ? Skeleton(width: 14, height: (height / 2 - 12) * (.35 + (i * 37 % 55) / 100), radius: 3) : null)),
                          Expanded(child: Align(alignment: Alignment.topCenter, child: i % 3 == 2 ? Skeleton(width: 14, height: (height / 2 - 12) * (.3 + (i * 23 % 45) / 100), radius: 3) : null)),
                        ])
                      : Align(alignment: Alignment.bottomCenter, child: Skeleton(width: 14, height: (height - 24) * (.4 + (i * 29 % 50) / 100), radius: 3)),
                ),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [for (var i = 0; i < 9; i++) const Expanded(child: Center(child: Skeleton(width: 14, height: 8, radius: 3)))]),
        ]),
      );

  /// Selected-day card under a chart.
  static Widget dayCard() => _glass(
        const Row(children: [
          Skeleton(width: 44, height: 44, radius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Skeleton(width: 120, height: 13, radius: 4),
              SizedBox(height: 7),
              Skeleton(width: 170, height: 9, radius: 3),
            ]),
          ),
        ]),
      );

  /// Sentiments / Situations page body.
  static Widget daily({bool signed = true}) => Column(children: [stats(), dailyChart(signed: signed), dayCard()]);

  /// Kundli circle card with a row of three pills.
  static Widget kundli() => Column(children: [
        _glass(
          LayoutBuilder(builder: (c, b) {
            final d = b.maxWidth * .86;
            return Center(child: Skeleton(width: d, height: d, radius: d / 2));
          }),
          padding: const EdgeInsets.all(16),
        ),
        const SizedBox(height: 10),
        Row(children: [
          for (var i = 0; i < 3; i++) ...[if (i > 0) const SizedBox(width: 7), const Expanded(child: Skeleton(height: 56, radius: 12))],
        ]),
      ]);

  /// Table card: label, middle and value columns.
  static Widget table(int rows, {bool mid = true}) => _glass(
        Column(children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(children: [
                const Skeleton(width: 34, height: 11, radius: 4),
                const SizedBox(width: 14),
                if (mid) Expanded(child: Align(alignment: Alignment.centerLeft, child: Skeleton(width: 60.0 + (i * 17 % 40), height: 10, radius: 4))) else const Spacer(),
                const Skeleton(width: 48, height: 11, radius: 4),
              ]),
            ),
        ]),
      );

  /// GRAH bar chart card (Power / Flavor).
  static Widget bars({int n = 9, double height = 220}) => _glass(
        Column(children: [
          SizedBox(
            height: height,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < n; i++)
                Expanded(child: Center(child: Skeleton(width: 18, height: height * (.35 + (i * 31 % 60) / 100), radius: 4))),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [for (var i = 0; i < n; i++) const Expanded(child: Center(child: Skeleton(width: 16, height: 9, radius: 3)))]),
        ]),
      );

  /// Melapak result: two people, the score ring, then the 8 kootas.
  static Widget match() => Column(children: [
        Row(children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Glass(
                padding: const EdgeInsets.all(12),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Skeleton(width: 36, height: 8, radius: 3),
                  SizedBox(height: 8),
                  Skeleton(width: 90, height: 13, radius: 4),
                  SizedBox(height: 8),
                  Skeleton(width: 70, height: 9, radius: 3),
                ]),
              ),
            ),
          ],
        ]),
        _glass(const Row(children: [
          Skeleton(width: 100, height: 100, radius: 50),
          SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Skeleton(width: 70, height: 8, radius: 3),
              SizedBox(height: 8),
              Skeleton(width: 130, height: 16, radius: 4),
              SizedBox(height: 8),
              Skeleton(width: 150, height: 9, radius: 3),
            ]),
          ),
        ])),
        table(8, mid: false),
      ]);

  /// Month calendar (5D).
  static Widget calendar() => Column(children: [
        stats(),
        _glass(
          Column(children: [
            Row(children: [for (var i = 0; i < 7; i++) const Expanded(child: Center(child: Skeleton(width: 14, height: 8, radius: 3)))]),
            const SizedBox(height: 10),
            for (var r = 0; r < 5; r++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  for (var i = 0; i < 7; i++) const Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 3), child: Skeleton(height: 40, radius: 9))),
                ]),
              ),
          ]),
        ),
        dayCard(),
      ]);

  /// Client cards (avatar, name, one line, ⋮).
  static Widget clientCards(int n) => Column(children: [
        for (var i = 0; i < n; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Glass(
              radius: 16,
              shadow: false,
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              child: Row(children: [
                const Skeleton(width: 44, height: 44, radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Skeleton(width: 110.0 + (i * 23 % 50), height: 13, radius: 4),
                    const SizedBox(height: 8),
                    Skeleton(width: 170.0 + (i * 13 % 40), height: 9, radius: 3),
                  ]),
                ),
                const Skeleton(width: 5, height: 18, radius: 2),
              ]),
            ),
          ),
      ]);

  /// Report rows: cover thumbnail, three lines, share + open buttons.
  static Widget reportRows(int n) => Column(children: [
        for (var i = 0; i < n; i++)
          Glass(
            margin: const EdgeInsets.only(top: 10),
            radius: 16,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const Skeleton(width: 40, height: 54, radius: 6),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Skeleton(width: 100.0 + (i * 19 % 40), height: 13, radius: 4),
                  const SizedBox(height: 7),
                  const Skeleton(width: 120, height: 11, radius: 4),
                  const SizedBox(height: 7),
                  const Skeleton(width: 150, height: 9, radius: 3),
                ]),
              ),
              const Skeleton(width: 24, height: 24, radius: 6),
              const SizedBox(width: 12),
              const Skeleton(width: 46, height: 46, radius: 13),
            ]),
          ),
      ]);

  /// Plain rows of a list card (transactions, people).
  static Widget rows(int n) => _glass(
        Column(children: [
          for (var i = 0; i < n; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                const Skeleton(width: 34, height: 34, radius: 17),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Skeleton(width: 120.0 + (i * 19 % 40), height: 12, radius: 4),
                    const SizedBox(height: 6),
                    const Skeleton(width: 80, height: 9, radius: 3),
                  ]),
                ),
                const Skeleton(width: 50, height: 12, radius: 4),
              ]),
            ),
        ]),
      );
}


/// Text whose first number counts up from 0 (e.g. "+42%", "72% · 31").
class CountUpText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const CountUpText(this.text, {super.key, this.style});
  static final _re = RegExp(r'^(\D*?)([+-]?\d+(?:\.\d+)?)(.*)$', dotAll: true);
  @override
  Widget build(BuildContext context) {
    final m = _re.firstMatch(text);
    final n = m == null ? null : double.tryParse(m.group(2)!);
    if (m == null || n == null) return Text(text, style: style);
    final dec = m.group(2)!.contains('.') ? m.group(2)!.split('.').last.length : 0;
    final plus = m.group(2)!.startsWith('+');
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: n),
      duration: _still(context) ? Duration.zero : const Duration(milliseconds: 1100),
      curve: kEase,
      builder: (_, v, __) => Text('${m.group(1)}${plus && v > 0 ? '+' : ''}${v.toStringAsFixed(dec)}${m.group(3)}', style: style),
    );
  }
}


/// Sentiments 5D colour: a plain low -> high scale (no zones). Values may be
/// 0..100 or signed -100..100; [signed] picks the range.
Color fiveDColor(double v, {bool signed = false}) {
  final t = signed ? ((v + 100) / 200).clamp(0.0, 1.0) : (v / 100).clamp(0.0, 1.0);
  const a = Color(0xFF283C8C), m = Color(0xFF3C96FF), b = Color(0xFF73F4C4);
  return t < .5 ? Color.lerp(a, m, t * 2)! : Color.lerp(m, b, (t - .5) * 2)!;
}

/// "Low ▬▬▬ High" legend for [fiveDColor].
class FiveDLegend extends StatelessWidget {
  const FiveDLegend({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        const Text('Low', style: TextStyle(fontSize: 11, color: CkColors.textSecondary)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(colors: [fiveDColor(0), fiveDColor(50), fiveDColor(100)]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text('High', style: TextStyle(fontSize: 11, color: CkColors.textSecondary)),
      ]);
}


/// Hidden testing switch: Flutter's frame-time graph over the app.
/// Greyed-out content for things not available (coming soon, expired):
/// colour removed and dimmed. Applied to what's inside a glass card, not the
/// card itself, so it reads clearly over the see-through glass.
Widget greyed(Widget child, {bool on = true, double opacity = .42}) {
  if (!on) return child;
  return Opacity(
    opacity: opacity,
    child: ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        .2126, .7152, .0722, 0, 0,
        .2126, .7152, .0722, 0, 0,
        .2126, .7152, .0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: child,
    ),
  );
}

final perfOverlay = ValueNotifier<bool>(false);

/// Test-only switches for measuring what costs frame time (hidden sheet on
/// long-press of Log out). Bits: 1 dock refraction off, 2 background still,
/// 4 card blur off, 8 glows off, 16 dock blur off, 32 entrances off. Nothing here is on by default.
final perfFlags = ValueNotifier<int>(0);
bool perfOff(int bit) => perfFlags.value & bit != 0;

/// Extra entries for the speed sheet (labs register themselves).
final perfLabs = <(String, void Function(BuildContext))>[];

void showPerfSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xF2101634),
    builder: (c) => SafeArea(
      child: ListenableBuilder(
        listenable: Listenable.merge([perfOverlay, perfFlags]),
        builder: (c, _) {
          Widget sw(String t, bool v, void Function(bool) f) =>
              SwitchListTile(title: Text(t), value: v, onChanged: (x) { f(x); WidgetsBinding.instance.reassembleApplication(); });
          void flip(int bit, bool on) => perfFlags.value = on ? perfFlags.value | bit : perfFlags.value & ~bit;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Speed test (only for testing)')),
            sw('Frame graph', perfOverlay.value, (v) => perfOverlay.value = v),
            sw('Dock refraction OFF', perfOff(1), (v) => flip(1, v)),
            sw('Background animation OFF', perfOff(2), (v) => flip(2, v)),
            sw('Card blur OFF', perfOff(4), (v) => flip(4, v)),
            sw('Glows OFF (bar and dot shadows)', perfOff(8), (v) => flip(8, v)),
            sw('Dock blur OFF', perfOff(16), (v) => flip(16, v)),
            sw('Card entrances OFF', perfOff(32), (v) => flip(32, v)),
            for (final l in perfLabs)
              ListTile(
                title: Text(l.$1),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(c).pop();
                  l.$2(context);
                },
              ),
            const SizedBox(height: 8),
          ]);
        },
      ),
    ),
  );
}
