import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class SaniPanotiScreen extends StatefulWidget {
  const SaniPanotiScreen({super.key});
  @override
  State<SaniPanotiScreen> createState() => _SaniPanotiScreenState();
}

class _SaniPanotiScreenState extends State<SaniPanotiScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);

  @override
  void initState() {
    super.initState();
    if (!_ctrl.isSaniPanotiApiCalled) _ctrl.getShaniPanotiData();
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
              const CustomAppBar(title: 'Sani Panoti'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value || _ctrl.saniPanotiData == null) {
                    return const LoadingWidget();
                  }
                  final items = _ctrl.saniPanotiData!.list ?? [];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: GlassCard(
                      padding: EdgeInsets.all(2.w),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 14,
                          dataRowMinHeight: 32,
                          dataRowMaxHeight: 42,
                          headingRowColor: WidgetStatePropertyAll(
                            AppTheme.gmHighlight.withOpacity(0.1),
                          ),
                          border: TableBorder.all(color: AppTheme.gmBorder, width: 0.5),
                          columns: [
                            DataColumn(label: Text('Panoti', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('Rashi', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('Start', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('End', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('Duration', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700))),
                          ],
                          rows: items.map((p) {
                            return DataRow(cells: [
                              DataCell(Text(p.panoti?.toString() ?? '', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600))),
                              DataCell(Text(p.rashi?.toString() ?? '', style: AppTheme.bodySmall)),
                              DataCell(Text(p.startDate?.toString() ?? '', style: AppTheme.bodySmall)),
                              DataCell(Text(p.endDate?.toString() ?? '', style: AppTheme.bodySmall)),
                              DataCell(Text(p.duration?.toString() ?? '', style: AppTheme.bodySmall)),
                            ]);
                          }).toList(),
                        ),
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
