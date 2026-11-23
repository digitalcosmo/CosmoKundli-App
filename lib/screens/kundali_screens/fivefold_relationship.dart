import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/kundali_controller.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../custom_widgets/main_table.dart';
import '../../values/get_tags.dart';

class FiveFoldRelationship extends StatefulWidget {
  const FiveFoldRelationship({super.key});

  @override
  State<FiveFoldRelationship> createState() => _FiveFoldRelationshipState();
}

final KundaliController _kundaliController = Get.find(tag: GetTags.kundaliTag);

class _FiveFoldRelationshipState extends State<FiveFoldRelationship> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        _kundaliController.getFiveFoldRelationshipTableData();
      },

    );
   // debugPrint(_kundaliController.fiveFoldRelationshipModel!.list[1].planets.moon);
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(17.sp),
          child: Obx(
            () => _kundaliController.isLoading.value ||
                    _kundaliController.fiveFoldRelationshipModel == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MainTable(
                        colors: AppConstants.grah_colors,
                        headers: AppConstants.headers,
                        header: "planet".tr,
                        planetData:
                            _kundaliController.fiveFoldRelationshipModel!.list,
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        "notation".tr,
                        style: TextStyle(
                            fontSize: 17.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        children: [
                          Text(
                            "friend".tr,
                            style: TextStyle(fontSize: 15.sp),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            "neutral".tr,
                            style: TextStyle(fontSize: 15.sp),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            "enemy".tr,
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Row(
                        children: [
                          Text(
                            "intimate_friend".tr,
                            style: TextStyle(fontSize: 15.sp),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            "intimate_enemy".tr,
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
