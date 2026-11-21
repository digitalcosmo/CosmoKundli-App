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

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final controller = Get.find<ProfileController>(tag: GetTags.profileTag);
  final _formKey = GlobalKey<FormState>();

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
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                    ),
                    Expanded(child: Text('Change Password', style: AppTheme.headingLarge)),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),

                        GlassCard(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lock_outline, color: AppTheme.accent, size: 22),
                                  SizedBox(width: 2.w),
                                  Text('Update Password', style: AppTheme.headingSmall),
                                ],
                              ),
                              SizedBox(height: 2.h),

                              // Old Password
                              GlassTextField(
                                controller: controller.oldPassController,
                                label: 'Current Password',
                                hint: 'Enter current password',
                                obscureText: true,
                                prefix: const Icon(Icons.lock_clock_outlined, color: AppTheme.textMuted, size: 20),
                                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                              ),
                              SizedBox(height: 1.5.h),

                              // New Password
                              GlassTextField(
                                controller: controller.newPassController,
                                label: 'New Password',
                                hint: 'Enter new password',
                                obscureText: true,
                                prefix: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Required';
                                  if (val.length < 6) return 'Min 6 characters';
                                  return null;
                                },
                              ),
                              SizedBox(height: 1.5.h),

                              // Confirm Password
                              GlassTextField(
                                controller: controller.newPass1Controller,
                                label: 'Confirm Password',
                                hint: 'Re-enter new password',
                                obscureText: true,
                                prefix: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Required';
                                  if (val != controller.newPassController.text) return 'Passwords do not match';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                        SizedBox(height: 3.h),

                        Obx(() => GlassButton(
                          text: 'Change Password',
                          icon: Icons.check,
                          isLoading: controller.isLoading.value,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              controller.updatePassword(context);
                            }
                          },
                        )),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
