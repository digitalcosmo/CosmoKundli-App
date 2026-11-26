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
      defaultTransition: Transition.noTransition,
      transitionDuration: const Duration(milliseconds: 240),
      home: const SplashPage(),
      navigatorObservers: [UnfocusObserver()],
      builder: (context, child) => MediaQuery(
        // keep layouts stable on large system font settings
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 1.15),
        ),
        child: BackdropGroup(child: child!),
      ),
    ),
    );
  }
}

void goHome() => Get.offAll(() => const AppShell());
void goLogin() => Get.offAll(() => const LoginPage());

