import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:io';

import 'package:cosmo_kundali/controllers/profile_controller.dart';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../services/services.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';
import '../../values/tr_strings.dart';

class ReportHistory extends StatefulWidget {
  const ReportHistory({super.key});

  @override
  State<ReportHistory> createState() => _ReportHistoryState();
}

class _ReportHistoryState extends State<ReportHistory> {
  late String _localPath;
  late TargetPlatform? platform;

  final ProfileController profileController =
      Get.put(ProfileController(), tag: GetTags.profileTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.fetchReportHistory();
    if (Platform.isAndroid) {
      platform = TargetPlatform.android;
    } else {
      platform = TargetPlatform.iOS;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainBgframe(
      child: Column(
        children: [
          SizedBox(height: 5.h),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Services.back();
                },
                child: Image.asset(
                  AppImages.previousGradient,
                  width: 5.w,
                  height: 5.h,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                TrStrings.reportHistory,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
              )
            ],
          ),
          SizedBox(height: 10.h),

          Obx(() {
            if (profileController.isLoading.value) {
              return Center(
                  child: CircularProgressIndicator());
            }
             if (profileController.reportList.length == 0) {
              return Center(
                  child: Text("No Records Found !! "));
            }
            return Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                        CkColors.text.withOpacity(0.30)),
                    border:
                        TableBorder.all(color: CkColors.text.withOpacity(0.50)),
                    columns: [
                      DataColumn(label: Text("date".tr)),
                      DataColumn(label: Text("details".tr)),
                      DataColumn(label: Text("details".tr)),
                      DataColumn(label: Text("details".tr)),
                      DataColumn(label: Text("details".tr)),
                    ],
                    rows: profileController.reportList.map((report) {
                      return DataRow(cells: [
                        DataCell(Text(report.date!)),
                        DataCell(Text(report.type!)),
                        DataCell(Text(report.name!)),
                        DataCell(Text(report.month!)),
                        DataCell(
                          GestureDetector(
                            onTap: () async {
                              try {
                                downloadPdfDio(
                                    report.downloadLink!, "${report.name}.pdf");
                              } catch (s) {
                                debugPrint(s.toString());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'An error occurred. Please try again.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            child:
                                const Icon(Icons.download, color: CkColors.linkBlue),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> downloadPdfDio(String url, String filename) async {
    // Check for storage permission

    Dio dio = Dio();

    Services.snackBarSuccess(context, 'Download Started');

    try {
      // Get the downloads directory
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory != null) {
        final savePath = '${downloadsDirectory.path}/$filename';

        await dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print('${(received / total * 100).toStringAsFixed(0)}%');
              // You can update a progress indicator here
            }
          },
        );
        Services.snackBarSuccess(
            context, 'Download Success. Access this file in download folder');
      } else {
        Services.snackBarError(
            context, 'Could not access the downloads directory.');
      }
    } catch (e) {
      Services.snackBarError(context, '$e');
    }
  }
}

class Report {
  final String date;
  final String details;

  Report({required this.date, required this.details});
}
