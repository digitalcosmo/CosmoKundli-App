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

class DisplayDetailsScreen extends StatefulWidget {
  const DisplayDetailsScreen({super.key});
  @override
  State<DisplayDetailsScreen> createState() => _DisplayDetailsScreenState();
}

class _DisplayDetailsScreenState extends State<DisplayDetailsScreen> {
  final ProfileController _ctrl = Get.find(tag: GetTags.profileTag);

  @override
  void initState() { super.initState(); _ctrl.fetchDisplayDetails(); }

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
              const CustomAppBar(title: 'Display Details'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value) return const LoadingWidget();
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: GlassCard(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        children: [
                          GlassTextField(controller: _ctrl.displayName, label: 'Display Name'),
                          SizedBox(height: 1.5.h),
                          GlassTextField(controller: _ctrl.displayMsg, label: 'Message', maxLines: 3),
                          SizedBox(height: 1.5.h),
                          GlassTextField(controller: _ctrl.displayAddress, label: 'Address', maxLines: 2),
                          SizedBox(height: 1.5.h),
                          GlassTextField(controller: _ctrl.displayEmail, label: 'Email'),
                          SizedBox(height: 1.5.h),
                          GlassTextField(controller: _ctrl.displayMobile, label: 'Mobile'),
                          SizedBox(height: 3.h),
                          GlassButton(text: 'Update', onPressed: () => _ctrl.updateDisplayDetails()),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms),
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
