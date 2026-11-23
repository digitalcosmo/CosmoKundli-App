import 'package:cosmo_kundali/screens/home/home.dart';
import 'package:cosmo_kundali/screens/bottom_pages/mb_algo.dart';
import 'package:cosmo_kundali/screens/bottom_pages/other_screen.dart';
import 'package:cosmo_kundali/screens/bottom_pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../custom_widgets/main_bottom.dart';
import '../screens/bottom_pages/kundali_screen.dart';
import '../values/images.dart';

class HomeController extends GetxController {
  List<BottomNavigationBarItem> bottomPageItemList = [];
  List<Widget> bottomPageWidgets = [];
  RxInt currentPageIndex = 0.obs;
  RxString mId = ''.obs;
  RxString selectedUserName = ''.obs;
  RxString selectedGender = ''.obs;
  RxString selectedBirthDate = ''.obs;
  RxString selectedBirthTime = ''.obs;

  List<NavItemData> navItems = [
    //NavItemData(icon: AppImages.home, label: 'Home'),
    NavItemData(icon: AppImages.kundali, label: 'Kundli'),
    NavItemData(icon: AppImages.mb_algo, label: 'MB Algo'),
    NavItemData(icon: AppImages.others, label: 'Others'),
    NavItemData(icon: AppImages.profile, label: 'Profile'),
  ];

  @override
  void onInit() {
    addBottomPageItems();
    super.onInit();
  }

  void addBottomPageItems() {
    bottomPageWidgets.addAll([
      //const Home(),
      KundaliScreen(),
      MbAlgo(),
      const OtherScreen(),
      ProfileScreen(),
    ]);
  }

  void setPageIndex(int index) => currentPageIndex.value = index;

  void setMId(String val) => mId.value = val;

  void navigateToTab(
      {required int index, required TabController tabController}) {
    tabController.animateTo(index);
  }
}
