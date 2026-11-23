import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../services/services.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';

class ChangeLanguage extends StatelessWidget {
  const ChangeLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController =
        Get.put(ProfileController(), tag: GetTags.profileTag);
    final LanguageController languageController =
        Get.put(LanguageController(), tag: GetTags.langTag);

    return MainBgframe(
        child: Column(
      children: [
        SizedBox(
          height: 5.h,
        ),
        Row(
          children: [
            GestureDetector(
                onTap: () {
                  Services.back();
                },
                child: Image.asset(
                  AppImages.previousGradient,
                  width: 5.w,
                  height: 5.h,
                )),
            SizedBox(
              width: 2.w,
            ),
            Text(
              "change_language".tr,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(
          height: 30.h,
        ),
        Align(
            alignment: Alignment.topLeft,
            child: Text(
              "change_language".tr,
              style: TextStyle(fontSize: 16.sp),
            )),
        SizedBox(
          height: 2.h,
        ),
        Container(
          height: 5.5.h,
          width: 95.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(14.sp)),
              border:
                  Border.all(color: AppColors.headerColor.withOpacity(0.26))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "select_language".tr,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: CkColors.text,
                ),
              ),
              GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: CkColors.glassFillStrong,
                          contentPadding: EdgeInsets.all(5.sp),
                          content: Container(
                            padding: EdgeInsets.all(15.sp),
                            width: 10.w,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: AppConstants.langList.length,
                              separatorBuilder: (context, index) => Divider(),
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 3.h,
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.updateLocale(Locale(
                                              AppConstants.langList[index]
                                                      ["lan_code"]
                                                  .toString(),
                                              AppConstants.langList[index]
                                                      ["country_code"]
                                                  .toString()));

                                          profileController
                                                  .selectedLanguage.value =
                                              AppConstants.langList[index]
                                                      ["lan_name"]
                                                  .toString();
                                          // UserData.saveLanguage(AppConstants.langList[index]["name"].toString(),
                                          //     AppConstants.langList[index]["code"].toString());

                                          languageController.saveLocal(
                                              AppConstants.langList[index]
                                                      ["lan_code"]
                                                  .toString(),
                                              AppConstants.langList[index]
                                                      ["country_code"]
                                                  .toString());

                                          debugPrint(AppConstants
                                                  .langList[index]["lan_code"]
                                                  .toString() +
                                              AppConstants.langList[index]
                                                      ["country_code"]
                                                  .toString());
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          AppConstants.langList[index]
                                                  ["lan_name"]
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1.h,
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Image.asset(
                    AppImages.downward,
                  )),
              Image.asset(AppImages.divider),
              Obx(
                () => SizedBox(
                  width: 27.w,
                  child: Text(
                    profileController.selectedLanguage.value != null
                        ? profileController.selectedLanguage.value.toString()
                        : '',
                    softWrap: true,
                    style: TextStyle(
                        fontSize: 15.sp,
                        overflow: TextOverflow.ellipsis,
                        color: CkColors.text),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
