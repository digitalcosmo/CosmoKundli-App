import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'ck_theme.dart';
import 'cosmic_background.dart';
import 'widgets.dart' show perfOff;

const String kCkBackground = 'assets/images/ck_bg.jpg';

/// The sky (background) is painted once, under every page, by [CkSky] in
/// main.dart. Pages never draw their own, so opening or closing a page can
/// never redraw it. Kept as a no-op wrapper for existing call sites.
class CkBackground extends StatelessWidget {
  final Widget child;
  const CkBackground({super.key, required this.child});
  const CkBackground.none({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}

/// The app's one sky: background art plus the space colour, under the
/// navigator. Nothing above it ever paints a background.
class CkSky extends StatelessWidget {
  final Widget child;
  const CkSky({super.key, required this.child});
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: CkColors.deepSpace,
        child: Stack(fit: StackFit.expand, children: [
          const RepaintBoundary(child: CosmicBackground()),
          child,
        ]),
      );
}

/// Marks content whose background is already drawn (kept for call sites).
class SharedBackdrop extends InheritedWidget {
  const SharedBackdrop({super.key, required super.child});
  static bool covers(BuildContext c) => true;
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
    // Frost (Build 2, speed): over the sky, a card shows the pre-blurred
    // copy of the sky ([SkyFrost]) behind its face instead of blurring the
    // screen live; it looks the same, because the sky is the only thing
    // behind a card, and costs one small picture instead of a blur per card
    // per frame. A card inside a card, and a card outside a page (a sheet),
    // keep the old way. The entrance fades the whole card, frost included.
    final Widget body;
    final bool nested = context.getInheritedWidgetOfExactType<_InGlass>() != null;
    if (liquid) {
      body = LiquidGlass(radius: radius, blur: blur > 0 ? blur : 20, child: face);
    } else if (!frost || perfOff(4) || nested) {
      body = face;
    } else if (context.getInheritedWidgetOfExactType<_OverSky>() != null) {
      body = ClipRRect(
        borderRadius: r,
        child: Stack(children: [
          const Positioned.fill(child: _FrostView()),
          _InGlass(child: face),
        ]),
      );
    } else {
      final double sigma = blur > 0 ? blur : 14;
      body = ClipRRect(
        borderRadius: r,
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma), child: _InGlass(child: face)),
      );
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
      this.haptic = false});

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

/// Gap between cards in the wave below it: [CkMotion.waveTab] on a tab,
/// [CkMotion.wavePage] on a pushed page.
class EntranceWave extends InheritedWidget {
  final int stepMs;
  const EntranceWave({super.key, required this.stepMs, required super.child});
  static int of(BuildContext c) => c.getInheritedWidgetOfExactType<EntranceWave>()?.stepMs ?? CkMotion.waveTab;
  @override
  bool updateShouldNotify(EntranceWave old) => old.stepMs != stepMs;
}

/// The card entrance, exactly as MyAcharyaji: 550 ms, rise 16 px, scale
/// 0.98 to 1, one fade over the whole card, cards [EntranceWave] apart.
///
/// One entrance per card: inside another entrance that is still running it
/// does nothing. It plays when built, again when its tab is visited, and
/// again when the page above it closes. Items past [kEntranceCount] (rows
/// reached by scrolling) appear without animating. With the phone's
/// "remove animations" setting it shows at once.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

/// Rows past this index are reached by scrolling and never animate.
const int kEntranceCount = 12;

class _InEntrance extends InheritedWidget {
  /// The fade cards use here: this one combined with any outer fade.
  final Animation<double> t;
  /// An entrance is running here, so entrances below it don't play again.
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

/// Marks a page whose cards sit over the sky (they can use [SkyFrost]).
class _OverSky extends InheritedWidget {
  const _OverSky({required super.child});
  @override
  bool updateShouldNotify(_OverSky old) => false;
}

/// Marks the inside of a frosted card (a card inside it needs no frost).
class _InGlass extends InheritedWidget {
  const _InGlass({required super.child});
  @override
  bool updateShouldNotify(_InGlass old) => false;
}

/// Paints the part of [SkyFrost] that lies behind this box. It repaints on
/// its own (own layer) when the sky updates or a scroll moves it, so the
/// card's content is never redrawn for it.
class _FrostView extends LeafRenderObjectWidget {
  const _FrostView();
  List<ScrollPosition> _scrolls(BuildContext c) {
    final out = <ScrollPosition>[];
    var s = Scrollable.maybeOf(c);
    while (s != null && out.length < 3) {
      out.add(s.position);
      s = Scrollable.maybeOf(s.context);
    }
    return out;
  }

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFrost(_scrolls(context));
  @override
  void updateRenderObject(BuildContext context, _RenderFrost r) => r.scrolls = _scrolls(context);
}

class _RenderFrost extends RenderBox {
  _RenderFrost(this._scrolls);
  List<ScrollPosition> _scrolls;
  set scrolls(List<ScrollPosition> v) {
    if (attached) {
      for (final p in _scrolls) {
        p.removeListener(markNeedsPaint);
      }
      for (final p in v) {
        p.addListener(markNeedsPaint);
      }
    }
    _scrolls = v;
  }

