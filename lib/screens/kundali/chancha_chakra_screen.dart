import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';

class ChanchaChakraScreen extends StatefulWidget {
  const ChanchaChakraScreen({super.key});
  @override
  State<ChanchaChakraScreen> createState() => _ChanchaChakraScreenState();
}

class _ChanchaChakraScreenState extends State<ChanchaChakraScreen> {
  final controller = Get.find<KundaliController>(tag: GetTags.kundaliTag);

  @override
  void initState() {
    super.initState();
    if (!controller.isChanchaApiCalled.value) controller.fetchchanchaChakra();
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
            const CustomAppBar(title: 'Chancha Chakra'),
            Expanded(child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();
              final data = controller.chanchaChakraData.value;
              if (data == null || data.list == null) {
                return Center(child: Text('No data', style: AppTheme.bodySmall));
              }
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (data.startingRashi != null)
                    GlassCard(
                      padding: EdgeInsets.all(3.w),
                      child: Text('Starting Rashi: ${data.startingRashi}', style: AppTheme.headingSmall),
                    ).animate().fadeIn(duration: 400.ms),
                  SizedBox(height: 1.5.h),
                  ...List.generate(data.list!.length, (i) {
                    final rashi = data.list![i];
                    return GlassCard(
                      margin: EdgeInsets.only(bottom: 1.5.h),
                      padding: EdgeInsets.all(3.w),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(rashi.rashi ?? 'Rashi ${i + 1}',
                          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppTheme.accent)),
                        if (rashi.table != null) ...[
                          SizedBox(height: 1.h),
                          ...rashi.table!.map((row) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 0.3.h),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(row.title ?? '', style: AppTheme.bodySmall),
                              Text(row.value ?? '', style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary)),
                            ]),
                          )),
                        ],
                      ]),
                    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * (i > 10 ? 10 : i)));
                  }),
                ]),
              );
            })),
          ]),
        ),
      ),
    );
  }
}
