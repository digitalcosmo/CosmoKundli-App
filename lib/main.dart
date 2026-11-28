import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/session.dart';
import 'pages/auth_pages.dart';
import 'pages/app_shell.dart';
import 'ui/ck_theme.dart';
import 'ui/glass.dart';
import 'ui/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF061A3F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  // Fonts ship inside the app: no download on first launch.
  GoogleFonts.config.allowRuntimeFetching = false;
  await Session.init();
  await LiquidGlass.preload();
  runApp(const CosmoKundliApp());
}

class CosmoKundliApp extends StatelessWidget {
  const CosmoKundliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CosmoKundli',
      debugShowCheckedModeBanner: false,
      theme: CkTheme.dark(),
      darkTheme: CkTheme.dark(),
      themeMode: ThemeMode.dark,
      // Every page: content moves, the sky stays (glass.dart
      // ckPageTransition). cupertinoDialog is the GetX value that hands over
      // to customTransition.
      defaultTransition: Transition.cupertinoDialog,
      customTransition: _CkTransition(),
      transitionDuration: kPageDuration,
      home: const SplashPage(),
      navigatorObservers: [UnfocusObserver()],
      scrollBehavior: const _CkScroll(),
      builder: (context, child) => MediaQuery(
        // keep layouts stable on large system font settings
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 1.15),
        ),
        // the one sky, under every page; pages never paint a background
        child: CkSky(child: child!),
      ),
    );
  }
}

void goHome() => Get.offAll(() => const AppShell());
void goLogin() => Get.offAll(() => const LoginPage());

/// One feel for every list (Build 5, T): the same soft bounce at both ends
/// on every screen, short lists included, and no Android glow.
class _CkScroll extends MaterialScrollBehavior {
  const _CkScroll();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class _CkTransition extends CustomTransition {
  @override
  Widget buildTransition(BuildContext context, Curve? curve, Alignment? alignment, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      ckPageTransition(context, animation, secondaryAnimation, child);
}

