import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/profile_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController ctrl = Get.find(tag: GetTags.profileTag);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.bgPrimary, AppTheme.bgSecondary]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Change Password'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: GlassCard(
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      children: [
                        GlassTextField(controller: ctrl.oldPass, label: 'Old Password', obscureText: true),
                        SizedBox(height: 2.h),
                        GlassTextField(controller: ctrl.newPass, label: 'New Password', obscureText: true),
                        SizedBox(height: 2.h),
                        GlassTextField(controller: ctrl.newPass1, label: 'Confirm Password', obscureText: true),
                        SizedBox(height: 3.h),
                        GlassButton(text: 'Change Password', onPressed: () => ctrl.changePassword()),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
