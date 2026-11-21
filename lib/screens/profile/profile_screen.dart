import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/profile_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.find<ProfileController>(tag: GetTags.profileTag);

  @override
  Widget build(BuildContext context) {
    controller.fetchProfile();

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
          child: Obx(() {
            if (controller.isLoading.value) return const LoadingWidget();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                        ),
                        Text('My Profile', style: AppTheme.headingLarge),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  // Profile card
                  GlassCard(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.accent.withOpacity(0.2),
                          child: const Icon(Icons.person, color: AppTheme.accent, size: 32),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(controller.profileName.value, style: AppTheme.headingMedium),
                              const SizedBox(height: 4),
                              Text(controller.profileEmail.value, style: AppTheme.labelSmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: 2.h),

                  // Credit balance
                  GlassCard(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.jupiterColor.withOpacity(0.15),
                          ),
                          child: const Icon(Icons.account_balance_wallet, color: AppTheme.jupiterColor, size: 22),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Credit Balance', style: AppTheme.labelSmall),
                            const SizedBox(height: 2),
                            Text(controller.creditBalance.value, style: AppTheme.headingMedium),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: 2.h),

                  // Menu items
                  ..._buildMenuItems(context),

                  SizedBox(height: 4.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final items = [
      _MenuItem('Display Details', Icons.info_outline, () => Get.toNamed(AppRoutes.displayDetails)),
      _MenuItem('App Details', Icons.phone_android_outlined, () => Get.toNamed(AppRoutes.appDetails)),
      _MenuItem('Change Password', Icons.lock_outline, () => Get.toNamed(AppRoutes.changePassword)),
      _MenuItem('Credit Transactions', Icons.receipt_long_outlined, () => Get.toNamed(AppRoutes.creditTransaction)),
      _MenuItem('Report History', Icons.history_outlined, () => Get.toNamed(AppRoutes.reportHistory)),
    ];

    return items.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      return Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: GlassCard(
          onPressed: item.onTap,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          child: Row(
            children: [
              Icon(item.icon, color: AppTheme.accent, size: 22),
              SizedBox(width: 3.w),
              Expanded(child: Text(item.label, style: AppTheme.bodyMedium)),
              const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: 300 + i * 60)).fadeIn(duration: 300.ms).slideX(begin: 0.03);
    }).toList();
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuItem(this.label, this.icon, this.onTap);
}
