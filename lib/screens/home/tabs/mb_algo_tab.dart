import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';

class MbAlgoTab extends StatelessWidget {
  const MbAlgoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>(tag: GetTags.homeTag);

    final menuItems = [
      _MenuItem('Star Power', Icons.star_rounded, AppRoutes.starPower, AppTheme.jupiterColor,
          'Daily star power sentiment analysis'),
      _MenuItem('Cosmo Power', Icons.brightness_7_rounded, AppRoutes.cosmoPower, AppTheme.sunColor,
          'Cosmic energy influence report'),
      _MenuItem('Periodic Monthly', Icons.calendar_month_outlined, AppRoutes.periodicMonthly, AppTheme.mercuryColor,
          'Monthly periodic report analysis'),
      _MenuItem('Gochar Prabhav', Icons.moving_rounded, AppRoutes.gocharPrabhav, AppTheme.venusColor,
          'Transit influence predictions'),
      _MenuItem('Gochar Table', Icons.table_chart_rounded, AppRoutes.gocharTable, AppTheme.saturnColor,
          'Animated transit position table'),
    ];

    return Obx(() {
      if (homeCtrl.mId.value.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search_outlined, size: 64, color: AppTheme.textMuted),
              SizedBox(height: 2.h),
              Text('Select a client first', style: AppTheme.headingSmall),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MB Algorithm', style: AppTheme.headingLarge)
                .animate().fadeIn(duration: 400.ms),
            SizedBox(height: 1.h),
            Text('Mathematical astrology analysis', style: AppTheme.bodySmall)
                .animate(delay: 100.ms).fadeIn(duration: 400.ms),
            SizedBox(height: 2.h),
            ...menuItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: GlassCard(
                  onPressed: () => Get.toNamed(item.route),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.color, size: 22),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: AppTheme.headingSmall),
                            SizedBox(height: 2),
                            Text(item.subtitle, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: 100 + i * 60))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.05, end: 0),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  final String subtitle;
  const _MenuItem(this.title, this.icon, this.route, this.color, this.subtitle);
}
