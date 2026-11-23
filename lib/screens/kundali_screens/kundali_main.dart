import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/screens/kundali_screens/temp.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/home_controller.dart';
import '../../values/get_tags.dart';
import 'navmansh_kundali.dart';

class KundaliMain extends StatefulWidget {
  @override
  _KundaliMainState createState() => _KundaliMainState();
}

class _KundaliMainState extends State<KundaliMain> {


  final HomeController homeController = Get.find(tag: GetTags.homeTag);

  @override
  void initState() {
    super.initState();
    debugPrint("MID"+homeController.mId.value);
    // Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    Widget action(String label, IconData icon, String route, int i) =>
        FadeSlideIn(
          index: i,
          child: Pressable(
            onTap: () => Services.to(route),
            child: Glass(
              radius: 18,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: CkColors.cta,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: CkColors.text)),
                  ),
                ],
              ),
            ),
          ),
        );

    return CkScaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
        child: Column(
          children: [
            FadeSlideIn(
              child: Glass(
                radius: 24,
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 50.h,
                  child: KundaliWidget(
                    mid: homeController.mId.value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: action('bhav_chalit'.tr, Icons.grid_4x4_rounded, AppRoutes.bhavChaitKundali, 1)),
              const SizedBox(width: 10),
              Expanded(child: action('navmansh'.tr, Icons.auto_awesome_mosaic_rounded, AppRoutes.navamanshKundali, 2)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: action('birth_planet_info'.tr, Icons.public_rounded, AppRoutes.birthPlanetInfo, 3)),
              const SizedBox(width: 10),
              Expanded(child: action('vimshottari_maha_dasha'.tr, Icons.timeline_rounded, AppRoutes.vimshottariView, 4)),
            ]),
          ],
        ),
      ),
    );
  }
}
