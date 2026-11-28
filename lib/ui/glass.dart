import 'dart:ui';

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
    // Entrance: fade the face only (see [entranceFade]); a card inside a card
    // that is already fading does not fade a second time.
    final fade = entranceFade(context);
    final shown = fade == null || context.getInheritedWidgetOfExactType<_Faded>() != null
        ? face
        : FadeTransition(opacity: fade, child: _Faded(child: face));
    // Real backdrop blur is expensive (one full-screen pass per card), so
    // only surfaces that float over moving content (dock, sheets) ask for
    // it. Cards get the same look from a tinted, pre-blurred background.
    // Cards: frosted blur through the page's shared BackdropGroup (one
    // backdrop read for every card on screen, as in MyAcharyaji). Floating
    // surfaces pass `liquid: true` for the refracting lens on top.
    final Widget body;
    if (liquid) {
      body = LiquidGlass(radius: radius, blur: blur > 0 ? blur : 20, child: shown);
    } else if (frost && !perfOff(4)) {
      final f = ImageFilter.blur(sigmaX: blur > 0 ? blur : 14, sigmaY: blur > 0 ? blur : 14);
      body = ClipRRect(
        borderRadius: r,
        child: BackdropGroup.of(context) != null ? BackdropFilter.grouped(filter: f, child: shown) : BackdropFilter(filter: f, child: shown),
      );
    } else {
      body = shown;
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
      this.scale = .97,
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
/// One entrance per card: inside another entrance that is still running it
/// does nothing, so a card never plays two entrances at once; cards that
/// arrive later (data loaded) play their own. Only the first [kEntranceCount]
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
  /// The fade cards use here: this one combined with any outer fade.
  final Animation<double> t;
  /// An entrance (or data swap) is running here, so entrances below it
  /// don't play again. A tab switch alone doesn't count.
  final bool nests;
  const _InEntrance({required this.t, required this.nests, required super.child});

  /// Publishes [t] under any outer fade (cards show the lower of the two).
  static Widget wrap(BuildContext c, Animation<double> t, {required bool entrance, required Widget child}) {
    final outer = c.getInheritedWidgetOfExactType<_InEntrance>();
    return _InEntrance(
      t: outer == null ? t : AnimationMin<double>(outer.t, t),
      nests: entrance || (outer?.nests ?? false),
      child: child,
    );
  }
  @override
  bool updateShouldNotify(_InEntrance old) => !identical(old.t, t);
}

/// Fades the cards under it in with [t] the way an entrance does: each
/// [Glass] fades its face and keeps its blur steady. For data swapping in.
class CardFade extends StatelessWidget {
  final Animation<double> t;
  final Widget child;
  final bool entrance;
  const CardFade({super.key, required this.t, required this.child}) : entrance = true;

  /// For a tab switch: cards fade, but entrances below still play.
  const CardFade.tab({super.key, required this.t, required this.child}) : entrance = false;
  @override
  Widget build(BuildContext context) => _InEntrance.wrap(context, t, entrance: entrance, child: child);
}

class _Faded extends InheritedWidget {
  const _Faded({required super.child});
  @override
  bool updateShouldNotify(_Faded old) => false;
}

