import 'dart:ui';

import 'package:flutter/cupertino.dart' show CupertinoPageTransition;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ck_theme.dart';
import 'cosmic_background.dart';
import 'widgets.dart' show perfOff;

const String kCkBackground = 'assets/images/ck_bg.jpg';

/// Deep-space backdrop shared by every page (same art as the software).
///
/// Motion spec (Phase 1b): a page is fully drawn from its first frame, with
/// its own background; it arrives by sliding in ([CkRoute]), never by fading
/// from empty. Inside a shell that already paints the background for its
/// tabs ([SharedBackdrop]), a page draws only its content.
class CkBackground extends StatelessWidget {
  final Widget child;
  const CkBackground({super.key, required this.child}) : paint = true;

  /// [paint] false: a container screen whose pages each draw their own
  /// background draws none itself.
  final bool paint;
  const CkBackground.none({super.key, required this.child}) : paint = false;

  @override
  Widget build(BuildContext context) {
    final content = BackdropGroup(child: child);
    if (!paint || SharedBackdrop.covers(context)) return content;
    return ColoredBox(
      color: CkColors.deepSpace,
      child: Stack(fit: StackFit.expand, children: [const CosmicBackground(), content]),
    );
  }
}

/// The background alone, for a shell to paint once behind all its tabs.
class CkBackdrop extends StatelessWidget {
  const CkBackdrop({super.key});
  @override
  Widget build(BuildContext context) =>
      const ColoredBox(color: CkColors.deepSpace, child: SizedBox.expand(child: CosmicBackground()));
}

/// Marks a tab page whose shell already paints the background behind all
/// its tabs, so cross-fading tabs never fade the background itself.
class SharedBackdrop extends InheritedWidget {
  const SharedBackdrop({super.key, required super.child});
  static bool covers(BuildContext c) => c.getInheritedWidgetOfExactType<SharedBackdrop>() != null;
  @override
  bool updateShouldNotify(SharedBackdrop old) => false;
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
    this.background = true,
  });

  /// false for a shell whose pages draw their own background.
  final bool background;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: CkColors.deepSpace,
      ),
      child: (background ? CkBackground.new : CkBackground.none)(
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
    this.radius = 22,
    this.blur = 0,
    this.tint = const Color(0x00000000),
    this.stroke = CkColors.panelStroke,
    this.width,
    this.height,
    this.shadow = false,
    this.alignment,
    this.frost = true,
    this.liquid = false,
  });

  /// Real backdrop blur behind the card.
  final bool frost;

  /// Refracting liquid-glass lens (dock, sheets, floating bars).
  final bool liquid;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final face = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        border: Border.all(color: stroke, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(tint, CkColors.panelTop),
            Color.alphaBlend(tint, CkColors.panelBottom),
          ],
        ),
      ),
      child: Container(alignment: alignment, padding: padding, child: child),
    );
    // Real backdrop blur is expensive (one full-screen pass per card), so
    // only surfaces that float over moving content (dock, sheets) ask for
    // it. Cards get the same look from a tinted, pre-blurred background.
    // Cards: frosted blur through the page's shared BackdropGroup (one
    // backdrop read for every card on screen, as in MyAcharyaji). Floating
    // surfaces pass `liquid: true` for the refracting lens on top.
    final Widget body;
    if (liquid) {
      body = LiquidGlass(radius: radius, blur: blur > 0 ? blur : 20, child: face);
    } else if (frost && !perfOff(4)) {
      final f = ImageFilter.blur(sigmaX: blur > 0 ? blur : 14, sigmaY: blur > 0 ? blur : 14);
      body = ClipRRect(
        borderRadius: r,
        child: BackdropGroup.of(context) != null ? BackdropFilter.grouped(filter: f, child: face) : BackdropFilter(filter: f, child: face),
      );
    } else {
      body = face;
    }
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: shadow
          ? BoxDecoration(borderRadius: r, boxShadow: const [
              BoxShadow(color: Color(0x26000000), blurRadius: 12, offset: Offset(0, 6)),
            ])
          : null,
      child: body,
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
        child: widget.child,
      ),
    );
  }
}

/// Fade + rise entrance, staggered by [index] (motion spec, MyAcharyaji:
/// 550 ms, rise 16 px, scale 98 -> 100%, 70 ms apart, curve kEase).
///
/// One entrance per card: inside another FadeSlideIn it does nothing, so a
/// card never plays its entrance twice. Only the first [kEntranceCount]
/// items animate (later ones are usually off screen and must not animate
/// while scrolling). Plays once when it is built; with the phone's
/// "remove animations" setting it shows at once.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

