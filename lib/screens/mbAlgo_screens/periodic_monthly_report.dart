import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:cosmo_kundali/values/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/mbAlgo_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class PeriodicMonthlyReport extends StatefulWidget {
  const PeriodicMonthlyReport({super.key});

  @override
  State<PeriodicMonthlyReport> createState() => _PeriodicMonthlyReportState();
}

class _PeriodicMonthlyReportState extends State<PeriodicMonthlyReport> {
  final MbalgoController mbalgoController =
      Get.put(MbalgoController(), tag: GetTags.mbAlgoTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mbalgoController.fetchPeriodicMonthlyReport();
    });
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
                "periodic_monthly_report".tr,
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
                              .format(mbalgoController.selectedDate.value)
                              .toString()),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              mbalgoController.selectMonth(context).then((value) {
                                mbalgoController.fetchPeriodicMonthlyReport();
        
                              },);
                            } ,
                            icon: const Icon(Icons.calendar_month))
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      mbalgoController.fetchPeriodicMonthlyReport();
                    },
                    child: SizedBox(
                      width: 45.w,
                      height: 5.h,
                      child: MainButton(radius: 14.sp, text: "get_details".tr),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3.h,
              ),
              Obx(
                    () => Container(
                  padding: EdgeInsets.all(15.sp),
                  height: 48.h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.sp)
                  ),
                  child: mbalgoController.isLoading.value || mbalgoController.periodicMonthlyReportList.value.length == 0?
                  const Center(child:  CircularProgressIndicator()) :
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: mbalgoController.periodicMonthlyReportList.length * 65,
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                              allowTouchBarBackDraw: true,
                              touchTooltipData: BarTouchTooltipData(
        
        
                                  direction: TooltipDirection.bottom)
                          ),
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: 100,
                          minY: 0,
                          titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
        
                                      space: 5,
                                      child: Text(
                                        mbalgoController.periodicMonthlyReportList[index].value!.toDouble().toStringAsFixed(2) .toString(), // Handle out of bounds
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
        
                                  getTitlesWidget: (double value, TitleMeta meta) {
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
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 10,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    return Flexible(
                                      child: Text(
                                        mbalgoController.periodicMonthlyReportList[index].title.toString().firstTwoLetter(),
                                        style:  TextStyle(
                                          color: CkColors.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: true,
                            horizontalInterval:30,
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
                          barGroups: mbalgoController.periodicMonthlyReportList.asMap().entries.map((entry) {
                            int index = entry.key;
                            double value = entry.value.value ?? 0;
                            String title = entry.value.title ?? '';
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  color: AppConstants.periodicColor(title),
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
              // Obx(() => Padding(
              //       padding: EdgeInsets.only(right: 9.w),
              //       child: SizedBox(
              //         height: 20.h,
              //         width: 100.w,
              //         child: DChartBarCustom(
              //           showMeasureLine: true,
              //           valuePadding: EdgeInsets.all(10.sp),
              //           loadingDuration: const Duration(milliseconds: 1500),
              //           showLoading: false,
              //           valueAlign: Alignment.bottomCenter,
              //           showDomainLabel: true,
              //           spaceDomainLabeltoChart: 15,
              //           spaceMeasureLabeltoChart: 15,
              //           spaceMeasureLinetoChart: 15,
              //           spaceBetweenItem: 20,
              //           max: 100.0,
              //           domainLabelStyle: const TextStyle(
              //             fontSize: 16,
              //             color: Colors.white,
              //           ),
              //           showDomainLine: true,
              //           listData: List.generate(
              //             mbalgoController.periodicMonthlyReportList.value.length,
              //             (index) {
              //               final graphModel = mbalgoController
              //                   .periodicMonthlyReportList.value[index];
              //               return DChartBarDataCustom(
              //                 value: double.parse(graphModel.value.toString()),
              //                 label: graphModel.title.toString(),
              //                 labelCustom: SizedBox(
              //                   width: 20.w,
              //                   child: Text(
              //                     graphModel.title.toString(),
              //                     softWrap: true,
              //                     style: TextStyle(
              //                         fontSize: 14.sp,
              //                         overflow: TextOverflow.ellipsis),
              //                   ),
              //                 ),
              //                 barDecoration:
              //                     const BoxDecoration(color: CkColors.textMuted
              //                         // color: Services.graphColors(
              //                         //     type: graphModel.title.toString()
              //                         //         .capitalizeFirst
              //                         //         .toString()),
              //                         ),
              //                 showValue: true,
              //                 valueCustom: Column(
              //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(
              //                       graphModel.title.toString(),
              //                       style: TextStyle(
              //                           color: Colors.white,
              //                           fontWeight: FontWeight.bold,
              //                           fontSize: 12.sp),
              //                     ),
              //                   ],
              //                 ),
              //                 valueStyle: const TextStyle(
              //                   fontSize: 16,
              //                   color: Colors.white,
              //                 ),
              //               );
              //             },
              //           ),
              //         ),
              //       ),
              //     )),
              //const MainGraph(graphModel: AppConstants.graph_items,)
            ],
          ),
        ),
      ),
    );
  }
}
