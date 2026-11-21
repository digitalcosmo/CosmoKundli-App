import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/other_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';

class MelapakNewUserScreen extends StatelessWidget {
  const MelapakNewUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OtherController ctrl = Get.find(tag: GetTags.otherTag);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.bgPrimary, AppTheme.bgSecondary]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'New User for Matching'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: GlassCard(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter Details', style: AppTheme.headingSmall),
                        SizedBox(height: 2.h),
                        GlassTextField(controller: ctrl.melapakNameController, label: 'Name'),
                        SizedBox(height: 1.5.h),
                        Obx(() => Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: AppTheme.glassControl(),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: ctrl.melapakGender.value == 'Gender' ? null : ctrl.melapakGender.value,
                              hint: Text('Gender', style: AppTheme.bodyMedium.copyWith(color: Colors.white38)),
                              dropdownColor: AppTheme.bgSecondary,
                              isExpanded: true,
                              style: AppTheme.bodyMedium,
                              items: AppConstants.genderList.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (val) => ctrl.melapakGender.value = val!,
                            ),
                          ),
                        )),
                        SizedBox(height: 1.5.h),
                        GestureDetector(
                          onTap: () => ctrl.selectMelapakDate(context),
                          child: AbsorbPointer(
                            child: GlassTextField(
                              controller: ctrl.melapakDobController,
                              label: 'Date of Birth',
                              suffixIcon: const Icon(Icons.calendar_today, color: Colors.white38),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Expanded(child: GlassTextField(controller: ctrl.melapakHourController, label: 'HH', keyboardType: TextInputType.number)),
                            SizedBox(width: 2.w),
                            Expanded(child: GlassTextField(controller: ctrl.melapakMinController, label: 'MM', keyboardType: TextInputType.number)),
                            SizedBox(width: 2.w),
                            Expanded(child: GlassTextField(controller: ctrl.melapakSecController, label: 'SS', keyboardType: TextInputType.number)),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        GlassTextField(controller: ctrl.melapakPlaceController, label: 'Birth Place'),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Expanded(child: GlassTextField(controller: ctrl.melapakLatController, label: 'Lat', keyboardType: TextInputType.number)),
                            SizedBox(width: 2.w),
                            Expanded(child: GlassTextField(controller: ctrl.melapakLongController, label: 'Long', keyboardType: TextInputType.number)),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Obx(() => GlassButton(
                          label: 'Match',
                          onTap: () => ctrl.getMelapakMatch(),
                          isLoading: ctrl.isLoading.value,
                        )),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
