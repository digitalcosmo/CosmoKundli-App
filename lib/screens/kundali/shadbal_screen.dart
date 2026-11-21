import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class ShadbalScreen extends StatefulWidget {
  const ShadbalScreen({super.key});

  @override
  State<ShadbalScreen> createState() => _ShadbalScreenState();
}

class _ShadbalScreenState extends State<ShadbalScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);

  @override
  void initState() {
    super.initState();
    if (!_ctrl.isShabdalApiCalled) {
      _ctrl.shadbalGraph();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Shadbal'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value || _ctrl.shadbalData.value == null) {
                    return const LoadingWidget();
                  }
                  final items = _ctrl.shadbalData.value!.list ?? [];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        // Bar Chart
                        GlassCard(
                          padding: EdgeInsets.all(3.w),
                          child: SizedBox(
                            height: 45.h,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceEvenly,
                                maxY: 100,
                                minY: 0,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipRoundedRadius: 8,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx >= items.length) return const SizedBox();
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          space: 4,
                                          child: Text(
                                            (items[idx].title ?? '').substring(0, 2),
                                            style: AppTheme.labelSmall.copyWith(fontSize: 10),
                                          ),
                                        );
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 20,
                                      reservedSize: 35,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}',
                                          style: AppTheme.labelSmall.copyWith(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(),
                                  topTitles: const AxisTitles(),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  horizontalInterval: 20,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: AppTheme.gmBorder,
                                    strokeWidth: 0.5,
                                  ),
                                  drawVerticalLine: false,
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: AppTheme.gmBorder, width: 0.5),
                                ),
                                barGroups: items.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;
                                  return BarChartGroupData(
                                    x: idx,
                                    barRods: [
                                      BarChartRodData(
                                        toY: item.value?.toDouble() ?? 0,
                                        color: AppConstants.getPlanetColor(item.title),
                                        width: 22,
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 600.ms),

                        SizedBox(height: 2.h),

                        // Planet List
                        GlassCard(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Planet Strengths', style: AppTheme.headingSmall),
                              SizedBox(height: 1.h),
                              ...items.map((item) => Padding(
                                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.title ?? '',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppConstants.getPlanetColor(item.title),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppConstants.getPlanetColor(item.title)
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                                          ),
                                          child: Text(
                                            '${item.value ?? 0}%',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppConstants.getPlanetColor(item.title),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