/// The fade of the card entrance this widget sits in (null outside one).
/// [Glass] fades only its face with it and keeps the blur steady: a blur
/// inside a part-transparent layer has nothing behind it to blur, so a
/// card fading as a whole looks clear first and gets its blur at the end.
Animation<double>? entranceFade(BuildContext c) => c.getInheritedWidgetOfExactType<_InEntrance>()?.t;

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: kEase);
  bool _decided = false;
  bool _nested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    final i = widget.index;
    final still = (MediaQuery.maybeDisableAnimationsOf(context) ?? false) || perfOff(32);
    final outer = context.getInheritedWidgetOfExactType<_InEntrance>();
    final nested = _nested = outer != null && outer.nests && outer.t.value < 1;
    if (still || nested || i < 0 || i >= kEntranceCount) {
      _c.value = 1;
      return;
    }
    _play(0);
    // Coming back to this page (the page above is closing): the cards rise
    // in again, one after another, as in MyAcharyaji.
    _cover = ModalRoute.of(context)?.secondaryAnimation;
    _cover?.addStatusListener(_onCover);
    // Switching to this tab: the cards rise in again too.
    _visit = context.getInheritedWidgetOfExactType<_TabVisit>()?.visits;
    _visit?.addListener(_onVisit);
  }

  Animation<double>? _cover;
  Listenable? _visit;
  int _run = 0;

  // switching to this tab: the cards rise in again with the tab
  void _onVisit() => _play(0, from: 0);

  void _onCover(AnimationStatus s) {
    // the page above starts sliding away: this page's cards rise in again
    if (s == AnimationStatus.reverse) _play(0, from: 0);
  }

  void _play(int waitMs, {double? from}) {
    final run = ++_run;
    if (from != null) _c.value = from;
    final wait = waitMs + 70 * widget.index;
    if (wait == 0) {
      _c.forward();
      return;
    }
    Future.delayed(Duration(milliseconds: wait), () {
      if (mounted && run == _run) _c.forward();
    });
  }

  @override
  void dispose() {
    _cover?.removeStatusListener(_onCover);
    _visit?.removeListener(_onVisit);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inside another entrance: the outer one moves and fades this too.
    if (_nested) return widget.child;
    // No fade layer around the whole item: cards ([Glass]) fade their own
    // face through [entranceFade] and keep their blur from the first frame.
    return _InEntrance.wrap(
      context,
      _t,
      entrance: true,
      child: AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (_, c) {
          final v = _t.value;
          // Always the same widget shape: returning the bare child once the
          // entrance ends would tear the whole card down and build it again
          // (a heavy frame, and charts inside restarting from zero).
          return Transform.translate(
            offset: Offset(0, (1 - v) * 16),
            child: Transform.scale(scale: .98 + .02 * v, child: c),
          );
        },
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
    if (perfOff(16)) return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
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
          transitionDuration: kPageDuration,
          reverseTransitionDuration: kPageDuration,
          pageBuilder: (c, a, b) => builder(c),
          transitionsBuilder: (c, a, b, child) => ckPageTransition(c, a, b, child),
        );
}

/// Page open/close length (MyAcharyaji: 550 ms, one curve).
const Duration kPageDuration = Duration(milliseconds: 550);

/// Every page in the app, opening and closing, as in MyAcharyaji:
/// - each page is one solid piece with its own background (the background
///   runs on one shared clock, so two pages show the same sky and the seam
///   never shows);
/// - the new page slides in from the right; the page under it moves 28% to
///   the left and dims; back reverses both;
/// - the cards of the new page rise in one after another while it slides.
/// Used by GetX routes (main.dart) and by [CkRoute].
Widget ckPageTransition(BuildContext c, Animation<double> a, Animation<double> b, Widget child) {
  final page = _SolidPage(child: child);
  if (MediaQuery.maybeDisableAnimationsOf(c) ?? false) return page;
  final into = CurvedAnimation(parent: a, curve: kEase, reverseCurve: kEase.flipped);
  final under = CurvedAnimation(parent: b, curve: kEase, reverseCurve: kEase.flipped);
  return SlideTransition(
    position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(into),
    child: SlideTransition(
      position: Tween(begin: Offset.zero, end: const Offset(-.28, 0)).animate(under),
      child: Stack(fit: StackFit.passthrough, children: [
        page,
        // dimming the page underneath: a cheap dark veil, not a fade layer
        // (a fade layer would drop the cards' blur)
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: under,
              builder: (_, __) => ColoredBox(color: Color.fromRGBO(0, 0, 0, .35 * under.value)),
            ),
          ),
        ),
      ]),
    ),
  );
}

