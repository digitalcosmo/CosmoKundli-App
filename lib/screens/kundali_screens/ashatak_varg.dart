import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/kundali_controller.dart';
import '../../values/get_tags.dart';

class AshatakVarg extends StatefulWidget {
  AshatakVarg({super.key});

  @override
  State<AshatakVarg> createState() => _AshatakVargState();
}

class _AshatakVargState extends State<AshatakVarg> {
  final KundaliController _kundaliController =
      Get.find(tag: GetTags.kundaliTag);

  final RxString _selectedName = ''.obs;

  final List<Map<String, String>> planets =   [
    {'name': 'Sun', 'value': 'Ashtakvarg_Sun'},
    {'name': 'Moon', 'value': 'Ashtakvarg_Moon'},
    {'name': 'Mars', 'value': 'Ashtakvarg_Mars'},
    {'name': 'Mercury', 'value': 'Ashtakvarg_Mercury'},
    {'name': 'Jupiter', 'value': 'Ashtakvarg_Jupiter'},
    {'name': 'Venus', 'value': 'Ashtakvarg_Venus'},
    {'name': 'Saturn', 'value': 'Ashtakvarg_Saturn'},
    {'name': 'Lagan', 'value': 'Ashtakvarg_Lagan'},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        _kundaliController.ashtakVargSunTableData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectedName.value = planets.first['value']!;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15.sp),
        child: Obx(() {
          if (_kundaliController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_kundaliController.ashtakVargSun == null ||
              _kundaliController.ashtakVargSun!.table.isEmpty ||
              _kundaliController.ashtakVargMoon == null ||
              _kundaliController.ashtakVargMoon!.table.isEmpty ||
              _kundaliController.ashtakVargMars == null ||
              _kundaliController.ashtakVargMars!.table.isEmpty ||
              _kundaliController.ashtakVargMercury == null ||
              _kundaliController.ashtakVargMercury!.table.isEmpty ||
              _kundaliController.ashtakVargJupiter == null ||
              _kundaliController.ashtakVargJupiter!.table.isEmpty ||
              _kundaliController.ashtakVargVenus == null ||
              _kundaliController.ashtakVargVenus!.table.isEmpty ||
              _kundaliController.ashtakVargSaturn == null ||
              _kundaliController.ashtakVargSaturn!.table.isEmpty ||
              _kundaliController.ashtakVargLagan == null ||
              _kundaliController.ashtakVargLagan!.table.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          List<Map<String, dynamic>> processTableData(
              List<List<dynamic>> tableData) {
            final headers =
            tableData[0].map((header) => header.toString()).toList();
            final rowsData = tableData
                .sublist(1)
                .map((row) => row.map((cell) => cell.toString()).toList())
                .toList();

            List<int> columnTotals =
            List.generate(headers.length - 1, (index) => 0);
            for (var row in rowsData) {
              for (int i = 1; i < row.length; i++) {
                columnTotals[i - 1] += int.tryParse(row[i]) ?? 0;
              }
            }

            List<String> totalRow = ["Total"];
            totalRow.addAll(
                columnTotals.map((total) => total.toString()).toList());
            rowsData.add(totalRow);
            List<int> rowTotals = [];
            for (var row in rowsData) {
              int rowTotal = 0;
              for (int i = 1; i < row.length; i++) {
                rowTotal += int.tryParse(row[i]) ?? 0;
              }
              rowTotals.add(rowTotal);
            }
            for (int i = 0; i < rowsData.length; i++) {
              rowsData[i].add(rowTotals[i].toString());
            }
            headers.add("Total");
            return [
              {'headers': headers},
              {'rowsData': rowsData}
            ];
          }

          final sunData =
          processTableData(_kundaliController.ashtakVargSun!.table);
          final moonData =
          processTableData(_kundaliController.ashtakVargMoon!.table);
          final marsData =
          processTableData(_kundaliController.ashtakVargMars!.table);
          final mercuryData =
          processTableData(_kundaliController.ashtakVargMercury!.table);
          final jupiterData =
          processTableData(_kundaliController.ashtakVargJupiter!.table);
          final venusData =
          processTableData(_kundaliController.ashtakVargVenus!.table);
          final saturnData =
          processTableData(_kundaliController.ashtakVargSaturn!.table);
          final laganData =
          processTableData(_kundaliController.ashtakVargLagan!.table);

          List<Map<String, dynamic>> tableDataMap = [
            {"name": "Ashtakvarg_Sun", "value": sunData},
            {"name": "Ashtakvarg_Moon", "value": moonData},
            {"name": "Ashtakvarg_Mars", "value": marsData},
            {"name": "Ashtakvarg_Mercury", "value": mercuryData},
            {"name": "Ashtakvarg_Jupiter", "value": jupiterData},
            {"name": "Ashtakvarg_Venus", "value": venusData},
            {
              "name": "Ashtakvarg_Saturn",
              "value": saturnData
            }, // Corrected spelling
            {"name": "Ashtakvarg_Lagan", "value": laganData},
          ];

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CkColors.text, width: 2.sp),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CkColors.text, width: 2.sp),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CkColors.text, width: 2.sp),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: CkColors.text, width: 2.sp),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                ),
                value: _selectedName.value,
                items: planets.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value['value'],
                    child: Text(value['name'].toString(),
                        style: TextStyle(fontSize: 15.sp)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  _selectedName.value = newValue!;
                  debugPrint("Selected Name: " + _selectedName.value);
                },
              ),
              SizedBox(height: 2.h),
              buildTableSection(
                planets.firstWhere((element) =>
                element['value'] == _selectedName.value)['name']!,
                tableDataMap.firstWhere((element) =>
                element['name'] == _selectedName.value)['value'] ??
                    [],
                AppImages.kundali,
                AppImages.kundaliImage,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget buildTableSection(String title, List<Map<String, dynamic>> tableData,
      String headerImage, String footerImage) {
    if (tableData.isEmpty || tableData.length < 2) {
      return Center(
          child: Text("No table data available",
              style: TextStyle(fontSize: 16.sp)));
    }
    // Extract headers and rows data with null checks
    final headers = tableData[0]['headers'] as List<String>? ?? [];
    final rowsData = tableData[1]['rowsData'] as List<List<String>>? ?? [];

    // Ensure that headers and rows are not empty before proceeding
    if (headers.isEmpty || rowsData.isEmpty) {
      return Center(
          child: Text("No table data to display",
              style: TextStyle(fontSize: 16.sp)));
    }

    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              headerImage,
              height: 5.h,
              width: 5.w,
              color: AppColors.headerColor,
            ),
            SizedBox(
              width: 2.w,
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 17.sp,
                  color: AppColors.headerColor,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
        SizedBox(
          height: 2.h,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DataTable(
              dataRowHeight: 26.sp,
              columnSpacing: 24.sp,
              border:
                  TableBorder.all(color: CkColors.glassStroke, width: 1.sp),
              columns: [
                DataColumn(label: Text(headers[0])),
              ],
              rows: rowsData.map((row) {
                return DataRow(
                  cells: [
                    DataCell(Text(
                      row[0],
                      style: TextStyle(
                        color: AppConstants.getRowColor(row[0]),
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24.sp,
                  dataRowHeight: 26.sp,
                  border: TableBorder.all(
                      color: CkColors.glassStroke, width: 2.sp),
                  columns: headers.sublist(1).map((header) {
                    return DataColumn(
                      label: Text(
                        header,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  rows: rowsData.map((row) {
                    return DataRow(
                      cells: row.sublist(1).map((cell) {
                        return DataCell(
                          Text(cell),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 2.h,
        ),
      ],
    );
  }
}