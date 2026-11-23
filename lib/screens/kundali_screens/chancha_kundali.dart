import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChanchaKundali extends StatefulWidget {
   ChanchaKundali({super.key});

  @override
  State<ChanchaKundali> createState() => _ChanchaKundaliState();
}

class _ChanchaKundaliState extends State<ChanchaKundali> {


  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      appBar: AppBar(
        foregroundColor: AppColors.headerColor,
        title: Text("chancha_kundali".tr,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17.sp),),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.center,
              child:  InteractiveViewer(
                  panEnabled: false,
                  boundaryMargin: EdgeInsets.all(80.sp),
                  //minScale: 0.2,

                  maxScale: 4,
                  child: Image.asset(AppImages.roundkundaliImage))
          ),
        ],
      ),
    );
  }
}
