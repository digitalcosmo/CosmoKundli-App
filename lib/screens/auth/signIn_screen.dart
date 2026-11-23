
import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:cosmo_kundali/values/tr_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';
import '../../controllers/auth_controllers/signIn_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../custom_widgets/main_loader.dart';
import '../../custom_widgets/main_text_filed.dart';
import '../../values/get_tags.dart';
import '../../values/app_messages.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});


  @override
  Widget build(BuildContext context) {

    final SignInController signInController = Get.put(SignInController(),tag: GetTags.signInTag);


    return CkScaffold(
      body: Obx(
        () => MainLoader(
          isLoading: signInController.isLoading.value,
          child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: signInController.loginFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 7.h,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            AppImages.logo,
                            height: 20.h,
                          )),
                      SizedBox(
                        height: 4.h,
                      ),
                      Text(
                        "login".tr,
                        style: TextStyle(
                            fontSize: 20.sp,
                            color: AppColors.fontHeaderColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      MainTextField(
                        lableText: TrStrings.username,
                        validator: Validatorless.multiple([
                          Validatorless.email(AppMessages.emailValidation),
                          Validatorless.required(
                              AppMessages.emailRequiredValidation),
                        ]),
                        hintText: TrStrings.email,
                        textEditingController: signInController.emailController,
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      MainTextField(
                        lableText: "password".tr,
                        validator: Validatorless.multiple([
                          Validatorless.required(
                              AppMessages.passRequiredValidation),
                        ]),
                        obscureText: signInController.obscureText.value,
                        hintText: TrStrings.password,
                        textEditingController:
                            signInController.passwordController,
                        suffix: IconButton(
                          icon: Icon(
                            signInController.obscureText.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: CkColors.textMuted,
                          ),
                          onPressed: signInController.toggleObscureText,
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          Services.to(AppRoutes.resetPassword);
                        },
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'forgot_password'.tr,
                            style:
                                const TextStyle(color: AppColors.fontHeaderColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Center(
                          child: MainButton(
                        text: "sign_in".tr,
                        onTap: () async {
                          bool isValidated = await Services.validateForm(
                              signInController.loginFormKey);
                          if (isValidated) {
                            signInController.login(context: context);
                            // Services.offAll(AppRoutes.signUpView);
                          }
                        },
                      )),
                      SizedBox(
                        height: 1.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "new_one".tr,
                            style: const TextStyle(color: CkColors.textMuted),
                          ),
                          SizedBox(
                            width: 1.w,
                          ),
                          GestureDetector(
                              onTap: () async {
                                Services.offAll(AppRoutes.signUpView);
                              },
                              child: Text(
                                "sign_up".tr,
                                style: const TextStyle(
                                    color: AppColors.fontHeaderColor),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
