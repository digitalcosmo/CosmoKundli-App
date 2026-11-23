import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/values/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../controllers/mbAlgo_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../services/services.dart';
import '../../values/app_constants.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

final MbalgoController mbalgoController = Get.find(tag: GetTags.mbAlgoTag);

class GocharPrbhav extends StatefulWidget {
  GocharPrbhav({super.key});

  @override
  State<GocharPrbhav> createState() => _GocharPrbhavState();
}

class _GocharPrbhavState extends State<GocharPrbhav> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mbalgoController.gocharPrbhav("Lagan");
    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mbalgoController.selectedGrah.value =  "Lagan";
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Obx(
        () => SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "gochar_prabhav".tr,
                    style: TextStyle(
                        color: AppColors.headerColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 17.sp),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    "select_date".tr,
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
                            border: Border.all(
                                color: CkColors.text.withOpacity(0.25)),
                            borderRadius: BorderRadius.circular(10.sp)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 2.w,
                            ),
                            Obx(
                              () => Text(
                                  "${mbalgoController.selectedDate.value.day}-${mbalgoController.selectedDate.value.month}-${mbalgoController.selectedDate.value.year}"),
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  mbalgoController.selectDate(context);
                                },
                                icon: const Icon(Icons.calendar_month))
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 45.w,
                        height: 5.h,
                        child: MainButton(
                            onTap: () {
                              debugPrint(mbalgoController.selectedGrah.value);
                              mbalgoController.gocharPrbhav(mbalgoController.selectedGrah.value );
                            },
                            radius: 14.sp,
                            text: "get_details".tr),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    height: 5.h,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return SizedBox(width: 2.w);
                        },
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.gocharGrah.length,
                        itemBuilder: (context, index) {
                          return Obx(
                            () => GestureDetector(
                              onTap: () {
                                mbalgoController.selectedGrah.value = AppConstants.gocharGrah[index].toString();
                                mbalgoController.selectIcon(index);
                                mbalgoController.gocharPrbhav(
                                    AppConstants.gocharGrah[index].toString());
                              },
                              child: Container(
                                height: 5.h,
                                width: 19.w,
                                decoration: BoxDecoration(
                                  color: mbalgoController
                                              .selectedIconIndex.value ==
                                          index
                                      ? AppConstants.getBoxColor(AppConstants
                                          .gocharGrah[index]
                                          .toString())
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: mbalgoController
                                              .selectedIconIndex.value ==
                                          index
                                      ? null
                                      : Border.all(color: CkColors.textMuted),
                                ),
                                child: Center(
                                    child: Text(
                                  AppConstants.gocharGrah[index].toString(),
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: mbalgoController
                                                  .selectedIconIndex.value ==
                                              index
                                          ? Colors.white
                                          : CkColors.text),
                                )),
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  mbalgoController.isLoading.value ||
                          mbalgoController.gocharPrabhavList.value.isEmpty
                      ? SizedBox(
                          height: 40.h,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(10.sp),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              mbalgoController.gocharPrabhavList.value.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemBuilder: (context, index) {
                            var currentItem =
                                mbalgoController.gocharPrabhavList.value[index];

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 2.sp),
                                borderRadius: BorderRadius.circular(15.sp),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SfCircularChart(
                                      tooltipBehavior:
                                          TooltipBehavior(elevation: 2),
                                      palette: [
                                        Services.gocharColors(
                                            value: currentItem.value!),
                                        //CkColors.textMuted
                                      ],
                                      series: <CircularSeries>[
                                        DoughnutSeries<ChartData, String>(
                                          animationDuration: 0,
                                          pointColorMapper:
                                              (ChartData data, _) {
                                            return data.x == "Remaining"
                                                ? CkColors.textMuted
                                                : Services.gocharColors(
                                                    value: data.y);
                                          },
                                          dataSource: [
                                            ChartData(
                                                'Gochar', currentItem.value!),
                                            ChartData('Remaining',
                                                100 - currentItem.value!)
                                            // Remaining part of the chart
                                          ],
                                          xValueMapper: (ChartData data, _) =>
                                              data.x,
                                          yValueMapper: (ChartData data, _) =>
                                              data.y,
                                          groupTo: 1,
                                          groupMode:
                                              CircularChartGroupMode.point,
                                          enableTooltip: true,
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                                  isVisible: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text(currentItem.title.toString()),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Builder(
                                              builder: (context) {
                                                double remainingValue = ((100) -
                                                    currentItem.value!
                                                        .firstTwoDigits());

                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      (currentItem.value!
                                                              .firstTwoDigits())
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Services
                                                              .gocharTextColors(
                                                                  value: currentItem
                                                                      .value!),
                                                          fontSize: 12.sp),
                                                    ),
                                                    Text(
                                                      remainingValue
                                                          .firstTwoDigits()
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: CkColors.textMuted,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  0.6.sbh,
                                ],
                              ),
                            );
                          },
                        ),
                  SizedBox(height: 2.h),

                  // Footer for Legends
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LegendIndicator(title: "Shubh", color: AppColors.green),
                      LegendIndicator(
                          title: "Madhayam", color: Color(0xffbda502)),
                      LegendIndicator(title: "Ashubh", color: AppColors.red),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

// Helper widget for the legend at the bottom
class LegendIndicator extends StatelessWidget {
  final String title;
  final Color color;

  const LegendIndicator({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: CkColors.text.withOpacity(0.70),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 1.w),
        Container(
          height: 2.h,
          width: 2.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.sp),
            color: color,
          ),
        ),
      ],
    );
  }
}
