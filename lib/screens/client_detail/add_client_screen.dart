import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/client_detail_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';

class AddClientScreen extends StatelessWidget {
  const AddClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientDetailController ctrl = Get.find(tag: GetTags.clientDetailTag);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.bgPrimary, AppTheme.bgSecondary]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Add Client'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Form(
                    key: ctrl.clientDetailFormKey,
                    child: Column(
                      children: [
                        GlassCard(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Personal Details', style: AppTheme.headingSmall),
                              SizedBox(height: 2.h),
                              GlassTextField(controller: ctrl.firstNameController, label: 'First Name'),
                              SizedBox(height: 1.5.h),
                              GlassTextField(controller: ctrl.middleNameController, label: 'Middle Name'),
                              SizedBox(height: 1.5.h),
                              GlassTextField(controller: ctrl.lastNameController, label: 'Last Name'),
                              SizedBox(height: 1.5.h),
                              GlassTextField(controller: ctrl.mobileNumberController, label: 'Mobile', keyboardType: TextInputType.phone),
                              SizedBox(height: 1.5.h),
                              // Gender dropdown
                              Obx(() => Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: AppTheme.glassControl(),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: ctrl.selectedGender.value == 'Gender' ? null : ctrl.selectedGender.value,
                                    hint: Text('Gender', style: AppTheme.bodyMedium.copyWith(color: Colors.white38)),
                                    dropdownColor: AppTheme.bgSecondary,
                                    isExpanded: true,
                                    style: AppTheme.bodyMedium,
                                    items: AppConstants.genderList.map((g) {
                                      return DropdownMenuItem(value: g, child: Text(g));
                                    }).toList(),
                                    onChanged: (val) => ctrl.selectedGender.value = val!,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms),

                        SizedBox(height: 2.h),

                        GlassCard(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Birth Details', style: AppTheme.headingSmall),
                              SizedBox(height: 2.h),
                              // Date picker
                              GestureDetector(
                                onTap: () => ctrl.selectDate(context),
                                child: AbsorbPointer(
                                  child: Obx(() => GlassTextField(
                                    controller: ctrl.dobController,
                                    label: ctrl.selectedBday.value,
                                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.white38),
                                  )),
                                ),
                              ),
                              SizedBox(height: 1.5.h),
                              // Time
                              Row(
                                children: [
                                  Expanded(child: GlassTextField(controller: ctrl.birthTimeHourController, label: 'HH', keyboardType: TextInputType.number)),
                                  SizedBox(width: 2.w),
                                  Expanded(child: GlassTextField(controller: ctrl.birthTimeMinController, label: 'MM', keyboardType: TextInputType.number)),
                                  SizedBox(width: 2.w),
                                  Expanded(child: GlassTextField(controller: ctrl.birthTimeSecController, label: 'SS', keyboardType: TextInputType.number)),
                                  SizedBox(width: 2.w),
                                  IconButton(
                                    icon: const Icon(Icons.access_time, color: AppTheme.accent),
                                    onPressed: () => ctrl.selectTime(context),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              // Birth place with autocomplete
                              GlassTextField(
                                controller: ctrl.birthPlaceController,
                                label: 'Birth Place',
                                onChanged: (val) => ctrl.debounceSearch(val),
                              ),
                              Obx(() {
                                if (ctrl.googlePlaceList.isEmpty) return const SizedBox();
                                return Container(
                                  constraints: BoxConstraints(maxHeight: 20.h),
                                  margin: EdgeInsets.only(top: 0.5.h),
                                  decoration: AppTheme.glassCard(),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: ctrl.googlePlaceList.length,
                                    itemBuilder: (_, i) {
                                      final place = ctrl.googlePlaceList[i];
                                      return ListTile(
                                        dense: true,
                                        title: Text(place['description'] ?? '', style: AppTheme.bodySmall),
                                        onTap: () => ctrl.selectPlace(place),
                                      );
                                    },
                                  ),
                                );
                              }),
                              SizedBox(height: 1.5.h),
                              Row(
                                children: [
                                  Expanded(child: GlassTextField(controller: ctrl.latController, label: 'Latitude', keyboardType: TextInputType.number)),
                                  SizedBox(width: 2.w),
                                  Expanded(child: GlassTextField(controller: ctrl.longController, label: 'Longitude', keyboardType: TextInputType.number)),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              GlassTextField(controller: ctrl.timmDiffController, label: 'Time Diff'),
                            ],
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

                        SizedBox(height: 3.h),
                        Obx(() => GlassButton(
                          label: 'Add Member',
                          onTap: () => ctrl.addMember(),
                          isLoading: ctrl.isLoading.value,
                        )).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
