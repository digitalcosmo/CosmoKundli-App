import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:cosmo_kundali/custom_widgets/main_text_filed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';
import '../../controllers/profile_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../services/services.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';
import '../../values/app_messages.dart';

class AppDetails extends StatelessWidget {
  AppDetails({super.key});

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
                "app_details".tr,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
              )
            ],
          ),
          SizedBox(
            height: 4.h,
          ),
          Obx(
            () => !profileController.isLoading.value
                ? Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 2.h,
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        MainTextField(
                          validator: Validatorless.multiple([
                            Validatorless.required(
                                AppMessages.nameRequiredValidation),
                          ]),
                          hintText: '',
                          lableText: "app_code".tr,
                          isEnabled: false,
                          lableTextStyle: TextStyle(fontSize: 15.sp),
                          textEditingController: profileController.appCode,
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        MainTextField(
                          validator: Validatorless.multiple([
                            Validatorless.required(
                                AppMessages.nameRequiredValidation),
                          ]),
                          lableText: "description".tr,
                          hintText: '',
                          maxLines: 3,
                          lableTextStyle: TextStyle(
                            fontSize: 15.sp,
                          ),
                          textEditingController: profileController.appDesc,
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Text(
                          "app_icon".tr,
                          style: TextStyle(
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Container(
                          height: 5.5.h,
                          width: 95.w,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14.sp)),
                              border: Border.all(
                                  color:
                                      AppColors.headerColor.withOpacity(0.26))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                child: Text(
                                  "choose_file".tr,
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      color: CkColors.text.withOpacity(0.70)),
                                ),
                                onTap: () async {
                                  profileController.selectedAppFile.value =
                                      (await profileController.pickFile(
                                          context,
                                          profileController
                                              .selectedAppImage.value))!;
                                },
                              ),
                              Image.asset(AppImages.divider),
                              Obx(
                                () => SizedBox(
                                  width: 27.w,
                                  child: Text(
                                    profileController.selectedFrontFile.value !=
                                            null
                                        ? profileController
                                            .selectedFrontFile.value
                                            .toString()
                                        : 'no_file_choosen'.tr,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        overflow: TextOverflow.ellipsis,
                                        color: CkColors.text.withOpacity(0.70)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            'upload_formats'.tr,
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: CkColors.text.withOpacity(0.50)),
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          children: [
                            Obx(
                              () => Container(
                                height: 20.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppColors.mainColor),
                                ),
                                child:
                                    profileController.selectedAppFile.value ==
                                            null
                                        ? CachedNetworkImage(
                                            imageUrl: profileController
                                                .selectedAppImage.value)
                                        : Image.file(File(profileController
                                            .selectedAppFile.value!.path)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Center(
                          child: MainButton(
                            width: 40,
                            radius: 15.sp,
                            text: 'save'.tr,
                            onTap: () async {
                              await profileController.updateAppDetail(context);

                              if (profileController.selectedAppFile.value !=
                                  null) {
                                await profileController.updateAppImage(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    ));
  }
}
