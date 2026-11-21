import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
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
  void initState() {
    super.initState();
    _ctrl.fetchReportHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
        )),
        child: SafeArea(child: Column(children: [
          const CustomAppBar(title: 'Report History'),
          Expanded(child: Obx(() {
            if (_ctrl.isLoading.value) return const LoadingWidget();
            final data = _ctrl.reportHistoryData.value;
            if (data == null || (data.list ?? []).isEmpty) {
              return Center(child: Text('No reports yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15.sp)));
            }
            final items = data.list!;
            return ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return GlassCard(
                  margin: EdgeInsets.only(bottom: 2.5.w),
                  padding: EdgeInsets.all(4.w),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name ?? '', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15.sp)),
                      SizedBox(height: 1.w),
                      Row(children: [
                        _chip(item.type ?? ''),
                        SizedBox(width: 2.w),
                        if (item.month != null && item.month!.isNotEmpty) _chip(item.month!),
                      ]),
                      SizedBox(height: 1.w),
                      Text(item.date ?? '', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5.sp)),
                    ])),
                    if (item.downloadLink != null && item.downloadLink!.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.download_rounded, color: AppTheme.accentGold, size: 6.w),
                        onPressed: () async {
                          final uri = Uri.tryParse(item.downloadLink!);
                          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),
                  ]),
                ).animate().fadeIn(duration: 300.ms, delay: (i * 50).ms).slideY(begin: 0.05, end: 0);
              },
            );
          })),
        ])),
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.8.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white.withValues(alpha: 0.08),
      border: Border.all(color: AppTheme.glassBorder),
    ),
    child: Text(text, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
  );
}
