import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class DashaScreen extends StatefulWidget {
  const DashaScreen({super.key});
  @override
  State<DashaScreen> createState() => _DashaScreenState();
}

class _DashaScreenState extends State<DashaScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);

  @override
  void initState() {
    super.initState();
    if (!_ctrl.isDashaApiCalled) _ctrl.getDasha();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Dasha'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value || _ctrl.dashaModel == null) {
                    return const LoadingWidget();
                  }
                  final dasha = _ctrl.dashaModel!;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        // Balance info
                        GlassCard(
                          padding: EdgeInsets.all(4.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dasha Balance', style: AppTheme.labelMedium),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      '${dasha.dashaBalanceGrah ?? ''}: ${dasha.dashaBalance ?? ''}',
                                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Current Dasha', style: AppTheme.labelMedium),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      '${dasha.subGrah1 ?? ''}-${dasha.subGrah2 ?? ''}-${dasha.subGrah3 ?? ''}',
                                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                        SizedBox(height: 2.h),
                        // Maha Dasha list
                        ...List.generate(dasha.list?.length ?? 0, (i) {
                          final item = dasha.list![i];
                          final planetColor = AppConstants.getPlanetColor(item.title);
                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: GlassCard(
                              padding: EdgeInsets.zero,
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                                  childrenPadding: EdgeInsets.symmetric(horizontal: 4.w),
                                  iconColor: Colors.white70,
                                  collapsedIconColor: Colors.white54,
                                  title: Row(
                                    children: [
                                      Container(
                                        width: 4, height: 32,
                                        decoration: BoxDecoration(
                                          color: planetColor,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Text(item.title ?? '',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: planetColor, fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: (item.list ?? []).map((sub) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: AppTheme.gmBorder, width: 0.5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(sub.title ?? '', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${sub.startDate ?? ''} - ${sub.endDate ?? ''}',
                                              style: AppTheme.labelSmall.copyWith(color: Colors.white54),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ).animate(delay: (100 * i).ms).fadeIn(duration: 400.ms).slideX(begin: 0.05);
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
