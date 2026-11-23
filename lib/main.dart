import 'package:cosmo_kundali/controllers/kundali_controller.dart';
import 'package:cosmo_kundali/controllers/language_controller.dart';
import 'package:cosmo_kundali/screens/spalsh_screen.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:cosmo_kundali/ui/ck_theme.dart';
import 'package:cosmo_kundali/values/get_tags.dart';
import 'package:cosmo_kundali/values/messages.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:edge_to_edge/edge_to_edge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'controllers/clientdetail_controller.dart';
import 'controllers/home_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  EdgeToEdge.configure(
    statusBarColor: Colors.transparent,
    navigationBarColor: Color(0xFF061A3F),
    statusBarIconBrightness: Brightness.light,
    navigationBarIconBrightness: Brightness.light,
    enableTop: true,
    enableBottom: false,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: CkTheme.dark(),
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LanguageController languageController =
  Get.put(LanguageController(), tag: GetTags.langTag);

  @override
  void initState() {
    super.initState();
    initController();
    languageController.getLocal();
  }

  void initController() {
    Get.lazyPut<ClientDetailController>(() => ClientDetailController(),
        tag: GetTags.clientDetailTag);
    Get.lazyPut<HomeController>(() => HomeController(), tag: GetTags.homeTag);
    Get.lazyPut<KundaliController>(() => KundaliController(),
        tag: GetTags.kundaliTag);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (p0, p1, p2) =>
          GetMaterialApp(
            locale: languageController.locale.value,
            fallbackLocale: const Locale('en', 'US'),
            title: AppConstants.appTitle,
            translations: Messages(),
            debugShowCheckedModeBanner: false,
            //initialRoute: AppRoutes.loginView,
            getPages: AppRoutes.routeList,
            theme: CkTheme.dark(),
            darkTheme: CkTheme.dark(),
            themeMode: ThemeMode.dark,
            defaultTransition: Transition.cupertino,
            transitionDuration: const Duration(milliseconds: 320),
            home: SpalshScreen(),
          ),
    );
  }
}
