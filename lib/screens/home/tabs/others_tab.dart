import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';

class OthersTab extends StatelessWidget {
  const OthersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>(tag: GetTags.homeTag);

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
            Text('Others', style: AppTheme.headingLarge)
                .animate().fadeIn(duration: 400.ms),
            SizedBox(height: 1.h),
            Text('Kundali matching & more', style: AppTheme.bodySmall)
                .animate(delay: 100.ms).fadeIn(duration: 400.ms),
            SizedBox(height: 3.h),

            GlassCard(
              onPressed: () => Get.toNamed(AppRoutes.melapak),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.venusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.compare_arrows_rounded,
                        color: AppTheme.venusColor, size: 26),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Melapak', style: AppTheme.headingSmall),
                        SizedBox(height: 4),
                        Text('Kundali matching - 8 Koot analysis',
                            style: AppTheme.labelSmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.05),
          ],
        ),
      );
    });
  }
}
