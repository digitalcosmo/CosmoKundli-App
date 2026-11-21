import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cosmo_kundli/controllers/profile_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class AppDetailsScreen extends StatelessWidget {
  const AppDetailsScreen({super.key});

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
          const CustomAppBar(title: 'App Details'),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(children: [
              // App icon
              Obx(() {
                final img = ctrl.selectedAppImage.value;
                return GlassCard(
                  padding: EdgeInsets.all(5.w),
                  child: Column(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: img.isNotEmpty
                        ? CachedNetworkImage(imageUrl: img, width: 20.w, height: 20.w, fit: BoxFit.cover,
                            placeholder: (_, __) => SizedBox(width: 20.w, height: 20.w, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                            errorWidget: (_, __, ___) => _placeholder())
                        : _placeholder(),
                    ),
                    SizedBox(height: 3.w),
                    GlassButton(text: 'Change App Icon', onPressed: () async {
                      final file = await ctrl.pickFile(context, 'app');
                      if (file != null) {
                        ctrl.selectedAppFile.value = file;
                        ctrl.updateAppImage(context);
                      }
                    }),
                  ]),
                );
              }).animate().fadeIn(duration: 300.ms),
              SizedBox(height: 3.w),
              // Details form
              GlassCard(
                padding: EdgeInsets.all(5.w),
                child: Column(children: [
                  GlassTextField(controller: ctrl.appNameController, hintText: 'App Name', prefixIcon: Icons.apps, enabled: false),
                  SizedBox(height: 3.w),
                  GlassTextField(controller: ctrl.appCodeController, hintText: 'App Code', prefixIcon: Icons.code, enabled: false),
                  SizedBox(height: 3.w),
                  GlassTextField(controller: ctrl.appDescController, hintText: 'Description', prefixIcon: Icons.description, maxLines: 3),
                  SizedBox(height: 5.w),
                  Obx(() => ctrl.isLoading.value
                    ? const LoadingWidget()
                    : GlassButton(text: 'Update', onPressed: () => ctrl.updateAppDetail(context)),
                  ),
                ]),
              ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.05, end: 0),
            ]),
          )),
        ])),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 20.w, height: 20.w,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white.withValues(alpha: 0.05)),
    child: Icon(Icons.apps, color: AppTheme.textSecondary, size: 8.w),
  );
}
