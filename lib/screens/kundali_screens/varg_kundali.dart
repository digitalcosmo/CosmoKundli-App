import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:convert';

import 'package:cosmo_kundali/screens/kundali_screens/birth_planet_info.dart';
import 'package:cosmo_kundali/screens/kundali_screens/varg_kundalis.dart';
import 'package:cosmo_kundali/values/colors.dart';
import 'package:cosmo_kundali/values/urls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:responsive_sizer/responsive_sizer.dart';

class VargKundali extends StatefulWidget {
  VargKundali({super.key});

  @override
  State<VargKundali> createState() => _VargKundaliState();
}

class _VargKundaliState extends State<VargKundali> {
  final List<Map<String, String>> nameValueMap = [
    {'name': 'Moon (D-1)', 'value': 'D1'},
    {'name': 'Hora (D-2)', 'value': 'D2'},
    {'name': 'Drekkana (D-3)', 'value': 'D3'},
    {'name': 'Chatuthmasa (D-4)', 'value': 'D4'},
    {'name': 'Saptmasa (D-7)', 'value': 'D7'},
    {'name': 'Navamsa (D-9)', 'value': 'D9'},
    {'name': 'Dasama (D-10)', 'value': 'D10'},
    {'name': 'Davadasama (D-12)', 'value': 'D12'},
    {'name': 'Shodasamasa (D-16)', 'value': 'D16'},
    {'name': 'Vimsamsa (D-20)', 'value': 'D20'},
    {'name': 'ChaturVimsamsa (D-24)', 'value': 'D24'},
    {'name': 'SaptaVimsamsa (D-27)', 'value': 'D27'},
    {'name': 'Trimsamsa (D-30)', 'value': 'D30'},
    {'name': 'KhaVedamsa (D-40)', 'value': 'D40'},
    {'name': 'AkshaVedamsa (D-45)', 'value': 'D45'},
    {'name': 'Shastiamsa (D-60)', 'value': 'D60'},
  ];

  RxString _selectedName = ''.obs;
  VargKundalis vargKundalis = VargKundalis('');

  @override
  void initState() {
    super.initState();
    _selectedName.value = nameValueMap.first['value']!;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.sp),
      child: Obx(
            () => Column(
          children: [
            DropdownButtonFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CkColors.text, width: 2.sp),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CkColors.text, width: 2.sp),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CkColors.text, width: 2.sp),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: CkColors.text, width: 2.sp),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
              ),
              value: _selectedName.value,
              items: nameValueMap.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value['value'],
                  child: Text(value['name'].toString(),
                      style: TextStyle(fontSize: 15.sp)),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                getKundaliData(newValue!);
                _selectedName.value = newValue!;
                AppUrls.varg_kundali = _selectedName.value;

                debugPrint("Selected value: " + _selectedName.value);
              },
            ),
            SizedBox(
              height: 5.h,
            ),
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: nameValueMap.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final RxString name = ''.obs;
                    name.value = nameValueMap[index]['value'].toString();
                    return Obx(
                          () => Visibility(
                        visible: name.value == _selectedName.value,
                        child: VargKundalis(
                          _selectedName.value.toString(),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void getKundaliData(String url) async {
    Dio dio = Dio();

    Map<String, dynamic> data = {
      'mID': kundaliController.mId.value,
    };

    debugPrint('Varg Kundali Called');

    Response response = await dio.post(
      'https://software.cosmokundli.com/API/$url',
      data: data,
    );
    debugPrint('https://software.cosmokundli.com/API/${_selectedName.value}');

    List<dynamic> planets = response.data['planets'];
    debugPrint(planets.length.toString());
    debugPrint(jsonEncode(planets));

    Map<String, dynamic>? asPlanet =
        planets.firstWhere((planet) => planet['planet'] == 'As');
    int asRashi = int.parse(asPlanet!['rashi']);
    List<int> allRashis = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    List<int> rashiOrder = [
      ...allRashis.where((r) => r >= asRashi),
      ...allRashis.where((r) => r < asRashi)
    ];

    List otherPlanets =
        planets.where((planet) => planet['planet'] != 'As').toList();

    otherPlanets.sort((a, b) {
      int rashiA = int.parse(a['rashi']);
      int rashiB = int.parse(b['rashi']);
      return rashiOrder.indexOf(rashiA).compareTo(rashiOrder.indexOf(rashiB));
    });

    List<Map<String, dynamic>> sortedPlanets = [asPlanet, ...otherPlanets];

    if (mounted) {
      setState(() {
        planetsData.clear();
        for (int i = 0; i < sortedPlanets.length; i++) {
          planetsData.add(
            KundaliModel(
              color: sortedPlanets[i]['color'],
              degree: sortedPlanets[i]['degree'],
              planet: sortedPlanets[i]['planet'],
              rashi: sortedPlanets[i]['rashi'],
            ),
          );
        }
      });
    }

    rashiToGharMapping.clear();

    for (int i = 0; i < rashiOrder.length; i++) {
      rashiToGharMapping[rashiOrder[i]] = i + 1;
    }

    rashiToGharMapping.forEach((rashi, ghar) {});

    kundaliController.isVargKundaliApiCalled = true;

    debugPrint('Rashi maping is $rashiToGharMapping');
  }
}
