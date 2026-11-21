import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/models/ashtak_varg_model.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class AshtakVargScreen extends StatefulWidget {
  const AshtakVargScreen({super.key});
  @override
  State<AshtakVargScreen> createState() => _AshtakVargScreenState();
}

class _AshtakVargScreenState extends State<AshtakVargScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);

  @override
  void initState() {
    super.initState();
    if (!_ctrl.isAshtakApiCalled.value) _ctrl.ashtakVargSunTableData();
  }

  static const _planetNames = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Lagan'];

  List<Rx<AshtakVargModel?>> get _allData => [
    _ctrl.ashtakVargSun, _ctrl.ashtakVargMoon, _ctrl.ashtakVargMars,
    _ctrl.ashtakVargMercury, _ctrl.ashtakVargJupiter, _ctrl.ashtakVargVenus,
    _ctrl.ashtakVargSaturn, _ctrl.ashtakVargLagan,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
        )),
        child: SafeArea(child: Column(children: [
          const CustomAppBar(title: 'Ashtak Varg'),
          Expanded(child: Obx(() {
            if (_ctrl.isLoading.value || _allData.every((d) => d.value == null)) return const LoadingWidget();
            return ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _planetNames.length,
              itemBuilder: (_, i) {
                final data = _allData[i].value;
                if (data == null) return const SizedBox.shrink();
                return _buildPlanetTable(_planetNames[i], data, i);
              },
            );
          })),
        ])),
      ),
    );
  }

  Widget _buildPlanetTable(String planetName, AshtakVargModel data, int index) {
    final rashis = AppConstants.rashiList;
    return Padding(
      padding: EdgeInsets.only(bottom: 3.w),
      child: GlassCard(
        padding: EdgeInsets.all(3.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 2.5.w, height: 2.5.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppConstants.getPlanetColor(planetName))),
            SizedBox(width: 2.w),
            Text(planetName, style: TextStyle(color: AppConstants.getPlanetColor(planetName), fontWeight: FontWeight.w600, fontSize: 16.sp)),
            const Spacer(),
            Text('Start: ${data.startingRashi}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.sp)),
          ]),
          SizedBox(height: 2.w),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.06)),
              columnSpacing: 2.5.w,
              horizontalMargin: 2.w,
              dataRowMinHeight: 7.w,
              dataRowMaxHeight: 9.w,
              columns: [
                const DataColumn(label: Text('')),
                ...rashis.map((r) => DataColumn(label: Text(r.substring(0, r.length > 3 ? 3 : r.length),
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 12.sp)))),
              ],
              rows: List.generate(data.table.length, (rowIdx) {
                final row = data.table[rowIdx];
                return DataRow(cells: [
                  DataCell(Text(rowIdx < AppConstants.planetHeaders.length ? AppConstants.planetHeaders[rowIdx] : '${rowIdx + 1}',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp))),
                  ...row.map((cell) => DataCell(Text(cell,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 12.sp)))),
                ]);
              }),
            ),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms).slideY(begin: 0.05, end: 0);
  }
}