/// A page with its own background; pages inside it draw only content.
class _SolidPage extends StatelessWidget {
  final Widget child;
  const _SolidPage({required this.child});
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: CkColors.deepSpace,
        child: Stack(fit: StackFit.expand, children: [
          const RepaintBoundary(child: CosmicBackground()),
          SharedBackdrop(child: BackdropGroup(child: child)),
        ]),
      );
}

/// Keeps every tab alive and switches as in MyAcharyaji: the new tab fades
/// in over 400 ms while rising 16 px (450 ms), and its cards rise in one
/// after another; the old tab gets out of the way in 150 ms. Cards fade only
/// their face ([CardFade]) so their blur never pops in late. Hidden tabs are
/// not painted, take no touches and pause their animations.
class TabFader extends StatefulWidget {
  final int index;
  final List<Widget> children;
  const TabFader({super.key, required this.index, required this.children});
  @override
  State<TabFader> createState() => _TabFaderState();
}

/// Counts visits to one tab, so the cards in it can rise in again.
class _TabVisit extends InheritedWidget {
  final ValueNotifier<int> visits;
  const _TabVisit({required this.visits, required super.child});
  @override
  bool updateShouldNotify(_TabVisit old) => !identical(old.visits, visits);
}

class _TabFaderState extends State<TabFader> with SingleTickerProviderStateMixin {
  final _visits = <ValueNotifier<int>>[];
  ValueNotifier<int> _v(int i) {
    while (_visits.length <= i) {
      _visits.add(ValueNotifier<int>(0));
    }
    return _visits[i];
  }

  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450), value: 1)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && _prev != null && mounted) setState(() => _prev = null);
    });
  // old tab: gone within the first third (150 ms), ease-in
  late final Animation<double> _out = ReverseAnimation(CurvedAnimation(parent: _c, curve: const Interval(0, 1 / 3, curve: Curves.easeIn)));
  // new tab: fade 400 ms, rise 450 ms
  late final Animation<double> _in = CurvedAnimation(parent: _c, curve: const Interval(0, 400 / 450, curve: kEase));
  late final Animation<double> _rise = CurvedAnimation(parent: _c, curve: kEase);
  static const _shown = AlwaysStoppedAnimation<double>(1);
  int? _prev;

  @override
  void didUpdateWidget(TabFader old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _prev = null;
      _c.value = 1;
      return;
    }
    _prev = old.index;
    _c.forward(from: 0);
    _v(widget.index).value++;
  }

  @override
  void dispose() {
    _c.dispose();
    for (final v in _visits) {
      v.dispose();
    }
    super.dispose();
  }

  // One fixed fade per tab, pointed at the right curve on each switch, so
  // cards built earlier keep following it.
  final _fade = <ProxyAnimation>[];

  ProxyAnimation _f(int i) {
    while (_fade.length <= i) {
      _fade.add(ProxyAnimation(_shown));
    }
    return _fade[i];
  }

  @override
  Widget build(BuildContext context) {
    final cur = widget.index;
    final prev = _prev;
    for (var i = 0; i < widget.children.length; i++) {
      final want = i == prev ? _out : (i == cur && prev != null ? _in : _shown);
      final f = _f(i);
      if (!identical(f.parent, want)) f.parent = want;
    }
    // Every tab keeps the same widget shape at all times, so switching
    // never rebuilds a tab from scratch.
    return Stack(children: [
      for (var i = 0; i < widget.children.length; i++)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: i != cur,
            child: TickerMode(
              enabled: i == cur || i == prev,
              child: AnimatedBuilder(
                animation: _c,
                child: _TabVisit(visits: _v(i), child: CardFade.tab(t: _f(i), child: widget.children[i])),
                builder: (_, c) {
                  final leaving = i == prev && _c.value < 1 / 3;
                  final arriving = i == cur && prev != null;
                  final hidden = !(i == cur || leaving);
                  return Offstage(
                    offstage: hidden,
                    child: Transform.translate(offset: Offset(0, arriving ? (1 - _rise.value) * 16 : 0), child: c),
                  );
                },
              ),
            ),
          ),
        ),
    ]);
  }
}