  static final _paint = Paint()..filterQuality = FilterQuality.low;

  @override
  bool get isRepaintBoundary => true;
  @override
  bool get sizedByParent => true;
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    SkyFrost.image.addListener(markNeedsPaint);
    for (final p in _scrolls) {
      p.addListener(markNeedsPaint);
    }
  }

  @override
  void detach() {
    SkyFrost.image.removeListener(markNeedsPaint);
    for (final p in _scrolls) {
      p.removeListener(markNeedsPaint);
    }
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final img = SkyFrost.image.value;
    if (img == null || size.isEmpty) return;
    final g = localToGlobal(Offset.zero);
    const k = SkyFrost.scale;
    final src = Rect.fromLTWH(g.dx * k, g.dy * k, size.width * k, size.height * k);
    context.canvas.drawImageRect(img, src, offset & size, _paint);
  }
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: CkMotion.enter);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: kEase);
  bool _decided = false;
  bool _nested = false;
  int _step = CkMotion.waveTab;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    final i = widget.index;
    _step = EntranceWave.of(context);
    final still = (MediaQuery.maybeDisableAnimationsOf(context) ?? false) || perfOff(32);
    final outer = context.getInheritedWidgetOfExactType<_InEntrance>();
    final nested = _nested = outer != null && outer.nests && outer.t.value < 1;
    if (still || nested || i < 0 || i >= kEntranceCount) {
      _c.value = 1;
      return;
    }
    _play();
    // Coming back to this page (the page above is closing): the cards rise
    // in again, one after another.
    _cover = ModalRoute.of(context)?.secondaryAnimation;
    _cover?.addStatusListener(_onCover);
    // Switching to this tab: the cards rise in again too.
    _visit = context.getInheritedWidgetOfExactType<_TabVisit>()?.visits;
    _visit?.addListener(_onVisit);
  }

  Animation<double>? _cover;
  Listenable? _visit;
  int _run = 0;

  void _onVisit() => _play(from: 0);

  void _onCover(AnimationStatus s) {
    if (s == AnimationStatus.reverse) _play(from: 0);
  }

  void _play({double? from}) {
    final run = ++_run;
    if (from != null) _c.value = from;
    final wait = _step * widget.index;
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
    // Always the same widget shape: returning the bare child once the
    // entrance ends would tear the whole card down and build it again.
    final moved = AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (_, c) {
        final v = _t.value;
        return Transform.translate(
          offset: Offset(0, (1 - v) * CkMotion.rise),
          child: Transform.scale(scale: CkMotion.scaleFrom + (1 - CkMotion.scaleFrom) * v, child: c),
        );
      },
    );
    return _InEntrance.wrap(
      context,
      _t,
      entrance: true,
      child: FadeTransition(opacity: _t, child: moved),
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

/// Every pushed page (module pages inside a client tab use this; GetX
/// pages get the same motion through main.dart).
class CkRoute<T> extends PageRouteBuilder<T> {
  CkRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: kPageDuration,
          reverseTransitionDuration: kPageDuration,
          pageBuilder: (c, a, b) => builder(c),
          transitionsBuilder: (c, a, b, child) => ckPageTransition(c, a, b, child),
        );
}

/// Page open/close length.
const Duration kPageDuration = CkMotion.push;

