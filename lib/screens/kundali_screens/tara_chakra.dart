import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/kundali_controller.dart';
import '../../values/get_tags.dart';

class TaraChakra extends StatelessWidget {
  TaraChakra({super.key});

  final KundaliController _kundaliController =
      Get.find(tag: GetTags.kundaliTag);

  @override
  Widget build(BuildContext context) {
    if (!_kundaliController.isTaraChakraApiCalled) {
      Future.microtask(
        () => _kundaliController.taraChakraData(),
      );
    }

    return CkScaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.all(20.sp),
          child: Obx(() {
            if (_kundaliController.isLoading.value ||
                _kundaliController.taraChakra == null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              List<DataRow> dataRows =
                  _kundaliController.taraChakra!.list!.map((item) {
                List<DataCell> cells = [
                  DataCell(Text(item.tara ?? '',
                      style: TextStyle(fontWeight: FontWeight.w500))),
                ];
                List<String> nakshatras = item.nakshatra?.split(',') ?? [];
                cells.addAll(
                  nakshatras
                      .map((nak) => DataCell(Text(nak,
                          style: TextStyle(fontWeight: FontWeight.w500))))
                      .toList(),
                );
                int maxCells = _kundaliController.taraChakra!.list!
                        .map((item) => item.nakshatra?.split(',').length ?? 0)
                        .reduce((a, b) => a > b ? a : b) +
                    1;
                while (cells.length < maxCells) {
                  cells.add(DataCell(Text('')));
                }

                return DataRow(cells: cells);
              }).toList();

              List<DataColumn> dataColumns = [
                DataColumn(
                    label: Text("tara".tr,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("nakshatra".tr,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ];
              int maxColumns = _kundaliController.taraChakra!.list!
                  .map((item) => item.nakshatra?.split(',').length ?? 0)
                  .reduce((a, b) => a > b ? a : b);
              for (int i = 0; i < maxColumns - 1; i++) {
                dataColumns.add(DataColumn(
                    label: Text('',
                        style: TextStyle(fontWeight: FontWeight.bold))));
              }

              return DataTable(
                columnSpacing: 15.sp,
                headingRowColor:
                    const WidgetStatePropertyAll(AppColors.table_header),
                border: TableBorder.all(),
                columns: dataColumns,
                rows: dataRows,
              );
            }
          }),
        ),
      ),
    );
  }
}
