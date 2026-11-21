import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/other_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/kundali_chart_widget.dart';

class MelapakDetailsScreen extends StatelessWidget {
  MelapakDetailsScreen({super.key});

  final controller = Get.find<OtherController>(tag: GetTags.otherTag);

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
              const CustomAppBar(title: 'Melapak Results'),
              Expanded(
                child: Obx(() {
                  if (controller.isMelapakLoading.value) {
                    return const LoadingWidget();
                  }
                  final data = controller.melapakData;
                  if (data.isEmpty) {
                    return Center(
                      child: Text('No matching data available', style: AppTheme.bodySmall),
                    );
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total score header
                        _buildScoreHeader(data),
                        SizedBox(height: 2.h),
                        // Two kundali charts side by side
                        _buildKundaliCharts(data),
                        SizedBox(height: 2.h),
                        // 8 Koot matching results
                        _buildKootResults(data),
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

  Widget _buildScoreHeader(Map<String, dynamic> data) {
    final totalScore = data['TotalScore']?.toString() ?? '0';
    final maxScore = data['MaxScore']?.toString() ?? '36';
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, color: AppTheme.accent, size: 24),
          SizedBox(width: 2.w),
          Text('Total Match Score: ', style: AppTheme.headingMedium),
          Text(
            '$totalScore / $maxScore',
            style: AppTheme.headingLarge.copyWith(color: AppTheme.accent),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildKundaliCharts(Map<String, dynamic> data) {
    final boyPlanets = data['BoyPlanets'] as List<dynamic>? ?? [];
    final girlPlanets = data['GirlPlanets'] as List<dynamic>? ?? [];
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: EdgeInsets.all(2.w),
            child: Column(
              children: [
                Text(
                  data['BoyName']?.toString() ?? 'Boy',
                  style: AppTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                SizedBox(
                  height: 20.h,
                  child: KundaliChartWidget(planets: boyPlanets),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: GlassCard(
            padding: EdgeInsets.all(2.w),
            child: Column(
              children: [
                Text(
                  data['GirlName']?.toString() ?? 'Girl',
                  style: AppTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                SizedBox(
                  height: 20.h,
                  child: KundaliChartWidget(planets: girlPlanets),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildKootResults(Map<String, dynamic> data) {
    final kootList = [
      {'name': 'Varn', 'key': 'Varn'},
      {'name': 'Vaishya', 'key': 'Vaishya'},
      {'name': 'Tara', 'key': 'Tara'},
      {'name': 'Yoni', 'key': 'Yoni'},
      {'name': 'Rashidhyapati', 'key': 'Rashidhyapati'},
      {'name': 'Gan', 'key': 'Gan'},
      {'name': 'Bhakoot', 'key': 'Bhakoot'},
      {'name': 'Naadi', 'key': 'Naadi'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ashtakoot Matching', style: AppTheme.headingMedium),
        SizedBox(height: 1.h),
        ...List.generate(kootList.length, (index) {
          final koot = kootList[index];
          final kootData = data[koot['key']] as Map<String, dynamic>? ?? {};
          final score = kootData['Score']?.toString() ?? '0';
          final maxScore = kootData['MaxScore']?.toString() ?? '0';
          final boyValue = kootData['BoyValue']?.toString() ?? '-';
          final girlValue = kootData['GirlValue']?.toString() ?? '-';

          return GlassCard(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(koot['name']!, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$score / $maxScore',
                        style: AppTheme.labelSmall.copyWith(color: AppTheme.accent),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text('Boy: $boyValue', style: AppTheme.bodySmall),
                    ),
                    Expanded(
                      child: Text('Girl: $girlValue', style: AppTheme.bodySmall),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(
                duration: 400.ms,
                delay: Duration(milliseconds: 100 * index),
              );
        }),
      ],
    );
  }
}
