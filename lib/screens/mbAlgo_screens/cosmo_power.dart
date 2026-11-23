import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/mbAlgo_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../models/cosmo_power_report.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class CosmoPower extends StatefulWidget {
  const CosmoPower({super.key});

  @override
  State<CosmoPower> createState() => _CosmoPowerState();
}

final MbalgoController _mbAlgoController = Get.find(tag: GetTags.mbAlgoTag);

class _CosmoPowerState extends State<CosmoPower> {
  CosmoPowerList? items;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        _mbAlgoController.fetchCosmoPowerReport();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
        body: Container(
      padding: EdgeInsets.all(15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "cosmo_power_9_month".tr,
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
                    Obx(
                      () => Text(DateFormat('MMM yyyy')
                          .format(_mbAlgoController.selectedDate.value)
                          .toString()),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () async {
                          // mbalgoController.selectDate(context);
                          DateTime? selected = await showMonthPicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1970),
                              lastDate: DateTime(2100));

                          // cosmoReportController.currentDate.value = selected;
                          // cosmoReportController.getMonthlyData(
                          // date: monthName,
                          // context: context,
                          // );
                          if (selected != null &&
                              selected !=
                                  _mbAlgoController.selectedDate.value) {
                            _mbAlgoController.selectedDate.value = selected;
                            _mbAlgoController.fetchCosmoPowerReport();
                          }
                        },
                        icon: const Icon(Icons.calendar_month))
                  ],
                ),
              ),
              Container(
                width: 45.w,
                height: 5.h,
                child: MainButton(
                    onTap: () {
                      _mbAlgoController.fetchCosmoPowerReport();
                    },
                    radius: 14.sp,
                    text: "get_details".tr),
              ),
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          Obx(
            () => Container(
              padding: EdgeInsets.all(15.sp),
              height: 37.h,
              width: MediaQuery.of(context).size.width,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.sp)),
              child: _mbAlgoController.isLoading.value ||
                      _mbAlgoController
                              .cosmoPowerReportDailyList.value.length ==
                          0
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width:
                            _mbAlgoController.cosmoPowerReportDailyList.length *
                                50,
                        child: BarChart(
                          BarChartData(
                            barTouchData: BarTouchData(
                                allowTouchBarBackDraw: true,
                                touchTooltipData: BarTouchTooltipData(
                                    direction: TooltipDirection.bottom)),
                            alignment: BarChartAlignment.spaceEvenly,
                            maxY: 100,
                            minY: 0,
                            titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      final index = value.toInt();
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 8,
                                        child: Text(
                                          _mbAlgoController
                                              .cosmoPowerReportDailyList[index]
                                              .date
                                              .toString(),
                                          // Handle out of bounds
                                          style: const TextStyle(
                                            color: CkColors.text,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    },
                                    reservedSize: 42,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 10,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          color: CkColors.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: const AxisTitles(),
                                topTitles: const AxisTitles()),
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: true,
                              horizontalInterval: 30,
                              getDrawingHorizontalLine: (value) {
                                return const FlLine(
                                  color: CkColors.textMuted,
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return const FlLine(
                                  color: CkColors.textMuted,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: CkColors.text, width: 1),
                            ),
                            barGroups: _mbAlgoController
                                .cosmoPowerReportDailyList
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              double value = entry.value.value ?? 0;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: value,
                                    color: Services.cosmoGraphColor(value),
                                    width: 30,
                                    borderRadius: BorderRadius.zero,
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: value,
                                      color: CkColors.text,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: SfSparkBarChart(
              //    labelDisplayMode: SparkChartLabelDisplayMode.all,
              //    labelStyle: TextStyle(fontSize: 11.sp,fontWeight: FontWeight.w600,height: 1.sp),
              //    data: mbalgoController.cosmoPowerReportDailyList.map((item) {
              //      items = item;
              //      return item.value ?? 0;
              //    },).toList(),
              //    color:Services.cosmoGraphColor(items!.value!),),
              // )
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 5.h,
                width: 45.w,
                decoration: BoxDecoration(
                    border: Border.all(color: CkColors.text.withOpacity(0.50)),
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
                      width: 4.w,
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
                    border: Border.all(color: CkColors.text.withOpacity(0.50)),
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
                    border: Border.all(color: CkColors.text.withOpacity(0.50)),
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
                      width: 4.w,
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
      ),
    ));
  }
}
