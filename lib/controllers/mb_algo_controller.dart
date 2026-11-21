import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:cosmo_kundli/models/chart_data.dart';
import 'package:cosmo_kundli/models/cosmo_power_model.dart';
import 'package:cosmo_kundli/models/download_report_model.dart';
import 'package:cosmo_kundli/models/gochar_prabhav_model.dart';
import 'package:cosmo_kundli/models/periodic_monthly_report_model.dart';
import 'package:cosmo_kundli/models/star_power_report_daily_model.dart';
import 'package:cosmo_kundli/repos/mb_algo_repo.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/user_data.dart';

import 'home_controller.dart';

class MbAlgoController extends GetxController {
  final MbAlgoRepo _repo = MbAlgoRepo();
  final HomeController homeController = Get.find(tag: GetTags.homeTag);

  RxString mId = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;

  // Week/Date/Month pickers
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DateTime> selectedMonth = DateTime.now().obs;
  RxInt selectedIconIndex = 0.obs;

  // Data holders
  Rx<StarPowerReportDaily?> starPowerDailyData = Rx<StarPowerReportDaily?>(null);
  Rx<CosmoPowerModel?> cosmoPowerData = Rx<CosmoPowerModel?>(null);
  RxMap<String, dynamic> starPowerReportData = <String, dynamic>{}.obs;
  Rx<PeriodicMonthlyReportModel?> periodicMonthlyData = Rx<PeriodicMonthlyReportModel?>(null);
  Rx<GocharPrabhavModel?> gocharPrabhavData = Rx<GocharPrabhavModel?>(null);
  Rx<DownloadReport?> downloadReportData = Rx<DownloadReport?>(null);

  @override
  void onInit() {
    mId.value = homeController.mId.toString();
    fetchStarPowerReport("Career");
    fetchPeriodicMonthlyReport();
    gocharPrbhav("Lagan");
    super.onInit();
  }

  // ── Week helpers ──

  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (weekNumber < 1) {
      weekNumber = getWeekNumber(DateTime(date.year - 1, 12, 31));
    } else if (weekNumber > 52) {
      DateTime lastDay = DateTime(date.year, 12, 31);
      if (lastDay.weekday < DateTime.thursday) {
        weekNumber = 1;
      }
    }
    return weekNumber;
  }

  Map<String, dynamic> getWeekInfo(DateTime date) {
    int weekNumber = getWeekNumber(date);
    DateTime weekStart = date.subtract(Duration(days: date.weekday - 1));
    DateTime weekEnd = weekStart.add(const Duration(days: 6));
    return {
      'weekNumber': weekNumber,
      'weekStartDate': weekStart,
      'weekEndDate': weekEnd,
      'formattedWeek':
          '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM yyyy').format(weekEnd)}',
      'formattedWeekShort':
          '${DateFormat('dd/MM').format(weekStart)} - ${DateFormat('dd/MM').format(weekEnd)}',
      'formattedWeekOuter':
          'Week $weekNumber (${DateFormat('MMM yyyy').format(weekStart)})',
    };
  }

  Map<String, dynamic> selectWeek(DateTime date) {
    return getWeekInfo(date);
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectMonth(DateTime date) {
    selectedMonth.value = date;
  }

  // ── API calls ──

  Future<void> fetchStarPowerReportDaily() async {
    try {
      isLoading.value = true;
      String month = DateFormat('yyyy-MM').format(selectedMonth.value);
      Map<String, dynamic> data = {"mID": mId.value, "Month": month};
      starPowerDailyData.value = await _repo.getStarPowerReportDaily(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> fetchCosmoPowerReport() async {
    try {
      isLoading.value = true;
      String month = DateFormat('yyyy-MM').format(selectedMonth.value);
      Map<String, dynamic> data = {"mID": mId.value, "Month": month};
      cosmoPowerData.value = await _repo.getCosmoPowerReport(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> fetchStarPowerReport(String type) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> weekInfo = getWeekInfo(selectedDate.value);
      int weekNumber = weekInfo['weekNumber'];
      int year = selectedDate.value.year;
      Map<String, dynamic> data = {
        "mID": mId.value,
        "Weeknumber": weekNumber.toString(),
        "Year": year.toString(),
        "Type": type,
      };
      starPowerReportData.value = await _repo.getStarPowerReport(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> fetchPeriodicMonthlyReport() async {
    try {
      isLoading.value = true;
      String month = DateFormat('yyyy-MM').format(selectedMonth.value);
      Map<String, dynamic> data = {"mID": mId.value, "Month": month};
      periodicMonthlyData.value = await _repo.getPeriodicMonthlyReport(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> gocharPrbhav(String grah) async {
    try {
      isLoading.value = true;
      String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      Map<String, dynamic> data = {
        "mID": mId.value,
        "date": dateStr,
        "grah": grah,
      };
      gocharPrabhavData.value = await _repo.gocharPrabhav(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> generate3MonthReport() async {
    try {
      isLoading.value = true;
      String uID = await UserData.getuID() ?? '';
      String month = DateFormat('yyyy-MM').format(selectedMonth.value);
      Map<String, dynamic> data = {
        "uID": uID,
        "mID": mId.value,
        "Month": month,
      };
      downloadReportData.value = await _repo.download3MonthReport(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> generate6MonthReport() async {
    try {
      isLoading.value = true;
      String uID = await UserData.getuID() ?? '';
      String month = DateFormat('yyyy-MM').format(selectedMonth.value);
      Map<String, dynamic> data = {
        "uID": uID,
        "mID": mId.value,
        "Month": month,
      };
      downloadReportData.value = await _repo.download6MonthReport(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> generate12MonthReport() async {
    try {
      isLoading.value = true;
      String uID = await UserData.getuID() ?? '';
      String month = DateFormat('yyyy-MM').format(selectedMonth.value);
      Map<String, dynamic> data = {
        "uID": uID,
        "mID": mId.value,
        "Month": month,
      };
      downloadReportData.value = await _repo.download12MonthReport(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }
}
