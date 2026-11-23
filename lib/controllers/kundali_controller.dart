import 'dart:convert';
import 'dart:developer';
import 'package:cosmo_kundali/controllers/home_controller.dart';
import 'package:cosmo_kundali/models/GraphModel.dart';
import 'package:cosmo_kundali/models/ashtak_varg_sun.dart';
import 'package:cosmo_kundali/models/birth_chart_model.dart';
import 'package:cosmo_kundali/models/birth_planet_info_model.dart';
import 'package:cosmo_kundali/models/chancha_chakra.dart';
import 'package:cosmo_kundali/models/five_fold_relationship_model.dart';
import 'package:cosmo_kundali/models/sani_panoti_model.dart';
import 'package:cosmo_kundali/models/shadbal_graph.dart';
import 'package:cosmo_kundali/models/tara_chakra_model.dart';
import 'package:cosmo_kundali/models/varg_kundalis.dart';
import 'package:cosmo_kundali/models/vimshottri_maha_dasha_model.dart';
import 'package:cosmo_kundali/repo/kundali_repo.dart';
import 'package:cosmo_kundali/values/get_tags.dart';
import 'package:cosmo_kundali/values/urls.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:get/get.dart' hide Response;
import '../models/dasha_model.dart';
import '../models/kundali_model.dart';

