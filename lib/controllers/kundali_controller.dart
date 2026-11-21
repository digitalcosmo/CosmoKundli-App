import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cosmo_kundli/models/ashtak_varg_model.dart';
import 'package:cosmo_kundli/models/birth_chart_model.dart';
import 'package:cosmo_kundli/models/birth_planet_info_model.dart';
import 'package:cosmo_kundli/models/chancha_chakra_model.dart';
import 'package:cosmo_kundli/models/dasha_model.dart';
import 'package:cosmo_kundli/models/five_fold_relationship_model.dart';
import 'package:cosmo_kundli/models/kundali_model.dart';
import 'package:cosmo_kundli/models/sani_panoti_model.dart';
import 'package:cosmo_kundli/models/shadbal_graph_model.dart';
import 'package:cosmo_kundli/models/tara_chakra_model.dart';
import 'package:cosmo_kundli/models/varg_kundalis_model.dart';
import 'package:cosmo_kundli/models/vimshottri_maha_dasha_model.dart';
import 'package:cosmo_kundli/repos/kundali_repo.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/user_data.dart';

import 'home_controller.dart';

class KundaliController extends GetxController {
  final KundaliRepo _repo = KundaliRepo();
  final HomeController homeController = Get.find(tag: GetTags.homeTag);

  RxString mId = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;

  // Lazy loading flags
  RxBool isDashaApiCalled = false.obs;
  RxBool isFiveFoldApiCalled = false.obs;
  RxBool isShabdalApiCalled = false.obs;
  RxBool isAshtakApiCalled = false.obs;
  RxBool isChanchaApiCalled = false.obs;
  RxBool isTaraChakraApiCalled = false.obs;
  RxBool isSaniPanotiApiCalled = false.obs;
  RxBool isVargKundaliApiCalled = false.obs;
  RxBool isAshtakVargApiCalled = false.obs;

  // Data holders
  RxList<KundaliModel> planetsData = <KundaliModel>[].obs;
  Rx<ShadbalGraphModel?> shadbalData = Rx<ShadbalGraphModel?>(null);
  Rx<BirthPlanetInfoModel?> birthPlanetInfoData = Rx<BirthPlanetInfoModel?>(null);
  Rx<VimshottriMahaDashaModel?> mahaDashaData = Rx<VimshottriMahaDashaModel?>(null);
  Rx<PlanetData?> fiveFoldData = Rx<PlanetData?>(null);
  Rx<ChanchaChakra?> chanchaChakraData = Rx<ChanchaChakra?>(null);
  Rx<TaraChakra?> taraChakraData = Rx<TaraChakra?>(null);
  Rx<SaniPanotiModel?> saniPanotiData = Rx<SaniPanotiModel?>(null);
  Rx<DashaModel?> dashaData = Rx<DashaModel?>(null);
  Rx<VargKundalisModel?> vargKundalisData = Rx<VargKundalisModel?>(null);

  // Ashtakvarg data for each planet
  Rx<AshtakVargModel?> ashtakVargSun = Rx<AshtakVargModel?>(null);
  Rx<AshtakVargModel?> ashtakVargMoon = Rx<AshtakVargModel?>(null);
  Rx<AshtakVargModel?> ashtakVargMars = Rx<AshtakVargModel?>(null);
  Rx<AshtakVargModel?> ashtakVargMercury = Rx<AshtakVargModel?>(null);
  Rx<AshtakVargModel?> ashtakVargJupiter = Rx<AshtakVargModel?>(null);
  Rx<AshtakVargModel?> ashtakVargVenus = Rx<AshtakVargModel?>(null);
  Rx<AshtakVargModel?> ashtakVargSaturn = Rx<AshtakVargModel?>(null);
  Rx<AshtakVargModel?> ashtakVargLagan = Rx<AshtakVargModel?>(null);

  // Rashi to Ghar mapping
  Map<int, int> rashiToGharMapping = {};

  @override
  void onInit() {
    mId.value = homeController.mId.toString();
    super.onInit();
  }

  Map<String, dynamic> get _baseData => {"mID": mId.value};

