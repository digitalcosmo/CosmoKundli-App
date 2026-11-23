import 'dart:convert';

import 'package:cosmo_kundali/models/gochar_table_model.dart';
import 'package:cosmo_kundali/models/melapak_opp_user_list_model.dart';
import 'package:cosmo_kundali/repo/other_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/melapak_details_existing_user.dart';
import '../values/get_tags.dart';
import 'home_controller.dart';

class OtherController extends GetxController {
  RxString mId = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxBool isVisible = false.obs;
  RxInt oppId = 0.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxString selectedName = ''.obs;
  RxString selectedGender = ''.obs;
  RxString gun = ''.obs;
  MelapakOppUserList? melapakOppUserList;
  MelapakDetailsExistingUser? melapakDetailsExistingUser;
  GocharTable? gocharTable;
  OtherRepo otherRepo = OtherRepo();
  RxList rows = [].obs;
  RxString selctedBday = 'Date of Birth'.obs;
  RxBool isNewUser = false.obs;
  GlobalKey<FormState> melapakFormKey = GlobalKey<FormState>();
  Rx<DateTime> selectedDateGochar = DateTime.now().obs;

  TextEditingController oppName = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController btime_hrs = TextEditingController();
  TextEditingController btime_min = TextEditingController();
  TextEditingController btime_sec = TextEditingController();
  TextEditingController birth_place = TextEditingController();
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  TextEditingController timm_diff = TextEditingController();
  TextEditingController gender = TextEditingController();

  @override
  void onInit() {
    mId.value = Get.find<HomeController>(tag: GetTags.homeTag).mId.toString();
    //fetchMemberList();
    // fetchGocharTableData();
    super.onInit();
  }

  void setLoading(bool newValue) => isLoading.value = newValue;

  void setError(bool newValue) => isError.value = newValue;

  void updateStartDate(String newValue) {
    selctedBday.value = newValue;
  }