class KundaliController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxList<ShabdalGraphModel> shabdalList = <ShabdalGraphModel>[].obs;
  final KundaliRepo kundaliRepo = KundaliRepo();
  ShabdalGraphModel?  shadbalGrpah;
  ChanchaChakra? chanchaChakra;
  RxList<Table> chanchaChakraTable = <Table>[].obs;
  BirthPlanetInfoModel? birthPlanetInfoModel;
  BirthChartModel? birthChartModel;
  Rx<VimshottriMahaDashaModel> vimshottriMahaDashaModel =
      VimshottriMahaDashaModel().obs;
  Rx<TaraChakraList> taraChakraList = TaraChakraList().obs;
  DashaModel? dashaModel;
  VargKundalisModel? vargKundalisModel;
  PlanetData? fiveFoldRelationshipModel;
  AshtakVargSun? ashtakVargSun;
  AshtakVargSun? ashtakVargMoon;
  AshtakVargSun? ashtakVargMars;
  AshtakVargSun? ashtakVargMercury;
  AshtakVargSun? ashtakVargJupiter;
  AshtakVargSun? ashtakVargVenus;
  AshtakVargSun? ashtakVargSaturn;
  AshtakVargSun? ashtakVargLagan;
  TaraChakra? taraChakra;
  SaniPanotiModel? saniPanotiModel;
  GraphModel? shabdalGraphModel;
  RxBool isVimshottriLoading = false.obs;
  List<String> ashtaVargTitleList = [];
  RxString mId = ''.obs;
  RxInt index = 0.obs;
  RxInt selectedRashi = 1.obs;

  final List<KundaliModel> planetsData = [];

  Map<int, int> rashiToGharMapping = {};

  bool isDashaApiCalled = false;
  bool isFiveFoldApiCalled = false;
  bool isShabdalApiCalled = false;
  bool isAshtakApiCalled = false;
  bool isChanchaApiCalled = false;
  bool isTaraChakraApiCalled = false;
  bool isVargKundaliApiCalled = false;



  @override
  void onInit() {
    // TODO: implement onInit
    mId.value = Get.find<HomeController>(tag: GetTags.homeTag).mId.toString();
    debugPrint("MID:${mId.value}");
    // vimshottriMahaDashaTable();
    super.onInit();
  }

  void setLoading(bool newValue) => isLoading.value = newValue;

  void setError(bool newValue) => isError.value = newValue;

  void setIndex(int newindex) => index.value = newindex;

  void shadbalGraph() async {
    //Get.find<HomeController>().mId

    Map<String, dynamic> data = {"mID": mId.value};
    try {
      setLoading(true);
      shadbalGrpah = await kundaliRepo.shadbalGraph(data);
      shabdalList.add(shadbalGrpah!);

      debugPrint(jsonEncode(shabdalList));
      setLoading(false);
      if (shadbalGrpah!.status == true) {
        debugPrint(jsonEncode(shadbalGrpah));
        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e) {
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void fetchchanchaChakra() async {
    //Get.find<HomeController>().mId

    Map<String, dynamic> data = {"mID": mId.value};
    try {
      setLoading(true);
      chanchaChakra = await kundaliRepo.chanchaChakra(data);

      debugPrint(jsonEncode(shabdalList));
      setLoading(false);
      if (chanchaChakra!.status == true) {
        chanchaChakraTable.value = chanchaChakra!.list![0].table!;
        debugPrint("ChanchaChkra :${jsonEncode(chanchaChakra)}");
        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e) {
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void fetchBirthPlanetInfo() async {
    Map<String, dynamic> data = {"mID": mId.value};
    try {
      debugPrint("birth plant Data  :$data");
      setLoading(true);
      birthPlanetInfoModel = await kundaliRepo.fetchBirthPlanetInfo(data);
      setLoading(false);
      if (birthPlanetInfoModel!.status == true) {
        debugPrint('birth plant Res' +
            birthPlanetInfoModel!.planets.length.toString());
        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e) {
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void birthChartInfo() async {
    Map<String, dynamic> data = {"mID": mId.value};
    try {
      setLoading(true);
      birthChartModel = await kundaliRepo.birthChartInfo(data);
      setLoading(false);
      if (birthChartModel!.status == true) {
        List<dynamic> planets = birthChartModel?.planets ?? [];

        Map<String, dynamic>? asPlanet =
            planets.firstWhere((planet) => planet['planet'] == 'As');

        int asRashi = int.parse(asPlanet!['rashi']);

        List<int> allRashis = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        List<int> rashiOrder = [
          ...allRashis.where((r) => r >= asRashi),
          ...allRashis.where((r) => r < asRashi)
        ];

        debugPrint('Rashi Order $rashiOrder');

        List otherPlanets =
            planets.where((planet) => planet['planet'] != 'As').toList();

        otherPlanets.sort((a, b) {
          int rashiA = int.parse(a['rashi']);
          int rashiB = int.parse(b['rashi']);
          return rashiOrder
              .indexOf(rashiA)
              .compareTo(rashiOrder.indexOf(rashiB));
        });

        List<Map<String, dynamic>> sortedPlanets = [asPlanet, ...otherPlanets];

        // planetsData.clear();
        for (int i = 0; i < sortedPlanets.length; i++) {
          planetsData.add(
            KundaliModel(
              color: sortedPlanets[i]['color'],
              degree: sortedPlanets[i]['degree'],
              planet: sortedPlanets[i]['planet'],
              rashi: sortedPlanets[i]['rashi'],
            ),
          );
        }

        for (int i = 0; i < rashiOrder.length; i++) {
          rashiToGharMapping[rashiOrder[i]] = i + 1;
        }

        // Print the dynamic mapping
        rashiToGharMapping.forEach((rashi, ghar) {});

        debugPrint('Rashi maping is $rashiToGharMapping');

        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e) {
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  Future<void> vimshottriMahaDashaTable() async {
    Map<String, dynamic> data = {"mID": mId.value};
    try {
      setLoading(true);
      isVimshottriLoading.value = true;
      vimshottriMahaDashaModel.value =
          await kundaliRepo.vimshottriMahaDashaTable(data);
      setLoading(false);
      isVimshottriLoading.value = false;

      debugPrint('Vim Res ${jsonEncode(isVimshottriLoading)}');

      if (vimshottriMahaDashaModel.value.status == true) {
        debugPrint(vimshottriMahaDashaModel.value.list![0].planet);
        debugPrint('Vim Res ${jsonEncode(isVimshottriLoading)}');
        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e) {
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void getFiveFoldRelationshipTableData() async {
    Map<String, dynamic> data = {"mID": mId.value};

    debugPrint('Five Fold Data $data');
    try {
      setLoading(true);
      fiveFoldRelationshipModel =
          await kundaliRepo.fiveFoldRelationshipTable(data);

      debugPrint(fiveFoldRelationshipModel!.list.toString());

      setLoading(false);
    } catch (e, s) {
      setLoading(false);
      setError(true);
      debugPrint('Catch FiveFold $e');
      debugPrint('Catch FiveFold $s');
      //Services.snackBarError(context, e.toString());
    }
  }

  void ashtakVargSunTableData() async {
    Map<String, dynamic> data = {"mID": mId.value};
    try {
      setLoading(true);
      ashtakVargSun = await kundaliRepo.ashtakVargSunData(data);
      ashtakVargMoon = await kundaliRepo.ashtakVargMoonData(data);
      ashtakVargMars = await kundaliRepo.ashtakVargMarsData(data);
      ashtakVargMercury = await kundaliRepo.ashtakVargMercuryData(data);
      ashtakVargJupiter = await kundaliRepo.ashtakVargJupiterData(data);
      ashtakVargVenus = await kundaliRepo.ashtakVargVenusData(data);
      ashtakVargSaturn = await kundaliRepo.ashtakVargSatrunData(data);
      ashtakVargLagan = await kundaliRepo.ashtakVargLaganData(data);

      setLoading(false);

      if (ashtakVargSun!.status == true) {
        debugPrint(ashtakVargSun?.startingRashi);
        //
        // for (int i = 0; i < ashtakVargSun!.table[0].length; i++) {
        //   ashtaVargTitleList.add(ashtakVargSun!.table[0][0].toString());
        // }

        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e, s) {
      //setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());

      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  void taraChakraData() async {
    Map<String, dynamic> data = {"mID": mId.value};
    try {
      setLoading(true);
      taraChakra = await kundaliRepo.taraChakraData(data);
      setLoading(false);
      if (taraChakra!.status == true) {
        //taraChakraList.value = TaraChakraList.fromJson(taraChakra!.list);

        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e, s) {
      debugPrint(e.toString() + s.toString());
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void getShaniPanotiData() async {
    Map<String, dynamic> data = {"mID": mId.value};

    debugPrint('Shani Panoti Data $data');
    try {
      setLoading(true);
      saniPanotiModel = await kundaliRepo.saniPanotiData(data);
      setLoading(false);

      debugPrint('Shani Panoti res ${jsonEncode(saniPanotiModel)}');
    } catch (e) {
      debugPrint('Error In Shani Panoti' + e.toString());
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void getDasha() async {
    Map<String, dynamic> data = {"mID": mId.value};

    try {
      setLoading(true);
      dashaModel = await kundaliRepo.dasha(data);
      setLoading(false);

      debugPrint('Dash Data $data');
      log('Dash Response ${jsonEncode(dashaModel)}');
    } catch (e) {
      setLoading(false);
      debugPrint(e.toString());
    }
  }

  void vargKundalis(String url) async {
    Map<String, dynamic> data = {"mID": mId.value};
    try {
      setLoading(true);
      vargKundalisModel = await kundaliRepo.vargKundalis(data, url);
      debugPrint("dynamic url :${AppUrls.varg_kundali}");
      setLoading(false);
      if (vargKundalisModel?.status == true) {
        List<dynamic> planets = vargKundalisModel!.planets!;
        debugPrint("planets::${planets.length}"); //
        Map<String, dynamic>? asPlanet =
            planets.firstWhere((planet) => planet['planet'] == 'As');

        int asRashi = int.parse(asPlanet!['rashi']);
        List<int> allRashis = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        List<int> rashiOrder = [
          ...allRashis.where((r) => r >= asRashi),
          ...allRashis.where((r) => r < asRashi)
        ];
        List otherPlanets =
            planets.where((planet) => planet['planet'] != 'As').toList();
        otherPlanets.sort((a, b) {
          int rashiA = int.parse(a['rashi']);
          int rashiB = int.parse(b['rashi']);
          return rashiOrder
              .indexOf(rashiA)
              .compareTo(rashiOrder.indexOf(rashiB));
        });
        List<Map<String, dynamic>> sortedPlanets = [asPlanet, ...otherPlanets];
        planetsData.clear();
        for (int i = 0; i < sortedPlanets.length; i++) {
          planetsData.add(
            KundaliModel(
              color: sortedPlanets[i]['color'],
              degree: sortedPlanets[i]['degree'],
              planet: sortedPlanets[i]['planet'],
              rashi: sortedPlanets[i]['rashi'],
            ),
          );
        }
        rashiToGharMapping.clear();
        for (int i = 0; i < rashiOrder.length; i++) {
          rashiToGharMapping[rashiOrder[i]] = i + 1;
        }
        rashiToGharMapping.forEach((rashi, ghar) {});
      }
    } catch (e) {
      setLoading(false);
      debugPrint(e.toString());
    }
  }
}

