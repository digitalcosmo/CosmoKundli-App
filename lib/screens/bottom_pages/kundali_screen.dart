import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/kundali_controller.dart';
import 'package:cosmo_kundali/custom_widgets/main_appbar.dart';
import 'package:cosmo_kundali/custom_widgets/main_tabBar.dart';
import 'package:cosmo_kundali/screens/kundali_screens/ashatak_varg.dart';
import 'package:cosmo_kundali/screens/kundali_screens/bhav_chalit_kundali.dart';
import 'package:cosmo_kundali/screens/kundali_screens/dasha.dart';
import 'package:cosmo_kundali/screens/kundali_screens/fivefold_relationship.dart';
import 'package:cosmo_kundali/screens/kundali_screens/kundali_main.dart';
import 'package:cosmo_kundali/screens/kundali_screens/navmansh.dart';
import 'package:cosmo_kundali/screens/kundali_screens/sani_panoti.dart';
import 'package:cosmo_kundali/screens/kundali_screens/shadbal.dart';
import 'package:cosmo_kundali/screens/kundali_screens/tara_chakra.dart';
import 'package:cosmo_kundali/screens/kundali_screens/varg_kundali.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:cosmo_kundali/values/user_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../values/get_tags.dart';
import '../kundali_screens/chancha_chakra.dart';

class KundaliScreen extends StatefulWidget {
  const KundaliScreen({super.key});

  @override
  State<KundaliScreen> createState() => _KundaliScreenState();
}

class _KundaliScreenState extends State<KundaliScreen>
    with SingleTickerProviderStateMixin {
  final KundaliController kundaliController =
  Get.put(KundaliController(), tag: GetTags.kundaliTag);
  TabController? tabController;
  List<String> _featureList = [];
  List<String> _filteredFeatureList = [];
  List<Widget> _widgetList = [];

  @override
  void initState() {
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
    return tabController == null
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(_filteredFeatureList[index]),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          tabController!.animateTo(index);
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 14.sp,
                          color: CkColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
    );
  }

  Future<void> getFeatureList() async {
    String a = await UserData.getFeatures();
    List<String> kundliFeatures = a
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',')
        .map((feature) => feature.trim())
        .toList();

    _featureList = kundliFeatures;
    _filteredFeatureList.clear();
    _widgetList.clear();

    for (String pages in _featureList) {
      switch (pages) {
        case 'Birth Kundli':
          _filteredFeatureList.add("Kundli".tr);
          _widgetList.add( KundaliMain());
          break;
        case 'Dasha':
          _filteredFeatureList.add("dasha".tr);
          _widgetList.add(const Dasha());
          break;
        case 'Five Fold Friendship':
          _filteredFeatureList.add("five_fold_friendship".tr);
          _widgetList.add(const FiveFoldRelationship());
          break;
        case 'Shadbal':
          _filteredFeatureList.add("shadbal".tr);
          _widgetList.add( Shadbal());
          break;
        case 'Varg Kundlis':
          _filteredFeatureList.add("varg_kundlis".tr);
          _widgetList.add( VargKundali());
          break;
        case 'Ashtakvarg':
          _filteredFeatureList.add("ashtakvarg".tr);
          _widgetList.add( AshatakVarg());
          break;
        case 'Chanchachakra':
          _filteredFeatureList.add("chanchachakra".tr);
          _widgetList.add(const Chanchachakra());
          break;
        case 'Tara Chakra':
          _filteredFeatureList.add("tara_chakra".tr);
          _widgetList.add( TaraChakra());
          break;
        case 'Sani Panoti':
          _filteredFeatureList.add("sani_panoti".tr);
          _widgetList.add( SaniPanoti());
          break;
        case 'Bhav Chalit':
          _filteredFeatureList.add("bhav_chalit".tr);
          _widgetList.add( BhavChalitKundali());
          break;
        case 'Navmansh':
          _filteredFeatureList.add("navmansh".tr);
          _widgetList.add(const Navmansh());
          break;
      }
    }
  }

  Future<void> initTabBar() async {
    await getFeatureList();
    if (_filteredFeatureList.isNotEmpty && _widgetList.isNotEmpty) {
      setState(() {
        tabController =
            TabController(length: _filteredFeatureList.length, vsync: this);
        tabController!.addListener(() {
          if (!tabController!.indexIsChanging) {
            setState(() {});
          }
        });
      });
    }
  }
}