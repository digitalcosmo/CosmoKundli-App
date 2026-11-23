import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ck_theme.dart';

const String kCkBackground = 'assets/images/ck_bg.jpg';

/// Deep-space backdrop shared by every page (same art as the software).
class CkBackground extends StatelessWidget {
  final Widget child;
  const CkBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: CkColors.deepSpace,
        image: DecorationImage(
          image: AssetImage(kCkBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: DecoratedBox(
        // soft vignette so glass panels keep contrast
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x33000814), Color(0x00000000), Color(0x55000814)],
            stops: [0, .45, 1],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Drop-in replacement for [Scaffold]: paints the cosmic backdrop under a
/// transparent scaffold so each route stays opaque during transitions.
class CkScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Widget? drawer;
  final Widget? bottomSheet;

  const CkScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawer,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: CkColors.deepSpace,
      ),
      child: CkBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          drawer: drawer,
          bottomSheet: bottomSheet,
        ),
      ),
    );
  }
}

/// Liquid-glass surface: backdrop blur + faint tint + specular rim,
/// the Flutter equivalent of the software's `.gm-container`.
class Glass extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final Color tint;
  final Color stroke;
  final double? width;
  final double? height;
  final bool shadow;
  final AlignmentGeometry? alignment;

  const Glass({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.radius = CkRadius.card,
    this.blur = 14,
    this.tint = CkColors.glassFill,
    this.stroke = CkColors.glassStroke,
    this.width,
    this.height,
    this.shadow = true,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: shadow
            ? const [
                BoxShadow(
                    color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            alignment: alignment,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: r,
              border: Border.all(color: stroke, width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(const Color(0x14FFFFFF), tint),
                  tint,
                  Color.alphaBlend(const Color(0x05FFFFFF), tint),
                ],
                stops: const [0, .55, 1],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Springy press feedback used across buttons, tiles and chips.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  const Pressable(
      {super.key,
      required this.child,
      this.onTap,
      this.scale = .96,
      this.haptic = true});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: CkMotion.fast,
        curve: CkMotion.ease,
        child: AnimatedOpacity(
          opacity: _down ? .85 : 1,
          duration: CkMotion.fast,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Fade + rise entrance, staggered by [index].
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 10)) * 0.06;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (delay * 1000).round()),
      curve: Interval(delay / (0.42 + delay), 1, curve: CkMotion.ease),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
      ),
      child: child,
    );
  }
}

/// Card heading: icon chip + title, like `.ck-heading` in the software.
class CkHeading extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  const CkHeading({super.key, required this.title, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CkColors.orangeTint,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: CkColors.orangeStroke),
              ),
              child: Icon(icon, size: 17, color: CkColors.orangeSoft),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Glass list tile used for menus (profile, others, algorithms).
class GlassTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  const GlassTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Glass(
        margin: margin,
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            if (leading != null) ...[
              Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CkColors.orangeTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CkColors.orangeStroke),
                ),
                child: leading,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CkColors.text)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 12, color: CkColors.textSecondary)),
                  ]
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: CkColors.textMuted),
          ],
        ),
      ),
    );
  }
}
