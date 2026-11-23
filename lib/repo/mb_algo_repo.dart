import 'package:cosmo_kundali/models/dasha_model.dart';
import 'package:cosmo_kundali/models/download_report.dart';
import 'package:cosmo_kundali/models/star_power_report_daily.dart';
import 'package:cosmo_kundali/models/star_power_report_model.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/cosmo_power_report.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/gochar_prbhav.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/periodic_monthly_report.dart';
import 'package:flutter/material.dart';
import '../models/cosmo_power_report.dart';
import '../models/gochar_prabhav_model.dart';
import '../models/member_list_model.dart';
import '../models/periodic_monthly_report.dart';
import '../network/network_api_services.dart';
import '../values/urls.dart';

class MbAlgoRepo
{
  final NetworkApiServices networkApiServices = NetworkApiServices();

  Future<StarPowerReportDaily> getStarPowerReportDaily(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Star_Power_Daily);
    debugPrint("dataa ::"+ response.toString() );

    return StarPowerReportDaily .fromJson(response);
  }


  Future<CosmoPowerModel> getCosmoPowerReport(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Cosmo_Power_Daily);
    return CosmoPowerModel.fromJson(response);
  }

  // Future<StarPowerReport> getStarPowerReport(Map<String, dynamic> data) async {
  //   Map<String, dynamic> response =
  //   await networkApiServices.postApi(data, AppUrls.Star_Power_Report);
  //   return StarPowerReport.fromJson(response);
  // }

  Future<MemberListModel> fetchMemberList(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.memberList);
    return MemberListModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getStarPowerReport(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Star_Power_Report);
    return response;
  }

  Future<PeriodicMonthlyReportModel> getPeriodicMonthlyReport(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Periodic_Monthly_Report);
    return PeriodicMonthlyReportModel.fromJson(response);
  }

  Future<GocharPrabhavModel> gocharPrabhav(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Gochar_Prabhav);
    return GocharPrabhavModel.fromJson(response);
  }

  Future<DownloadReport> download3MonthReport(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.CosmoPower_3Month);
    return DownloadReport.fromJson(response);
  }

  Future<DownloadReport> download6MonthReport(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.CosmoPower_6Month);
    return DownloadReport.fromJson(response);
  }

  Future<DownloadReport> download12MonthReport(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.CosmoPower_12Month);
    return DownloadReport.fromJson(response);
  }


}