const int kEntranceCount = 6;

class _InEntrance extends InheritedWidget {
  const _InEntrance({required super.child});
  @override
  bool updateShouldNotify(_InEntrance old) => false;
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: kEase);
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    final i = widget.index;
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final nested = context.getInheritedWidgetOfExactType<_InEntrance>() != null;
    if (still || nested || i < 0 || i >= kEntranceCount) {
      _c.value = 1;
    } else if (i == 0) {
      _c.forward();
    } else {
      Future.delayed(Duration(milliseconds: 70 * i), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InEntrance(
      child: FadeTransition(
        opacity: _t,
        child: AnimatedBuilder(
          animation: _t,
          child: widget.child,
          builder: (_, c) {
            final v = _t.value;
            if (v >= 1) return c!;
            return Transform.translate(
              offset: Offset(0, (1 - v) * 16),
              child: Transform.scale(scale: .98 + .02 * v, child: c),
            );
          },
        ),
      ),
    );
  }
}

const Curve kEase = Cubic(.22, 1, .36, 1);

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


/// Liquid-glass lens: blur + edge refraction through a fragment shader where
/// the engine supports shader image filters (Impeller); plain blur elsewhere.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final double depth;
  const LiquidGlass({super.key, required this.child, this.radius = 20, this.blur = 20, this.depth = 9});

  static FragmentProgram? program;
  static Future<void> preload() async {
    if (!ImageFilter.isShaderFilterSupported) return;
    try {
      program = await FragmentProgram.fromAsset('shaders/liquid_glass.frag');
    } catch (_) {
      program = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final blurF = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    return LayoutBuilder(builder: (context, box) {
      ImageFilter filter = blurF;
      final prog = program;
      final ro = context.findRenderObject();
      if (prog != null && !perfOff(1) && box.hasBoundedWidth && box.hasBoundedHeight) {
        try {
          final shader = prog.fragmentShader();
          final dpr = MediaQuery.of(context).devicePixelRatio;
          // The filter input covers the screen; place the lens where this
          // widget sits (falls back to local coordinates on the first frame).
          Offset o = Offset.zero;
          if (ro is RenderBox && ro.hasSize) o = ro.localToGlobal(Offset.zero);
          shader
            ..setFloat(2, o.dx * dpr)
            ..setFloat(3, o.dy * dpr)
            ..setFloat(4, box.maxWidth * dpr)
            ..setFloat(5, box.maxHeight * dpr)
            ..setFloat(6, radius * dpr)
            ..setFloat(7, depth * dpr);
          filter = ImageFilter.compose(outer: ImageFilter.shader(shader), inner: blurF);
        } catch (_) {
          filter = blurF;
        }
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(filter: filter, child: child),
      );
    });
  }
}

/// Page transition (motion spec): the new page slides in from the right,
/// fully drawn, while the old one shifts a little left; back reverses it.
/// Same feel as MyAcharyaji's pushed pages (iOS-style slide, 300 ms).
class CkRoute<T> extends PageRouteBuilder<T> {
  CkRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (c, a, b) => builder(c),
          transitionsBuilder: (c, a, b, child) => (MediaQuery.maybeDisableAnimationsOf(c) ?? false)
              ? child
              : CupertinoPageTransition(
            primaryRouteAnimation: a,
            secondaryRouteAnimation: b,
            linearTransition: false,
            child: child,
          ),
        );
}

/// Keeps every tab alive and switches like MyAcharyaji: the old tab fades
/// out fast (the curve drops most of it within ~100 ms) while the new one
/// fades in over 400 ms and rises 2.5% over 450 ms. Hidden tabs are not
/// painted (opacity 0), don't take touches and have their animations paused.
class TabFader extends StatelessWidget {
  final int index;
  final List<Widget> children;
  const TabFader({super.key, required this.index, required this.children});

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Stack(children: [
        for (var i = 0; i < children.length; i++)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: i != index,
              // The fade itself must keep ticking after the tab is left, so
              // only the tab's content is paused (TickerMode inside).
              child: AnimatedOpacity(
                opacity: i == index ? 1 : 0,
                duration: still ? Duration.zero : const Duration(milliseconds: 400),
                curve: kEase,
                child: AnimatedSlide(
                  offset: i == index ? Offset.zero : const Offset(0, 0.025),
                  duration: still ? Duration.zero : const Duration(milliseconds: 450),
                  curve: kEase,
                  child: TickerMode(enabled: i == index, child: children[i]),
                ),
              ),
            ),
          ),
      ]);
  }
}
