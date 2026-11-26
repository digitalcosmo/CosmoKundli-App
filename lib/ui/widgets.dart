import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

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
                      onTap: () => onChanged(v),
                      child: AnimatedContainer(
                        duration: CkMotion.fast,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: v == selected ? CkColors.orangeTint : CkColors.glassFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: v == selected ? CkColors.orangeStroke : CkColors.glassStroke),
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

class LoadView<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final double minHeight;
  final Widget? skeleton;
  const LoadView({super.key, required this.future, required this.builder, this.onRetry, this.minHeight = 220, this.skeleton});
  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
        future: future,
        builder: (c, s) {
          final Widget child;
          if (s.connectionState != ConnectionState.done) {
            child = KeyedSubtree(key: const ValueKey('skel'), child: skeleton ?? (minHeight >= 300 ? SkeletonCard(height: minHeight) : const SkeletonList(rows: 5)));
          } else if (s.hasError || !s.hasData) {
            child = KeyedSubtree(
              key: const ValueKey('err'),
              child: ErrorBox(message: 'Couldn\'t load this. Check your connection and try again.', onRetry: onRetry),
            );
          } else {
            child = KeyedSubtree(key: const ValueKey('ok'), child: builder(s.data as T));
          }
          // loading -> data -> error swap with a soft cross-fade
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            layoutBuilder: (cur, prev) => Stack(alignment: Alignment.topCenter, children: [...prev, if (cur != null) cur]),
            child: child,
          );
        },
      );
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
          child: Opacity(
            opacity: comingSoon ? .72 : 1,
            child: Glass(
              margin: const EdgeInsets.only(top: 12),
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              ]),
            ),
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
class MonthBar extends StatelessWidget {
  final DateTime month;
  final ValueChanged<DateTime> onChanged;
  const MonthBar({super.key, required this.month, required this.onChanged});
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
                Text(DateFormat('MMMM').format(month), style: CkText.h(16)),
                const SizedBox(width: 6),
                Text('${month.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CkColors.textSecondary)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        CircleBtn(Icons.chevron_right_rounded, size: 40, label: 'Next month',
            onTap: () => onChanged(DateTime(month.year, month.month + 1))),
      ]);
}

