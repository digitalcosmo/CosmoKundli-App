import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/other_controller.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';

class MelapakScreen extends StatelessWidget {
  MelapakScreen({super.key});

  final controller = Get.find<OtherController>(tag: GetTags.otherTag);
  final homeController = Get.find<HomeController>(tag: GetTags.homeTag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const GlassAppBar(title: 'Melapak - Kundali Matching'),
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: GlassTextField(
                  hint: 'Search members...',
                  prefixIcon: Icons.search,
                  onChanged: (val) => controller.searchMelapakMembers(val),
                ),
              ).animate().fadeIn(duration: 400.ms),
              // Member list
              Expanded(
                child: Obx(() {
                  if (controller.isMelapakListLoading.value) {
                    return const LoadingWidget();
                  }
                  final members = controller.filteredMelapakMembers;
                  if (members.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, color: AppTheme.textMuted, size: 48),
                          SizedBox(height: 2.h),
                          Text('No matching members found', style: AppTheme.bodySmall),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return GlassCard(
                        margin: EdgeInsets.only(bottom: 1.5.h),
                        padding: EdgeInsets.all(4.w),
                        onTap: () {
                          controller.matchWithExistingUser(
                            context,
                            memberId: member['oID']?.toString() ?? '',
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.accent.withOpacity(0.2),
                              child: Text(
                                (member['Name']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.accent),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member['Name']?.toString() ?? 'Unknown',
                                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    member['Gender']?.toString() ?? '',
                                    style: AppTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
                          ],
                        ),
                      ).animate().fadeIn(
                            duration: 400.ms,
                            delay: Duration(milliseconds: 50 * (index > 10 ? 10 : index)),
                          );
                    },
                  );
                }),
              ),
              // Match with new user button
              Padding(
                padding: EdgeInsets.all(4.w),
                child: GlassButton(
                  text: 'Match with New Person',
                  icon: Icons.person_add_outlined,
                  onPressed: () => Get.toNamed(AppRoutes.melapakNewUser),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
