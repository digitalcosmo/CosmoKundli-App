import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/kundali_controller.dart';
import 'package:cosmo_kundali/controllers/other_controller.dart';
import 'package:cosmo_kundali/screens/other_screens/ashatkoot_melapak.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../values/get_tags.dart';

class Gochar extends StatefulWidget {
  Gochar({super.key});

  @override
  State<Gochar> createState() => _GocharState();
}

class _GocharState extends State<Gochar> {
  final OtherController otherController = Get.find(tag: GetTags.otherTag);

  final KundaliController kundaliController = Get.find(tag: GetTags.kundaliTag);

  final List<String> timeUnits = [
    '10 Years',
    'Year',
    'Month',
    'Week',
    'Day',
    'Hour',
    'Real Time'
  ];

  final List<Color> colors = [
    Colors.brown,
    Colors.red,
    CkColors.text,
    Colors.red,
    Colors.green,
    Colors.orangeAccent,
    Colors.deepPurpleAccent,
    CkColors.linkBlue,
    CkColors.textMuted,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      otherController.fetchGocharTableData();
      kundaliController.fetchBirthPlanetInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Obx(
        () => SingleChildScrollView(
          child: otherController.isLoading.value ||
                  otherController.gocharTable == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "gochar_animated".tr,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                            color: AppColors.smallText),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        "inner_birth_chart".tr + " | " + "outer_gochar".tr,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: Image.asset(AppImages.gochar),
                      // ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Table(
                          border: TableBorder.all(),
                          children: timeUnits.map((unit) {
                            return unit != 'Real Time'
                                ? _buildTableRow(unit)
                                : _buildRealTimeRow();
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Text(
                        'planetary_birth_kundali'.tr,
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.sp),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStatePropertyAll(
                                Colors.grey.withOpacity(0.50)),
                            border: TableBorder.all(
                                color: CkColors.textMuted, width: 2.sp),
                            horizontalMargin: 4.sp,
                            headingRowHeight: 5.h,
                            dataRowHeight: 23.sp,
                            columns: <DataColumn>[
                              DataColumn(
                                label: Text('planet'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('rashi'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('degree'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('nakshatra'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                            rows: List<DataRow>.generate(
                              kundaliController
                                  .birthPlanetInfoModel?.planets.length ?? 0,
                              (index) => DataRow(
                                // color: MaterialStateProperty.resolveWith<Color>(
                                //       (Set<MaterialState> states) {
                                //     return colors[index  % colors.length];
                                //   },
                                // ),
                                cells: <DataCell>[
                                  DataCell(Container(
                                    child: Text(
                                      kundaliController.birthPlanetInfoModel!
                                          .planets[index].planet,
                                      style: TextStyle(
                                        color: colors[index % colors.length],
                                      ),
                                    ),
                                  )),
                                  DataCell(Container(
                                    // color: colors[index % colors.length],
                                    child: Text(kundaliController
                                        .birthPlanetInfoModel!
                                        .planets[index]
                                        .rashi),
                                  )),
                                  DataCell(Container(
                                    // color: colors[index % colors.length],
                                    child: Text(kundaliController
                                        .birthPlanetInfoModel!
                                        .planets[index]
                                        .degree
                                        .toString()),
                                  )),
                                  DataCell(Container(
                                    //  color: colors[index % colors.length],
                                    child: Text(kundaliController
                                        .birthPlanetInfoModel!
                                        .planets[index]
                                        .nakshatra
                                        .toString()),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Text(
                        'gochar_kundali'.tr,
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.sp),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStatePropertyAll(
                                Colors.grey.withOpacity(0.50)),
                            border: TableBorder.all(
                                color: CkColors.textMuted, width: 2.sp),
                            horizontalMargin: 4.sp,
                            headingRowHeight: 5.h,
                            dataRowHeight: 23.sp,
                            columns: <DataColumn>[
                              DataColumn(
                                label: Text('planet'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('rashi'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('degree'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              DataColumn(
                                label: Text('nakshatra'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                            rows: List<DataRow>.generate(
                              otherController.gocharTable?.planets?.length ?? 0,
                              (index) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Container(
                                    //color: colors[index % colors.length],
                                    child: Text(
                                      otherController.gocharTable
                                              ?.planets?[index].planet
                                              .toString() ??
                                          '',
                                      style: TextStyle(
                                        color: colors[index % colors.length],
                                      ),
                                    ),
                                  )),
                                  DataCell(Container(
                                    //color: colors[index % colors.length],
                                    child: Text(otherController
                                            .gocharTable?.planets?[index].rashi
                                            .toString() ??
                                        ''),
                                  )),
                                  DataCell(Container(
                                    //color: colors[index % colors.length],
                                    child: Text(otherController
                                            .gocharTable?.planets?[index].degree
                                            .toString() ??
                                        ''),
                                  )),
                                  DataCell(Container(
                                    //color: colors[index % colors.length],
                                    child: Text(otherController.gocharTable
                                            ?.planets?[index].nakshatra
                                            .toString() ??
                                        ''),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }


  TableRow _buildTableRow(String unit) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(unit, style: const TextStyle(fontSize: 16)),
        ),
        GestureDetector(
          onTap: () {
            otherController.decrementDays(unit);
          },
          child: SizedBox(
            height: 6.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child: Image.asset(AppImages.previous),
                  onTap: () {
                    otherController.decrementDays(unit);
                  },
                ),
                Text("previous".tr),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            otherController.incrementDays(unit);
          },
          child: Container(
            height: 6.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("next".tr),
                GestureDetector(
                    onTap: () {
                      otherController.incrementDays(unit);
                    },
                    child: Image.asset(
                      AppImages.next,
                    ))
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildRealTimeRow() {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text('Real Time', style: TextStyle(fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              otherController.selectedDateGochar.value = DateTime.now();
              debugPrint(otherController.selectedDateGochar.value.toString());
            },
            child: Text('Current Time',
                style: TextStyle(fontSize: 15, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: CkColors.linkBlue,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
            ),
          ),
        ),
        const SizedBox(),
      ],
    );
  }
}


