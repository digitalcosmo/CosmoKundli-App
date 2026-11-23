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
    Colors.red[100]!,
    Colors.orange[100]!,
    Colors.yellow[100]!,
    Colors.green[100]!,
    CkColors.linkBlue[100]!,
    Colors.indigo[100]!,
    Colors.purple[100]!,
    Colors.pink[100]!,
    Colors.teal[100]!,
    Colors.brown[100]!,
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
                    border:TableBorder.all(color: Colors.white,width: 2.sp) ,
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
