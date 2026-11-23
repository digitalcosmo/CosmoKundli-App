import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/auth_controllers/signUp_controller.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';

import '../../custom_widgets/main_button.dart';
import '../../custom_widgets/main_text_filed.dart';
import '../../values/app_messages.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';

final SignUnController signUpController =
    Get.put(SignUnController(), tag: GetTags.signUpTag);

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: SingleChildScrollView(
        child: Obx(
          () => Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: signUpController.registerFormKey,
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
                    "registration".tr,
                    style: TextStyle(
                        fontSize: 20.sp,
                        color: AppColors.fontHeaderColor,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  MainTextField(
                    validator: Validatorless.multiple([
                      Validatorless.required(
                          AppMessages.nameRequiredValidation),
                    ]),
                    lableText: "full_name".tr,
                    hintText: "Name".tr,
                    textEditingController: signUpController.nameController,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  // MainTextField(
                  //         validator: Validatorless.multiple([
                  //           Validatorless.required(
                  //               AppMessages.nameRequiredValidation),
                  //         ]),
                  //         lableText: "surname".tr,
                  //         hintText: "Surname".tr, textEditingController: signUpController.nameController,),
                  // SizedBox(height: 2.h,),
                  // MainTextField(
                  //   validator: Validatorless.multiple([
                  //     Validatorless.required(
                  //         AppMessages.nameRequiredValidation),
                  //   ]),
                  //   lableText: "WhatsApp Number".tr,
                  //   hintText: "WhatsApp Number".tr,
                  //   maxLength: 10,
                  //   keyboardType: TextInputType.phone,
                  //   textEditingController: signUpController.mobileController,),

                  IntlPhoneField(
                    disableLengthCheck: true,

                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.headerColor.withOpacity(0.26),
                        ),
                        borderRadius: BorderRadius.circular(14.sp),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.sp),
                      ),
                    ),
                    initialCountryCode: 'IN',
                    onSubmitted: (val) {
                      print(val);
                    },
                    keyboardType: TextInputType.phone,
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    // ],
                    textInputAction: TextInputAction.go,
                    controller: signUpController.mobileController,
                    onCountryChanged: (value) {
                      signUpController.selectedCountryCode.value =
                          "+${value.fullCountryCode}";
                      signUpController.numberLength.value = value.maxLength;
                    },
                    onChanged: (value) {},
                  ),
                  SizedBox(
                    height: 2.h,
                  ),

                  MainTextField(
                    lableText: "email".tr,
                    validator: Validatorless.multiple([
                      Validatorless.required(
                          AppMessages.emailRequiredValidation),
                      Validatorless.email(AppMessages.emailRequiredValidation),
                    ]),
                    hintText: "email".tr,
                    textEditingController: signUpController.emailController,
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
                    obscureText: signUpController.obscureText1.value,
                    hintText: "password".tr,
                    textEditingController: signUpController.passwordController,
                    suffix: IconButton(
                      icon: Icon(
                        signUpController.obscureText1.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: CkColors.textMuted,
                      ),
                      onPressed: signUpController.toggleObscureText,
                    ),
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  MainTextField(
                    onSubmitted: (p0) {
                      if (signUpController.passwordController.text !=
                          signUpController.passwordController1.text) {
                        Services.snackBarError(
                            context, "Password is not matched");
                      }
                    },
                    lableText: "re_enter_password".tr,
                    validator: Validatorless.multiple([
                      Validatorless.required(
                          AppMessages.passRequiredValidation),
                    ]),
                    obscureText: signUpController.obscureText2.value,
                    hintText: "re_enter_password".tr,
                    textEditingController: signUpController.passwordController1,
                    suffix: IconButton(
                      icon: Icon(
                        signUpController.obscureText2.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: CkColors.textMuted,
                      ),
                      onPressed: signUpController.toggleObscureText1,
                    ),
                  ),

                  SizedBox(
                    height: 2.h,
                  ),
                  // MainTextField(
                  //   lableText: "Location".tr,
                  //   validator: Validatorless.multiple([
                  //     Validatorless.required(
                  //         AppMessages.passRequiredValidation),
                  //   ]),
                  //   obscureText: signUpController.obscureText2.value,
                  //   hintText: "Location".tr,
                  //   textEditingController: signUpController.passwordController1,
                  //   suffix: IconButton(
                  //     icon: Icon(
                  //       signUpController.obscureText2.value ? Icons.visibility_off : Icons.visibility,
                  //       color: CkColors.textMuted,
                  //     ),
                  //     onPressed: signUpController.toggleObscureText1,
                  //   ),
                  // ),
                  // SizedBox(height: 1.h,),
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          value: signUpController.isTAndC.value,
                          onChanged: (value) =>
                              signUpController.setTAndC(value!),
                        ),
                      ),
                      Text(
                        "agree_terms".tr,
                        style: TextStyle(
                          color: AppColors.hintColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Center(
                      child: MainButton(
                    text: "sign_up".tr,
                    onTap: () async {
                      if (signUpController.isTAndC.value) {
                        bool isValidated = await Services.validateForm(
                            signUpController.registerFormKey);
                        if (isValidated) {
                          if (signUpController.passwordController.text ==
                              signUpController.passwordController1.text) {
                            signUpController.signUp(context: context);
                          } else {
                            Services.snackBarError(
                                context, "Password is not matched");
                          }
                        }
                      } else {
                        Services.snackBarError(
                            context, AppMessages.tAndCValidation);
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
                        "already_have_account".tr,
                        style: const TextStyle(color: CkColors.textMuted),
                      ),
                      GestureDetector(
                          onTap: () {
                            Services.offAll(AppRoutes.signInView);
                          },
                          child: Text(
                            "sign_in".tr,
                            style: const TextStyle(
                                color: AppColors.fontHeaderColor),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
