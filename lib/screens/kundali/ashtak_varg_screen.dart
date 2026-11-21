import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_dropdown.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class AshtakVargScreen extends StatefulWidget {
  const AshtakVargScreen({super.key});

  @override
  State<AshtakVargScreen> createState() => _AshtakVargScreenState();
}

class _AshtakVargScreenState extends State<AshtakVargScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);
  final RxString _selectedPlanet = 'Sun'.obs;

  final List<Map<String, String>> planets = [
    {'name': 'Sun', 'value': 'Sun'},
    {'name': 'Moon', 'value': 'Moon'},
    {'name': 'Mars', 'value': 'Mars'},
    {'name': 'Mercury', 'value': 'Mercury'},
    {'name': 'Jupiter', 'value': 'Jupiter'},
    {'name': 'Venus', 'value': 'Venus'},
    {'name': 'Saturn', 'value': 'Saturn'},
    {'name': 'Ascendant', 'value': 'Lagan'},
  ];

  @override
  void initState() {
    super.initState();
    if (!_ctrl.isAshtakVargApiCalled) {
      _ctrl.ashtakVargSunTableData();
    }
  }

  List<Map<String, dynamic>> _processTableData(List<List<dynamic>> tableData) {
    if (tableData.isEmpty) return [];
    final headers = tableData[0].map((h) => h.toString()).toList();
    final rowsData = tableData
        .sublist(1)
        .map((row) => row.map((c) => c.toString()).toList())
        .toList();

    List<int> colTotals = List.generate(headers.length - 1, (_) => 0);
    for (var row in rowsData) {
      for (int i = 1; i < row.length; i++) {
        colTotals[i - 1] += int.tryParse(row[i]) ?? 0;
      }
    }
    List<String> totalRow = ['Total'];
    totalRow.addAll(colTotals.map((t) => t.toString()));
    rowsData.add(totalRow);

    for (var row in rowsData) {
      int rowTotal = 0;
      for (int i = 1; i < row.length; i++) {
        rowTotal += int.tryParse(row[i]) ?? 0;
      }
      row.add(rowTotal.toString());
    }
    headers.add('Total');
    return [
      {'headers': headers},
      {'rowsData': rowsData}
    ];
  }

  List<List<dynamic>>? _getTableForPlanet(String planet) {
    switch (planet) {
      case 'Sun': return _ctrl.ashtakVargSun?.table;
      case 'Moon': return _ctrl.ashtakVargMoon?.table;
      case 'Mars': return _ctrl.ashtakVargMars?.table;
      case 'Mercury': return _ctrl.ashtakVargMercury?.table;
      case 'Jupiter': return _ctrl.ashtakVargJupiter?.table;
      case 'Venus': return _ctrl.ashtakVargVenus?.table;
      case 'Saturn': return _ctrl.ashtakVargSaturn?.table;
      case 'Lagan': return _ctrl.ashtakVargLagan?.table;
      default: return null;
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
              const CustomAppBar(title: 'Ashtak Varg'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value) return const LoadingWidget();

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        // Planet Dropdown
                        GlassCard(
                          padding: EdgeInsets.all(3.w),
                          child: DropdownButtonFormField<String>(
                            value: _selectedPlanet.value,
                            dropdownColor: AppTheme.bgSecondary,
                            style: AppTheme.bodyMedium,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                                borderSide: const BorderSide(color: AppTheme.gmBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                                borderSide: const BorderSide(color: AppTheme.gmBorder),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                            ),
                            items: planets.map((p) {
                              return DropdownMenuItem(
                                value: p['value'],
                                child: Text(p['name']!, style: AppTheme.bodyMedium),
                              );
                            }).toList(),
                            onChanged: (val) {
                              _selectedPlanet.value = val!;
                            },
                          ),
                        ).animate().fadeIn(duration: 400.ms),

                        SizedBox(height: 2.h),

                        // Table
                        Builder(builder: (_) {
                          final table = _getTableForPlanet(_selectedPlanet.value);
                          if (table == null || table.isEmpty) {
                            return GlassCard(
                              padding: EdgeInsets.all(6.w),
                              child: Center(
                                child: Text('No data available', style: AppTheme.bodyMedium),
                              ),
                            );
                          }
                          final processed = _processTableData(table);
                          if (processed.length < 2) return const SizedBox();
                          final headers = processed[0]['headers'] as List<String>;
                          final rows = processed[1]['rowsData'] as List<List<String>>;

                          return GlassCard(
                            padding: EdgeInsets.all(2.w),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 12,
                                dataRowMinHeight: 32,
                                dataRowMaxHeight: 40,
                                headingRowColor: WidgetStatePropertyAll(
                                  AppTheme.gmHighlight.withOpacity(0.1),
                                ),
                                border: TableBorder.all(
                                  color: AppTheme.gmBorder,
                                  width: 0.5,
                                ),
                                columns: headers.map((h) {
                                  return DataColumn(
                                    label: Text(h, style: AppTheme.labelSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                    )),
                                  );
                                }).toList(),
                                rows: rows.asMap().entries.map((entry) {
                                  final isTotal = entry.key == rows.length - 1;
                                  return DataRow(
                                    color: isTotal
                                        ? WidgetStatePropertyAll(AppTheme.accent.withOpacity(0.1))
                                        : null,
                                    cells: entry.value.asMap().entries.map((cell) {
                                      return DataCell(Text(
                                        cell.value,
                                        style: AppTheme.bodySmall.copyWith(
                                          fontWeight: (cell.key == 0 || isTotal)
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: cell.key == 0
                                              ? AppConstants.getPlanetColor(cell.value)
                                              : null,
                                        ),
                                      ));
                                    }).toList(),
                                  );
                                }).toList(),
                              ),
                            ),
                          ).animate(delay: 200.ms).fadeIn(duration: 500.ms);
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
