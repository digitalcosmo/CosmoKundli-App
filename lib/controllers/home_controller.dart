import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentPageIndex = 0.obs;
  final mId = ''.obs;
  final selectedUserName = ''.obs;
  final selectedGender = ''.obs;
  final selectedBirthDate = ''.obs;
  final selectedBirthTime = ''.obs;

  void setPageIndex(int index) => currentPageIndex.value = index;
  void setMId(String val) => mId.value = val;

  void setUserInfo({
    required String name,
    required String gender,
    required String birthDate,
    required String birthTime,
    required String memberId,
  }) {
    selectedUserName.value = name;
    selectedGender.value = gender;
    selectedBirthDate.value = birthDate;
    selectedBirthTime.value = birthTime;
    mId.value = memberId;
  }
}
