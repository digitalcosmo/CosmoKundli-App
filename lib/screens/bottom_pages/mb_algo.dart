import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/custom_widgets/main_tabBar.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/cosmo_power.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/cosmo_power_report.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/gochar_prbhav.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/periodic_monthly_report.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/star_power.dart';
import 'package:cosmo_kundali/screens/mbAlgo_screens/star_power_report.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../custom_widgets/main_appbar.dart';
import '../../services/services.dart';
import '../../values/app_constants.dart';
import '../../values/user_data.dart';

class MbAlgo extends StatefulWidget {
  MbAlgo({super.key});

  @override
  State<MbAlgo> createState() => _MbAlgoState();
}

List<String> _featureList = [];
List<String> _filteredFeatureList = [];
List<Widget> _widgetList = [];

class _MbAlgoState extends State<MbAlgo> with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTabBar();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
    _filteredFeatureList.clear();
    _featureList.clear();
    _widgetList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: tabController == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                MainAppBar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredFeatureList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          tabController!.animateTo(index);
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: [
                            Text(_filteredFeatureList[index].toString()),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                tabController?.animateTo(index);
                                Services.back();
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                size: 14.sp,
                                color: CkColors.text,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )
                // MainAppBar(
                //     child: Row(
                //       //mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         SizedBox(
                //           width: 20.w,
                //         ),
                //         const Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Text(
                //               'Jaini B Shah',
                //               style: TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 17,
                //                   fontWeight: FontWeight.w600),
                //             ),
                //             Text('13/08/2000' + ' | ' + '16:08',
                //                 style: TextStyle(
                //                     color: CkColors.textMuted,
                //                     fontSize: 13,
                //                     fontWeight: FontWeight.w600))
                //           ],
                //         ),
                //         SizedBox(
                //           width: 40.w,
                //         ),
                //         GestureDetector(
                //           onTap: () {
                //             showDialog(
                //               context: context,
                //               builder: (context) {
                //                 return AlertDialog(
                //                   content: Container(
                //                     width: double.maxFinite,
                //                     child: ListView.builder(
                //                       shrinkWrap: true,
                //                       itemCount: AppConstants.kundaliList.length,
                //                       itemBuilder: (context, index) {
                //                         return Row(
                //                           children: [
                //                             Text(AppConstants.kundaliList[index]
                //                                 .toString()),
                //                             Spacer(),
                //                             IconButton(
                //                                 onPressed: () {
                //                                   // _navigateToTab(AppConstants
                //                                   //     .kundaliList[index]
                //                                   //     .toString());
                //                                 },
                //                                 icon: Icon(
                //                                   Icons.arrow_forward_ios,
                //                                   size: 14.sp,
                //                                   color: CkColors.text,
                //                                 ))
                //                           ],
                //                         );
                //                       },
                //                     ),
                //                   ),
                //                 );
                //               },
                //             );
                //           },
                //           child: Image.asset(
                //             AppImages.drawer,
                //             height: 2.h,
                //           ),
                //         )
                //       ],
                //     ),),
                ,
                // Expanded(
                //   child: MainTabBar(tabItems: [
                //     TabItem(text: "star_power_9_month".tr, content: StarPower()),
                //     TabItem(text: "star_power_report".tr, content: StarPowerReport()),
                //     TabItem(text: "cosmo_power_9_month".tr, content: CosmoPower()),
                //    // TabItem(text:  "cosmo_power_report".tr, content: CosmoPowerReport()),
                //     TabItem(text: "periodic_monthly_report".tr, content: PeriodicMonthlyReport()),
                //     TabItem(text: "gochar_prabhav".tr, content: GocharPrbhav()),
                //   ], controller: tabController),
                // ),
                Expanded(
                  child: MainTabBar(
                    controller: tabController,
                    tabItems: List.generate(
                      _filteredFeatureList.length,
                      (index) => TabItem(
                        text: _filteredFeatureList[index],
                        content: _widgetList[index],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> getFeatureList() async {
    String a = await UserData.getFeatures();
    List<String> kundliFeatures = a
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',')
        .map((feature) => feature.trim()) // Trim whitespace
        .toList();

    _featureList = kundliFeatures;
    _filteredFeatureList.clear(); // Clear previous entries
    _widgetList.clear(); // Clear previous widgets

    for (String pages in _featureList) {
      switch (pages) {
        case 'Star Power - Daily (Full)':
          _filteredFeatureList.add("star_power".tr);
          _widgetList.add(StarPower());
          break;
        case 'Star Power Report':
          _filteredFeatureList.add("star_power_report".tr);
          _widgetList.add(StarPowerReport());
          break;
        case 'Cosmo Power - 9 Month':
          _filteredFeatureList.add("cosmo_power_9_month".tr);
          _widgetList.add(const CosmoPower());
          break;
        case 'Cosmo Power Report':
          _filteredFeatureList.add("cosmo_power_report".tr);
          _widgetList.add(CosmoPowerReport());
          break;
        case 'Periodic Monthly Report':
          _filteredFeatureList.add("periodic_monthly_report".tr);
          _widgetList.add(PeriodicMonthlyReport());
          break;
        case 'Gochar Prabhav':
          _filteredFeatureList.add("gochar_prabhav".tr);
          _widgetList.add(GocharPrbhav());
          break;
      }
    }
    debugPrint('Filter Features $_filteredFeatureList');
    debugPrint('Filter Features $_featureList');
  }

  void initTabBar() async {
    await getFeatureList();
    if (_filteredFeatureList.isNotEmpty && _widgetList.isNotEmpty) {
      tabController =
          TabController(length: _filteredFeatureList.length, vsync: this);
      setState(() {});
    }
  }
}
