import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/kundali_controller.dart';
import 'package:cosmo_kundali/screens/kundali_screens/dasha_detail.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/services.dart';
import '../../values/get_tags.dart';

class Dasha extends StatefulWidget {
  const Dasha({
    super.key,
  });

  @override
  State<Dasha> createState() => _DashaState();
}

class _DashaState extends State<Dasha> {
  // final KundaliController kundaliController =
  //     Get.put(KundaliController(), tag: GetTags.kundaliTag);

  final KundaliController kundaliController = Get.find(tag: GetTags.kundaliTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    kundaliController.getDasha();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => kundaliController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : CkScaffold(
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "dasha_header".tr,
                        style: TextStyle(
                            color: AppColors.headerColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 17.sp),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        height: 10.h,
                        padding: EdgeInsets.all(7.sp),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.sp),
                            color: AppColors.skin_color.withOpacity(0.25),
                            border: Border.all(color: AppColors.skin_color)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "dasha_balance".tr,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15.sp),
                                  ),
                                  Text(
                                    ': ${kundaliController.dashaModel?.dashaBalanceGrah ?? 0}: ${kundaliController.dashaModel?.dashaBalance}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: CkColors.textSecondary,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "dasha_time".tr,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.sp),
                                  ),
                                  Text(
                                    ':${kundaliController.dashaModel?.subGrah1}-${kundaliController.dashaModel?.subGrah2}-${kundaliController.dashaModel?.subGrah3}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: CkColors.textSecondary),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      SizedBox(
                        height: 49.h,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => SizedBox(
                            height: 1.h,
                          ),
                          shrinkWrap: true,
                          itemCount:
                              kundaliController.dashaModel?.list?.length ?? 0,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(DashaDetail(
                                    index: kundaliController
                                        .dashaModel!.list![index].list!
                                        .indexOf(kundaliController.dashaModel!
                                            .list![index].list![index])));
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.sp),
                                height: 5.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.sp),
                                    color: Services.colorOfGrahs(
                                        type: AppConstants.grahs[index]
                                            .toString()),
                                    border: Border.all(
                                        color: Services.colorOfGrahs(
                                            type: AppConstants.grahs[index]
                                                .toString()))),
                                child: Row(
                                  children: [
                                    Text(
                                      kundaliController
                                          .dashaModel!.list![index].title
                                          .toString(),
                                      style: const TextStyle(
                                          color: CkColors.textSecondary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                        onTap: () {
                                          //AppConstants.grahs.indexOf(AppConstants.grahs[index])

                                          Get.to(DashaDetail(
                                              index: kundaliController
                                                  .dashaModel!
                                                  .list![index]
                                                  .list!
                                                  .indexOf(kundaliController
                                                      .dashaModel!
                                                      .list![index]
                                                      .list![index])));
                                        },
                                        child: Image.asset(AppImages.forward))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