  /// Sorts planets: finds 'As' planet, builds rashi order starting from As rashi,
  /// sorts other planets by that order
  List<KundaliModel> _sortPlanets(List<KundaliModel> planets) {
    if (planets.isEmpty) return planets;

    // Find ascendant planet
    KundaliModel? asPlanet;
    try {
      asPlanet = planets.firstWhere((p) => p.name == 'As');
    } catch (_) {
      return planets;
    }

    int asRashi = int.tryParse(asPlanet.rashi ?? '1') ?? 1;

    // Build rashi order starting from As rashi
    List<int> rashiOrder = [];
    for (int i = 0; i < 12; i++) {
      rashiOrder.add(((asRashi - 1 + i) % 12) + 1);
    }

    // Build rashi-to-ghar mapping
    rashiToGharMapping.clear();
    for (int i = 0; i < rashiOrder.length; i++) {
      rashiToGharMapping[rashiOrder[i]] = i + 1;
    }

    // Sort planets by rashi order index
    List<KundaliModel> otherPlanets = planets.where((p) => p.name != 'As').toList();
    otherPlanets.sort((a, b) {
      int rashiA = int.tryParse(a.rashi ?? '1') ?? 1;
      int rashiB = int.tryParse(b.rashi ?? '1') ?? 1;
      int indexA = rashiOrder.indexOf(rashiA);
      int indexB = rashiOrder.indexOf(rashiB);
      return indexA.compareTo(indexB);
    });

    return [asPlanet, ...otherPlanets];
  }

  // ── API calls ──

  Future<void> birthChartInfo() async {
    try {
      isLoading.value = true;
      BirthChartModel result = await _repo.birthChartInfo(_baseData);
      if (result.status == true && result.kundaliModel != null) {
        planetsData.value = _sortPlanets(result.kundaliModel!);
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> shadbalGraph() async {
    try {
      isShabdalApiCalled.value = true;
      isLoading.value = true;
      shadbalData.value = await _repo.shadbalGraph(_baseData);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> fetchBirthPlanetInfo() async {
    try {
      isLoading.value = true;
      birthPlanetInfoData.value = await _repo.fetchBirthPlanetInfo(_baseData);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> vimshottriMahaDashaTable() async {
    try {
      isLoading.value = true;
      mahaDashaData.value = await _repo.vimshottriMahaDashaTable(_baseData);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> getFiveFoldRelationshipTableData() async {
    try {
      isFiveFoldApiCalled.value = true;
      isLoading.value = true;
      fiveFoldData.value = await _repo.fiveFoldRelationshipTable(_baseData);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> fetchchanchaChakra() async {
    try {
      isChanchaApiCalled.value = true;
      isLoading.value = true;
      chanchaChakraData.value = await _repo.chanchaChakra(_baseData);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> ashtakVargSunTableData() async {
    try {
      isAshtakApiCalled.value = true;
      isLoading.value = true;
      final results = await Future.wait([
        _repo.ashtakVargSunData(_baseData),
        _repo.ashtakVargMoonData(_baseData),
        _repo.ashtakVargMarsData(_baseData),
        _repo.ashtakVargMercuryData(_baseData),
        _repo.ashtakVargJupiterData(_baseData),
        _repo.ashtakVargVenusData(_baseData),
        _repo.ashtakVargSaturnData(_baseData),
        _repo.ashtakVargLaganData(_baseData),
      ]);
      ashtakVargSun.value = results[0];
      ashtakVargMoon.value = results[1];
      ashtakVargMars.value = results[2];
      ashtakVargMercury.value = results[3];
      ashtakVargJupiter.value = results[4];
      ashtakVargVenus.value = results[5];
      ashtakVargSaturn.value = results[6];
      ashtakVargLagan.value = results[7];
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> taraChakraTableData() async {
    try {
      isTaraChakraApiCalled.value = true;
      isLoading.value = true;
      taraChakraData.value = await _repo.taraChakraData(_baseData);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> getShaniPanotiData() async {
    try {
      isSaniPanotiApiCalled.value = true;
      isLoading.value = true;
      saniPanotiData.value = await _repo.saniPanotiData(_baseData);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> getDasha() async {
    try {
      isDashaApiCalled.value = true;
      isLoading.value = true;
      dashaData.value = await _repo.dasha(_baseData);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> vargKundalis(String url) async {
    try {
      isVargKundaliApiCalled.value = true;
      isLoading.value = true;
      VargKundalisModel result = await _repo.vargKundalis(_baseData, url);
      if (result.status == true && result.kundaliModel != null) {
        vargKundalisData.value = result;
        // Apply same planet sorting as birth chart
        vargKundalisData.value!.kundaliModel = _sortPlanets(result.kundaliModel!);
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }
}
