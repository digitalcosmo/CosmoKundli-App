import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:io';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';
import '../../controllers/profile_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../custom_widgets/main_text_filed.dart';
import '../../services/services.dart';
import '../../values/get_tags.dart';
import '../../values/app_messages.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DisplayDetail extends StatefulWidget {
  DisplayDetail({super.key});

  @override
  State<DisplayDetail> createState() => _DisplayDetailState();
}

class _DisplayDetailState extends State<DisplayDetail> {
  final ProfileController profileController =
      Get.put(ProfileController(), tag: GetTags.profileTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.displayDetails();
  }

  @override
  Widget build(BuildContext context) {
    return MainBgframe(
        child: Container(
      padding: EdgeInsets.all(15.sp),
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
                "display_details".tr,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
              )
            ],
          ),
          SizedBox(
            height: 4.h,
          ),
          Obx(
            () => !profileController.isLoading.value
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: profileController.appDetailsFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 2.h,
                            ),
                            MainTextField(
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                    AppMessages.nameRequiredValidation),
                              ]),
                              hintText: ' ',
                              lableText: "display_name".tr,
                              textEditingController:
                                  profileController.displayName,
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
                              lableText: "display_msg".tr,
                              textEditingController:
                                  profileController.displayMsg,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            MainTextField(
                              // validator: Validatorless.multiple([
                              //   Validatorless.required(
                              //       AppMessages.displayAddress),
                              // ]),
                              hintText: '',
                              lableText: "display_address".tr,
                              textEditingController:
                                  profileController.displayAddress,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            MainTextField(
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                    AppMessages.nameRequiredValidation),
                              ]),
                              lableText: "display_email".tr,
                              hintText: '',
                              lableTextStyle: TextStyle(
                                fontSize: 15.sp,
                              ),
                              textEditingController:
                                  profileController.displayEmail,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            MainTextField(
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                    AppMessages.numberValidation),
                                Validatorless.min(10, AppMessages.numberLengthValidation)
                              ]),
                              lableText: "display_num".tr,
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
                              hintText: '',
                              lableTextStyle: TextStyle(
                                fontSize: 15.sp,
                              ),
                              textEditingController:
                                  profileController.displayMobile,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Text('Front - Inner Page'),

                            Container(
                              height: 5.5.h,
                              width: 95.w,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14.sp)),
                                  border: Border.all(
                                      color: AppColors.headerColor
                                          .withOpacity(0.26))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Text(
                                      "choose_file".tr,
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          color:
                                              CkColors.text.withOpacity(0.70)),
                                    ),
                                    onTap: () async {
                                      profileController
                                              .selectedFrontFile.value =
                                          (await profileController.pickFile(
                                              context,
                                              profileController
                                                  .selectedFrontImage.value))!;
                                      debugPrint(profileController
                                          .selectedFrontFile.value?.path);
                                    },
                                  ),
                                  Image.asset(AppImages.divider),
                                  Obx(
                                    () => SizedBox(
                                      width: 27.w,
                                      child: Text(
                                        profileController
                                                    .selectedFrontFile.value !=
                                                null
                                            ? profileController
                                                .selectedFrontFile.value
                                                .toString()
                                            : "no_file_choosen".tr,
                                        softWrap: true,
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            overflow: TextOverflow.ellipsis,
                                            color:
                                                CkColors.text.withOpacity(0.70)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                "upload_formats".tr,
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: CkColors.text.withOpacity(0.50)),
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Text('Back - Inner Page'),

                            Container(
                              height: 5.5.h,
                              width: 95.w,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14.sp)),
                                  border: Border.all(
                                      color: AppColors.headerColor
                                          .withOpacity(0.26))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Text(
                                      "choose_file".tr,
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          color:
                                              CkColors.text.withOpacity(0.70)),
                                    ),
                                    onTap: () async {
                                      profileController.selectedBackFile.value =
                                          (await profileController.pickFile(
                                              context,
                                              profileController
                                                  .selectedBackImage.value))!;

                                      debugPrint(profileController
                                          .selectedBackFile.value?.path);
                                    },
                                  ),
                                  Image.asset(AppImages.divider),
                                  Obx(
                                    () => SizedBox(
                                      width: 27.w,
                                      child: Text(
                                        profileController
                                                    .selectedBackFile.value !=
                                                null
                                            ? profileController
                                                .selectedBackFile.value
                                                .toString()
                                            : "no_file_choosen".tr,
                                        softWrap: true,
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            overflow: TextOverflow.ellipsis,
                                            color:
                                                CkColors.text.withOpacity(0.70)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                "upload_formats".tr,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text('Front - Inner Page'),
                                    Obx(
                                      () => Container(
                                        height: 20.h,
                                        width: 40.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: AppColors.mainColor),
                                        ),
                                        child: profileController
                                                    .selectedFrontFile.value ==
                                                null
                                            ? CachedNetworkImage(
                                                imageUrl: profileController
                                                    .selectedFrontImage.value)
                                            : Image.file(File(profileController
                                                .selectedFrontFile.value!.path)),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Back - Inner Page'),


                                    Obx(
                                      () => Container(
                                        height: 20.h,
                                        width: 40.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: AppColors.mainColor),
                                        ),
                                        child: profileController
                                                    .selectedBackFile.value ==
                                                null
                                            ? CachedNetworkImage(
                                                imageUrl: profileController
                                                    .selectedBackImage.value)
                                            : Image.file(File(profileController
                                                .selectedBackFile.value!.path)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Center(
                              child: MainButton(
                                width: 40,
                                radius: 15.sp,
                                text: "save".tr,
                                onTap: () async {
                                  bool isValidated =
                                      await Services.validateForm(
                                          profileController.appDetailsFormKey);

                                  if (isValidated) {
                                    await profileController
                                        .updateDisplayDetails(context);

                                    if (profileController
                                            .selectedFrontFile.value !=
                                        null) {
                                      await profileController
                                          .updateFrontImage(context);
                                    }

                                    if (profileController
                                            .selectedBackFile.value !=
                                        null) {
                                      await profileController
                                          .updateBckImage(context);
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          )
        ],
      ),
    ));
  }
}
//Image.network(profileController.displayDetail?.backImg.toString() ??
//'https://images.pexels.com/photos/56866/garden-rose-red-pink-56866.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
