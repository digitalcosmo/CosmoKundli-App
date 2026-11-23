import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:async';

import 'package:cosmo_kundali/controllers/auth_controllers/signIn_controller.dart';
import 'package:cosmo_kundali/custom_widgets/main_tabBar.dart';
import 'package:cosmo_kundali/screens/home/existing_clients.dart';
import 'package:cosmo_kundali/screens/home/new_clients.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../values/get_tags.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Timer? _timer;

  final SignInController signInController =
      Get.put(SignInController(), tag: GetTags.signInTag);

  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      signInController.verifyDevice(context: context);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
        child: Column(
          children: [
            SizedBox(
              height: 2.h,
            ),
            Expanded(
              child: MainTabBar(tabItems: [
                TabItem(text: "new_client".tr, content: NewClients()),
                TabItem(
                    text: "existing_clients".tr, content: ExistingClients()),
              ], controller: tabController),
            )
          ],
        ),
      ),
    );
  }
}
