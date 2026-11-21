import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/client_detail_controller.dart';
import 'package:cosmo_kundli/controllers/home_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class ClientListScreen extends StatelessWidget {
  ClientListScreen({super.key});

  final controller = Get.put(ClientDetailController(), tag: GetTags.clientDetailTag);

  @override
  Widget build(BuildContext context) {
    controller.fetchMemberList();

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
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                    ),
                    Expanded(
                      child: Text('All Clients', style: AppTheme.headingLarge),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GlassTextField(
                  controller: controller.searchController,
                  hint: 'Search clients...',
                  prefixIcon: Icons.search,
                  onChanged: (val) => controller.searchMembers(val),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

              SizedBox(height: 1.5.h),

              // List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingWidget();
                  }

                  final members = controller.filteredMemberList;
                  if (members.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
                          SizedBox(height: 2.h),
                          Text('No clients found', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Dismissible(
                          key: Key(member.mID ?? index.toString()),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(context, member.name ?? ''),
                          onDismissed: (_) => controller.deleteMember(context, member.mID ?? ''),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 5.w),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            ),
                            child: const Icon(Icons.delete_outline, color: AppTheme.error),
                          ),
                          child: GlassCard(
                            onPressed: () => _selectMember(member),
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _genderColor(member.gender).withOpacity(0.15),
                                  ),
                                  child: Icon(
                                    member.gender == 'Male' ? Icons.male : Icons.female,
                                    color: _genderColor(member.gender),
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name ?? '',
                                        style: AppTheme.headingSmall.copyWith(fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${member.dOB ?? ''} · ${member.city ?? ''}',
                                        style: AppTheme.labelSmall,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                // Edit button
                                IconButton(
                                  onPressed: () => Get.toNamed(AppRoutes.editClient, arguments: member),
                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 18),
                                ),
                                const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
                              ],
                            ),
                          ),
                        ).animate(delay: Duration(milliseconds: 100 + index * 40))
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.03),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addClient),
        backgroundColor: AppTheme.accent,
        child: const Icon(Icons.person_add, color: Colors.white),
      ).animate(delay: 500.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Color _genderColor(String? gender) {
    return gender == 'Male' ? AppTheme.accent : AppTheme.venusColor;
  }

  void _selectMember(dynamic member) {
    final homeCtrl = Get.find<HomeController>(tag: GetTags.homeTag);
    homeCtrl.setUserInfo(
      name: member.name ?? '',
      gender: member.gender ?? '',
      birthDate: member.dOB ?? '',
      birthTime: member.birthTime ?? '',
      memberId: member.mID ?? '',
    );
    Get.back();
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Client', style: AppTheme.headingSmall),
        content: Text('Delete "$name"? This cannot be undone.', style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