  Future<void> selectTime(BuildContext context) async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (btime_hrs != null) {
      final formattedTime =
          "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}";
      btime_hrs.text = time.hour.toString();
      btime_min.text = time.minute.toString();
    }
  }

  Future<void> showSecondsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.minPositive,
            height: 300,
            child: ListView.builder(
              itemCount: 60,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(index.toString().padLeft(2, '0')),
                  onTap: () {
                    btime_sec.text = index.toString();
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

  void fetchMemberList({required String mId}) async {
    Map<String, dynamic> data = {"mID": mId};
    try {
      debugPrint('Data Is ' + data.toString());
      setLoading(true);
      melapakOppUserList = await otherRepo.fetchMemberList(data);

      if (melapakOppUserList!.status == true) {}
      setLoading(false);
    } catch (s) {
      debugPrint('Fetch Member Catch' + s.toString());
      setLoading(false);
      setError(true);
    }
  }

  void matchKundali({required String mId}) async {
    // oppId.value = int.parse(melapakOppUserList!.members![0].oID.toString());

    Map<String, dynamic> data = {
      "mID": mId,
      "oID": oppId.value == 0
          ? int.parse(melapakOppUserList!.members![0].oID.toString())
          : oppId.value
    };

    debugPrint(data.toString());

    try {
      setLoading(true);
      melapakDetailsExistingUser = await otherRepo.matchKundalis(data);

      if (melapakDetailsExistingUser!.status == true &&
          melapakDetailsExistingUser != null) {
        rows.value = [
          {
            'Koot': 'Rashi',
            'name 1': melapakDetailsExistingUser!.VarRashi,
            'name 2': melapakDetailsExistingUser!.VadhuRashi,
          },
          {
            'Koot': 'Varn',
            'name 1': melapakDetailsExistingUser!.VarVarn,
            'name 2': melapakDetailsExistingUser!.VadhuVarn,
            "obtain_points": melapakDetailsExistingUser!.VarnPoints,
            "max_points": "1.0"
          },
          {
            'Koot': 'Vaishya',
            'name 1': melapakDetailsExistingUser!.VarVaishya,
            'name 2': melapakDetailsExistingUser!.VadhuVaishya,
            "obtain_points": melapakDetailsExistingUser!.VaishyaPoints,
            "max_points": "2.0"
          },
          {
            'Koot': 'Tara(Nakshatra Gun)',
            'name 1': melapakDetailsExistingUser!.VarTara,
            'name 2': melapakDetailsExistingUser!.VadhuTara,
            "obtain_points": melapakDetailsExistingUser!.TaraPoints,
            "max_points": "3.0"
          },
          {
            'Koot': 'Yoni',
            'name 1': melapakDetailsExistingUser!.VarYoni,
            'name 2': melapakDetailsExistingUser!.VadhuYoni,
            "obtain_points": melapakDetailsExistingUser!.YoniPoints,
            "max_points": "4.0"
          },
          {
            'Koot': 'Rashidhyapati(GrahMaitri)',
            'name 1': melapakDetailsExistingUser!.VarRashidhyapati,
            'name 2': melapakDetailsExistingUser!.VadhuRashidhyapati,
            "obtain_points": melapakDetailsExistingUser!.RashidhyapatiPoints,
            "max_points": "5.0"
          },
          {
            'Koot': 'Gan',
            'name 1': melapakDetailsExistingUser!.VarGan,
            'name 2': melapakDetailsExistingUser!.VadhuGan,
            "obtain_points": melapakDetailsExistingUser!.GanPoints,
            "max_points": "6.0"
          },
          {
            'Koot': 'Bhakoot',
            'name 1': melapakDetailsExistingUser!.VarBhakoot ?? '',
            'name 2': melapakDetailsExistingUser!.VadhuBhakoot ?? '',
            "obtain_points": melapakDetailsExistingUser!.BhakootPoints == null
                ? '-'
                : melapakDetailsExistingUser!.BhakootPoints,
            "max_points": "7.0"
          },
          {
            'Koot': 'Naadi',
            'name 1': melapakDetailsExistingUser!.VarNaadi,
            'name 2': melapakDetailsExistingUser!.VadhuNaadi,
            "obtain_points": melapakDetailsExistingUser!.NaadiPoints,
            "max_points": "8.0"
          },
        ];
        gun.value = melapakDetailsExistingUser!.TotalGunMatch;
      }
      setLoading(false);
    } catch (s, e) {
      debugPrint(s.toString() + e.toString());
      setLoading(false);
      setError(true);
    }
  }

  void addNewMember() async {
    Map<String, dynamic> data = {
      "mID": mId.value,
      "opp_name": oppName.text,
      "dob": dob.text, // yyyy-MM-dd Formate
      "btime_hrs": btime_hrs.text, // 00 to 24
      "btime_min": btime_min.text, // 00 to 60
      "btime_sec": btime_sec.text, // 00 to 60
      "birth_place": birth_place.text,
      "latitude": latitude.text,
      "longitude": longitude.text,
      "timm_diff": timm_diff.text // +/- in minutes
    };

    try {
      setLoading(true);
      melapakDetailsExistingUser =
          await otherRepo.matchKundalisWithNewMember(data);
      setLoading(false);

      if (melapakDetailsExistingUser?.status == true) {
        debugPrint(jsonEncode(melapakDetailsExistingUser));

        rows.value = [
          {
            'Koot': 'Rashi',
            'name 1': melapakDetailsExistingUser!.VarRashi,
            'name 2': melapakDetailsExistingUser!.VadhuRashi,
          },
          {
            'Koot': 'Varn',
            'name 1': melapakDetailsExistingUser!.VarVarn,
            'name 2': melapakDetailsExistingUser!.VadhuVarn,
            "obtain_points": melapakDetailsExistingUser!.VarnPoints,
            "max_points": "1.0"
          },
          {
            'Koot': 'Vaishya',
            'name 1': melapakDetailsExistingUser!.VarVaishya,
            'name 2': melapakDetailsExistingUser!.VadhuVaishya,
            "obtain_points": melapakDetailsExistingUser!.VaishyaPoints,
            "max_points": "2.0"
          },
          {
            'Koot': 'Tara(Nakshatra Gun)',
            'name 1': melapakDetailsExistingUser!.VarTara,
            'name 2': melapakDetailsExistingUser!.VadhuTara,
            "obtain_points": melapakDetailsExistingUser!.TaraPoints,
            "max_points": "3.0"
          },
          {
            'Koot': 'Yoni',
            'name 1': melapakDetailsExistingUser!.VarYoni,
            'name 2': melapakDetailsExistingUser!.VadhuYoni,
            "obtain_points": melapakDetailsExistingUser!.YoniPoints,
            "max_points": "4.0"
          },
          {
            'Koot': 'Rashidhyapati(GrahMaitri)',
            'name 1': melapakDetailsExistingUser!.VarRashidhyapati,
            'name 2': melapakDetailsExistingUser!.VadhuRashidhyapati,
            "obtain_points": melapakDetailsExistingUser!.RashidhyapatiPoints,
            "max_points": "5.0"
          },
          {
            'Koot': 'Gan',
            'name 1': melapakDetailsExistingUser!.VarGan,
            'name 2': melapakDetailsExistingUser!.VadhuGan,
            "obtain_points": melapakDetailsExistingUser!.GanPoints,
            "max_points": "6.0"
          },
          {
            'Koot': 'Bhakoot',
            'name 1': melapakDetailsExistingUser!.VarBhakoot.toString(),
            'name 2': melapakDetailsExistingUser!.VadhuBhakoot.toString(),
            "obtain_points": melapakDetailsExistingUser!.BhakootPoints == null
                ? '-'
                : melapakDetailsExistingUser!.BhakootPoints,
            "max_points": "7.0"
          },
          {
            'Koot': 'Naadi',
            'name 1': melapakDetailsExistingUser!.VarNaadi,
            'name 2': melapakDetailsExistingUser!.VadhuNaadi,
            "obtain_points": melapakDetailsExistingUser!.NaadiPoints,
            "max_points": "8.0"
          },
        ];
        gun.value = melapakDetailsExistingUser!.TotalGunMatch;
      }
    } catch (e) {
      setLoading(false);
    }
  }

  void fetchGocharTableData() async {
    // oppId.value = int.parse(melapakOppUserList!.members![0].oID.toString());
    Map<String, dynamic> data = {
      "mID": mId.value,
      "Datetime": DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(selectedDateGochar.value)
          .toString()
    };
    debugPrint("Gochar Data :" + selectedDateGochar.value.toString());
    debugPrint("Gochar Data :" + data.toString());

    try {
      setLoading(true);
      gocharTable = await otherRepo.fetchGocharTableData(data);
      if (gocharTable!.status == true && gocharTable != null) {
        debugPrint(gocharTable?.planets?.length.toString());
        debugPrint("Gochar Res :" + jsonEncode(gocharTable.toString()));
      }
      setLoading(false);
    } catch (e, s) {
      debugPrint(s.toString());
      setLoading(false);
      setError(true);
    }
  }

  incrementDays(String type) {
    selectedDateGochar.value = DateTime.now();
    if (type == '10 Years') {
      selectedDateGochar.value = selectedDateGochar.value
          .copyWith(year: selectedDateGochar.value.year + 10);
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Year') {
      selectedDateGochar.value = selectedDateGochar.value
          .copyWith(year: selectedDateGochar.value.year + 1);
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Month') {
      selectedDateGochar.value = selectedDateGochar.value
          .copyWith(month: selectedDateGochar.value.month + 1);
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Week') {
      selectedDateGochar.value =
          selectedDateGochar.value.add(const Duration(days: 7));
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Day') {
      selectedDateGochar.value =
          selectedDateGochar.value.add(const Duration(days: 1));
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Hour') {
      selectedDateGochar.value =
          selectedDateGochar.value.add(const Duration(hours: 1));
      debugPrint(type + selectedDateGochar.value.toString());
    }
    debugPrint("day :" + selectedDateGochar.value.toString());
    fetchGocharTableData();
  }

  decrementDays(String type) {
    selectedDateGochar.value = DateTime.now();

    if (type == '10 Years') {
      selectedDateGochar.value = selectedDateGochar.value
          .copyWith(year: selectedDateGochar.value.year - 10);
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Year') {
      selectedDateGochar.value = selectedDateGochar.value
          .copyWith(year: selectedDateGochar.value.year - 1);
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Month') {
      selectedDateGochar.value = selectedDateGochar.value
          .copyWith(month: selectedDateGochar.value.month - 1);
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Week') {
      selectedDateGochar.value =
          selectedDateGochar.value.subtract(const Duration(days: 7));
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Day') {
      selectedDateGochar.value =
          selectedDateGochar.value.subtract(const Duration(days: 1));
      debugPrint(type + selectedDateGochar.value.toString());
    } else if (type == 'Hour') {
      selectedDateGochar.value =
          selectedDateGochar.value.subtract(const Duration(hours: 1));
      debugPrint(type + selectedDateGochar.value.toString());
    }
    fetchGocharTableData();
  }

  void clearData() {
    oppName.clear();
    dob.clear();
    btime_hrs.clear();
    btime_min.clear();
    btime_sec.clear();
    birth_place.clear();
    latitude.clear();
    longitude.clear();
    timm_diff.clear();
    gender.clear();
  }
}
