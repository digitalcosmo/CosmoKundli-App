import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/custom_widgets/main_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/kundali_controller.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class BirthPlanetInfo extends StatefulWidget {
   const BirthPlanetInfo({super.key});

  @override
  State<BirthPlanetInfo> createState() => _BirthPlanetInfoState();
}

class _BirthPlanetInfoState extends State<BirthPlanetInfo> {
  final List<Color> colors = [
    Colors.red.withOpacity(0.18),
    Colors.orange.withOpacity(0.18),
    Colors.yellow.withOpacity(0.18),
    Colors.green.withOpacity(0.18),
    Colors.blue.withOpacity(0.18),
    Colors.indigo.withOpacity(0.18),
    Colors.purple.withOpacity(0.18),
    Colors.pink.withOpacity(0.18),
    Colors.teal.withOpacity(0.18),
    Colors.brown.withOpacity(0.18),
  ];

   final KundaliController _kundaliController = Get.find(tag: GetTags.kundaliTag);

   @override
  void initState() {
    super.initState();
    _kundaliController.fetchBirthPlanetInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CkScaffold(
        appBar: AppBar(
          foregroundColor: AppColors.fontHeaderColor,
          title: Text(
            "birth_planet_info".tr,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 19,
              color: AppColors.smallText,
            ),
          ),
        ),

        body: kundaliController.isLoading.value ||
                kundaliController.birthPlanetInfoModel == null
            ?  Center(
                child: MainLoader(isLoading: kundaliController.isLoading.value ,child: Container(), ),
              )
            : Container(
              padding: EdgeInsets.all(20.sp),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border:TableBorder.all(color: CkColors.glassStroke, width: 1) ,
                    columnSpacing: 29.sp,
                    horizontalMargin: 4.sp,
                    dataRowHeight: 23.sp,
                    columns:  <DataColumn> [
                      DataColumn(
                        label: Text('planet'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('rashi'.tr,
                            style:const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('degree'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('nakshatra'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows:  List<DataRow>.generate(
                      kundaliController.birthPlanetInfoModel!.planets.length,
                        (index) => DataRow(

                      color: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          return colors[index % colors.length];
                        },
                      ),
                      cells: <DataCell>[
                        DataCell(
                            Container(
                          color: colors[index % colors.length],
                          child: Text(kundaliController.birthPlanetInfoModel!.planets[index].planet),
                        )),
                        DataCell(Container(
                          color: colors[index % colors.length],
                          child: Text(kundaliController.birthPlanetInfoModel!.planets[index].rashi),
                        )),
                        DataCell(Container(
                          color: colors[index % colors.length],
                          child: Text(kundaliController.birthPlanetInfoModel!.planets[index].degree),
                        )),
                        DataCell(Container(
                          color: colors[index % colors.length],
                          child: Text(kundaliController.birthPlanetInfoModel!.planets[index].nakshatra),
                        )),
                      ],
                    ),
                  ),
                  ),

                ),
            ),
      ),
    );
  }
}

final KundaliController kundaliController = Get.find(tag: GetTags.kundaliTag);