/// Push and back, at every level (family plan: "content moves, sky stays"):
/// - the sky never moves; pages have no background of their own;
/// - the arriving page fades in while drifting from 8% to the right, and
///   its cards rise in one after another (60 ms apart);
/// - the page underneath fades out while drifting 8% to the left;
/// - back is the exact mirror, and the cards of the page you return to
///   rise in again.
/// Docks stay where they are ([StayPut]) and simply cross-fade.
/// [wave] is the card gap for the page (tab roots keep the tab gap).
Widget ckPageTransition(BuildContext c, Animation<double> a, Animation<double> b, Widget child,
    {int wave = CkMotion.wavePage}) {
  final page = EntranceWave(stepMs: wave, child: _OverSky(child: child));
  if (MediaQuery.maybeDisableAnimationsOf(c) ?? false) return page;
  final into = CurvedAnimation(parent: a, curve: kEase, reverseCurve: kEase.flipped);
  final under = CurvedAnimation(parent: b, curve: kEase, reverseCurve: kEase.flipped);
  final shift = _PageShift(into: into, under: under);
  return _PageShiftScope(
    shift: shift,
    child: AnimatedBuilder(
      animation: shift.both,
      child: page,
      // always the same widget shape, so the page is never rebuilt
      builder: (_, k) => Opacity(
        opacity: shift.opacity,
        child: FractionalTranslation(translation: Offset(shift.dx, 0), child: k),
      ),
    ),
  );
}

/// Where a page is in its push/back motion.
class _PageShift {
  final Animation<double> into;
  final Animation<double> under;
  final Listenable both;
  _PageShift({required this.into, required this.under}) : both = Listenable.merge([into, under]);
  /// Horizontal drift, as a share of the page width.
  double get dx => CkMotion.pushShift * (1 - into.value) - CkMotion.pushShift * under.value;
  double get opacity => (into.value * (1 - under.value)).clamp(0.0, 1.0);
}

class _PageShiftScope extends InheritedWidget {
  final _PageShift shift;
  const _PageShiftScope({required this.shift, required super.child});
  @override
  bool updateShouldNotify(_PageShiftScope old) => !identical(old.shift, shift);
}

/// Keeps a floating surface (a dock) in place while its page drifts during
/// push and back, so two docks cross-fade on the same spot.
class StayPut extends StatelessWidget {
  final Widget child;
  const StayPut({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final s = context.getInheritedWidgetOfExactType<_PageShiftScope>()?.shift;
    if (s == null) return child;
    return AnimatedBuilder(
      animation: s.both,
      child: child,
      builder: (c, k) => Transform.translate(offset: Offset(-s.dx * MediaQuery.sizeOf(c).width, 0), child: k),
    );
  }
}

/// Keeps every tab alive and switches exactly as MyAcharyaji: the old and
/// the new tab cross-fade over 400 ms while sliding 2.5% of the screen
/// height over 450 ms (the new one rises into place, the old one sinks
/// away), and the new tab's cards rise in one after another, 70 ms apart.
/// Hidden tabs are not painted, take no touches and pause their animations.
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

  late final AnimationController _c = AnimationController(vsync: this, duration: CkMotion.tabSlide, value: 1)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && _prev != null && mounted) setState(() => _prev = null);
    });
  late final Animation<double> _fade = CurvedAnimation(
      parent: _c, curve: Interval(0, CkMotion.tabFade.inMilliseconds / CkMotion.tabSlide.inMilliseconds, curve: kEase));
  late final Animation<double> _slide = CurvedAnimation(parent: _c, curve: kEase);
  int? _prev;

  @override
  void didUpdateWidget(TabFader old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    _v(widget.index).value++;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _prev = null;
      _c.value = 1;
      return;
    }
    _prev = old.index;
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    for (final v in _visits) {
      v.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cur = widget.index;
    final prev = _prev;
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
                child: _TabVisit(
                  visits: _v(i),
                  child: EntranceWave(stepMs: CkMotion.waveTab, child: widget.children[i]),
                ),
                builder: (_, k) {
                  final moving = prev != null;
                  final arriving = moving && i == cur;
                  final leaving = moving && i == prev;
                  final opacity = arriving ? _fade.value : (leaving ? 1 - _fade.value : 1.0);
                  final dy = arriving
                      ? CkMotion.tabShift * (1 - _slide.value)
                      : (leaving ? CkMotion.tabShift * _slide.value : 0.0);
                  return Offstage(
                    offstage: !(i == cur || leaving),
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: FractionalTranslation(translation: Offset(0, dy), child: k),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
    ]);
  }
}
