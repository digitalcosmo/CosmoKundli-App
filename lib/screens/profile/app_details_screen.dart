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

class AppDetailsScreen extends StatefulWidget {
  const AppDetailsScreen({super.key});
  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  final ProfileController _ctrl = Get.find(tag: GetTags.profileTag);

  @override
  void initState() { super.initState(); _ctrl.fetchAppDetails(); }

  Widget _imageSection(String title, String type, RxString imageUrl) {
    return GlassCard(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.labelMedium),
          SizedBox(height: 1.h),
          Obx(() => imageUrl.value.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  child: Image.network(imageUrl.value, height: 15.h, width: double.infinity, fit: BoxFit.cover),
                )
              : Container(
                  height: 15.h, width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.gmBg, borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: AppTheme.gmBorder),
                  ),
                  child: const Center(child: Icon(Icons.image_outlined, color: Colors.white38, size: 40)),
                ),
          ),
          SizedBox(height: 1.h),
          GlassButton(text: 'Upload $title', onPressed: () => _ctrl.uploadImage(type)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.bgPrimary, AppTheme.bgSecondary]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'App Details'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value) return const LoadingWidget();
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Form(
                      key: _ctrl.appDetailsFormKey,
                      child: Column(
                        children: [
                          GlassCard(
                            padding: EdgeInsets.all(4.w),
                            child: Column(
                              children: [
                                GlassTextField(controller: _ctrl.appName, label: 'App Name'),
                                SizedBox(height: 1.5.h),
                                GlassTextField(controller: _ctrl.appCode, label: 'App Code'),
                                SizedBox(height: 1.5.h),
                                GlassTextField(controller: _ctrl.appDesc, label: 'Description', maxLines: 3),
                                SizedBox(height: 2.h),
                                GlassButton(text: 'Update', onPressed: () => _ctrl.updateAppDetails()),
                              ],
                            ),
                          ).animate().fadeIn(duration: 500.ms),
                          SizedBox(height: 2.h),
                          _imageSection('Front Image', 'front', _ctrl.selectedFrontImage).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                          SizedBox(height: 1.5.h),
                          _imageSection('Back Image', 'back', _ctrl.selectedBackImage).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                          SizedBox(height: 1.5.h),
                          _imageSection('App Image', 'app', _ctrl.selectedAppImage).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
