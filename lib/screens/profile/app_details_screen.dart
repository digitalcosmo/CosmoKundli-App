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
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppDetailsScreen extends StatelessWidget {
  AppDetailsScreen({super.key});

  final controller = Get.find<ProfileController>(tag: GetTags.profileTag);

  @override
  Widget build(BuildContext context) {
    controller.fetchAppDetails();

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

            return Column(
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
                      Expanded(child: Text('App Details', style: AppTheme.headingLarge)),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 1.h),

                        // App Icon preview
                        if (controller.selectedAppImage.value.isNotEmpty)
                          Center(
                            child: GlassCard(
                              padding: EdgeInsets.all(4.w),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: CachedNetworkImage(
                                      imageUrl: controller.selectedAppImage.value,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.apps, color: AppTheme.textMuted, size: 40),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  GlassButton(
                                    text: 'Change Icon',
                                    onPressed: () async {
                                      await controller.pickFile('app');
                                      if (controller.selectedAppFile.value != null) {
                                        controller.updateAppImage(context);
                                      }
                                    },
                                    isOutlined: true,
                                  ),
                                ],
                              ),
                            ),
                          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                        SizedBox(height: 2.h),

                        // App Name
                        GlassTextField(
                          controller: controller.appNameController,
                          label: 'App Name',
                          hint: 'Enter app name',
                          prefix: const Icon(Icons.apps_outlined, color: AppTheme.textMuted, size: 20),
                        ),
                        SizedBox(height: 1.5.h),

                        // App Code
                        GlassTextField(
                          controller: controller.appCodeController,
                          label: 'App Code',
                          hint: 'Enter app code',
                          prefix: const Icon(Icons.code, color: AppTheme.textMuted, size: 20),
                        ),
                        SizedBox(height: 1.5.h),

                        // Description
                        GlassTextField(
                          controller: controller.appDescController,
                          label: 'Description',
                          hint: 'Enter description',
                          prefix: const Icon(Icons.description_outlined, color: AppTheme.textMuted, size: 20),
                          maxLines: 4,
                        ),
                        SizedBox(height: 3.h),

                        // Update button
                        GlassButton(
                          text: 'Update App Details',
                          icon: Icons.save_outlined,
                          onPressed: () => controller.updateAppDetail(context),
                          isLoading: controller.isLoading.value,
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
