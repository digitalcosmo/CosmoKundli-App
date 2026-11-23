import 'package:cosmo_kundali/controllers/home_controller.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../values/get_tags.dart';

/// Floating glass header showing the selected client.
class MainAppBar extends StatelessWidget {
  final Widget child;
  final HomeController homeController = Get.find(tag: GetTags.homeTag);

  MainAppBar({super.key, required this.child});

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Pressable(
        onTap: onTap,
        child: Glass(
          width: 42,
          height: 42,
          radius: 21,
          shadow: false,
          tint: CkColors.glassFillStrong,
          alignment: Alignment.center,
          child: Icon(icon, color: CkColors.text, size: 21),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
        child: Glass(
          radius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Obx(
            () => Row(
              children: [
                _circleBtn(Icons.home_rounded,
                    () => Services.offAll(AppRoutes.clientDetailView)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        homeController.selectedUserName.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700, color: CkColors.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        homeController.selectedBirthDate.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: CkColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _circleBtn(Icons.grid_view_rounded, () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: 'menu',
                    barrierColor: const Color(0x99000814),
                    transitionDuration: CkMotion.base,
                    pageBuilder: (ctx, a1, a2) => SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 70, 14, 20),
                          child: Material(
                            type: MaterialType.transparency,
                            child: Glass(
                              radius: 26,
                              blur: 24,
                              tint: const Color(0xCC0E2F66),
                              padding: const EdgeInsets.all(16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(ctx).size.height * .7),
                                child: SizedBox(
                                    width: double.maxFinite, child: child),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    transitionBuilder: (ctx, a, _, w) {
                      final c = CurvedAnimation(parent: a, curve: CkMotion.ease);
                      return FadeTransition(
                        opacity: c,
                        child: ScaleTransition(
                          alignment: Alignment.topRight,
                          scale: Tween(begin: .92, end: 1.0).animate(c),
                          child: w,
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
