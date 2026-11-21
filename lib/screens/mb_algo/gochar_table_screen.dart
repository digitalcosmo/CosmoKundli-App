import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/other_controller.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';

class GocharTableScreen extends StatelessWidget {
  GocharTableScreen({super.key});

  final controller = Get.find<OtherController>(tag: GetTags.otherTag);
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
              const GlassAppBar(title: 'Gochar Table'),
              Expanded(
                child: Obx(() {
                  if (controller.isGocharTableLoading.value) {
                    return const LoadingWidget();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      children: [
                        _buildDateTimeDisplay(),
                        SizedBox(height: 1.5.h),
                        _buildTimeControls(),
                        SizedBox(height: 2.h),
                        _buildPlanetTable(),
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

  Widget _buildDateTimeDisplay() {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: Obx(() => Column(
            children: [
              Text(
                controller.gocharDateLabel.value,
                style: AppTheme.headingMedium,
              ),
              SizedBox(height: 0.5.h),
              Text(
                controller.gocharTimeLabel.value,
                style: AppTheme.bodySmall,
              ),
            ],
          )),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTimeControls() {
    final controls = [
      {'label': '10Y', 'inc': () => controller.incrementGochar('10year'), 'dec': () => controller.decrementGochar('10year')},
      {'label': '1Y', 'inc': () => controller.incrementGochar('year'), 'dec': () => controller.decrementGochar('year')},
      {'label': '1M', 'inc': () => controller.incrementGochar('month'), 'dec': () => controller.decrementGochar('month')},
      {'label': '1W', 'inc': () => controller.incrementGochar('week'), 'dec': () => controller.decrementGochar('week')},
      {'label': '1D', 'inc': () => controller.incrementGochar('day'), 'dec': () => controller.decrementGochar('day')},
      {'label': '1H', 'inc': () => controller.incrementGochar('hour'), 'dec': () => controller.decrementGochar('hour')},
    ];

    return GlassCard(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: controls.map((ctrl) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: ctrl['inc'] as VoidCallback,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, color: AppTheme.accent, size: 16),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(ctrl['label'] as String, style: AppTheme.labelSmall.copyWith(fontSize: 10)),
              SizedBox(height: 0.5.h),
              GestureDetector(
                onTap: ctrl['dec'] as VoidCallback,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove, color: AppTheme.error, size: 16),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildPlanetTable() {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Planet Positions', style: AppTheme.headingSmall),
          SizedBox(height: 1.5.h),
          // Header row
          Container(
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _headerCell('Planet', 2),
                _headerCell('Rashi', 2),
                _headerCell('Degree', 2),
                _headerCell('Nakshatra', 2),
                _headerCell('Long.', 1),
              ],
            ),
          ),
          SizedBox(height: 0.5.h),
          Obx(() {
            final planets = controller.gocharTablePlanets;
            return Column(
              children: planets.map((planet) {
                final name = planet['planet']?.toString() ?? '';
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.gmBorder, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          name,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppConstants.getPlanetColor(name),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(flex: 2, child: Text(planet['rashi']?.toString() ?? '', style: AppTheme.bodySmall)),
                      Expanded(flex: 2, child: Text(planet['degree']?.toString() ?? '', style: AppTheme.bodySmall)),
                      Expanded(flex: 2, child: Text(planet['nakshatra']?.toString() ?? '', style: AppTheme.bodySmall)),
                      Expanded(flex: 1, child: Text(planet['longitute']?.toString() ?? '', style: AppTheme.bodySmall)),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
