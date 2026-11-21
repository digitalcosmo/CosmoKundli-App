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

class DisplayDetailsScreen extends StatelessWidget {
  DisplayDetailsScreen({super.key});

  final controller = Get.find<ProfileController>(tag: GetTags.profileTag);

  @override
  Widget build(BuildContext context) {
    controller.displayDetails();

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
                      Expanded(child: Text('Display Details', style: AppTheme.headingLarge)),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 1.h),

                        // Front & Back image previews
                        if (controller.selectedFrontImage.value.isNotEmpty ||
                            controller.selectedBackImage.value.isNotEmpty)
                          GlassCard(
                            padding: EdgeInsets.all(3.w),
                            child: Row(
                              children: [
                                if (controller.selectedFrontImage.value.isNotEmpty)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('Front Image', style: AppTheme.labelSmall),
                                        SizedBox(height: 1.h),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: controller.selectedFrontImage.value,
                                            height: 10.h,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) =>
                                                const Icon(Icons.broken_image, color: AppTheme.textMuted),
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        GlassButton(
                                          text: 'Change',
                                          onPressed: () async {
                                            await controller.pickFile('front');
                                            if (controller.selectedFrontFile.value != null) {
                                              controller.updateFrontImage(context);
                                            }
                                          },
                                          isOutlined: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                if (controller.selectedFrontImage.value.isNotEmpty &&
                                    controller.selectedBackImage.value.isNotEmpty)
                                  SizedBox(width: 3.w),
                                if (controller.selectedBackImage.value.isNotEmpty)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('Back Image', style: AppTheme.labelSmall),
                                        SizedBox(height: 1.h),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: controller.selectedBackImage.value,
                                            height: 10.h,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) =>
                                                const Icon(Icons.broken_image, color: AppTheme.textMuted),
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        GlassButton(
                                          text: 'Change',
                                          onPressed: () async {
                                            await controller.pickFile('back');
                                            if (controller.selectedBackFile.value != null) {
                                              controller.updateBackImage(context);
                                            }
                                          },
                                          isOutlined: true,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                        SizedBox(height: 2.h),

                        // Display Name
                        GlassTextField(
                          controller: controller.displayNameController,
                          label: 'Display Name',
                          hint: 'Enter display name',
                          prefix: const Icon(Icons.person_outline, color: AppTheme.textMuted, size: 20),
                        ),
                        SizedBox(height: 1.5.h),

                        // Display Message
                        GlassTextField(
                          controller: controller.displayMsgController,
                          label: 'Display Message',
                          hint: 'Enter message',
                          prefix: const Icon(Icons.message_outlined, color: AppTheme.textMuted, size: 20),
                          maxLines: 2,
                        ),
                        SizedBox(height: 1.5.h),

                        // Display Address
                        GlassTextField(
                          controller: controller.displayAddressController,
                          label: 'Address',
                          hint: 'Enter address',
                          prefix: const Icon(Icons.location_on_outlined, color: AppTheme.textMuted, size: 20),
                          maxLines: 2,
                        ),
                        SizedBox(height: 1.5.h),

                        // Display Email
                        GlassTextField(
                          controller: controller.displayEmailController,
                          label: 'Email',
                          hint: 'Enter email',
                          prefix: const Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 1.5.h),

                        // Display Mobile
                        GlassTextField(
                          controller: controller.displayMobileController,
                          label: 'Mobile',
                          hint: 'Enter mobile',
                          prefix: const Icon(Icons.phone_outlined, color: AppTheme.textMuted, size: 20),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 3.h),

                        // Update button
                        GlassButton(
                          text: 'Update Display Details',
                          icon: Icons.save_outlined,
                          onPressed: () => controller.updateDisplayDetails(context),
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
