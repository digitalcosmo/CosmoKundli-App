import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/custom_widgets/custom_bar_graph.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/mbAlgo_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../services/services.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class StarPowerReport extends StatefulWidget {
  const StarPowerReport({super.key});

  @override
  State<StarPowerReport> createState() => _StarPowerReportState();
}

class _StarPowerReportState extends State<StarPowerReport> {
  final MbalgoController _mbAlgoController =
      Get.put(MbalgoController(), tag: GetTags.mbAlgoTag);

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        _mbAlgoController
            .fetchStarPowerReport(AppConstants.iconList[0]['name'].toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
        body: SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.all(15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "star_power_report".tr + " (In Percentage)",
                style: TextStyle(
                    color: AppColors.headerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 17.sp),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                "select_week".tr,
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
                    padding: EdgeInsets.all(2.sp),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: CkColors.text.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(10.sp)),
                    child: Row(
                      children: [
                        Obx(
                          () => Text(
                            " ${"week".tr},${_mbAlgoController.getWeekInfo(
                                    _mbAlgoController.selectedDate.value)['formattedWeekOuter']}",
                          ),
                        ),
                        IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _mbAlgoController.selectWeek(context);
                            },
                            icon: const Icon(
                              Icons.calendar_month,
                            ))
                      ],
                    ),
                  ),
                  Container(
                    width: 45.w,
                    height: 5.h,
                    child: MainButton(
                        onTap: () {
                          _mbAlgoController.fetchStarPowerReport(AppConstants
                              .iconList[_mbAlgoController
                                  .selectedIconIndex.value]['name']
                              .toString());
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
                height: 9.h,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return SizedBox(width: 2.w);
                    },
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.iconList.length,
                    itemBuilder: (context, index) {
                      return Obx(
                        () => GestureDetector(
                          onTap: () {
                            _mbAlgoController.selectIcon(index);

                            _mbAlgoController.fetchStarPowerReport(AppConstants
                                .iconList[index]['name']
                                .toString());
                          },
                          child: Container(
                            height: 9.h,
                            width: 19.w,
                            decoration: BoxDecoration(
                              gradient:
                                  _mbAlgoController.selectedIconIndex.value ==
                                          index
                                      ? const LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.button_gradientColor1,
                                            AppColors.button_gradientColor2
                                          ],
                                        )
                                      : null,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  _mbAlgoController.selectedIconIndex.value ==
                                          index
                                      ? null
                                      : Border.all(color: CkColors.textMuted),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppConstants.iconList[index]['icon']!,
                                  height: 2.h,
                                  width: 10.w,
                                  color: _mbAlgoController
                                              .selectedIconIndex.value ==
                                          index
                                      ? Colors.white
                                      : CkColors.textMuted,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  AppConstants.iconList[index]['name']!,
                                  style: TextStyle(
                                    color: _mbAlgoController
                                                .selectedIconIndex.value ==
                                            index
                                        ? Colors.white
                                        : CkColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 2.h,
              ),
              // Obx(
              //   () => SizedBox(
              //     height: 40.h,
              //     child: _mbAlgoController.isLoading.value ||
              //             _mbAlgoController.starPowerReportList.value.length ==
              //                 0
              //         ? const Center(child: CircularProgressIndicator())
              //         : Container(
              //             width:
              //                 _mbAlgoController.starPowerReportList.length * 50,
              //             child: BarChart(
              //               BarChartData(
              //                 alignment: BarChartAlignment.spaceEvenly,
              //                 maxY: 100,
              //                 minY: 0,
              //                 titlesData: FlTitlesData(
              //                   show: true,
              //                   bottomTitles: AxisTitles(
              //                     sideTitles: SideTitles(
              //                       showTitles: true,
              //                       getTitlesWidget:
              //                           (double value, TitleMeta meta) {
              //                         final index = value.toInt();
              //                         if (index <
              //                             _mbAlgoController
              //                                 .starPowerReportList.length) {
              //                           final graphModel = _mbAlgoController
              //                               .starPowerReportList[index];
              //
              //                           Map<String, String> dayAbbreviations = {
              //                             'Monday': 'Mon',
              //                             'Moday': 'Mon',
              //                             'Tuesday': 'Tue',
              //                             'Wednesday': 'Wed',
              //                             'Thursday': 'Thu',
              //                             'Friday': 'Fri',
              //                             'Saturday': 'Sat',
              //                             'Sunday': 'Sun',
              //                           };
              //
              //                           // Get the abbreviation of the day
              //                           String dayAbbr = dayAbbreviations[
              //                                   graphModel['day']] ??
              //                               graphModel['day'];
              //                           return SideTitleWidget(
              //                             axisSide: meta.axisSide,
              //                             space: 8,
              //                             child: SizedBox(
              //                               width: 7.w,
              //                               child: Text(
              //                                 dayAbbr,
              //                                 softWrap: true,
              //                                 style: TextStyle(
              //                                   color: CkColors.text,
              //                                   fontWeight: FontWeight.bold,
              //                                   fontSize: 12.sp,
              //                                 ),
              //                               ),
              //                             ),
              //                           );
              //                         } else {
              //                           return const SizedBox
              //                               .shrink(); // Prevent out of bounds error
              //                         }
              //                       },
              //                       reservedSize: 42,
              //                     ),
              //                   ),
              //                   leftTitles: AxisTitles(
              //                     sideTitles: SideTitles(
              //                       showTitles: true,
              //                       interval: 10,
              //                       getTitlesWidget:
              //                           (double value, TitleMeta meta) {
              //                         return Text(
              //                           value.toInt().toString(),
              //                           style: const TextStyle(
              //                             color: CkColors.text,
              //                             fontWeight: FontWeight.bold,
              //                             fontSize: 12,
              //                           ),
              //                         );
              //                       },
              //                       reservedSize: 40,
              //                     ),
              //                   ),
              //                   rightTitles: const AxisTitles(),
              //                   topTitles: const AxisTitles(),
              //                 ),
              //                 gridData: FlGridData(
              //                   show: true,
              //                   drawHorizontalLine: true,
              //                   drawVerticalLine: true,
              //                   horizontalInterval: 30,
              //                   getDrawingHorizontalLine: (value) {
              //                     return const FlLine(
              //                       color: CkColors.textMuted,
              //                       strokeWidth: 1,
              //                     );
              //                   },
              //                   getDrawingVerticalLine: (value) {
              //                     return const FlLine(
              //                       color: CkColors.textMuted,
              //                       strokeWidth: 1,
              //                     );
              //                   },
              //                 ),
              //                 borderData: FlBorderData(
              //                   show: true,
              //                   border:
              //                       Border.all(color: CkColors.text, width: 1),
              //                 ),
              //                 barGroups: _mbAlgoController.starPowerReportList
              //                     .asMap()
              //                     .entries
              //                     .map((entry) {
              //                   int index = entry.key;
              //                   double value = entry.value['value'] ??
              //                       0; // Access 'value' correctly
              //                   return BarChartGroupData(
              //                     x: index,
              //                     barRods: [
              //                       BarChartRodData(
              //                         toY: value,
              //                         color: Services.cosmoGraphColor(value),
              //                         width: 30,
              //                         borderRadius: BorderRadius.zero,
              //                         backDrawRodData:
              //                             BackgroundBarChartRodData(
              //                           show: true,
              //                           toY: value,
              //                           color: CkColors.text,
              //                         ),
              //                       ),
              //                     ],
              //                   );
              //                 }).toList(),
              //               ),
              //             ),
              //           ),
              //   ),
              // ),
              Obx(
                () => SizedBox(
                  height: 40.h,
                  width: double.infinity,
                  child: _mbAlgoController.isLoading.value ||
                          _mbAlgoController.starPowerReportList.value.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width:
                              _mbAlgoController.starPowerReportList.length * 50,
                          child: Builder(builder: (context) {
                            List<double> barPercentages = _mbAlgoController
                                .starPowerReportList
                                .map((report) => report['value'] as double)
                                .toList();

                            List<Color> barColors = _mbAlgoController
                                .starPowerReportList
                                .map((report) => Services.cosmoGraphColor(
                                    report['value'] as double))
                                .toList();

                            return CustomBarGraph(
                              barColors: barColors,
                              barPercentages: barPercentages,
                              labels: [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ],
                            );
                          }),
                        ),
                ),
              ),

              SizedBox(
                height: 2.h,
              ),
              // Container(
              //   child: MainGraph(graphModel: AppConstants.weekDays,)
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 5.h,
                    width: 45.w,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: CkColors.text.withOpacity(0.50)),
                        borderRadius: BorderRadius.circular(10.sp)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Opportunity".tr,
                          style: TextStyle(
                              color: CkColors.text.withOpacity(0.70),
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 3.w,
                        ),
                        Container(
                          height: 2.h,
                          width: 2.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.sp),
                              color: AppColors.pastle),
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        Container(
                          height: 2.h,
                          width: 2.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.sp),
                              color: AppColors.dark_blue),
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        Container(
                          height: 2.h,
                          width: 2.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.sp),
                              color: AppColors.sea_blue),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 5.h,
                    width: 45.w,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: CkColors.text.withOpacity(0.50)),
                        borderRadius: BorderRadius.circular(10.sp)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "threat".tr,
                          style: TextStyle(
                              color: CkColors.text.withOpacity(0.70),
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Container(
                          height: 2.h,
                          width: 2.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.sp),
                              color: AppColors.yellow),
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        Container(
                          height: 2.h,
                          width: 2.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.sp),
                              color: AppColors.dark_yellow),
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        Container(
                          height: 2.h,
                          width: 2.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.sp),
                              color: AppColors.red),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 5.h,
                    width: 30.w,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: CkColors.text.withOpacity(0.50)),
                        borderRadius: BorderRadius.circular(12.sp)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "moderate".tr,
                          style: TextStyle(
                              color: CkColors.text.withOpacity(0.70),
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 3.w,
                        ),
                        Container(
                          height: 2.h,
                          width: 2.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.sp),
                              color: AppColors.dark_grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
    ));
  }
}

final List<ChartData> data = [
  ChartData(xval: 1, yval: 190),
  ChartData(xval: 2, yval: 165),
  ChartData(xval: 3, yval: 158),
  ChartData(xval: 4, yval: 175),
  ChartData(xval: 5, yval: 200),
  ChartData(xval: 6, yval: 180),
];

class ChartData {
  ChartData({required this.xval, required this.yval});

  final double xval;
  final double yval;
}
