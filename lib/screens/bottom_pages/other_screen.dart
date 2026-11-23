import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/home_controller.dart';
import 'package:cosmo_kundali/screens/other_screens/gochar.dart';
import 'package:cosmo_kundali/screens/other_screens/melaapak.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../custom_widgets/main_appbar.dart';
import '../../custom_widgets/main_tabBar.dart';
import '../../services/services.dart';
import '../../values/app_constants.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../values/get_tags.dart';
import '../../values/user_data.dart';

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

List<String> _featureList = [];
List<String> _filteredFeatureList = [];
List<Widget> _widgetList = [];

class _OtherScreenState extends State<OtherScreen>
    with SingleTickerProviderStateMixin {
  final HomeController homeController = Get.find(tag: GetTags.homeTag);
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    initTabBar();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
    _filteredFeatureList.clear();
    _featureList.clear();
    _widgetList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: _tabController == null
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
                          Navigator.pop(context);
                          _tabController!.animateTo(index);
                        },
                        child: Row(
                          children: [
                            Text(_filteredFeatureList[index].toString()),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                _tabController!.animateTo(index);
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
                ),
                Expanded(
                  child: MainTabBar(
                    controller: _tabController,
                    tabItems: List.generate(
                      _filteredFeatureList.length,
                      (index) => TabItem(
                        text: _filteredFeatureList[index],
                        content: _widgetList[index],
                      ),
                    ),
                  ),
                )
                //  TabBar(
                //   controller: _tabController,
                //   tabAlignment: TabAlignment.start,
                //   padding: EdgeInsets.all(15.sp),
                //    indicatorColor: AppColors.headerColor,
                //    labelColor:AppColors.headerColor ,
                //
                //    labelStyle: TextStyle(
                //      fontSize: 17.sp,
                //      fontWeight: FontWeight.w500
                //    ),
                //    isScrollable: true,
                //     dividerHeight: 0,
                //     tabs: const [
                //       Text('Kundali'),
                //       Text('Five Fold Friendship'),
                //       Text('Shadbal'),
                //       Text('Varg Kundalis'),
                //       Text('Ashtakvarg'),
                //       Text('Chanchachakra'),
                //       Text('Dasha'),
                //       Text('Tara Chakra'),
                //       Text('Sani Panoti'),
                //     ]),
                //   Expanded(
                //    child: TabBarView(
                //
                //      controller: _tabController,
                //     children: [
                //       KundaliMain(),
                //       FiveFoldRelationship(),
                //       Shadbal(),
                //       VargKundali(),
                //       AshatakVarg(),
                //       Chanchachakra(),
                //       Center(child: Text('Dasha')),
                //       Center(child: Text('Tara Chakra')),
                //       Center(child: Text('Sani Panoti')),
                //     ],
                //   ),
                // ),
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
        // case 'Gochar (Animated)':
        //   _filteredFeatureList.add("gochar_animated".tr);
        //   _widgetList.add(Gochar());
        //   break;

      //Removed Gochar

        case 'Melaapak':
          _filteredFeatureList.add("melaapak".tr);
          _widgetList.add(Melaapak());
          break;
      }
    }
  }

  void initTabBar() async {
    await getFeatureList();
    if (_filteredFeatureList.isNotEmpty && _widgetList.isNotEmpty) {
      _tabController =
          TabController(length: _filteredFeatureList.length, vsync: this);
      setState(() {});
    }
  }
}
