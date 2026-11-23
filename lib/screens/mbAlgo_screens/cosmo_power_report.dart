import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/mbAlgo_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class CosmoPowerReport extends StatelessWidget {
  CosmoPowerReport({super.key});

  final MbalgoController mbalgoController =
      Get.put(MbalgoController(), tag: GetTags.mbAlgoTag);

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Container(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "cosmo_power_report".tr,
              style: TextStyle(
                  color: AppColors.headerColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 17.sp),
            ),
            SizedBox(
              height: 2.h,
            ),
            Text(
              "select_month".tr,
              style: TextStyle(fontSize: 15.sp, color: CkColors.textSecondary),
            ),
            SizedBox(
              height: 1.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 45.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                      border: Border.all(color: CkColors.text.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(10.sp)),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 2.h,
                      ),
                      Obx(() => Text(
                            DateFormat('MMM yyyy').format(mbalgoController.selectedDate.value).toString(),
                          )),
                      const Spacer(),
                      IconButton(
                          onPressed: () =>
                              mbalgoController.selectMonth(context),
                          icon: const Icon(Icons.calendar_month))
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: 45.w,
                    height: 5.h,
                    child: MainButton(radius: 14.sp, text: "get_details".tr),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 7.h,
                width: 70.w,
                decoration: BoxDecoration(
                    border: Border.all(color: CkColors.text.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(15.sp)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "download".tr,
                          style: const TextStyle(
                              color: CkColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "3_months_report".tr,
                          style: const TextStyle(
                              color: CkColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    // Spacer(),
                    GestureDetector(
                        onTap: () {
                          mbalgoController.generate3MonthReport(context);
                        },
                        child: Image.asset(AppImages.download))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 7.h,
                width: 70.w,
                decoration: BoxDecoration(
                    border: Border.all(color: CkColors.text.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(15.sp)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "download".tr,
                          style: const TextStyle(
                              color: CkColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "6_months_report".tr,
                          style: const TextStyle(
                              color: CkColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    GestureDetector(
                        onTap: () async {
                          mbalgoController.generate6MonthReport(context);
                        },
                        child: Image.asset(AppImages.download))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 7.h,
                width: 70.w,
                decoration: BoxDecoration(
                    border: Border.all(color: CkColors.text.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(15.sp)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "download".tr,
                          style: const TextStyle(
                              color: CkColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "12_months_report".tr,
                          style: const TextStyle(
                              color: CkColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    // Spacer(),
                    GestureDetector(
                        onTap: () async {
                          mbalgoController.generate12MonthReport(context);
                        },
                        child: Image.asset(AppImages.download))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
