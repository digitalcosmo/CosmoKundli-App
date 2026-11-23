import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:io';

import 'package:cosmo_kundali/controllers/profile_controller.dart';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/get_tags.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

RxList<Map<String, String>> profileList = <Map<String, String>>[
  {
    "name": "edit_profile",
    "icon": AppImages.profile_icon,
    "navigate": AppRoutes.editProfile
  },
  {
    "name": "display_details",
    "icon": AppImages.details,
    "navigate": AppRoutes.displayDetails
  },
  {
    "name": "app_details",
    "icon": AppImages.app_details,
    "navigate": AppRoutes.appDetails
  },
  if (!Platform.isIOS)
    {
      "name": "credit_transaction",
      "icon": AppImages.transaction,
      "navigate": AppRoutes.transactionHistory
    },
  {
    "name": "report_history",
    "icon": AppImages.history,
    "navigate": AppRoutes.reportHistory
  },
  {
    "name": "change_password",
    "icon": AppImages.change_password,
    "navigate": AppRoutes.changePassword
  },
  {
    "name": "change_language",
    "icon": AppImages.lang,
    "navigate": AppRoutes.changeLanguage
  },
  {
    "name": "delete_account",
    "icon": AppImages.delete_account,
    "navigate": AppRoutes.changeLanguage
  }
].obs;

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController =
      Get.put(ProfileController(), tag: GetTags.profileTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return MainBgframe(
      child: Obx(
        () => ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            FadeSlideIn(
              child: Glass(
                radius: 26,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: CkColors.cta,
                      ),
                      child: CircleAvatar(
                        radius: 27.sp,
                        backgroundImage: AssetImage(AppImages.dummyImage),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profileController.username.value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700, color: CkColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profileController.emailId.value,
                      style: const TextStyle(
                          color: CkColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(profileList.length, (index) {
              final item = profileList[index];
              final isDelete = item['name']! == 'delete_account';
              return FadeSlideIn(
                index: index + 1,
                child: GlassTile(
                  title: item['name']!.tr,
                  leading: Image.asset(item['icon'].toString(),
                      color: isDelete ? CkColors.red : CkColors.orangeSoft),
                  onTap: () {
                    if (isDelete) {
                      Services.showConfirmDialog(
                        context: context,
                        upperText: "Are you sure want to delete account?",
                        onPressYesButton: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          profileController.deactivateAccount(context);
                        },
                      );
                    } else {
                      Services.to(item['navigate'].toString());
                    }
                  },
                ),
              );
            }),
            const SizedBox(height: 14),
            Center(
              child: Pressable(
                onTap: () async {
                  Services.showConfirmDialog(
                      context: context,
                      upperText: 'Are you sure ?',
                      onPressYesButton: () async {
                        Navigator.pop(context);

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.clear();
                        Navigator.of(context, rootNavigator: true).pop();

                        Services.offAll(AppRoutes.splashView);
                      });
                },
                child: Glass(
                  radius: CkRadius.control,
                  tint: const Color(0x33EF4444),
                  stroke: const Color(0x66EF4444),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "log_out".tr,
                        style: const TextStyle(
                            color: CkColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.logout_rounded,
                          color: CkColors.text, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
