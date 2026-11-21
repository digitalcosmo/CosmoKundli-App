import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/urls.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/kundali_chart_widget.dart';

class VargKundalisScreen extends StatefulWidget {
  const VargKundalisScreen({super.key});
  @override
  State<VargKundalisScreen> createState() => _VargKundalisScreenState();
}

class _VargKundalisScreenState extends State<VargKundalisScreen> {
  final controller = Get.find<KundaliController>(tag: GetTags.kundaliTag);
  int selectedIndex = 0;

  static const List<String> _urls = [
    Urls.navamsha, Urls.hora, Urls.drekkana, Urls.chaturthamsha,
    Urls.saptamsha, Urls.dashamsha, Urls.dwadashamsha, Urls.shodashamsha,
    Urls.vishamsha, Urls.chaturVishamsha, Urls.saptaVishamsha,
    Urls.trishamsha, Urls.khavedamsha, Urls.akshavedamsha, Urls.shashtiyamsha,
  ];

  @override
  void initState() {
    super.initState();
    if (!controller.isVargKundaliApiCalled.value) {
      controller.vargKundalis(_urls[0]);
    }
  }

  void _selectVarg(int index) {
    setState(() => selectedIndex = index);
    controller.vargKundalis(_urls[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary]),
        ),
        child: SafeArea(
          child: Column(children: [
            const CustomAppBar(title: 'Varg Kundalis'),
            SizedBox(
              height: 5.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                itemCount: AppConstants.vargKundaliNames.length,
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  return Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: GestureDetector(
                      onTap: () => _selectVarg(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accent.withOpacity(0.3) : AppTheme.gmBg,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: isSelected ? AppTheme.accent : AppTheme.gmBorder),
                        ),
                        child: Center(child: Text(AppConstants.vargKundaliNames[index],
                          style: AppTheme.labelSmall.copyWith(
                            color: isSelected ? AppTheme.accent : AppTheme.textSecondary))),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();
              final data = controller.vargKundalisData.value;
              if (data == null || data.kundaliModel == null) {
                return Center(child: Text('No data', style: AppTheme.bodySmall));
              }
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(children: [
                  GlassCard(
                    padding: EdgeInsets.all(3.w),
                    child: SizedBox(height: 40.h,
                      child: KundaliChartWidget(planets: data.kundaliModel!.map((p) =>
                        {'Name': p.name, 'Rashi': p.rashi, 'Color': p.color}).toList()),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  GlassCard(
                    padding: EdgeInsets.all(3.w),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Planet Details', style: AppTheme.headingSmall),
                      SizedBox(height: 1.h),
                      ...data.kundaliModel!.map((planet) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.5.h),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(planet.name ?? '', style: AppTheme.bodyMedium),
                          Text('Rashi: ${planet.rashi ?? '-'}', style: AppTheme.bodySmall),
                        ]),
                      )),
                    ]),
                  ),
                ]).animate().fadeIn(duration: 400.ms),
              );
            })),
          ]),
        ),
      ),
    );
  }
}
