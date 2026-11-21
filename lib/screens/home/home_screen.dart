import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/screens/home/tabs/kundali_tab.dart';
import 'package:cosmo_kundli/screens/home/tabs/mb_algo_tab.dart';
import 'package:cosmo_kundli/screens/home/tabs/others_tab.dart';
import 'package:cosmo_kundli/screens/home/tabs/profile_tab.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController(), tag: GetTags.homeTag);

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
              // Top bar with member info
              _buildTopBar(context),
              // Tab content
              Expanded(
                child: Obx(() {
                  switch (controller.currentPageIndex.value) {
                    case 0:
                      return const KundaliTab();
                    case 1:
                      return const MbAlgoTab();
                    case 2:
                      return const OthersTab();
                    case 3:
                      return const ProfileTab();
                    default:
                      return const KundaliTab();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary.withOpacity(0.95),
              border: const Border(
                top: BorderSide(color: AppTheme.gmBorder, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentPageIndex.value,
              onPressed: controller.setPageIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.accent,
              unselectedItemColor: AppTheme.textMuted,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome),
                  label: 'Kundli',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  label: 'MB Algo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.compare_arrows),
                  label: 'Others',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Obx(() {
      final hasUser = controller.mId.value.isNotEmpty;
      return GlassCard(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Row(
          children: [
            // User avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasUser ? AppTheme.accent.withOpacity(0.2) : AppTheme.gmBg,
                border: Border.all(color: AppTheme.gmBorder),
              ),
              child: Icon(
                hasUser ? Icons.person : Icons.person_add_outlined,
                color: hasUser ? AppTheme.accent : AppTheme.textMuted,
                size: 22,
              ),
            ),
            SizedBox(width: 3.w),
            // Info
            Expanded(
              child: hasUser
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedUserName.value,
                          style: AppTheme.headingSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${controller.selectedBirthDate.value} · ${controller.selectedBirthTime.value}',
                          style: AppTheme.labelSmall,
                          maxLines: 1,
                        ),
                      ],
                    )
                  : Text('Select a client', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
            ),
            // All Clients button
            GestureDetector(
              onPressed: () => Get.toNamed(AppRoutes.clientList),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: AppTheme.glassPill,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: AppTheme.accent),
                    const SizedBox(width: 6),
                    Text('Clients', style: AppTheme.labelSmall.copyWith(color: AppTheme.accent)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
    });
  }
}
