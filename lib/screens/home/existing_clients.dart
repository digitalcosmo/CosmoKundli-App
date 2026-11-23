import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/clientdetail_controller.dart';
import 'package:cosmo_kundali/controllers/home_controller.dart';
import 'package:cosmo_kundali/controllers/other_controller.dart';
import 'package:cosmo_kundali/models/member_list_model.dart';
import 'package:cosmo_kundali/screens/kundali_screens/birth_planet_info.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/gochar_prbhav.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/get_tags.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../values/user_data.dart';

class ExistingClients extends StatelessWidget {
  ExistingClients({super.key});

  final ClientDetailController clientDetailController =
      Get.find(tag: GetTags.clientDetailTag);

  final HomeController homeController = Get.find(tag: GetTags.homeTag);
  final OtherController otherController = Get.find(tag: GetTags.otherTag);

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
        body: Obx(
      () => Container(
        child: clientDetailController.isLoading.value ||
                clientDetailController.memberListModel == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchBar(
                      elevation: const WidgetStatePropertyAll(1),
                      leading: const Icon(Icons.search_rounded),
                      hintText: 'Search',
                      onChanged: (value) {
                        clientDetailController.search(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => ListView.separated(
                        padding: EdgeInsets.zero,
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemCount: clientDetailController.memberList.length,
                        itemBuilder: (context, index) {
                          Members data = clientDetailController.memberList[index];
                          return GestureDetector(
                            onTap: () async {
                              String inputDate = data.DOB;
                              DateFormat inputFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
                              DateTime dateTime = inputFormat.parse(inputDate);
                              DateFormat outputFormat = DateFormat("dd/MM/yyyy | HH:mm");
                              String formattedDate = outputFormat.format(dateTime);
                              UserData.setmID(data.mID);
                              kundaliController.mId.value = data.mID;
                              mbalgoController.mId.value = data.mID;
                              otherController.mId.value = data.mID;
                              homeController.setMId(data.mID);
                              homeController.mId.value = data.mID;
                              homeController.currentPageIndex.value = 1;
                              homeController.selectedUserName.value = data.Name;
                              homeController.selectedGender.value = data.Gender;
                              homeController.selectedBirthDate.value = formattedDate;
                            },
                            child: Container(
                              padding: EdgeInsets.all(11.sp),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Stack(children: [
                                      CircleAvatar(
                                        radius: 27.sp,
                                        backgroundImage:
                                            AssetImage(AppImages.dummyImage),
                                      ),
                                      Positioned(
                                        bottom: -1,
                                        right: 1,
                                        child: GestureDetector(
                                          onTap: () {
                                            clientDetailController.onClickEdit(
                                                index: index, mid: data.mID);
                                            Services.to(
                                                AppRoutes.editClientsView);
                                          },
                                          child: CircleAvatar(
                                            minRadius: 14.sp,
                                            backgroundColor:
                                                Colors.deepOrangeAccent,
                                            child: Image.asset(
                                              AppImages.edit,
                                              width: 3.w,
                                              height: 3.h,
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 47.sp,
                                        child: Text(
                                          data.Name,
                                          style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 35.w,
                                            child: Text(
                                              data.DOB.toString(),
                                              softWrap: true,
                                              style: const TextStyle(
                                                  color: CkColors.textMuted),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        data.City,
                                        style:
                                            const TextStyle(color: CkColors.textMuted),
                                      ),
                                      Text(
                                        data.Gender.capitalizeFirst.toString(),
                                        style:
                                            const TextStyle(color: CkColors.textMuted),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 18.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      String inputDate = data.DOB;
                                      DateFormat inputFormat =
                                          DateFormat("dd-MM-yyyy HH:mm:ss");
                                      DateTime dateTime =
                                          inputFormat.parse(inputDate);
                                      DateFormat outputFormat =
                                          DateFormat("dd/MM/yyyy | HH:mm");
                                      String formattedDate =
                                          outputFormat.format(dateTime);
                                      kundaliController.mId.value = data.mID;
                                      mbalgoController.mId.value = data.mID;
                                      otherController.mId.value = data.mID;
                                      homeController.setMId(data.mID);
                                      homeController.currentPageIndex.value = 1;
                                      homeController.selectedUserName.value =
                                          data.Name;
                                      homeController.selectedGender.value =
                                          data.Gender;
                                      debugPrint("NAME::"+ homeController.selectedUserName.value);
                                      homeController.selectedBirthDate.value =
                                          formattedDate;
                                      //Get.to(ContainView(index: 1.obs));
                                    },
                                    child: Image.asset(
                                      AppImages.arrow,
                                      height: 5.h,
                                      width: 7.w,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      clientDetailController.deleteMember(
                                          context: context, mId: data.mID);
                                    },
                                    child: Image.asset(
                                      AppImages.delete,
                                      height: 5.h,
                                      width: 5.w,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ));
  }
}
