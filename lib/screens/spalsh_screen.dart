import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'dart:async';

import 'package:cosmo_kundali/controllers/home_controller.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:cosmo_kundali/values/user_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/other_controller.dart';
import '../services/services.dart';
import '../values/get_tags.dart';
import '../values/routes.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  late Timer _timer;

  final OtherController otherController =
      Get.put(OtherController(), tag: GetTags.otherTag);
  final HomeController homeController =
      Get.put(HomeController(), tag: GetTags.homeTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigate();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: .9 + .1 * t, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Glass(
                radius: 40,
                padding: const EdgeInsets.all(26),
                child: Image.asset(AppImages.logo, height: 120),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset('assets/images/ck_logo.png'),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: CkColors.orangeSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigate() async {
    bool isLoggedIn = await UserData.getLoggedIn();

    debugPrint('IS Logged in ${isLoggedIn}');

    _timer = Timer(const Duration(seconds: 4), () {
      if (isLoggedIn) {
        Services.offAll(AppRoutes.clientDetailView);
      } else {
        Services.offAll(AppRoutes.signInView);
      }
    });
  }
}
