import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/profile_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportHistoryScreen extends StatelessWidget {
  ReportHistoryScreen({super.key});

  final controller = Get.find<ProfileController>(tag: GetTags.profileTag);

  @override
  Widget build(BuildContext context) {
    controller.fetchReportHistory();

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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                    ),
                    Text('Report History', style: AppTheme.headingLarge),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) return const LoadingWidget();

                  final reports = controller.reportHistory;
                  if (reports.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
                          SizedBox(height: 2.h),
                          Text('No reports generated yet', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: GlassCard(
                          onTap: () {
                            final url = report['reportUrl'] ?? report['url'] ?? '';
                            if (url.toString().isNotEmpty) {
                              launchUrl(Uri.parse(url.toString()));
                            }
                          },
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accent.withOpacity(0.15),
                                ),
                                child: const Icon(Icons.description_outlined, color: AppTheme.accent, size: 20),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      report['reportName'] ?? report['name'] ?? 'Report',
                                      style: AppTheme.bodyMedium,
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${report['memberName'] ?? ''} · ${report['date'] ?? report['createdDate'] ?? ''}',
                                      style: AppTheme.labelSmall,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.open_in_new, color: AppTheme.textMuted, size: 18),
                            ],
                          ),
                        ),
                      ).animate(delay: Duration(milliseconds: 100 + index * 40))
                          .fadeIn(duration: 300.ms);
                    },
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
