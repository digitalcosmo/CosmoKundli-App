import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/kundali_controller.dart';
import 'package:cosmo_kundali/values/get_tags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../custom_widgets/main_loader.dart';
import '../../values/colors.dart';

class VimshottariView extends StatefulWidget {
  const VimshottariView({super.key});

  @override
  State<VimshottariView> createState() => _VimshottariViewState();
}

KundaliController _kundaliController =
    Get.find<KundaliController>(tag: GetTags.kundaliTag);

class _VimshottariViewState extends State<VimshottariView> {
  @override
  void initState() {
    super.initState();
    _kundaliController.vimshottriMahaDashaTable();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CkScaffold(
        appBar: AppBar(
          foregroundColor: AppColors.fontHeaderColor,
          title: Text(
            "vimshottari_maha_dasha".tr,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 19,
              color: AppColors.smallText,
            ),
          ),
        ),
        body: _kundaliController.isLoading.value ||
                _kundaliController.isVimshottriLoading.value == null
            ? Center(
                child: MainLoader(
                  isLoading: _kundaliController.isLoading.value,
                  child: Container(),
                ),
              )
            : Container(
                padding: EdgeInsets.all(20.sp),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder(
                      top: BorderSide(color: CkColors.text, width: 2.sp),
                      bottom: BorderSide(color: CkColors.text, width: 2.sp),
                      left: BorderSide(color: CkColors.text, width: 2.sp),
                      right: BorderSide(color: CkColors.text, width: 2.sp),
                      horizontalInside: BorderSide(color: CkColors.text, width: 2.sp),
                      verticalInside: BorderSide(color: CkColors.text, width: 2.sp), // Vertical Divider
                    ),
                    columnSpacing: 32.sp,
                    horizontalMargin: 10.sp,
                    dataRowMinHeight: 23.sp,
                    decoration: BoxDecoration(border: Border.all()),
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text('grah'.tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text('start'.tr,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataColumn(
                        label: Text('end'.tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    dividerThickness: 2,
                    rows: List<DataRow>.generate(
                      _kundaliController
                          .vimshottriMahaDashaModel.value.list!.length,
                      (index) => DataRow(
                        color: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            return Colors.white;
                          },
                        ),
                        cells: <DataCell>[
                          DataCell(Text(
                            _kundaliController.vimshottriMahaDashaModel.value
                                .list![index].planet
                                .toString(),
                            style: TextStyle(
                              color: _color(_kundaliController
                                  .vimshottriMahaDashaModel
                                  .value
                                  .list![index]
                                  .planet
                                  .toString()),
                            ),
                          )),
                          DataCell(
                            Text(
                              _kundaliController.vimshottriMahaDashaModel.value
                                  .list![index].startDate
                                  .toString(),
                            ),
                          ),
                          DataCell(
                            Text(
                              _kundaliController.vimshottriMahaDashaModel.value
                                  .list![index].endDate
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Color _color(String grahName) {
    switch (grahName) {
      case 'Venus':
        return const Color(0xffFF32FF);
      case 'Sun':
        return const Color(0xffff0000);
      case 'Moon':
        return CkColors.text;
      case 'Mars':
        return const Color(0xffff0000);
      case 'Rahu':
        return const Color(0xff808080);
      case 'Jupiter':
        return const Color(0xffff8c00);
      case 'Saturn':
        return CkColors.linkBlue;
      case 'Mercury':
        return const Color(0xff008000);
      case 'Ketu':
        return Color(0xffa52a2a);
      default:
        return CkColors.text;
    }
  }
}
