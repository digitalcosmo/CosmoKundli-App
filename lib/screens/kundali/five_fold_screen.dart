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

class FiveFoldScreen extends StatefulWidget {
  const FiveFoldScreen({super.key});

  @override
  State<FiveFoldScreen> createState() => _FiveFoldScreenState();
}

class _FiveFoldScreenState extends State<FiveFoldScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);

  @override
  void initState() {
    super.initState();
    if (!_ctrl.isFiveFoldApiCalled) {
      _ctrl.getFiveFoldRelationshipTableData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Five Fold Friendship'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value || _ctrl.fiveFoldRelationshipModel == null) {
                    return const LoadingWidget();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Matrix table
                        GlassCard(
                          padding: EdgeInsets.all(2.w),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildMatrix(),
                          ),
                        ).animate().fadeIn(duration: 500.ms),

                        SizedBox(height: 3.h),

                        // Legend
                        GlassCard(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Notation', style: AppTheme.headingSmall),
                              SizedBox(height: 1.h),
                              Wrap(
                                spacing: 6.w,
                                runSpacing: 1.h,
                                children: [
                                  _legendItem('F', 'Friend'),
                                  _legendItem('N', 'Neutral'),
                                  _legendItem('E', 'Enemy'),
                                  _legendItem('IF', 'Intimate Friend'),
                                  _legendItem('IE', 'Intimate Enemy'),
                                ],
                              ),
                            ],
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
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

  Widget _buildMatrix() {
    final headers = AppConstants.headers;
    final data = _ctrl.fiveFoldRelationshipModel!.list;

    return DataTable(
      columnSpacing: 12,
      headingRowHeight: 40,
      dataRowMinHeight: 36,
      dataRowMaxHeight: 36,
      border: TableBorder.all(color: AppTheme.gmBorder, width: 0.5),
      columns: [
        DataColumn(
          label: Text('Planet', style: AppTheme.labelSmall.copyWith(
            color: AppTheme.accent, fontWeight: FontWeight.w700,
          )),
        ),
        ...headers.map((h) => DataColumn(
              label: Text(
                h.substring(0, 2),
                style: AppTheme.labelSmall.copyWith(
                  color: AppConstants.getPlanetColor(h),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )),
      ],
      rows: List.generate(data?.length ?? 0, (i) {
        final planetData = data![i];
        final planetName = planetData.planet ?? '';
        final planets = planetData.planets;
        final values = [
          planets?.sun, planets?.moon, planets?.mars, planets?.mercury,
          planets?.jupiter, planets?.venus, planets?.saturn, planets?.rahu, planets?.ketu,
        ];
        return DataRow(
          cells: [
            DataCell(Text(
              planetName,
              style: AppTheme.bodySmall.copyWith(
                color: AppConstants.getPlanetColor(planetName),
                fontWeight: FontWeight.w600,
              ),
            )),
            ...values.map((v) => DataCell(
                  Text(
                    v ?? '-',
                    style: AppTheme.bodySmall.copyWith(fontSize: 10),
                  ),
                )),
          ],
        );
      }),
    );
  }

  Widget _legendItem(String code, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(code, style: AppTheme.labelSmall.copyWith(
            color: AppTheme.accent, fontWeight: FontWeight.w700,
          )),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }
}
