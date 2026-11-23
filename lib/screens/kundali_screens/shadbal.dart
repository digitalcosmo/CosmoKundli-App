import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/kundali_controller.dart';
import 'package:cosmo_kundali/values/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../custom_widgets/main_graph.dart';
import '../../models/shadbal_graph.dart';
import '../../services/services.dart';
import '../../values/app_constants.dart';
import '../../values/get_tags.dart';

class Shadbal extends StatefulWidget {
  Shadbal({super.key});

  @override
  State<Shadbal> createState() => _ShadbalState();
}

class _ShadbalState extends State<Shadbal> {
  final KundaliController _kundaliController =
      Get.put(KundaliController(), tag: GetTags.kundaliTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!_kundaliController.isShabdalApiCalled) {
      Future.delayed(
        const Duration(seconds: 1),
        () {
          _kundaliController.shadbalGraph();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CkScaffold(
        body: _kundaliController.isLoading.value ||
                _kundaliController.shadbalGrpah == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.all(10.sp),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    SizedBox(
                      height: 50.h,
                      width: 100.w,
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
                                    space: 5,
                                    child: Text(
                                      _kundaliController.shabdalList.value[0]
                                          .list![index].value
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
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 10,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  final index = value.toInt();
                                  return Flexible(
                                    child: Text(
                                      _kundaliController.shabdalList.value[0]
                                          .list![index].title!
                                          .firstTwoLetter(),
                                      style: TextStyle(
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
                          barGroups: _kundaliController
                              .shabdalList.value[0].list!
                              .asMap()
                              .entries
                              .map((entry) {
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
                    SizedBox(
                      height: 7.h,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount:
                              _kundaliController.shadbalGrpah?.list?.length ??
                                  0,
                          itemBuilder: (context, index) {
                            final item =
                                _kundaliController.shadbalGrpah?.list![index];
                            return SizedBox(
                              width: 27.w,
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${item?.title.toString().tr} - ${item?.value.toString()}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Services.graphColors(
                                        type: item!.title
                                            .toString()
                                            .capitalizeFirst
                                            .toString(),
                                      ),
                                      fontSize: 20,
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
