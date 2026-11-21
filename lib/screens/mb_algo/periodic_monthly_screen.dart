import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/mb_algo_controller.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';

class PeriodicMonthlyScreen extends StatelessWidget {
  PeriodicMonthlyScreen({super.key});

  final controller = Get.find<MbAlgoController>(tag: GetTags.mbAlgoTag);
  final homeController = Get.find<HomeController>(tag: GetTags.homeTag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const GlassAppBar(title: 'Periodic Monthly Report'),
              Expanded(
                child: Obx(() {
                  if (controller.isPeriodicMonthlyLoading.value) {
                    return const LoadingWidget();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      children: [
                        _buildMonthPicker(context),
                        SizedBox(height: 2.h),
                        _buildChart(),
                        SizedBox(height: 2.h),
                        _buildDataTable(),
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

  Widget _buildMonthPicker(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
            onPressed: () => controller.previousMonth(),
          ),
          GestureDetector(
            onTap: () => _showMonthYearPicker(context),
            child: Obx(() => Text(
                  controller.monthLabel.value,
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                )),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
            onPressed: () => controller.nextMonth(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  void _showMonthYearPicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              surface: AppTheme.bgSecondary,
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      if (date != null) {
        controller.setMonthYear(date.month, date.year);
      }
    });
  }

  Widget _buildChart() {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: SizedBox(
        height: 28.h,
        child: Obx(() {
          final data = controller.periodicMonthlyData;
          if (data.isEmpty) {
            return Center(child: Text('No data available', style: AppTheme.bodySmall));
          }
          return BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppTheme.gmBorder,
                  strokeWidth: 0.5,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: AppTheme.labelSmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            data[idx]['title']?.toString().substring(0, 3) ?? '',
                            style: AppTheme.labelSmall.copyWith(fontSize: 9),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((e) {
                final val = (e.value['value'] as num?)?.toDouble() ?? 0;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: val >= 0 ? AppTheme.success : AppTheme.error,
                      width: 14,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        }),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildDataTable() {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: Obx(() {
        final data = controller.periodicMonthlyData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Details', style: AppTheme.headingSmall),
            SizedBox(height: 1.5.h),
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Title', style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w700))),
                  Expanded(flex: 1, child: Text('Value', style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                ],
              ),
            ),
            SizedBox(height: 0.5.h),
            ...data.map((item) => Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.gmBorder, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item['title']?.toString() ?? '', style: AppTheme.bodyMedium)),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item['value']?.toString() ?? '',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ((item['value'] as num?) ?? 0) >= 0 ? AppTheme.success : AppTheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        );
      }),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }
}
