import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers/signIn_controller.dart';
import '../../controllers/home_controller.dart';
import '../../custom_widgets/main_bottom.dart';
import '../../values/get_tags.dart';

class ContainView extends StatefulWidget {
  RxInt index = 0.obs;

  ContainView({super.key, required this.index});

  @override
  State<ContainView> createState() => _ContainViewState();
}

class _ContainViewState extends State<ContainView> {
  Timer? _timer;

  final SignInController signInController =
      Get.put(SignInController(), tag: GetTags.signInTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      signInController.verifyDevice(context: context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController(),tag: GetTags.homeTag);

    return CkScaffold(
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          selectedIndex: homeController.currentPageIndex.value,
          onItemTapped: (index) {
            homeController.currentPageIndex.value = index;
            homeController.setPageIndex(index);
          },
          items: homeController.navItems,
        ),
      ),
      body: Obx(
        () => homeController
            .bottomPageWidgets[homeController.currentPageIndex.value],
      ),
    );
  }
}
