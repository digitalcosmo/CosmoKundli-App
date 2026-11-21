import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/other_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class MelapakDetailsScreen extends StatelessWidget {
  const MelapakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OtherController ctrl = Get.find(tag: GetTags.otherTag);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.bgPrimary, AppTheme.bgSecondary]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Melapak Details'),
              Expanded(
                child: Obx(() {
                  if (ctrl.isLoading.value || ctrl.melapakDetails == null) return const LoadingWidget();
                  final data = ctrl.melapakDetails!;
                  final items = data['list'] ?? [];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        // Score card
                        GlassCard(
                          padding: EdgeInsets.all(5.w),
                          child: Column(
                            children: [
                              Text('Match Score', style: AppTheme.headingMedium),
                              SizedBox(height: 1.h),
                              Text(
                                '${data['totalScore'] ?? 0} / ${data['maxScore'] ?? 36}',
                                style: AppTheme.displayLarge.copyWith(color: AppTheme.accent),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms),
                        SizedBox(height: 2.h),
                        // Detail list
                        ...List.generate(items.length, (i) {
                          final item = items[i];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: GlassCard(
                              padding: EdgeInsets.all(3.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(item['Name'] ?? '', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                                    ),
                                    child: Text('${item['Score'] ?? 0}/${item['Max'] ?? 0}', style: AppTheme.bodySmall.copyWith(color: AppTheme.accent, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ).animate(delay: (50 * i).ms).fadeIn(duration: 300.ms),
                          );
                        }),
                      ],
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
