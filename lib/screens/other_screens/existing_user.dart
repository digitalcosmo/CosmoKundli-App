import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/home_controller.dart';
import 'package:cosmo_kundali/values/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/other_controller.dart';
import '../../services/services.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';
import '../../values/routes.dart';

class ExistingUserMelaPak extends StatefulWidget {
  const ExistingUserMelaPak({super.key});

  @override
  State<ExistingUserMelaPak> createState() => _ExistingUserMelaPakState();
}

class _ExistingUserMelaPakState extends State<ExistingUserMelaPak> {
  final OtherController otherController = Get.find(tag: GetTags.otherTag);
  final HomeController _homeController = Get.find(tag: GetTags.homeTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint('Mid is ' + _homeController.mId.value);
    Future.delayed(
      const Duration(seconds: 1),
      () {
        otherController.fetchMemberList(mId: _homeController.mId.value);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    otherController.selectedName.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      appBar: AppBar(
        foregroundColor: AppColors.smallText,
        elevation: 0,
        title: Text(
          "existing_user".tr,
          style: const TextStyle(
              color: AppColors.smallText, fontWeight: FontWeight.w500),
        ),
        actions: [],
      ),
      body: Obx(
        () => otherController.isLoading.value ||
                otherController.melapakOppUserList == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _homeController.selectedGender.value.capitalize
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            1.sbh,
                            Container(
                              height: 5.h,
                              width: 65.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.sp),
                                  border: Border.all(
                                      color: CkColors.text.withOpacity(0.50))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Obx(
                                    () => SizedBox(
                                      width: 30.w,
                                      child: Text(
                                        _homeController.selectedUserName.value,
                                        style: TextStyle(
                                            color:
                                                CkColors.text.withOpacity(0.70),
                                            fontSize: 16.sp),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            otherController.isVisible.value = true;
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                otherController.selectedGender.value.capitalize
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Container(
                                height: 5.h,
                                width: 65.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.sp),
                                    border: Border.all(
                                        color: CkColors.text.withOpacity(0.50))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Obx(
                                      () => otherController.isLoading.value ||
                                              otherController
                                                      .melapakOppUserList ==
                                                  null
                                          ? Container()
                                          : SizedBox(
                                              width: 30.w,
                                              child: Text(
                                                otherController.selectedName
                                                        .value.isEmpty
                                                    ? (otherController
                                                                    .melapakOppUserList
                                                                    ?.members !=
                                                                null &&
                                                            otherController
                                                                .melapakOppUserList!
                                                                .members!
                                                                .isNotEmpty
                                                        ? "Select Partner"
                                                        : '')
                                                    : otherController
                                                        .selectedName.value,
                                                style: TextStyle(
                                                  color: CkColors.text
                                                      .withOpacity(0.70),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      otherController.melapakOppUserList!.members!.length == 0
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                "select_partner".tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17.sp,
                                    color: CkColors.text.withOpacity(0.50)),
                              ),
                            ),
                      SizedBox(
                        width: 65.w,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: otherController
                              .melapakOppUserList!.members!.length,
                          itemBuilder: (context, index) {
                            final data = otherController
                                .melapakOppUserList!.members![index];
                            return ListTile(
                              onTap: () {
                                otherController.oppId.value =
                                    int.parse(data.oID.toString());
                                otherController.selectedName.value =
                                    data.name.toString();
                                otherController.selectedGender.value =
                                    data.gender.toString();

                                Services.to(AppRoutes.ashtkootMelapakView);
                                debugPrint(data.oID);
                              },
                              title: Text(
                                data.name.toString(),
                                style: TextStyle(fontSize: 13),
                              ),
                              subtitle: Text(
                                data.gender.toString(),
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
