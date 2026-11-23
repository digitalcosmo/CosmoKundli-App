import 'package:cosmo_kundali/models/ashtak_varg_sun.dart';
import 'package:cosmo_kundali/models/birth_chart_model.dart';
import 'package:cosmo_kundali/models/birth_planet_info_model.dart';
import 'package:cosmo_kundali/models/chancha_chakra.dart';
import 'package:cosmo_kundali/models/five_fold_relationship_model.dart';
import 'package:cosmo_kundali/models/report_history.dart';
import 'package:cosmo_kundali/models/sani_panoti_model.dart';
import 'package:cosmo_kundali/models/shadbal_graph.dart';
import 'package:cosmo_kundali/models/vimshottri_maha_dasha_model.dart';
import 'package:cosmo_kundali/screens/kundali_screens/ashatak_varg.dart';
import 'package:flutter/cupertino.dart';

import '../models/dasha_model.dart';
import '../models/tara_chakra_model.dart';
import '../models/varg_kundalis.dart';
import '../network/network_api_services.dart';
import '../values/urls.dart';

class KundaliRepo
{
  final NetworkApiServices networkApiServices = NetworkApiServices();

  Future<ShabdalGraphModel> shadbalGraph(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.shadbal);
    return ShabdalGraphModel.fromJson(response);
  }

  Future<BirthPlanetInfoModel> fetchBirthPlanetInfo(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.bithPlanetInfo);
    return BirthPlanetInfoModel.fromJson(response);
  }

  Future<BirthChartModel> birthChartInfo(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.birthChart);
    return BirthChartModel.fromJson(response);
  }


  Future<VimshottriMahaDashaModel> vimshottriMahaDashaTable(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.vimshottriMahaDasha);
    return VimshottriMahaDashaModel.fromJson(response);
  }

  Future<PlanetData> fiveFoldRelationshipTable(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.fiveFoldFriendship);
    return PlanetData.fromJson(response);
  }

  Future<AshtakVargSun> ashtakVargSunData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Ashtakvarg_Sun);
    return AshtakVargSun.fromJson(response);
  }

  Future<AshtakVargSun> ashtakVargMoonData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Ashtakvarg_Moon);
    return AshtakVargSun.fromJson(response);
  }

  Future<AshtakVargSun> ashtakVargMarsData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Ashtakvarg_Mars);
    return AshtakVargSun.fromJson(response);
  }

  Future<AshtakVargSun> ashtakVargMercuryData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Ashtakvarg_Mercury);
    return AshtakVargSun.fromJson(response);
  }

  Future<AshtakVargSun> ashtakVargJupiterData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Ashtakvarg_Jupiter);
    return AshtakVargSun.fromJson(response);
  }

  Future<AshtakVargSun> ashtakVargVenusData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Ashtakvarg_Venus);
    return AshtakVargSun.fromJson(response);
  }

  Future<AshtakVargSun> ashtakVargSatrunData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Ashtakvarg_Saturn);
    return AshtakVargSun.fromJson(response);
  }

  Future<AshtakVargSun> ashtakVargLaganData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Ashtakvarg_Lagan);
    return AshtakVargSun.fromJson(response);
  }



  Future<TaraChakra> taraChakraData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Tara_Chakra);
    return TaraChakra.fromJson(response);
  }


  Future<SaniPanotiModel> saniPanotiData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Sani_Panoti);
    return SaniPanotiModel.fromJson(response);
  }

  Future<DashaModel> dasha(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Dasha);
    return DashaModel.fromJson(response);
  }



  Future<VargKundalisModel> vargKundalis(Map<String, dynamic> data,String url) async {
    debugPrint(url);
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, url);
    return VargKundalisModel.fromJson(response);
  }


  Future<ChanchaChakra> chanchaChakra(Map<String, dynamic> data,) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.chanchaChakra);
    return ChanchaChakra.fromJson(response);
  }






}