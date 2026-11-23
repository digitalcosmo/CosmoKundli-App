import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/other_controller.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';
import '../kundali_screens/temp.dart';

class AshatkootMelapak extends StatefulWidget {
  const AshatkootMelapak({super.key});

  @override
  State<AshatkootMelapak> createState() => _AshatkootMelapakState();
}

class _AshatkootMelapakState extends State<AshatkootMelapak> {
  final HomeController _homeController = Get.find(tag: GetTags.homeTag);
  final OtherController _otherController = Get.find(tag: GetTags.otherTag);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_otherController.isNewUser.value == false) {
        _otherController.matchKundali(mId: _homeController.mId.toString());
      } else {
        _otherController.addNewMember();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      appBar: AppBar(
        foregroundColor: AppColors.smallText,
        elevation: 0,
        title: Text(
          "ashatkoot_melapak".tr,
          style: const TextStyle(
            color: AppColors.smallText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => Container(
            padding: EdgeInsets.all(15.sp),
            child: _otherController.rows == null ||
                    _otherController.isLoading.value ||
                    _otherController.melapakDetailsExistingUser == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 15.sp,
                          dataRowHeight: 30.sp,
                          headingRowColor:
                              const WidgetStatePropertyAll(CkColors.glassStroke),
                          border: TableBorder.all(
                              color: CkColors.text.withOpacity(0.50)),
                          columns: [
                            const DataColumn(label: Text('Koot')),
                            DataColumn(
                                label: Text(_otherController
                                    .melapakDetailsExistingUser!.VarName)),
                            DataColumn(
                                label: Text(_otherController
                                    .melapakDetailsExistingUser!.VadhuName)),
                            const DataColumn(label: Text('Obtain Points')),
                            const DataColumn(label: Text('Max Points')),
                          ],
                          rows: _otherController.rows.value
                              .map(
                                (row) => DataRow(
                                  cells: [
                                    DataCell(Text(row['Koot'] ?? '')),
                                    DataCell(Text(row['name 1'] ?? '')),
                                    DataCell(Text(row['name 2'] ?? '')),
                                    DataCell(Text(row['obtain_points'] ?? '')),
                                    DataCell(Text(row['max_points'] ?? '')),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Obx(
                        () => Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: CkColors.textMuted)),
                          padding: EdgeInsets.all(10.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                _otherController.gun.value,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.smallText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${_otherController.melapakDetailsExistingUser!.VarName}`s Birth Chart',
                          style: TextStyle(
                              color: AppColors.smallText,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(
                        height: 55.h,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: KundaliWidget(
                            mid: _homeController.mId.value,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${_otherController.melapakDetailsExistingUser!.VadhuName}`s Birth Chart',
                          style: TextStyle(
                              color: AppColors.smallText,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(
                        height: 55.h,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: KundaliWidget(
                            mid: _otherController.oppId.value.toString(),
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
}
