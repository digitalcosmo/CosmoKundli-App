import 'package:cosmo_kundli/models/ashtak_varg_model.dart';
import 'package:cosmo_kundli/models/birth_chart_model.dart';
import 'package:cosmo_kundli/models/birth_planet_info_model.dart';
import 'package:cosmo_kundli/models/chancha_chakra_model.dart';
import 'package:cosmo_kundli/models/dasha_model.dart';
import 'package:cosmo_kundli/models/five_fold_relationship_model.dart';
import 'package:cosmo_kundli/models/sani_panoti_model.dart';
import 'package:cosmo_kundli/models/shadbal_graph_model.dart';
import 'package:cosmo_kundli/models/tara_chakra_model.dart';
import 'package:cosmo_kundli/models/varg_kundalis_model.dart';
import 'package:cosmo_kundli/models/vimshottri_maha_dasha_model.dart';
import 'package:cosmo_kundli/network/network_api_services.dart';
import 'package:cosmo_kundli/values/urls.dart';

class KundaliRepo {
  Future<ShadbalGraphModel> shadbalGraph(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.shadbal, data);
    return ShadbalGraphModel.fromJson(response);
  }

  Future<BirthPlanetInfoModel> fetchBirthPlanetInfo(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.birthPlanetInfo, data);
    return BirthPlanetInfoModel.fromJson(response);
  }

  Future<BirthChartModel> birthChartInfo(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.birthChart, data);
    return BirthChartModel.fromJson(response);
  }

  Future<VimshottriMahaDashaModel> vimshottriMahaDashaTable(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.vimshottriMahaDasha, data);
    return VimshottriMahaDashaModel.fromJson(response);
  }

  Future<PlanetData> fiveFoldRelationshipTable(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.fiveFoldFriendship, data);
    return PlanetData.fromJson(response);
  }

  // Ashtakvarg - 8 planets
  Future<AshtakVargModel> ashtakVargSunData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.ashtakVargSun, data);
    return AshtakVargModel.fromJson(response);
  }

  Future<AshtakVargModel> ashtakVargMoonData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.ashtakVargMoon, data);
    return AshtakVargModel.fromJson(response);
  }

  Future<AshtakVargModel> ashtakVargMarsData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.ashtakVargMars, data);
    return AshtakVargModel.fromJson(response);
  }

  Future<AshtakVargModel> ashtakVargMercuryData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.ashtakVargMercury, data);
    return AshtakVargModel.fromJson(response);
  }

  Future<AshtakVargModel> ashtakVargJupiterData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.ashtakVargJupiter, data);
    return AshtakVargModel.fromJson(response);
  }

  Future<AshtakVargModel> ashtakVargVenusData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.ashtakVargVenus, data);
    return AshtakVargModel.fromJson(response);
  }

  Future<AshtakVargModel> ashtakVargSaturnData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.ashtakVargSaturn, data);
    return AshtakVargModel.fromJson(response);
  }

  Future<AshtakVargModel> ashtakVargLaganData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.ashtakVargLagan, data);
    return AshtakVargModel.fromJson(response);
  }

  Future<TaraChakra> taraChakraData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.taraChakra, data);
    return TaraChakra.fromJson(response);
  }

  Future<SaniPanotiModel> saniPanotiData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.saniPanoti, data);
    return SaniPanotiModel.fromJson(response);
  }

  Future<DashaModel> dasha(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.dasha, data);
    return DashaModel.fromJson(response);
  }

  Future<VargKundalisModel> vargKundalis(Map<String, dynamic> data, String url) async {
    final response = await NetworkApiServices.postApi(url, data);
    return VargKundalisModel.fromJson(response);
  }

  Future<ChanchaChakra> chanchaChakra(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.chanchaChakra, data);
    return ChanchaChakra.fromJson(response);
  }
}
