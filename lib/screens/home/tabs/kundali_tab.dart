import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';

class KundaliTab extends StatelessWidget {
  const KundaliTab({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>(tag: GetTags.homeTag);

    return Obx(() {
      if (homeCtrl.mId.value.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
              SizedBox(height: 2.h),
              Text('No Client Selected', style: AppTheme.headingMedium.copyWith(color: AppTheme.textMuted)),
              SizedBox(height: 1.h),
              Text('Select a client to view their kundali', style: AppTheme.bodySmall),
            ],
          ).animate().fadeIn(duration: 500.ms),
        );
      }
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kundali', style: AppTheme.headingLarge)
                .animate().fadeIn(duration: 400.ms),
            SizedBox(height: 1.h),
            Text('Select an analysis type', style: AppTheme.bodySmall)
                .animate(delay: 100.ms).fadeIn(duration: 400.ms),
            SizedBox(height: 2.h),
            ..._menuItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 1.2.h),
                child: GlassCard(
                  onPressed: () => Get.toNamed(item['route'] as String),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item['icon'] as IconData, color: AppTheme.accent, size: 20),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] as String, style: AppTheme.headingSmall.copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(item['subtitle'] as String, style: AppTheme.labelSmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
                    ],
                  ),
                ).animate(delay: (150 + i * 60).ms).fadeIn(duration: 400.ms).slideX(begin: 0.05),
              );
            }),
          ],
        ),
      );
    });
  }

  static final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.grid_view_rounded, 'title': 'Birth Kundli', 'subtitle': 'Birth chart & planet info', 'route': AppRoutes.birthKundli},
    {'icon': Icons.handshake_outlined, 'title': 'Five Fold Friendship', 'subtitle': 'Planet relationships', 'route': AppRoutes.fiveFold},
    {'icon': Icons.bar_chart, 'title': 'Shadbal', 'subtitle': 'Planetary strength graph', 'route': AppRoutes.shadbal},
    {'icon': Icons.dashboard_outlined, 'title': 'Varg Kundalis', 'subtitle': 'Divisional charts', 'route': AppRoutes.vargKundalis},
    {'icon': Icons.table_chart_outlined, 'title': 'Ashtakvarg', 'subtitle': 'Point tables', 'route': AppRoutes.ashtakVarg},
    {'icon': Icons.donut_large, 'title': 'Chancha Chakra', 'subtitle': 'Ring chart', 'route': AppRoutes.chanchaChakra},
    {'icon': Icons.timeline, 'title': 'Dasha', 'subtitle': 'Planetary periods', 'route': AppRoutes.dasha},
    {'icon': Icons.star_outline, 'title': 'Tara Chakra', 'subtitle': 'Nakshatra taras', 'route': AppRoutes.taraChakra},
    {'icon': Icons.ring_volume_outlined, 'title': 'Sani Panoti', 'subtitle': 'Saturn transit periods', 'route': AppRoutes.saniPanoti},
    {'icon': Icons.explore_outlined, 'title': 'Grah Coordinates', 'subtitle': 'Planet positions', 'route': AppRoutes.grahCoordinates},
  ];
}
