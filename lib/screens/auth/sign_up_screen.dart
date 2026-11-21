import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/sign_up_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final controller = Get.put(SignUpController(), tag: GetTags.signUpTag);

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
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary, AppTheme.bgTertiary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Form(
              key: controller.signUpFormKey,
              child: Column(
                children: [
                  SizedBox(height: 6.h),
                  Icon(Icons.auto_awesome, size: 48, color: AppTheme.accent)
                      .animate().fadeIn(duration: 500.ms),
                  SizedBox(height: 2.h),
                  Text('Create Account', style: AppTheme.headingLarge)
                      .animate(delay: 200.ms).fadeIn(duration: 500.ms),
                  SizedBox(height: 1.h),
                  Text('Join CosmoKundli today', style: AppTheme.labelMedium)
                      .animate(delay: 300.ms).fadeIn(duration: 500.ms),
                  SizedBox(height: 4.h),

                  GlassCard(
                    padding: EdgeInsets.all(6.w),
                    child: Column(
                      children: [
                        GlassTextField(
                          controller: controller.nameController,
                          label: 'Full Name',
                          hint: 'Enter your name',
                          prefixIcon: Icons.person_outline,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter name' : null,
                        ),
                        SizedBox(height: 2.h),
                        GlassTextField(
                          controller: controller.emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Enter email';
                            if (!GetUtils.isEmail(val)) return 'Enter valid email';
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),
                        GlassTextField(
                          controller: controller.mobileController,
                          label: 'Mobile',
                          hint: 'Enter mobile number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter mobile' : null,
                        ),
                        SizedBox(height: 2.h),
                        Obx(() => GlassTextField(
                              controller: controller.passwordController,
                              label: 'Password',
                              hint: 'Create a password',
                              obscureText: controller.obscureText.value,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureText.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textMuted,
                                  size: 20,
                                ),
                                onPressed: controller.toggleObscureText,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Enter password';
                                if (val.length < 6) return 'Min 6 characters';
                                return null;
                              },
                            )),
                        SizedBox(height: 3.5.h),
                        Obx(() => GlassButton(
                              text: 'Create Account',
                              isLoading: controller.isLoading.value,
                              onPressed: () => controller.signUp(context),
                            )),
                      ],
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(begin: 0.1),

                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: AppTheme.bodySmall),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          'Sign In',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate(delay: 600.ms).fadeIn(duration: 500.ms),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
