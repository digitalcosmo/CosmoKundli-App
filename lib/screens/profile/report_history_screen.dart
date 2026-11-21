import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/profile_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});
  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final ProfileController _ctrl = Get.find(tag: GetTags.profileTag);

  @override
  void initState() { super.initState(); _ctrl.fetchReportHistory(); }

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
              const CustomAppBar(title: 'Report History'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value) return const LoadingWidget();
                  if (_ctrl.reportList.isEmpty) {
                    return Center(child: Text('No reports', style: AppTheme.bodyMedium));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: _ctrl.reportList.length,
                    itemBuilder: (_, i) {
                      final item = _ctrl.reportList[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: GlassCard(
                          padding: EdgeInsets.all(3.w),
                          child: Row(
                            children: [
                              const Icon(Icons.description_outlined, color: AppTheme.accent),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['ReportName'] ?? '', style: AppTheme.bodyMedium),
                                    SizedBox(height: 0.3.h),
                                    Text(item['Date'] ?? '', style: AppTheme.labelSmall.copyWith(color: Colors.white38)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.download_outlined, color: Colors.white38),
                            ],
                          ),
                        ).animate(delay: (50 * i).ms).fadeIn(duration: 300.ms),
                      );
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
