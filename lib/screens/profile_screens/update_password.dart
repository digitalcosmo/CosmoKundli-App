import 'package:cosmo_kundali/controllers/profile_controller.dart';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:cosmo_kundali/custom_widgets/main_button.dart';
import 'package:cosmo_kundali/custom_widgets/main_text_filed.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/services.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';


class UpdatePassword extends StatelessWidget {
   UpdatePassword({super.key});


  final ProfileController profileController =
  Get.put(ProfileController(), tag: GetTags.profileTag);


  @override
  Widget build(BuildContext context) {
    return MainBgframe(
        child:
        Obx(
          ()=> SingleChildScrollView(
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
                      "update_password".tr,
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
                    )
                  ],
                ),
                SizedBox(
                  height: 25.h,
                ),
                profileController.isVisible.value?
                Column(
                    children:[Image.asset(AppImages.correct,height: 15.h,width: 15.w,),
                  SizedBox(height: 1.h,),
                  Text("password_updated".tr,style: TextStyle(fontSize: 17.sp,fontWeight: FontWeight.w600,
                  color: AppColors.headerColor),)
                ]):
                Column(
                  children: [
                    Image.asset(AppImages.lock,height: 5.h,width: 5.w,),
                    Text("update_password".tr,style: TextStyle(color: AppColors.headerColor,fontSize: 17.sp,
                        fontWeight: FontWeight.w500),),
                    SizedBox(
                      height: 3.h,
                    ),
            
                    Pinput(
                      controller: profileController.otpController,
                      length: 6,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    MainTextField(hintText: '', textEditingController: TextEditingController(),
                      lableText: "enter_new_password".tr,
                      lableTextStyle: TextStyle( fontSize: 15.sp),),
                    SizedBox(
                      height: 2.h,
                    ),
                    MainTextField(hintText: '', textEditingController: TextEditingController(),
                      lableText: "re_enter_password".tr,
                      lableTextStyle: TextStyle( fontSize: 15.sp),),
                    SizedBox(
                      height: 10.h,
                    ),
                    MainButton(text: "reset_password".tr,width: 40,radius: 10,
                      onTap: () {
                      profileController.isVisible.value = true;
                      profileController.resetPassword(context);
            
            
            
            
                      },),
                  ],
                )
              ],),
          ),
        ));
  }
}
