import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'package:cosmo_kundali/controllers/clientdetail_controller.dart';
import 'package:cosmo_kundali/controllers/home_controller.dart';
import 'package:cosmo_kundali/controllers/mbAlgo_controller.dart';
import 'package:cosmo_kundali/controllers/other_controller.dart';
import 'package:cosmo_kundali/models/member_list_model.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/get_tags.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:cosmo_kundali/values/user_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/kundali_controller.dart';

class ExistingClientScreen extends StatefulWidget {
  const ExistingClientScreen({super.key});

  @override
  State<ExistingClientScreen> createState() => _ExistingClientScreenState();
}

class _ExistingClientScreenState extends State<ExistingClientScreen> {
  final ClientDetailController clientDetailController =
      Get.put(ClientDetailController(), tag: GetTags.clientDetailTag);

  final HomeController homeController = Get.put(HomeController(), tag: GetTags.homeTag);

  final KundaliController kundaliController = Get.put(KundaliController(), tag: GetTags.kundaliTag);
  final MbalgoController mbalgoController = Get.put(MbalgoController(), tag: GetTags.mbAlgoTag);
  final OtherController otherController = Get.find(tag: GetTags.otherTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    clientDetailController.fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
        appBar: AppBar(
          foregroundColor: AppColors.fontHeaderColor,
          actions: [
            // Row(
            //   children: [
            //     Text(
            //       "add_new".tr,
            //       style: const TextStyle(
            //         color: AppColors.smallText,
            //         fontWeight: FontWeight.w600,
            //         fontSize: 13,
            //       ),
            //     ),
            //     IconButton(
            //         onPressed: () {
            //           Services.to(AppRoutes.clientDetailView);
            //         },
            //         icon: const Icon(
            //           Icons.add,
            //           color: AppColors.smallText,
            //         ))
            //   ],
            // )
          ],
          title: Text(
            "existing_clients".tr,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 19,
              color: AppColors.smallText,
            ),
          ),
        ),
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
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemCount: clientDetailController.memberList.length,
                          itemBuilder: (context, index) {
                            Members data =
                                clientDetailController.memberList[index];
                            return GestureDetector(
                              onTap: () async {
                                homeController.setMId(clientDetailController
                                    .memberListModel!.members[index].mID);

                                String inputDate = clientDetailController
                                    .memberListModel!.members[index].DOB;
                                DateFormat inputFormat =
                                    DateFormat("dd-MM-yyyy HH:mm:ss");
                                DateTime dateTime =
                                    inputFormat.parse(inputDate);
                                DateFormat outputFormat =
                                    DateFormat("dd/MM/yyyy | HH:mm");
                                String formattedDate =
                                    outputFormat.format(dateTime);

                                UserData.setmID(data.mID);
                                //  homeController.currentPageIndex.value = 1;
                                homeController.selectedUserName.value =
                                    clientDetailController
                                        .memberListModel!.members[index].Name;
                                homeController.selectedGender.value =
                                    clientDetailController
                                        .memberListModel!.members[index].Gender;
                                homeController.selectedBirthDate.value =
                                    formattedDate;
                                kundaliController.mId.value =
                                    clientDetailController
                                        .memberListModel!.members[index].mID;
                                mbalgoController.mId.value = data.mID;
                                otherController.mId.value = data.mID;

                                Services.to(AppRoutes.containView);
                                // Get.to(ContainView(index: 1.obs));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Stack(children: [
                                        CircleAvatar(
                                          radius: 25.sp,
                                          backgroundImage:
                                              AssetImage(AppImages.dummyImage),
                                        ),
                                        Positioned(
                                          bottom: -1,
                                          right: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              clientDetailController
                                                  .onClickEdit(
                                                      index: index,
                                                      mid: data.mID);
                                              Services.to(
                                                  AppRoutes.editClientsView);
                                            },
                                            child: CircleAvatar(
                                              child: Image.asset(
                                                AppImages.edit,
                                                width: 3.w,
                                                height: 3.h,
                                              ),
                                              minRadius: 14.sp,
                                              backgroundColor:
                                                  AppColors.mainColor,
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
                                          width: 50.sp,
                                          child: Text(
                                            data.Name,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 17.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 50.sp,
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
                                          style: const TextStyle(
                                              color: CkColors.textMuted),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          homeController
                                                  .selectedUserName.value =
                                              clientDetailController
                                                  .memberList[index].Name;
                                          homeController
                                              .selectedGender.value =
                                              clientDetailController
                                                  .memberList[index].Gender;
                                          homeController.setMId(
                                              clientDetailController
                                                  .memberList[index].mID);
                                          mbalgoController.mId.value = data.mID;
                                          kundaliController.mId.value =
                                              data.mID;
                                          otherController.mId.value = data.mID;
                                          String inputDate =
                                              clientDetailController
                                                  .memberList[index].DOB;
                                          DateFormat inputFormat =
                                              DateFormat("dd-MM-yyyy HH:mm:ss");
                                          DateTime dateTime =
                                              inputFormat.parse(inputDate);
                                          DateFormat outputFormat =
                                              DateFormat("dd/MM/yyyy | HH:mm");
                                          String formattedDate =
                                              outputFormat.format(dateTime);
                                          homeController.selectedBirthDate
                                              .value = formattedDate;

                                          Services.to(AppRoutes.containView);
                                        },
                                        child: Image.asset(
                                          AppImages.arrow,
                                          height: 5.h,
                                          width: 7.w,
                                        )),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        clientDetailController
                                                .selectedMemberName =
                                            clientDetailController
                                                .memberList.value![index].Name!;

                                        Services.showConfirmDialog(
                                          context: context,
                                          upperText:
                                              'Are you sure want to delete ${clientDetailController.selectedMemberName}`s Kundli',
                                          onPressYesButton: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();

                                            clientDetailController.deleteMember(
                                                context: context,
                                                mId: clientDetailController
                                                    .memberList
                                                    .value![index]
                                                    .mID);
                                          },
                                        );

                                        debugPrint("done");
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
                    ],
                  ),
          ),
        ));
  }
}
