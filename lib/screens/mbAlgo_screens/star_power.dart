import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/mbAlgo_controller.dart';
import 'package:cosmo_kundali/custom_widgets/main_button.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../values/get_tags.dart';
import 'package:fl_chart/fl_chart.dart';

class StarPower extends StatefulWidget {
   const StarPower({super.key});

  @override
  State<StarPower> createState() => _StarPowerState();
}

class _StarPowerState extends State<StarPower> {
   final MbalgoController mbalgoController =
   Get.put(MbalgoController(), tag: GetTags.mbAlgoTag);

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){

      mbalgoController.fetchStarPowerReportDaily();

    });

   }

  @override
  Widget build(BuildContext context) {
    return  CkScaffold(
      body: Container(
        padding: EdgeInsets.all(13.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("star_power".tr,style: TextStyle(
                  color: AppColors.headerColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 17.sp
              ),),
              SizedBox(height: 2.h,),
              Text("select_month".tr,style: TextStyle(
                fontSize: 15.sp,
                color: CkColors.textSecondary
              ),),
              SizedBox(height: 1.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 45.w,
                    height: 5.h,
                    decoration: BoxDecoration(border: Border.all(color: CkColors.text.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(10.sp)),
                    child: Row(
                      children: [
                         SizedBox(width: 2.h,),
                         Obx(
                             ()=> Text(DateFormat('MMM yyyy').format(mbalgoController.selectedDate.value).toString()
                           ),
                         ),
                        const Spacer(),
                        IconButton(onPressed: () async
                        {
                          DateTime? selected = await showMonthPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1970),
                          lastDate: DateTime(2100));
                          String monthName =
                          DateFormat('MMM yy').format(selected!).toUpperCase();
                          // cosmoReportController.currentDate.value = selected;
                          // cosmoReportController.getMonthlyData(
                          // date: monthName,
                          // context: context,
                          // );
                          if (selected != null && selected != mbalgoController.selectedDate.value) {
                            mbalgoController.selectedDate.value = selected;
                            mbalgoController.fetchStarPowerReportDaily();
          
                          }
                          }, icon: const Icon(Icons.calendar_month))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 45.w,
                    height: 5.h,
                    child: MainButton(
                      onTap: () {
                        debugPrint('Tapped');
                        mbalgoController.fetchStarPowerReportDaily();
                      },
                      radius: 14.sp,
                        text: "get_details".tr),
                  ),
                ],
              ),
              SizedBox(height: 2.h,),
              Obx(
                () => Container(
                  padding: EdgeInsets.all(13.sp),
                  height: 45.h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                     // border: Border.all(color: CkColors.text.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(20.sp)
                  ),
                  child:  mbalgoController.isLoading.value || mbalgoController.starPowerReportDailyList.value.length == 0?
                  const Center(
                      child:  CircularProgressIndicator()) :
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: mbalgoController.starPowerReportDailyList.length * 50,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: 100,
                          minY: -100,
                          titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
          
                                      space: 8,
                                      child: Text(
                                        mbalgoController.starPowerReportDailyList[index].date.toString(), // Handle out of bounds
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
                                  interval: 20,
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
                              topTitles: const AxisTitles()
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
                          barGroups: mbalgoController.starPowerReportDailyList.asMap().entries.map((entry) {
                            int index = entry.key;
                            double value = entry.value.value ?? 0;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  color: value < 0 ? Colors.red : Colors.green,
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
                  //   child: SfSparkBarChart.custom(
                  //     dataCount: mbalgoController.starPowerReportDailyList.length,
                  //     labelStyle:const TextStyle(fontSize: 12),
                  //     xValueMapper: (int index) =>
                  //     mbalgoController.starPowerReportDailyList[index].date ?? 0.0,
                  //     yValueMapper: (int index) =>
                  //     mbalgoController.starPowerReportDailyList[index].value ?? 0.0,
                  //     color: AppColors.green,
                  //     negativePointColor: Colors.red,
                  //   )
                  //
                  //
                  //   //
                  //   //   Sf SparkBarChart(
                  //   //   data: mbalgoController.starPowerReportDailyList
                  //   //       .map((item) => item.value ?? 0.0)
                  //   //       .toList(),
                  //   //   negativePointColor: Colors.red,
                  //   //   color:AppColors.green,
                  //   // ),
                  // )
                ),
              ),
              SizedBox(height: 1.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 2.h,
                    width: 2.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.sp),
                      color: AppColors.green
                    ),
                  ),
                  SizedBox(width: 1.w,),
                  Text("favorable".tr,style: TextStyle(color: CkColors.text.withOpacity(0.70),
                  fontWeight: FontWeight.w600),),
                  SizedBox(width: 4.w,),
                  Container(
                    height: 2.h,
                    width: 2.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: CkColors.text.withOpacity(0.50),),
                        borderRadius: BorderRadius.circular(10.sp),
                        color:  AppColors.red
                    ),
                  ),
                  SizedBox(width: 1.w,),
                  Text("unfavorable".tr,style:TextStyle(color: CkColors.text.withOpacity(0.70),
                      fontWeight: FontWeight.w600),),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

