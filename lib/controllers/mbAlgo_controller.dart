import 'dart:convert';

import 'package:cosmo_kundali/custom_widgets/main_week_picker.dart';
import 'package:cosmo_kundali/models/download_report.dart';
import 'package:cosmo_kundali/models/star_power_report_daily.dart';
import 'package:cosmo_kundali/repo/mb_algo_repo.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/gochar_prbhav.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/user_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';

import '../models/cosmo_power_report.dart';
import '../models/gochar_prabhav_model.dart';
import '../models/periodic_monthly_report.dart';
import '../models/star_power_report_model.dart';
import '../values/app_constants.dart';
import '../values/get_tags.dart';
import 'home_controller.dart';

class MbalgoController extends GetxController {
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxInt selectedIconIndex = 0.obs;
  RxString selectedGrah = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxBool isActive = false.obs;
  MbAlgoRepo mbAlgoRepo = MbAlgoRepo();
  StarPowerReportDaily? starPowerReportDaily;
  StarPowerReport? starPowerReport;
  CosmoPowerModel? cosmoPowerReport;
  PeriodicMonthlyReportModel? periodicMonthlyReport;
  GocharPrabhavModel? gocharPrabhav;
  DownloadReport? downloadReport;
  RxList<StarPowerReportDailyList> starPowerReportDailyList =
      <StarPowerReportDailyList>[].obs;
  RxList<PeriodicMonthlyReportList> periodicMonthlyReportList =
      <PeriodicMonthlyReportList>[].obs;
  RxList<CosmoPowerList> cosmoPowerReportDailyList = <CosmoPowerList>[].obs;
  RxList starPowerReportList = [].obs;
  final dio = Dio();
  RxString mId = ''.obs;
  RxList<GocharPrabhavList> gocharPrabhavList = <GocharPrabhavList>[].obs;
  RxList<ChartData> chartData = <ChartData>[].obs;
  List<Map<String, dynamic>> gocharResult = [];
  final HomeController homeController = Get.find(tag: GetTags.homeTag);

  //Week Logic
  Rx<DateTime> initialDate = DateTime.now().obs;
  Rx<DateTime> initialDateCalendar = DateTime.now().obs;
  var selectedDateFromPicker = DateTime.now().obs;
  RxString formatedWeekDays = ''.obs;

  @override
  void onInit() {
    getMID();
    debugPrint("MID:" + mId.value);
    //fetchCosmoPowerReport();
    fetchStarPowerReport("Career");
    fetchPeriodicMonthlyReport();
    gocharPrbhav("Lagan");
    super.onInit();
  }

