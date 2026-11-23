import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:convert';

import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/kundali_controller.dart';
import '../../models/dasha_model.dart';
import '../../services/services.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class DashaDetail extends StatefulWidget {
  final int index;

  const DashaDetail({super.key, required this.index});

  @override
  State<DashaDetail> createState() => _DashaDetailState();
}

class _DashaDetailState extends State<DashaDetail> {
  final KundaliController kundaliController = Get.find(tag: GetTags.kundaliTag);
  RxInt isVisible = 0.obs;
  RxBool isVisibleBool = false.obs;

  @override
  void initState() {
    super.initState();
    debugPrint(
        jsonEncode(kundaliController.dashaModel!.list![widget.index].list!)
            .toString());
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      appBar: AppBar(
        foregroundColor: AppColors.headerColor,
        title: Text(
          kundaliController.dashaModel!.list![0].list![widget.index].grah
              .toString(),
          style: const TextStyle(
              color: AppColors.headerColor, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(15.sp),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "dasha_header".tr,
                    style: TextStyle(
                        color: AppColors.headerColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 17.sp),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Container(
                    height: 10.h,
                    padding: EdgeInsets.all(7.sp),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.sp),
                        color: AppColors.skin_color.withOpacity(0.25),
                        border: Border.all(color: AppColors.skin_color)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "dasha_balance".tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.sp),
                              ),
                              Text(
                                ': ${kundaliController.dashaModel!.dashaBalanceGrah}: '
                                '${kundaliController.dashaModel!.dashaBalance}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: CkColors.textSecondary,
                                ),
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "dasha_balance".tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp),
                              ),
                              Text(
                                ':${kundaliController.dashaModel!.subGrah1}-${kundaliController.dashaModel!.subGrah2}-${kundaliController.dashaModel!.subGrah3}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: CkColors.textSecondary),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Container(
                    padding: EdgeInsets.all(10.sp),
                    height: 5.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.sp),
                        color: Services.colorOfGrahs(
                            type: AppConstants.grahs[widget.index].toString()),
                        border: Border.all(
                            width: 2,
                            color: Services.colorOfGrahs(
                                type: AppConstants.grahs[widget.index]
                                    .toString()))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          kundaliController
                              .dashaModel!.list![widget.index].title
                              .toString(),
                          style: const TextStyle(
                              color: CkColors.textSecondary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DataTable(
                          headingRowColor:
                              const WidgetStatePropertyAll(AppCkColors.textMuted),
                          horizontalMargin: 16.sp,
                          border:
                              TableBorder.all(color: CkColors.glassStroke),
                          columns: const [
                            DataColumn(
                              label: Text(
                                '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: kundaliController.dashaModel!.list![0].list!
                              .map((row) {
                            int rowIndex = kundaliController
                                .dashaModel!.list![0].list!
                                .indexOf(row);

                            return DataRow(
                              cells: [
                                DataCell(
                                  Obx(
                                    () => GestureDetector(
                                      child: Image.asset(
                                        isVisible.value == rowIndex
                                            ? AppImages.downward
                                            : AppImages.forwardIos,
                                        height: 30.sp,
                                        width: 30.sp,
                                      ),
                                      onTap: () {
                                        debugPrint(
                                            'Sub Data ${jsonEncode(kundaliController.dashaModel!.list![widget.index].list![rowIndex])}');

                                        Map<String, dynamic> res =
                                            kundaliController
                                                .dashaModel!
                                                .list![widget.index]
                                                .list![rowIndex]
                                                .toJson();

                                        List<String> grahNames = res.entries
                                            .where((entry) => entry.key.startsWith(
                                                "Row")) // Filter only 'Row' keys
                                            .map((entry) => entry.value["Grah"]
                                                as String) // Extract 'Grah' values
                                            .toList();

                                        if (kundaliController
                                                .dashaModel!
                                                .list![widget.index]
                                                .list![rowIndex]
                                                .start !=
                                            null) {
                                          isVisible.value =
                                              isVisible.value == rowIndex
                                                  ? -1
                                                  : rowIndex;
                                          debugPrint(
                                              "IS VISIBLE :${isVisible.value}");
                                          isVisibleBool.value = true;
                                          kundaliController.setIndex(rowIndex);
                                        }
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Obx(() => Dialog(
                                                  child: Container(
                                                    color: Colors.white,
                                                    width: double.infinity,
                                                    child: FittedBox(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          DataTable(
                                                              headingRowColor:
                                                                  const WidgetStatePropertyAll(
                                                                      AppColors
                                                                          .grey),
                                                              border: TableBorder.all(
                                                                  color: const Color(
                                                                      0xffB9B9B9)),
                                                              columns: [
                                                                DataColumn(
                                                                  label: Text(
                                                                    "grah".tr,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ],
                                                              rows:
                                                                  List.generate(
                                                                grahNames
                                                                    .length,
                                                                (index) {
                                                                  return DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                          Text(
                                                                            grahNames[index],
                                                                            style: TextStyle(
                                                                              color: AppConstants.grah_colors[grahNames[index]] ?? CkColors.text,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ]);
                                                                },
                                                              )),
                                                          SizedBox(
                                                            width: 2.w,
                                                          ),
                                                          DataTable(
                                                            horizontalMargin:
                                                                6.sp,
                                                            border: TableBorder.all(
                                                                color: const Color(
                                                                    0xffB9B9B9)),
                                                            headingRowColor:
                                                                const WidgetStatePropertyAll(
                                                                    AppColors
                                                                        .grey),
                                                            columns: [
                                                              DataColumn(
                                                                  label: Text(
                                                                      "start_date"
                                                                          .tr)),
                                                              DataColumn(
                                                                  label: Text(
                                                                      "end_date"
                                                                          .tr)),
                                                            ],
                                                            rows: [
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row1
                                                                          ?.start
                                                                          ?.toString() ??
                                                                      '')),
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row1
                                                                          ?.end
                                                                          ?.toString() ??
                                                                      '')),
                                                                ],
                                                              ),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row2
                                                                          ?.start
                                                                          ?.toString() ??
                                                                      '')),
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row2
                                                                          ?.end
                                                                          ?.toString() ??
                                                                      '')),
                                                                ],
                                                              ),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row3
                                                                          ?.start
                                                                          ?.toString() ??
                                                                      '')),
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row3
                                                                          ?.end
                                                                          ?.toString() ??
                                                                      '')),
                                                                ],
                                                              ),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row4
                                                                          ?.start
                                                                          ?.toString() ??
                                                                      '')),
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row4
                                                                          ?.end
                                                                          ?.toString() ??
                                                                      '')),
                                                                ],
                                                              ),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row5
                                                                          ?.start
                                                                          ?.toString() ??
                                                                      '')),
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row5
                                                                          ?.end
                                                                          ?.toString() ??
                                                                      '')),
                                                                ],
                                                              ),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row6
                                                                          ?.start
                                                                          ?.toString() ??
                                                                      '')),
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row6
                                                                          ?.end
                                                                          ?.toString() ??
                                                                      '')),
                                                                ],
                                                              ),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(
                                                                    _dataShellChild(kundaliController
                                                                            .dashaModel
                                                                            ?.list?[widget.index]
                                                                            .list?[kundaliController.index.value]
                                                                            .row7
                                                                            ?.start
                                                                            ?.toString() ??
                                                                        ''),
                                                                  ),
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row7
                                                                          ?.end
                                                                          ?.toString() ??
                                                                      '')),
                                                                ],
                                                              ),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(_dataShellChild(kundaliController
                                                                          .dashaModel
                                                                          ?.list?[widget
                                                                              .index]
                                                                          .list?[kundaliController
                                                                              .index
                                                                              .value]
                                                                          .row8
                                                                          ?.start
                                                                          ?.toString() ??
                                                                      '')),
                                                                  DataCell(
                                                                    _dataShellChild(kundaliController
                                                                            .dashaModel
                                                                            ?.list?[widget.index]
                                                                            .list?[kundaliController.index.value]
                                                                            .row8
                                                                            ?.end
                                                                            ?.toString() ??
                                                                        ''),
                                                                  ),
                                                                ],
                                                              ),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(
                                                                      _dataShellChild(
                                                                    kundaliController
                                                                            .dashaModel
                                                                            ?.list?[widget.index]
                                                                            .list?[kundaliController.index.value]
                                                                            .row9
                                                                            ?.start
                                                                            ?.toString() ??
                                                                        '',
                                                                  )),
                                                                  DataCell(
                                                                    _dataShellChild(
                                                                      kundaliController
                                                                              .dashaModel
                                                                              ?.list?[widget.index]
                                                                              .list?[kundaliController.index.value]
                                                                              .row9
                                                                              ?.end
                                                                              ?.toString() ??
                                                                          '',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          // const SizedBox()
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        DataTable(
                          headingRowColor:
                              const WidgetStatePropertyAll(AppCkColors.textMuted),
                          border:
                              TableBorder.all(color: CkColors.glassStroke),
                          columns: [
                            DataColumn(
                              label: Text(
                                "sun_sign".tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: kundaliController
                              .dashaModel!.list![widget.index].list!
                              .map((row) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    row.grah.toString(),
                                    style: TextStyle(
                                      color:
                                          AppConstants.grah_colors[row.grah] ??
                                              CkColors.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        DataTable(
                          horizontalMargin: 4.sp,
                          border:
                              TableBorder.all(color: CkColors.glassStroke),
                          headingRowColor:
                              const WidgetStatePropertyAll(AppCkColors.textMuted),

                          columns: [
                            DataColumn(label: _dataShellChild("start_date".tr)),
                            DataColumn(label: _dataShellChild("end_date".tr)),
                          ],
                          rows: kundaliController
                              .dashaModel!.list![widget.index].list!
                              .map((row) {
                            return DataRow(
                              cells: [
                                DataCell(_dataShellChild(
                                  row.start.toString(),
                                )),
                                DataCell(
                                  _dataShellChild(
                                    row.end.toString(),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          // [
                          //                   DataRow(
                          //                     cells: [
                          //                       DataCell(Text(kundaliController.dashaModel!.list![0].list![widget.index].row1.toString())),
                          //                       DataCell(Text('-')),
                          //                     ],
                          //                   ),
                          //                   const DataRow(
                          //                     cells: [
                          //                       DataCell(Text('-')),
                          //                       DataCell(Text('-')),
                          //                     ],
                          //                   ),
                          //                   DataRow(
                          //                     cells: [
                          //                       DataCell(Text('-')),
                          //                       DataCell(Text('-')),
                          //                     ],
                          //                   ),
                          //                   DataRow(
                          //                     cells: [
                          //                       DataCell(Text(kundaliController.dashaModel!.list![0].list![widget.index].row1.toString())),
                          //                       DataCell(Text('09/12/2001')),
                          //                     ],
                          //                   ),
                          //                   DataRow(
                          //                     cells: [
                          //                       DataCell(Text('09/12/2001')),
                          //                       DataCell(Text('27/12/2002')),
                          //                     ],
                          //                   ),
                          //                   DataRow(
                          //                     cells: [
                          //                       DataCell(Text('27/12/2002')),
                          //                       DataCell(Text('27/12/2005')),
                          //                     ],
                          //                   ),
                          //                   DataRow(
                          //                     cells: [
                          //                       DataCell(Text('27/12/2005')),
                          //                       DataCell(Text('20/11/2006')),
                          //                     ],
                          //                   ),
                          //                   DataRow(
                          //                     cells: [
                          //                       DataCell(Text('20/11/2006')),
                          //                       DataCell(Text('20/05/2008')),
                          //                     ],
                          //                   ),
                          //                   DataRow(
                          //                     cells: [
                          //                       DataCell(Text('20/05/2008')),
                          //                       DataCell(Text('08/06/2009')),
                          //                     ],
                          //                   ),
                          //                 ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  // kundaliController
                  //     .dashaModel!.list![0].list![widget.index].start !=
                  //     null
                  //     ? Obx(() =>
                  //     Visibility(
                  //         visible: isVisibleBool.value,
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             DataTable(
                  //               headingRowColor:
                  //               const WidgetStatePropertyAll(AppCkColors.textMuted),
                  //               border: TableBorder.all(
                  //                   color: CkColors.glassStroke),
                  //               columns: [
                  //                 DataColumn(
                  //                   label: Text(
                  //                     "grah".tr,
                  //                     style: const TextStyle(
                  //                         fontWeight: FontWeight.bold),
                  //                   ),
                  //                 ),
                  //               ],
                  //               rows: kundaliController.dashaModel?.list?[0]
                  //                   .list
                  //                   ?.map((row) {
                  //                 return DataRow(
                  //                   cells: [
                  //                     DataCell(
                  //                       Text(
                  //                         row.grah.toString(),
                  //                         style: TextStyle(
                  //                           color: AppConstants
                  //                               .grah_colors[row.grah] ??
                  //                               CkColors.text,
                  //                           fontWeight: FontWeight.w600,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 );
                  //               }).toList() ??
                  //                   [],
                  //             ),
                  //             SizedBox(
                  //               width: 2.w,
                  //             ),
                  //             DataTable(
                  //               horizontalMargin: 6.sp,
                  //               border: TableBorder.all(
                  //                   color: CkColors.glassStroke),
                  //               headingRowColor:
                  //               const WidgetStatePropertyAll(AppCkColors.textMuted),
                  //               columns: [
                  //                 DataColumn(label: Text("start_date".tr)),
                  //                 DataColumn(label: Text("end_date".tr)),
                  //               ],
                  //               rows: [
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row1
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row1
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row2
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row2
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row3
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row3
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row4
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row4
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row5
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row5
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row6
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row6
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row7
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row7
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row8
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row8
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //                 DataRow(
                  //                   cells: [
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row9
                  //                         ?.start
                  //                         ?.toString() ??
                  //                         '')),
                  //                     DataCell(Text(kundaliController
                  //                         .dashaModel
                  //                         ?.list?[0]
                  //                         .list?[
                  //                     kundaliController.index.value]
                  //                         .row9
                  //                         ?.end
                  //                         ?.toString() ??
                  //                         '')),
                  //                   ],
                  //                 ),
                  //               ],
                  //             ),
                  //             // const SizedBox()
                  //           ],
                  //         ))
                  // )
                  //
                  //     : const SizedBox()
                ])),
      ),
    );
  }

  Widget _dataShellChild(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text),
    );
  }
}
