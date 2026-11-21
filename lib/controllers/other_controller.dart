import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:cosmo_kundli/models/gochar_table_model.dart';
import 'package:cosmo_kundli/models/melapak_details_model.dart';
import 'package:cosmo_kundli/models/melapak_opp_user_list_model.dart';
import 'package:cosmo_kundli/repos/other_repo.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/user_data.dart';
import 'package:cosmo_kundli/services/services.dart';

import 'home_controller.dart';

class OtherController extends GetxController {
  final OtherRepo _repo = OtherRepo();
  final HomeController homeController = Get.find(tag: GetTags.homeTag);

  RxString mId = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;

  // Melapak
  Rx<MelapakOppUserList?> melapakMemberListData = Rx<MelapakOppUserList?>(null);
  Rx<MelapakDetailsExistingUser?> melapakDetailsData = Rx<MelapakDetailsExistingUser?>(null);
  RxList<List<String>> rows = <List<String>>[].obs;
  RxString gun = ''.obs;

  // New member form for melapak
  TextEditingController oppNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController btimeHrsController = TextEditingController();
  TextEditingController btimeMinController = TextEditingController();
  TextEditingController btimeSecController = TextEditingController();
  TextEditingController birthPlaceController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController timmDiffController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  // Gochar table
  Rx<GocharTable?> gocharTableData = Rx<GocharTable?>(null);
  Rx<DateTime> selectedDateGochar = DateTime.now().obs;

  // Koot table headers
  final List<String> kootHeaders = [
    'Rashi', 'Varn', 'Vaishya', 'Tara', 'Yoni',
    'Rashidhyapati', 'Gan', 'Bhakoot', 'Naadi',
  ];

  @override
  void onInit() {
    mId.value = homeController.mId.toString();
    super.onInit();
  }

  // ── Melapak ──

  Future<void> fetchMemberList(String memberId) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> data = {"mID": memberId};
      melapakMemberListData.value = await _repo.fetchMemberList(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> matchKundali(String oppMId) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> data = {"mID": mId.value, "opp_mID": oppMId};
      melapakDetailsData.value = await _repo.matchKundalis(data);
      if (melapakDetailsData.value != null) {
        _buildKootTable();
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> addNewMember(BuildContext context) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> data = {
        "mID": mId.value,
        "opp_name": oppNameController.text,
        "dob": dobController.text,
        "btime_hrs": btimeHrsController.text,
        "btime_min": btimeMinController.text,
        "btime_sec": btimeSecController.text,
        "birth_place": birthPlaceController.text,
        "latitude": latitudeController.text,
        "longitude": longitudeController.text,
        "timm_diff": timmDiffController.text,
        "gender": genderController.text,
      };
      melapakDetailsData.value = await _repo.matchKundalisWithNewMember(data);
      if (melapakDetailsData.value != null) {
        _buildKootTable();
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  void _buildKootTable() {
    if (melapakDetailsData.value == null) return;
    final d = melapakDetailsData.value!;
    rows.value = [
      [d.rashi ?? '', d.varn ?? '', d.vaishya ?? '', d.tara ?? '', d.yoni ?? '',
       d.rashidhyapati ?? '', d.gan ?? '', d.bhakoot ?? '', d.naadi ?? ''],
    ];
    gun.value = d.totalGunMatch ?? '';
  }

  // ── Gochar table ──

  Future<void> fetchGocharTableData() async {
    try {
      isLoading.value = true;
      String dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateGochar.value);
      Map<String, dynamic> data = {
        "mID": mId.value,
        "datetime": dateStr,
      };
      gocharTableData.value = await _repo.fetchGocharTableData(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  // ── Date increment/decrement ──

  void incrementDays(String type) {
    selectedDateGochar.value = _adjustDate(selectedDateGochar.value, type, true);
    fetchGocharTableData();
  }

  void decrementDays(String type) {
    selectedDateGochar.value = _adjustDate(selectedDateGochar.value, type, false);
    fetchGocharTableData();
  }

  DateTime _adjustDate(DateTime date, String type, bool forward) {
    int multiplier = forward ? 1 : -1;
    switch (type) {
      case '10 Years':
        return DateTime(date.year + (10 * multiplier), date.month, date.day, date.hour, date.minute, date.second);
      case 'Year':
        return DateTime(date.year + (1 * multiplier), date.month, date.day, date.hour, date.minute, date.second);
      case 'Month':
        return DateTime(date.year, date.month + (1 * multiplier), date.day, date.hour, date.minute, date.second);
      case 'Week':
        return date.add(Duration(days: 7 * multiplier));
      case 'Day':
        return date.add(Duration(days: 1 * multiplier));
      case 'Hour':
        return date.add(Duration(hours: 1 * multiplier));
      default:
        return date;
    }
  }

  Future<void> selectTime(BuildContext context) async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateGochar.value),
    );
    if (time != null) {
      selectedDateGochar.value = DateTime(
        selectedDateGochar.value.year,
        selectedDateGochar.value.month,
        selectedDateGochar.value.day,
        time.hour,
        time.minute,
        selectedDateGochar.value.second,
      );
    }
  }

  Future<void> showSecondsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: ListView.builder(
              itemCount: 60,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(index.toString().padLeft(2, '0')),
                  onTap: () {
                    selectedDateGochar.value = DateTime(
                      selectedDateGochar.value.year,
                      selectedDateGochar.value.month,
                      selectedDateGochar.value.day,
                      selectedDateGochar.value.hour,
                      selectedDateGochar.value.minute,
                      index,
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void clearData() {
    oppNameController.clear();
    dobController.clear();
    btimeHrsController.clear();
    btimeMinController.clear();
    btimeSecController.clear();
    birthPlaceController.clear();
    latitudeController.clear();
    longitudeController.clear();
    timmDiffController.clear();
    genderController.clear();
  }
}
