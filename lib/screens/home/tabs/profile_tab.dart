import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/services/services.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _ProfileItem('Profile Details', Icons.person_outline_rounded, AppRoutes.profile),
      _ProfileItem('Display Details', Icons.badge_outlined, AppRoutes.displayDetails),
      _ProfileItem('App Details', Icons.app_settings_alt_outlined, AppRoutes.appDetails),
      _ProfileItem('Change Password', Icons.lock_outline_rounded, AppRoutes.changePassword),
      _ProfileItem('Credit Transaction', Icons.account_balance_wallet_outlined, AppRoutes.creditTransaction),
      _ProfileItem('Report History', Icons.history_rounded, AppRoutes.reportHistory),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: AppTheme.headingLarge)
              .animate().fadeIn(duration: 400.ms),
          SizedBox(height: 1.h),
          Text('Manage your account', style: AppTheme.bodySmall)
              .animate(delay: 100.ms).fadeIn(duration: 400.ms),
          SizedBox(height: 2.h),

          ...menuItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 1.2.h),
              child: GlassCard(
                onTap: () => Get.toNamed(item.route),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    Icon(item.icon, color: AppTheme.accent, size: 22),
                    SizedBox(width: 4.w),
                    Expanded(child: Text(item.title, style: AppTheme.bodyLarge)),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 150 + i * 50))
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.03),
            );
          }),

          SizedBox(height: 1.h),

          // Deactivate Account
          GlassCard(
            onTap: () => _showDeactivateDialog(context),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                const Icon(Icons.no_accounts_outlined, color: AppTheme.error, size: 22),
                SizedBox(width: 4.w),
                Expanded(child: Text('Deactivate Account',
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.error))),
              ],
            ),
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

          SizedBox(height: 1.5.h),

          // Logout
          GlassCard(
            onTap: () => _showLogoutDialog(context),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, color: AppTheme.warning, size: 22),
                SizedBox(width: 4.w),
                Expanded(child: Text('Logout',
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.warning))),
              ],
            ),
          ).animate(delay: 550.ms).fadeIn(duration: 400.ms),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Logout', style: AppTheme.headingSmall),
        content: Text('Are you sure you want to logout?', style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Services.logOut();
            },
            child: Text('Logout', style: TextStyle(color: AppTheme.warning)),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Deactivate Account', style: AppTheme.headingSmall),
        content: Text('This action cannot be undone. Are you sure?', style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Call deactivate API
            },
            child: Text('Deactivate', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem {
  final String title;
  final IconData icon;
  final String route;
  const _ProfileItem(this.title, this.icon, this.route);
}
