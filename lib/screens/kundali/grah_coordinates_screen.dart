import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';

class GrahCoordinatesScreen extends StatelessWidget {
  GrahCoordinatesScreen({super.key});

  final controller = Get.find<KundaliController>(tag: GetTags.kundaliController);
  final homeController = Get.find<HomeController>(tag: GetTags.homeTag);

  @override
  Widget build(BuildContext context) {
    if (controller.birthPlanetInfoData.value == null) {
      controller.fetchBirthPlanetInfo();
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: const AppBarWidget(title: 'Grah Coordinates'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        final data = controller.birthPlanetInfoData.value;
        if (data == null || !data.status) {
          return Center(
            child: Text('No data available', style: AppTheme.bodyMedium),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                homeController.selectedUserName.value,
                style: AppTheme.headingMedium,
              ).animate().fadeIn(duration: 400.ms),
              SizedBox(height: 2.h),
              GlassCard(
                child: Column(
                  children: [
                    _buildHeaderRow(),
                    const Divider(color: AppColors.gmBorder, height: 1),
                    ...data.planets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final planet = entry.value;
                      final color = AppConstants.planetColors[planet.planet] ?? Colors.white;
                      return _buildPlanetRow(planet.planet, planet.rashi, planet.degree, planet.nakshatra, color)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (100 * index).ms);
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Planet', style: AppTheme.labelSmall.copyWith(color: AppColors.accent))),
          Expanded(flex: 2, child: Text('Rashi', style: AppTheme.labelSmall.copyWith(color: AppColors.accent))),
          Expanded(flex: 2, child: Text('Degree', style: AppTheme.labelSmall.copyWith(color: AppColors.accent))),
          Expanded(flex: 2, child: Text('Nakshatra', style: AppTheme.labelSmall.copyWith(color: AppColors.accent))),
        ],
      ),
    );
  }

  Widget _buildPlanetRow(String planet, String rashi, String degree, String nakshatra, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.w),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gmBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                SizedBox(width: 2.w),
                Flexible(child: Text(planet, style: AppTheme.bodySmall.copyWith(color: color))),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(rashi, style: AppTheme.bodySmall)),
          Expanded(flex: 2, child: Text(degree, style: AppTheme.bodySmall)),
          Expanded(flex: 2, child: Text(nakshatra, style: AppTheme.bodySmall)),
        ],
      ),
    );
  }
}
