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

class GocharPrabhavScreen extends StatelessWidget {
  GocharPrabhavScreen({super.key});

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
              const GlassAppBar(title: 'Gochar Prabhav'),
              Expanded(
                child: Obx(() {
                  if (controller.isGocharPrabhavLoading.value) {
                    return const LoadingWidget();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      children: [
                        _buildDatePicker(context),
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

  Widget _buildDatePicker(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
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
          );
          if (date != null) {
            controller.setGocharPrabhavDate(date);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.accent, size: 18),
            SizedBox(width: 2.w),
            Obx(() => Text(
                  controller.gocharPrabhavDateLabel.value,
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                )),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildChart() {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: SizedBox(
        height: 28.h,
        child: Obx(() {
          final data = controller.gocharPrabhavData;
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
                        final title = data[idx]['Title']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            title.length > 3 ? title.substring(0, 3) : title,
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
                final val = (e.value['Value'] as num?)?.toDouble() ?? 0;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: val >= 0 ? AppTheme.jupiterColor : AppTheme.marsColor,
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
        final data = controller.gocharPrabhavData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prabhav Details', style: AppTheme.headingSmall),
            SizedBox(height: 1.5.h),
            ...data.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item['Title']?.toString() ?? '', style: AppTheme.bodyMedium)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: ((item['Value'] as num?) ?? 0) >= 0
                              ? AppTheme.success.withOpacity(0.15)
                              : AppTheme.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                        ),
                        child: Text(
                          item['Value']?.toString() ?? '0',
                          style: AppTheme.bodyMedium.copyWith(
                            color: ((item['Value'] as num?) ?? 0) >= 0 ? AppTheme.success : AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
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
