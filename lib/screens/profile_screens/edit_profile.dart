import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/profile_controller.dart';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';
import '../../controllers/clientdetail_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../custom_widgets/main_dropdown.dart';
import '../../custom_widgets/main_text_filed.dart';
import '../../services/services.dart';
import '../../values/app_constants.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';
import '../../values/app_messages.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  final ClientDetailController clientdetailController =
      Get.put(ClientDetailController(), tag: GetTags.clientDetailTag);

  final ProfileController profileController =
      Get.put(ProfileController(), tag: GetTags.profileTag);

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      resizeToAvoidBottomInset: true,
      body: MainBgframe(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(
                height: 5.h,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 12.sp),
                    child: GestureDetector(
                      onTap: () {
                        Services.back();
                      },
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            AppImages.previousGradient,
                            height: 6.h,
                            width: 6.w,
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 3.w,
                  ),
                  Text(
                    "edit_profile".tr,
                    style: TextStyle(
                        color: AppColors.smallText,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 27.sp,
                    backgroundImage: AssetImage(AppImages.dummyImage),
                  ),
                  // Positioned(
                  //     bottom: -10.sp,
                  //     right: 5.sp,
                  //     child: GestureDetector(
                  //       onTap: () {
                  //
                  //       },
                  //       child: Container(
                  //           height: 6.h,
                  //           width: 6.w,
                  //           decoration: const BoxDecoration(
                  //               color: Colors.white, shape: BoxShape.circle),
                  //           child: Center(
                  //               child: Image.asset(
                  //             AppImages.edit,
                  //             height: 4.h,
                  //             width: 4.w,
                  //             color: CkColors.textMuted,
                  //           ))),
                  //     ))
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                profileController.username.value,
                style: TextStyle(
                    color: AppColors.smallText,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                profileController.emailId.value,
                style: TextStyle(
                    color: AppColors.smallText.withOpacity(0.58),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                padding: EdgeInsets.all(10.sp),
                child: Form(
                  key: clientdetailController.clientDetailFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      // Text('Name',
                      //   style: TextStyle(
                      //       color: AppColors.smallText,
                      //       fontSize: 20.sp,
                      //       fontWeight: FontWeight.w600),),
                      MainTextField(
                        lableText: 'Name',
                        validator: Validatorless.multiple([
                          Validatorless.required(
                              AppMessages.nameRequiredValidation),
                        ]),
                        hintText: "full_name".tr,
                        textEditingController: profileController.name,
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        children: [

                          Container(
                            width: 45.w,
                            height: 7.h,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: CkColors.text.withOpacity(0.25)),
                                borderRadius: BorderRadius.circular(10.sp)),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 2.h,
                                ),
                                Obx(
                                  () => Text(profileController
                                      .selectedDate.value
                                      .toString()),
                                ),
                                const Spacer(),
                                IconButton(
                                    onPressed: () async {
                                      DateTime? picked = (await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                        initialEntryMode:
                                            DatePickerEntryMode.calendarOnly,
                                      ))!;
                                      if (picked != null) {
                                        profileController.selectedDate.value =
                                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                      }
                                      // if (selected != null && selected != mbalgoController.selectedDate.value) {
                                      //   mbalgoController.selectedDate.value = selected;
                                      // }
                                    },
                                    icon: const Icon(Icons.calendar_month))
                              ],
                            ),
                          ),

                          // Expanded(
                          //     child: Obx(
                          //   () => MainTextField(
                          //     validator: Validatorless.multiple([
                          //       Validatorless.required(
                          //           AppMessages.dateRequiredValidation),
                          //     ]),
                          //     hintText: Services.formatDate(
                          //         date: clientdetailController
                          //             .selectedDate.value),
                          //     textEditingController: profileController.selectedDate.value,
                          //     suffix: IconButton(
                          //       icon: const Icon(Icons.calendar_month),
                          //       onPressed: () async {
                          //         clientdetailController.selectedDate
                          //             .value = (await showDatePicker(
                          //           context: context,
                          //           initialDate: DateTime.now(),
                          //           firstDate: DateTime(1900),
                          //           lastDate: DateTime.now(),
                          //           initialEntryMode:
                          //               DatePickerEntryMode.calendarOnly,
                          //         ))!;
                          //         clientdetailController.updateStartDate(
                          //             clientdetailController
                          //                 .selectedDate.value
                          //                 .toString());
                          //       },
                          //     ),
                          //   ),
                          // )),
                          SizedBox(
                            width: 2.w,
                          ),

                          Expanded(
                            child: MainDropDown(

                              value:
                                  clientdetailController.selectedGender.value,
                              dropdownItems: AppConstants.genderList,
                              onChanged: (p0) {
                                clientdetailController.selectedGender.value =
                                    p0;
                                clientdetailController.genderController.text =
                                    clientdetailController.selectedGender.value;
                              },
                              dropdownValue: "Gender",

                              hintText: "gender".tr,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      MainTextField(
                        lableText: "Email",
                        validator: Validatorless.multiple([
                          Validatorless.required(
                              AppMessages.emailRequiredValidation),
                        ]),
                        hintText: "email".tr,
                        textEditingController:
                            profileController.emailController,
                        onTap: () {
                          _scrollToBottom();
                        },
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      MainTextField(
                        lableText: "Contact No",
                        validator: Validatorless.multiple([
                          Validatorless.required(
                              AppMessages.nameRequiredValidation),
                        ]),
                        hintText: "mobile_number".tr,
                        textEditingController: profileController.mobile,
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Center(
                        child: MainButton(
                          width: 40,
                          radius: 15.sp,
                          text: "save".tr,
                          onTap: () async {
                            bool isValidated = await Services.validateForm(
                                clientdetailController.clientDetailFormKey);
                            if (isValidated) {
                              profileController.updateProfile(context);
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
