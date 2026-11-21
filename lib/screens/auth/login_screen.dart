import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/sign_in_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final controller = Get.put(SignInController(), tag: GetTags.signInTag);

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
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10.h),
                  // Logo
                  Icon(Icons.auto_awesome, size: 56, color: AppTheme.accent)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.6, 0.6)),
                  SizedBox(height: 2.h),
                  Text('CosmoKundli', style: AppTheme.displayLarge)
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms),
                  SizedBox(height: 1.h),
                  Text('Sign in to continue', style: AppTheme.labelMedium)
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 500.ms),
                  SizedBox(height: 5.h),

                  // Login Card
                  GlassCard(
                    padding: EdgeInsets.all(6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back', style: AppTheme.headingLarge),
                        SizedBox(height: 0.5.h),
                        Text('Enter your credentials', style: AppTheme.bodySmall),
                        SizedBox(height: 3.h),

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

                        Obx(() => GlassTextField(
                              controller: controller.passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
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
                                if (val.length < 4) return 'Min 4 characters';
                                return null;
                              },
                            )),
                        SizedBox(height: 3.5.h),

                        Obx(() => GlassButton(
                              text: 'Sign In',
                              isLoading: controller.isLoading.value,
                              onPressed: () => controller.login(context),
                            )),
                      ],
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(begin: 0.1),

                  SizedBox(height: 3.h),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: AppTheme.bodySmall),
                      GestureDetector(
                        onPressed: () => Get.toNamed(AppRoutes.signUp),
                        child: Text(
                          'Sign Up',
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
