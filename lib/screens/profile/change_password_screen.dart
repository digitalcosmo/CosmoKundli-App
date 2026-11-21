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
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController ctrl = Get.find(tag: GetTags.profileTag);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
        )),
        child: SafeArea(child: Column(children: [
          const CustomAppBar(title: 'Change Password'),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: GlassCard(
              padding: EdgeInsets.all(5.w),
              child: Column(children: [
                GlassTextField(controller: ctrl.oldPassController, hintText: 'Old Password', obscureText: true, prefixIcon: Icons.lock_outline),
                SizedBox(height: 3.w),
                GlassTextField(controller: ctrl.newPassController, hintText: 'New Password', obscureText: true, prefixIcon: Icons.lock),
                SizedBox(height: 3.w),
                GlassTextField(controller: ctrl.newPass1Controller, hintText: 'Confirm New Password', obscureText: true, prefixIcon: Icons.lock),
                SizedBox(height: 5.w),
                Obx(() => ctrl.isLoading.value
                  ? const LoadingWidget()
                  : GlassButton(text: 'Update Password', onPressed: () {
                      if (ctrl.newPassController.text != ctrl.newPass1Controller.text) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                        return;
                      }
                      ctrl.updatePassword(context);
                    }),
                ),
              ]),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
          )),
        ])),
      ),
    );
  }
}
