import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/kundali_controller.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class SaniPanoti extends StatelessWidget {
  SaniPanoti({super.key});

  final KundaliController _kundaliController =
      Get.find(tag: GetTags.kundaliTag);

  @override
  Widget build(BuildContext context) {
    _kundaliController.getShaniPanotiData();

    return RefreshIndicator(
       onRefresh: ()async{
         _kundaliController.getShaniPanotiData();
       },
      child: CkScaffold(
        body: Obx(() {
          if (_kundaliController.isLoading.value ||
              _kundaliController.saniPanotiModel == null) {
            return const Center(child: CircularProgressIndicator());
          }

          else if(_kundaliController.isError.value){
            return Center(
              child: Text('Something went wrong!!!'),
            );
          }


          else {
            return Container(
              padding: EdgeInsets.all(17.sp),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                        AppColors.grey.withOpacity(0.25)),
                    columnSpacing: 15.sp,
                    dataRowHeight: 24.sp,
                    border: TableBorder.all(color: AppCkColors.textMuted),
                    columns: [
                      DataColumn(label: Text("Panoti".tr)),
                      DataColumn(label: Text("Rashi".tr)),
                      DataColumn(label: Text("Start Date".tr)),
                      DataColumn(label: Text("End Date".tr)),
                      DataColumn(label: Text("Duration".tr)),
                    ],
                    rows: _kundaliController.saniPanotiModel!.list!.map((panoti) {
                      return DataRow(
                        cells: [
                          DataCell(Text(panoti.panoti.toString())),
                          DataCell(Text(panoti.rashi.toString())),
                          DataCell(Text(panoti.startDate.toString())),
                          DataCell(Text(panoti.endDate.toString())),
                          DataCell(Text(panoti.duration.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}
