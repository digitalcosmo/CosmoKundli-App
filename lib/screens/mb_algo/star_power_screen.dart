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

class StarPowerScreen extends StatelessWidget {
  StarPowerScreen({super.key});

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
              const GlassAppBar(title: 'Star Power Sentiment'),
              Expanded(
                child: Obx(() {
                  if (controller.isStarPowerLoading.value) {
                    return const LoadingWidget();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      children: [
                        // User info
                        _buildUserInfo(),
                        SizedBox(height: 2.h),
                        // Week picker
                        _buildWeekPicker(),
                        SizedBox(height: 2.h),
                        // Chart
                        _buildChart(),
                        SizedBox(height: 2.h),
                        // Data table
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

  Widget _buildUserInfo() {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: AppTheme.accent, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(homeController.selectedUserName.value, style: AppTheme.headingSmall),
                Text(
                  '${homeController.selectedBirthDate.value} • ${homeController.selectedBirthTime.value}',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildWeekPicker() {
    return GlassCard(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
            onPressed: () => controller.previousWeek(),
          ),
          Obx(() => Text(
                controller.weekLabel.value,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              )),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
            onPressed: () => controller.nextWeek(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildChart() {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: SizedBox(
        height: 28.h,
        child: Obx(() {
          final data = controller.starPowerDailyData;
          if (data.isEmpty) {
            return Center(child: Text('No data available', style: AppTheme.bodySmall));
          }
          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
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
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final idx = value.toInt();
                      if (idx >= 0 && idx < days.length) {
                        return Text(days[idx], style: AppTheme.labelSmall);
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) =>
                    FlSpot(e.key.toDouble(), e.value),
                  ).toList(),
                  isCurved: true,
                  color: AppTheme.accent,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: spot.y >= 0 ? AppTheme.success : AppTheme.error,
                      strokeWidth: 1.5,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.accent.withOpacity(0.3),
                        AppTheme.accent.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
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
        final data = controller.starPowerDailyData;
        final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Values', style: AppTheme.headingSmall),
            SizedBox(height: 1.5.h),
            ...List.generate(
              data.length > 7 ? 7 : data.length,
              (i) => Padding(
                padding: EdgeInsets.symmetric(vertical: 0.8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(i < days.length ? days[i] : 'Day ${i + 1}', style: AppTheme.bodyMedium),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: data[i] >= 0
                            ? AppTheme.success.withOpacity(0.15)
                            : AppTheme.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                      ),
                      child: Text(
                        data[i].toStringAsFixed(1),
                        style: AppTheme.bodyMedium.copyWith(
                          color: data[i] >= 0 ? AppTheme.success : AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }
}