  getMID() async {
    mId.value = Get.find<HomeController>(tag: GetTags.homeTag).mId.toString();
    //mId.value = (await UserData.getmID()) ?? '';
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      mbalgoController.gocharPrbhav(mbalgoController.selectedGrah.value);
    }
  }

  Future<void> selectMonth(BuildContext contex) async {
    DateTime? picked = await showMonthPicker(
        context: contex,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime(2100));

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  // Future<void> selectWeek(BuildContext context) async {
  //   DateTime? selected = await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         content: WeekPickerWidget(
  //           startDate: DateTime.now(),
  //           initialDay: selectedDate.value,
  //           lastDay: DateTime.now(),
  //           onDateSelected: (val) {
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<Map<String, dynamic>?> selectWeek(BuildContext context) async {
    Map<String, dynamic>? selectedWeek = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: WeekPickerWidget(
            startDate: DateTime(DateTime.now().year, 1, 1),
            initialDay: DateTime.now(),
            lastDay: DateTime(DateTime.now().year, 12, 31),
            onDateSelected: (val) {
              // Navigator.pop(context, val);
            },
          ),
        );
      },
    );

    if (selectedWeek != null) {
      // Week number and selected date
      int selectedWeekNumber = selectedWeek['weekNumber'];
      selectedDate.value = selectedWeek['date'];
      fetchStarPowerReport(
          AppConstants.iconList[selectedIconIndex.value]['name'].toString() ??
              'Career');

      print("Selected week number: $selectedWeekNumber");
      print("Selected date: $selectedDate");
    }

    return selectedWeek;
  }

  void selectIcon(int index) {
    selectedIconIndex.value = index;
  }

  void downloadPdf() async {
    try {
      // FileDownloader.downloadFile(
      //   url: 'https://www.orimi.com/pdf-test.pdf',
      //   name: 'Test',
      //   downloadDestination: DownloadDestinations.appFiles,
      //   notificationType: NotificationType.all,
      //   onDownloadError: (val){
      //     debugPrint('Error $val');
      //   },
      //
      // );
    } catch (e, s) {
      debugPrint('Error $e');
      debugPrint('Error $s');
    }
  }

  void setLoading(bool newValue) => isLoading.value = newValue;

  void setError(bool newValue) => isError.value = newValue;

  void fetchStarPowerReportDaily() async {
    Map<String, dynamic> data = {
      "mID": mId.value,
      "Month": DateFormat('yyyy-MM').format(selectedDate.value),
    };
    debugPrint("Daily:" + data.toString());
    try {
      setLoading(true);
      starPowerReportDaily = await mbAlgoRepo.getStarPowerReportDaily(data);
      setLoading(false);
      if (starPowerReportDaily!.status == true) {
        starPowerReportDailyList.value = starPowerReportDaily!.list!
            .map((item) => StarPowerReportDailyList.fromJson(item.toJson()))
            .toList();

        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (s) {
      debugPrint(s.toString());
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void fetchCosmoPowerReport() async {
    Map<String, dynamic> data = {
      "mID": mId.value,
      "Month": DateFormat('yyyy-MM').format(selectedDate.value)
    };
    debugPrint("Cosmo Data :" + data.toString());

    try {
      setLoading(true);
      cosmoPowerReport = await mbAlgoRepo.getCosmoPowerReport(data);

      setLoading(false);
      if (cosmoPowerReport!.status == true) {
        cosmoPowerReportDailyList.value = cosmoPowerReport!.list!
            .map((item) => CosmoPowerList.fromJson(item.toJson()))
            .toList();

        debugPrint(jsonEncode(cosmoPowerReportDailyList.value.toString()));

        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (s) {
      debugPrint(s.toString());
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void fetchStarPowerReport(String type) async {
    Map<String, dynamic> data = {
      "mID": mId.value,
      "Type": type,
      "Weeknumber": getWeekNumber(selectedDate.value),
      "Year": DateFormat('yyyy').format(selectedDate.value),
    };

    debugPrint('Star Power Data $data');

    try {
      setLoading(true);
      Map<String, dynamic> starPowerMap =
          await mbAlgoRepo.getStarPowerReport(data);
      setLoading(false);

      if (starPowerMap['status'] == true) {
        List<Map<String, dynamic>> reportList = [];
        if (starPowerMap.containsKey('list') && starPowerMap['list'] is List) {
          List<dynamic> list = starPowerMap['list'];
          if (list.isNotEmpty && list[0] is Map<String, dynamic>) {
            Map<String, dynamic> dayValues = list[0];
            dayValues.forEach((day, value) {
              reportList.add({
                'day': day, // Changed 'title' to 'day'
                'value': value.toDouble(),
              });
            });
          }
        }
        starPowerReportList.value = reportList;

        debugPrint('Star Power Res ${starPowerReportList.value}');
      } else {
        // Handle failure case
      }
    } catch (e, s) {
      setLoading(false);
      setError(true);
    }
  }

  void fetchPeriodicMonthlyReport() async {
    Map<String, dynamic> data = {
      "mID": mId.value,
      "Month": DateFormat('yyyy-MM').format(selectedDate.value)
    };

    debugPrint('Periodic Data $data');

    try {
      setLoading(true);
      periodicMonthlyReport = await mbAlgoRepo.getPeriodicMonthlyReport(data);

      setLoading(false);

      if (periodicMonthlyReport!.status == true) {
        periodicMonthlyReportList.value = periodicMonthlyReport!.list!
            .map((item) => PeriodicMonthlyReportList.fromJson(item.toJson()))
            .toList();
        for (int i = 0; i < periodicMonthlyReportList.value.length; i++) {}

        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }

      debugPrint('Periodic Data ${jsonEncode(periodicMonthlyReport)}');
    } catch (e, s) {
      setLoading(false);
      setError(true);
      debugPrint('Periodic Data Catch ${e.toString()}');
      debugPrint('Periodic Data Catch ${s.toString()}');
      //Services.snackBarError(context, e.toString());
    }
  }

  void gocharPrbhav(String grah) async {
    Map<String, dynamic> data = {
      "mID": mId.value,
      "Date": DateFormat('yyyy-MM-dd').format(selectedDate.value),
      "grah": grah
    };
    debugPrint('Gochar Data $data');
    try {
      setLoading(true);
      gocharPrabhav = await mbAlgoRepo.gocharPrabhav(data);
      setLoading(false);

      if (gocharPrabhav!.status == true) {
        gocharPrabhavList.value = gocharPrabhav!.list!;
        for (int i = 0; i < gocharPrabhavList.value.length; i++) {
          chartData.value.add(ChartData(gocharPrabhavList[i].title.toString(),
              gocharPrabhavList[i].value!.toDouble()));
        }
      }
      debugPrint('Gochar Res ${jsonEncode(gocharPrabhav)}');
    } catch (e, s) {
      debugPrint('Gochar Catch $e');
      debugPrint('Gochar Catch $s');
    }
  }

  void generate3MonthReport(BuildContext context) async {
    Map<String, dynamic> data = {
      "uID": await UserData.getuID(),
      "mID": mId.value,
      "Month": DateFormat('yyyy-MM').format(selectedDate.value),
      // yyyy-MM formate
    };
    debugPrint('Gochar Data $data');
    try {
      setLoading(true);
      downloadReport = await mbAlgoRepo.download3MonthReport(data);
      setLoading(false);

      if (downloadReport!.status == true) {
        Services.snackBarSuccess(context,
            "${downloadReport?.msg} You can see it in report history section");
      }
      debugPrint('Gochar Res ${jsonEncode(gocharPrabhav)}');
    } catch (e, s) {
      debugPrint('Gochar Catch $e');
      debugPrint('Gochar Catch $s');
    }
  }

  void generate6MonthReport(BuildContext context) async {
    Map<String, dynamic> data = {
      "uID": await UserData.getuID(),
      "mID": mId.value,
      "Month": DateFormat('yyyy-MM').format(selectedDate.value),
      // yyyy-MM formate
    };
    debugPrint('Gochar Data $data');
    try {
      setLoading(true);
      downloadReport = await mbAlgoRepo.download6MonthReport(data);
      setLoading(false);

      if (downloadReport!.status == true) {
        Services.snackBarSuccess(context,
            "${downloadReport?.msg} You can see it in report history section");
      }
      debugPrint('Gochar Res ${jsonEncode(gocharPrabhav)}');
    } catch (e, s) {
      debugPrint('Gochar Catch $e');
      debugPrint('Gochar Catch $s');
    }
  }

  void generate12MonthReport(BuildContext context) async {
    debugPrint("done");
    Map<String, dynamic> data = {
      "uID": await UserData.getuID(),
      "mID": mId.value,
      "Month": DateFormat('yyyy-MM').format(selectedDate.value),
      // yyyy-MM formate
    };

    try {
      setLoading(true);
      downloadReport = await mbAlgoRepo.download12MonthReport(data);
      setLoading(false);
      debugPrint("done" + jsonEncode(downloadReport));

      if (downloadReport!.status == true) {
        debugPrint('Gochar Data $data');
        Services.snackBarSuccess(context,
            "${downloadReport?.msg} You can see it in report history section");
      }
    } catch (e, s) {
      debugPrint('Gochar Catch $e');
      debugPrint('Gochar Catch $s');
    }
  }

  Map<String, dynamic> getWeekInfo(DateTime date) {
    int weekNumber = getWeekNumber(date);
    int weekday = date.weekday;
    DateTime weekStartDate = date.subtract(Duration(days: weekday - 1));
    DateTime weekEndDate = weekStartDate.add(Duration(days: 6));

    String formattedWeek = 'WK- $weekNumber\n'
        '${DateFormat('d MMM').format(weekStartDate)} to ${DateFormat('d MMM').format(weekEndDate)}';

    String formattedWeekShort = 'WK- $weekNumber\n'
        '${DateFormat('d MMM').format(weekStartDate)} to ${DateFormat('d MMM').format(weekEndDate)}';

    String formattedWeekOuter = '$weekNumber ${weekStartDate.year}';

    Map<String, dynamic> weekData = {
      'weekNumber': weekNumber,
      'weekStartDate': weekStartDate,
      'weekEndDate': weekEndDate,
      'formattedWeek': formattedWeek, // Full formatted string
      'formattedWeekShort': formattedWeekShort,
      'formattedWeekOuter': formattedWeekOuter,
    };

    //debugPrint('Week Data $weekData');

    return weekData;
  }

  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

//
// Future<void> getMonthlyData(
//     {required String date, BuildContext? context}) async {
//   Map<String, dynamic> data = {
//     "uID": await UserData.getUserId(),
//     "month": date,
//     "app_id": await UserData.getAppId(),
//   };
//   setLoading(true);
//
//   Map<String, dynamic> reportModel = await reportRepo.getMonthlyData(data);
//
//   if (reportModel['status'] == true) {
//     isNext = reportModel['next'];
//     isPrevious = reportModel['previous'];
//
//     reportModel.removeWhere(
//           (key, value) => key == 'status',
//     );
//     reportModel.removeWhere(
//           (key, value) => key == 'message',
//     );
//
//     reportModel.removeWhere(
//           (key, value) => key == 'next',
//     );
//     reportModel.removeWhere(
//           (key, value) => key == 'previous',
//     );
//     reportModel.forEach((key, value) {
//       rashiList.value.add({
//         'title': key,
//         'value': value,
//       });
//     });
//
//     rashiList.value = removeDuplicates(rashiList.value);
//
//     setLoading(false);
//   } else {
//     Services.snackBarError(context!, AppMessages.subscriptionMessage);
//     setLoading(false);
//   }
// }
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}
