import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/screens/kundali_screens/birth_planet_info.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/gochar_prbhav.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../values/app_constants.dart';
import '../../values/colors.dart';

class Chanchachakra extends StatefulWidget {
  const Chanchachakra({super.key});

  @override
  State<Chanchachakra> createState() => _ChanchachakraState();
}

class _ChanchachakraState extends State<Chanchachakra> {
  List<dynamic> chanchaData = [];
  List<String> headers = ["", "Sa", "Ju", "Ma", "Su", "Ve", "Me", "Mo", "As"];
  List<String> planetRows = ["Su", "Mo", "Ma", "Me", "Ju", "Ve", "Sa"];
  RxList<dynamic> rashiWiseList = [].obs;
  RxList<dynamic> rashiWiseTableList = [].obs;
  RxList<dynamic> rashiWisePlantList = [].obs;
  RxList<Widget> widgetList = <Widget>[].obs;
  RxList dataToShow = [].obs;
  RxList<dynamic> filteredList = [].obs;

  Color getColor(String value, String planet) {
    if (value == "1") {
      if (planet == "Ma") {
        return Colors.red;
      }
      if (planet == "Su") {
        return Colors.orange;
      }
      if (planet == "Mo") {
        return CkColors.textMuted;
      }
      if (planet == "Me") {
        return Colors.green;
      }
      if (planet == "Ju") {
        return Colors.yellow;
      }
      if (planet == "Ve") {
        return Colors.purpleAccent;
      }
      if (planet == "Sa") {
        return CkColors.linkBlue;
      }
      if (planet == "As") {
        return const Color(0xfff8caca);
      }
      return CkColors.text;
    }
    return Colors.transparent;
  }

  @override
  void initState() {
    super.initState();

    getChanchaData(rashiNumber: '1');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: CkColors.text, width: 2.sp),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: CkColors.text, width: 2.sp),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: CkColors.text, width: 2.sp),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: CkColors.text, width: 2.sp),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                  ),
                  value: kundaliController.selectedRashi.value,
                  items: AppConstants.rashiMap.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    kundaliController.selectedRashi.value = newValue!;
                    widgetList.clear();
                    getChanchaData(rashiNumber: newValue.toString());
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 12.2.h,
            width: 100.w,
            child: GridView.builder(
              itemCount: headers.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: headers.length),
              itemBuilder: (context, index) => Container(
                height: 5.h,
                width: 20.w,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(child: Text(headers[index])),
              ),
            ),
          ),
          SizedBox(
            height: 50.h,
            child: Row(
              children: [
                SizedBox(
                  height: 50.h,
                  width: 11.5.w,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: planetRows.length,
                    itemBuilder: (context, index) => Container(
                      height: 5.h,
                      width: 20.w,
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: Center(child: Text(planetRows[index])),
                    ),
                  ),
                ),
                Obx(() => Column(children: widgetList.value))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void getChanchaData({required String rashiNumber}) async {
    Dio dio = Dio();

    try {
      Map<String, dynamic> data = {"mID": mbalgoController.mId.value};

      Response response = await dio.post(
          'https://software.cosmokundli.com/API/ChanchaChakra',
          data: data);

      chanchaData = response.data['list'];

      List<dynamic>? filteredData;
      List<dynamic>? tableData;
      List<dynamic>? ringData = [];

      for (int i = 0; i < chanchaData.length; i++) {
        filteredData = chanchaData
            .where((element) => element['Rashi'] == rashiNumber)
            .toList();
      }
      tableData = filteredData![0]['Table'];
      tableData!.removeAt(0);

      for (int i = 0; i < tableData.length; i++) {
        ringData.add(tableData[i]['Planets']);
      }

      var filteredRingData = ringData.map((innerList) {
        return innerList.map((map) {
          String grahName = map.keys.first.toUpperCase();
          String grahValue = map.values.first.toString();
          return {"grah_name": grahName, "grah_value": grahValue};
        }).toList();
      }).toList();
      // filteredRingData = filteredRingData[0];

      for (int i = 0; i < filteredRingData.length; i++) {
        widgetList.add(
          Row(
            children: List.generate(
              filteredRingData[i].length,
              (index) => Container(
                height: 5.h,
                width: 11.w,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: getColor(
                      filteredRingData[i][index]['grah_value'],
                      filteredRingData[i]![index]['grah_name']
                          .toString()
                          .capitalizeFirst
                          .toString()),
                ),
                // child: Text(
                //   filteredRingData[i][index]['grah_value'],
                // ),
              ),
            ),
          ),
        );
      }

      debugPrint('Table Data ' + tableData.toString());
      debugPrint('Ring Data ' + ringData.toString());
      debugPrint('Ring Data ' + filteredRingData.toString());

      // debugPrint('CData' + chanchaData.toString());
      //
      // for (int i = 0; i < chanchaData.length; i++) {
      //   rashiWiseList.value.add(chanchaData[i]);
      // }
      //
      // for (int i = 0; i < rashiWiseList.length; i++) {
      //   rashiWiseTableList.value.add(rashiWiseList[i]['Table']);
      // }
      //
      // for (int i = 0; i < rashiWiseTableList[0].length; i++) {
      //   rashiWisePlantList.value.add(rashiWiseTableList[0][i]['Planets']);
      // }
      //
      // var a = rashiWisePlantList.value.map((innerList) {
      //   return innerList.map((map) {
      //     String grahName = map.keys.first.toUpperCase();
      //     String grahValue = map.values.first.toString();
      //     return {"grah_name": grahName, "grah_value": grahValue};
      //   }).toList();
      // }).toList();
      //
      // filteredList.value = a;
      //
      //
      // debugPrint('CData' + filteredList.value.toString());
      //
      // for (int i = 0; i < filteredList.length; i++) {
      //   widgetList.add(
      //     Row(
      //       children: List.generate(
      //         filteredList[i].length,
      //         (index) => Container(
      //           height: 5.h,
      //           width: 11.w,
      //           decoration: BoxDecoration(
      //             border: Border.all(),
      //             color: getColor(
      //                 filteredList[i][index]['grah_value'],
      //                 filteredList[i]![index]['grah_name']
      //                     .toString()
      //                     .capitalizeFirst
      //                     .toString()),
      //           ),
      //           child: Text(
      //             filteredList[i][index]['grah_value'],
      //           ),
      //         ),
      //       ),
      //     ),
      //   );
      // }
      //
      // widgetList.removeAt(0);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }
}
