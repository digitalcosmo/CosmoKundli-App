import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:cosmo_kundali/custom_widgets/main_button.dart';
import 'package:cosmo_kundali/custom_widgets/main_text_filed.dart';
import 'package:cosmo_kundali/values/app_messages.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';
import '../../controllers/profile_controller.dart';
import '../../services/services.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

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
                "change_password".tr,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
              )
            ],
          ),
          SizedBox(
            height: 25.h,
          ),
          Form(
              key: profileController.changePasswordFormKey,
              child: Column(
                children: [
                  // Pinput(
                  //   length: 6,
                  //   onTap: () {
                  // },),
                  SizedBox(
                    height: 2.h,
                  ),
                  MainTextField(
                    hintText: '',
                    lableText: 'enter_old_password'.tr,
                    lableTextStyle: TextStyle(fontSize: 15.sp),
                    textEditingController: profileController.oldPass,
                    validator: Validatorless.required(
                        AppMessages.oldPassRequiredValidation),
                  ),
                  GestureDetector(
                    onTap: () {
                      Services.to(AppRoutes.resetPassword);
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "forgot_password".tr,
                        style: TextStyle(
                            fontSize: 15.sp, color: AppColors.smallText),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  MainTextField(
                    hintText: '',
                    lableText: "enter_new_password".tr,
                    lableTextStyle: TextStyle(fontSize: 15.sp),
                    textEditingController: profileController.newPass,
                    validator: Validatorless.required(
                        AppMessages.newPassRequiredValidation),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  MainTextField(
                    hintText: '',
                    lableText: "re_enter_password".tr,
                    lableTextStyle: TextStyle(fontSize: 15.sp),
                    textEditingController: profileController.newPass1,
                    validator: Validatorless.required(
                        AppMessages.confPassRequiredValidation),
                  ),
                ],
              )),
          SizedBox(
            height: 5.h,
          ),
          MainButton(
            text: "save".tr,
            width: 40,
            radius: 10,
            onTap: () async {
              bool isValidated = await Services.validateForm(
                  profileController.changePasswordFormKey);

              if (isValidated) {
                if (profileController.newPass.text ==
                    profileController.newPass1.text) {

                 profileController.updatePassword(context);
                } else {
                  Services.snackBarError(
                      context, AppMessages.passwordNotMatchValidation);
                }
              }
            },
          )
        ],
      ),
    ));
  }
}