/// Month picker sheet: a swipeable strip of years (tap any year directly)
/// above a 4×3 month grid, plus a one-tap jump to the current month.
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
  static const _chipW = 76.0;
  late int _year = widget.initial.year;
  late final int _first = math.min(widget.initial.year, DateTime.now().year) - 60;
  late final int _last = math.max(widget.initial.year, DateTime.now().year) + 30;
  ScrollController? _ctl;
  ScrollController get _years => _ctl!;

  double _centred(int y) =>
      math.max(0.0, (y - _first) * _chipW - (MediaQuery.of(context).size.width - 36) / 2 + _chipW / 2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctl ??= ScrollController(initialScrollOffset: _centred(_year));
  }

  @override
  void dispose() {
    _ctl?.dispose();
    super.dispose();
  }

  void _setYear(int y) {
    setState(() => _year = y);
    _years.animateTo(_centred(y).clamp(0.0, _years.position.maxScrollExtent),
        duration: const Duration(milliseconds: 380), curve: CkMotion.ease);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Container(
                  width: 44, height: 5,
                  decoration: BoxDecoration(color: CkColors.glassStroke, borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Text('Choose month', style: CkText.h(18))),
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
          const SizedBox(height: 14),
          HScroll(controller: _years, builder: (sc) => SizedBox(
            height: 40,
            child: ListView.builder(
              controller: sc,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemExtent: _chipW,
              itemCount: _last - _first + 1,
              itemBuilder: (_, i) {
                final y = _first + i;
                final sel = y == _year;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _setYear(y),
                  child: AnimatedContainer(
                    duration: CkMotion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: sel ? CkColors.cta : null,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? Colors.transparent : const Color(0x1FFFFFFF)),
                    ),
                    child: Text('$y',
                        style: TextStyle(
                            fontSize: sel ? 15 : 14,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w600,
                            color: sel ? Colors.white : (y == now.year ? CkColors.orangeSoft : CkColors.textSecondary))),
                  ),
                );
              },
            ),
          )),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(12, (i) {
              final sel = _year == widget.initial.year && i + 1 == widget.initial.month;
              final isNow = _year == now.year && i + 1 == now.month;
              return Pressable(
                scale: .94,
                onTap: () => Navigator.pop(context, DateTime(_year, i + 1)),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: sel ? CkColors.cta : null,
                    color: sel ? null : CkColors.glassFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isNow && !sel ? CkColors.orangeStroke : CkColors.glassStroke),
                  ),
                  child: Text(DateFormat('MMM').format(DateTime(2000, i + 1)),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: sel ? Colors.white : CkColors.text)),
                ),
              );
            }),
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
  Widget build(BuildContext context) {
    final p = CustomPaint(size: Size.square(size), painter: _ArrowPainter(zone));
    // soft glow: a blurred copy behind the sharp arrows (MyAcharyaji ZoneIcon)
    return SizedBox.square(
      dimension: size,
      child: Stack(clipBehavior: Clip.none, children: [
        Opacity(
          opacity: .75,
          child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: size * .14, sigmaY: size * .14), child: p),
        ),
        p,
      ]),
    );
  }
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
        duration: duration,
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

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _go ? widget.value : 0),
        duration: const Duration(milliseconds: 1000),
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
  @override
  void initState() {
    super.initState();
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
  @override
  void initState() {
    super.initState();
    _c.addListener(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_tick);
    if (widget.controller == null) _c.dispose();
    super.dispose();
  }

  void _step(int dir) {
    if (!_c.hasClients) return;
    final p = _c.position;
    _c.animateTo((p.pixels + dir * widget.step).clamp(p.minScrollExtent, p.maxScrollExtent), duration: CkMotion.slow, curve: kEase);
  }

  @override
  Widget build(BuildContext context) {
    final has = _c.hasClients && _c.position.hasContentDimensions;
    final max = has ? _c.position.maxScrollExtent : 0.0;
    final px = has ? _c.position.pixels.clamp(0.0, max) : 0.0;
    final vp = has ? _c.position.viewportDimension : 1.0;
    final canL = px > 1, canR = px < max - 1;
    final frac = max <= 0 ? 1.0 : (vp / (vp + max)).clamp(.15, 1.0);
    final pos = max <= 0 ? 0.0 : px / max;
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
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => LinearGradient(
          colors: [canL ? Colors.transparent : Colors.white, Colors.white, Colors.white, canR ? Colors.transparent : Colors.white],
          stops: const [0, .06, .94, 1],
        ).createShader(r),
        child: widget.builder(_c),
      ),
      if (max > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            arrow('‹', canL, -1),
            Expanded(
              child: LayoutBuilder(builder: (c, b) {
                final tw = b.maxWidth * frac;
                return SizedBox(
                  height: 2,
                  child: Stack(children: [
                    Container(decoration: BoxDecoration(color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(1))),
                    Positioned(
                      left: (b.maxWidth - tw) * pos,
                      width: tw,
                      top: 0,
                      bottom: 0,
                      child: Container(decoration: BoxDecoration(color: const Color(0x59FFFFFF), borderRadius: BorderRadius.circular(1))),
                    ),
                  ]),
                );
              }),
            ),
            arrow('›', canR, 1),
          ]),
        ),
    ]);
  }
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
    if (z.dir == 0) {
      canvas.drawLine(Offset(w * .2, w * .5), Offset(w * .8, w * .5), p);
      return;
    }
    final ys = z.arrows == 1 ? [.5] : z.arrows == 2 ? [.38, .66] : [.24, .5, .76];
    for (final y in ys) {
      final dy = w * .16 * z.dir;
      final path = Path()
        ..moveTo(w * .2, w * y + dy)
        ..lineTo(w * .5, w * y - dy)
        ..lineTo(w * .8, w * y + dy);
      canvas.drawPath(path, p);
    }
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
  final double value;
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
    final v = d.value.clamp(signed ? -100.0 : 0.0, 100.0);
    final sel = widget.selected == i;
    final today = widget.today == i;
    final up = v >= 0;
    final mid = _pt + _ph / 2, base = _pt + _ph;
    final full = signed ? v.abs() / 100 * _ph / 2 : v / 100 * _ph;
    final zc = signed ? null : zoneOf(v).color;
    // Software: .sps-bar--pos linear-gradient(0deg,#73F4C4,#10B981); .sps-bar--neg linear-gradient(0deg,#EF4444,#F6B8B8)
    final grad = signed
        ? LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: up ? const [Color(0xFF73F4C4), Color(0xFF10B981)] : const [Color(0xFFEF4444), Color(0xFFF6B8B8)],
          )
        : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [zc!, zc.withValues(alpha: .35)]);
    final glow = signed ? (up ? const Color(0xFF10B981) : const Color(0xFFEF4444)) : zc!;
    String label(double x) => signed ? '${x > 0.5 ? '+' : ''}${x.round()}%' : '${x.round()}%';
    final bw = math.max(10.0, w * .46);
    return GestureDetector(
      onTap: widget.onSelect == null ? null : () => widget.onSelect!(i),
      child: Column(children: [
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: today ? CkColors.cyanTint.withValues(alpha: .3) : sel ? Colors.white.withValues(alpha: .07) : null,
            border: today ? Border.all(color: CkColors.cyanStroke) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          // bars rise from the baseline as a wave, numbers count up beside them
          child: GrowIn(
            value: 1,
            delay: Duration(milliseconds: 40 * (i % 12)),
            builder: (k) {
              final h = full * k;
              return Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                Positioned(
                  top: signed ? (up ? mid - h : mid) : base - h,
                  height: math.max(h, 3),
                  child: Container(
                    width: bw,
                    decoration: BoxDecoration(
                      gradient: grad,
                      border: sel ? Border.all(color: Colors.white, width: 1.5) : null,
                      boxShadow: [BoxShadow(color: glow.withValues(alpha: today || sel ? .6 : .3), blurRadius: today || sel ? 14 : 8)],
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
                  child: signed
                      ? Text(label(v * k), style: CkText.mono(10, color: Colors.white))
                      : Column(mainAxisSize: MainAxisSize.min, children: [
                          ZoneArrows(zoneOf(v), size: 13),
                          Text(label(v * k), style: CkText.mono(10, color: Colors.white)),
                        ]),
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
                            boxShadow: [BoxShadow(color: c.withOpacity(.35), blurRadius: 10)],
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
      decoration: BoxDecoration(color: c, shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.withOpacity(.6), blurRadius: 8)]),
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
            if (on) ...[const Icon(Icons.check_rounded, size: 15, color: CkColors.cyan), const SizedBox(width: 4)],
            Text(label, style: const TextStyle(fontSize: 12.5, color: CkColors.labelMono)),
            const SizedBox(width: 6),
            Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
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
      duration: const Duration(milliseconds: 1100),
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
