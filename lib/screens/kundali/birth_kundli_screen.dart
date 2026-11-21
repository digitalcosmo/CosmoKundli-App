import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/kundali_chart_widget.dart';

class BirthKundliScreen extends StatefulWidget {
  const BirthKundliScreen({super.key});

  @override
  State<BirthKundliScreen> createState() => _BirthKundliScreenState();
}

class _BirthKundliScreenState extends State<BirthKundliScreen> {
  final KundaliController _kundaliCtrl = Get.find(tag: GetTags.kundaliTag);
  final HomeController _homeCtrl = Get.find(tag: GetTags.homeTag);

  @override
  void initState() {
    super.initState();
    _kundaliCtrl.getBirthChartData();
    _kundaliCtrl.getBirthPlanetInfoData();
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
              CustomAppBar(
                title: 'Birth Kundli',
                subtitle: _homeCtrl.selectedUserName.value,
              ),
              Expanded(
                child: Obx(() {
                  if (_kundaliCtrl.isLoading.value) {
                    return const LoadingWidget();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      children: [
                        // Birth Chart
                        if (_kundaliCtrl.planetsData.isNotEmpty)
                          GlassCard(
                            padding: EdgeInsets.all(3.w),
                            child: SizedBox(
                              height: 45.h,
                              child: KundaliChartWidget(
                                planets: _kundaliCtrl.planetsData,
                              ),
                            ),
                          ).animate().fadeIn(duration: 500.ms),

                        SizedBox(height: 2.h),

                        // Quick Nav Buttons
                        _buildNavGrid(),

                        SizedBox(height: 2.h),

                        // Planet Info Table
                        if (_kundaliCtrl.birthPlanetInfoList.isNotEmpty)
                          _buildPlanetInfoTable()
                              .animate(delay: 200.ms)
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: 0.05),

                        SizedBox(height: 3.h),
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

  Widget _buildNavGrid() {
    final navItems = [
      {'label': 'Grah Coordinates', 'route': AppRoutes.grahCoordinates},
      {'label': 'Five Fold', 'route': AppRoutes.fiveFold},
      {'label': 'Shadbal', 'route': AppRoutes.shadbal},
      {'label': 'Varg Kundalis', 'route': AppRoutes.vargKundalis},
      {'label': 'Ashtakvarg', 'route': AppRoutes.ashtakVarg},
      {'label': 'Dasha', 'route': AppRoutes.dasha},
      {'label': 'Tara Chakra', 'route': AppRoutes.taraChakra},
      {'label': 'Sani Panoti', 'route': AppRoutes.saniPanoti},
      {'label': 'Chancha Chakra', 'route': AppRoutes.chanchaChakra},
    ];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: navItems.map((item) {
        return GestureDetector(
          onTap: () => Get.toNamed(item['route'] as String),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: AppTheme.glassPill,
            child: Text(
              item['label'] as String,
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildPlanetInfoTable() {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Planet Information', style: AppTheme.headingSmall),
          SizedBox(height: 1.5.h),
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _tableHeader('Planet', flex: 2),
                _tableHeader('Rashi', flex: 2),
                _tableHeader('Degree', flex: 2),
                _tableHeader('Nakshatra', flex: 3),
              ],
            ),
          ),
          SizedBox(height: 0.5.h),
          ...List.generate(
            _kundaliCtrl.birthPlanetInfoList.length,
            (i) {
              final planet = _kundaliCtrl.birthPlanetInfoList[i];
              return Container(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.gmBorder,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        planet.planet ?? '',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppConstants.getPlanetColor(planet.planet),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(planet.rashi ?? '', style: AppTheme.bodySmall),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(planet.degree ?? '', style: AppTheme.bodySmall),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(planet.nakshatra ?? '', style: AppTheme.bodySmall),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTheme.labelSmall.copyWith(
          color: AppTheme.accent,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
