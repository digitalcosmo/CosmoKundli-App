import 'package:cosmo_kundli/models/cosmo_power_model.dart';
import 'package:cosmo_kundli/models/download_report_model.dart';
import 'package:cosmo_kundli/models/gochar_prabhav_model.dart';
import 'package:cosmo_kundli/models/member_list_model.dart';
import 'package:cosmo_kundli/models/periodic_monthly_report_model.dart';
import 'package:cosmo_kundli/models/star_power_report_daily_model.dart';
import 'package:cosmo_kundli/network/network_api_services.dart';
import 'package:cosmo_kundli/values/urls.dart';

class MbAlgoRepo {
  Future<StarPowerReportDaily> getStarPowerReportDaily(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.starPowerDaily, data);
    return StarPowerReportDaily.fromJson(response);
  }

  Future<CosmoPowerModel> getCosmoPowerReport(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.cosmoPowerDaily, data);
    return CosmoPowerModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getStarPowerReport(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.starPowerReport, data);
    return response;
  }

  Future<MemberListModel> fetchMemberList(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.memberList, data);
    return MemberListModel.fromJson(response);
  }

  Future<PeriodicMonthlyReportModel> getPeriodicMonthlyReport(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.periodicMonthlyReport, data);
    return PeriodicMonthlyReportModel.fromJson(response);
  }

  Future<GocharPrabhavModel> gocharPrabhav(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.gocharPrabhav, data);
    return GocharPrabhavModel.fromJson(response);
  }

  Future<DownloadReport> download3MonthReport(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.cosmoPower3Month, data);
    return DownloadReport.fromJson(response);
  }

  Future<DownloadReport> download6MonthReport(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.cosmoPower6Month, data);
    return DownloadReport.fromJson(response);
  }

  Future<DownloadReport> download12MonthReport(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.cosmoPower12Month, data);
    return DownloadReport.fromJson(response);
  }
}
