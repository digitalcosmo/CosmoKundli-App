import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:cosmo_kundali/custom_widgets/main_button.dart';
import 'package:cosmo_kundali/custom_widgets/main_text_filed.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/profile_controller.dart';
import '../../services/services.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';

class ResetPassword extends StatelessWidget {
   ResetPassword({super.key});

  final ProfileController profileController =
  Get.put(ProfileController(), tag: GetTags.profileTag);


  @override
  Widget build(BuildContext context) {
    return MainBgframe(
        child: SingleChildScrollView(
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
                "reset_password".tr,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
              )
            ],
          ),
          SizedBox(
            height: 25.h,
          ),
          Image.asset(
            AppImages.lock,
            height: 5.h,
            width: 5.w,
          ),
          Text(
            "reset_password".tr,
            style: TextStyle(
                color: AppColors.headerColor,
                fontSize: 17.sp,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 1.h,
          ),
          Text(
            "reset_text1".tr,
            style:
                TextStyle(fontSize: 13.sp, color: CkColors.text.withOpacity(0.50)),
          ),
          SizedBox(
            height: 5.h,
          ),
          MainTextField(
            hintText: '',
            textEditingController: profileController.resetEmailController,
            lableText: "registred_email".tr,
            lableTextStyle: TextStyle(fontSize: 15.sp),
          ),
          SizedBox(
            height: 10.h,
          ),
          Obx(
            ()=> MainButton(
              isLoading: profileController.isLoading.value,
              text: "next".tr,
              width: 35,
              radius: 10,
              onTap: () {
                if(profileController.resetEmailController.text != null){
                  debugPrint("DONE");
                  profileController.forgotPassword(context);
                }

                // showDialog(
                //   context: context,
                //   builder: (context) {
                //     return Container(
                //       height: 100.h,
                //       width: 100.w,
                //       child: AlertDialog(
                //         contentPadding: EdgeInsets.all(25.sp),
                //         alignment: Alignment.center,
                //         title: Align(
                //             alignment: Alignment.center,
                //             child: Text(
                //               "verify_link".tr,
                //               style: TextStyle(
                //                   fontSize: 17.sp,
                //                   fontWeight: FontWeight.w500,
                //                   color: AppColors.headerColor),
                //             )),
                //         content: Column(
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Text(
                //               "reset_text".tr,
                //               style: TextStyle(
                //                   fontSize: 13.sp,
                //                   color: CkColors.text.withOpacity(0.50)),
                //             ),
                //             SizedBox(
                //               height: 2.h,
                //             ),
                //             Row(
                //               children: [
                //                 SizedBox(
                //                   width: 10.w,
                //                 ),
                //                 TextButton(
                //                     onPressed: () {},
                //                     child: Text(
                //                       "didnt_get".tr,
                //                       style: TextStyle(
                //                           color: CkColors.text.withOpacity(0.50),
                //                           fontSize: 14.sp),
                //                     )),
                //                 TextButton(
                //                     onPressed: () {},
                //                     child: Text(
                //                       "send_it_again".tr,
                //                       style: TextStyle(
                //                           color: AppColors.headerColor,
                //                           fontSize: 14.sp),
                //                     )),
                //               ],
                //             ),
                //             SizedBox(
                //               height: 5.h,
                //             ),
                //             MainButton(
                //               text: "verify".tr,
                //               width: 40,
                //               radius: 10,
                //               onTap: () {
                //                 Services.to(AppRoutes.updatePassword);
                //               },
                //             )
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // );
              },
            ),
          )
                ],
              ),
        ));
  }
}
