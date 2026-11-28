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
    return ValueListenableBuilder<bool>(
      valueListenable: perfOverlay,
      builder: (c, perf, _) => GetMaterialApp(
      showPerformanceOverlay: perf,
      title: 'CosmoKundli',
      debugShowCheckedModeBanner: false,
      theme: CkTheme.dark(),
      darkTheme: CkTheme.dark(),
      themeMode: ThemeMode.dark,
      // Every page change: fade-through over the one shared background
      // (cupertinoDialog is the GetX value that hands over to customTransition).
      defaultTransition: Transition.cupertinoDialog,
      customTransition: _CkTransition(),
      transitionDuration: const Duration(milliseconds: 300),
      home: const SplashPage(),
      navigatorObservers: [UnfocusObserver()],
      builder: (context, child) => MediaQuery(
        // keep layouts stable on large system font settings
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 1.15),
        ),
        // One background for the whole app: painted once, under every page,
        // so it never moves or changes when pages change.
        child: Stack(children: [
          const Positioned.fill(child: CkBackdrop()),
          SharedBackdrop(child: BackdropGroup(child: child!)),
        ]),
      ),
    ),
    );
  }
}

void goHome() => Get.offAll(() => const AppShell());
void goLogin() => Get.offAll(() => const LoginPage());

class _CkTransition extends CustomTransition {
  @override
  Widget buildTransition(BuildContext context, Curve? curve, Alignment? alignment, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      ckFadeThrough(context, animation, secondaryAnimation, child);
}

