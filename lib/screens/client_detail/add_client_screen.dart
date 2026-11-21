import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/client_detail_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_dropdown.dart';

class AddClientScreen extends StatelessWidget {
  AddClientScreen({super.key});

  final controller = Get.find<ClientDetailController>(tag: GetTags.clientDetailTag);
  final bool isEdit = Get.arguments != null;

  @override
  Widget build(BuildContext context) {
    if (isEdit) {
      controller.populateForEdit(Get.arguments);
    } else {
      controller.clearForm();
    }

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
                      child: Text(
                        isEdit ? 'Edit Client' : 'Add New Client',
                        style: AppTheme.headingLarge,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 1.h),

                      // Name
                      GlassTextField(
                        controller: controller.nameController,
                        hint: 'Full Name',
                        prefixIcon: Icons.person_outline,
                      ),
                      SizedBox(height: 1.5.h),

                      // Gender
                      GlassDropdown<String>(
                        hint: 'Gender',
                        items: const ['Male', 'Female'],
                        value: controller.selectedGender.value.isEmpty ? null : controller.selectedGender.value,
                        onChanged: (val) => controller.selectedGender.value = val ?? '',
                        itemLabel: (item) => item,
                      ),
                      SizedBox(height: 1.5.h),

                      // Date of Birth
                      GestureDetector(
                        onTap: () => _pickDate(context),
                        child: AbsorbPointer(
                          child: GlassTextField(
                            controller: controller.dobController,
                            hint: 'Date of Birth',
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.5.h),

                      // Birth Time
                      GestureDetector(
                        onTap: () => _pickTime(context),
                        child: AbsorbPointer(
                          child: GlassTextField(
                            controller: controller.birthTimeController,
                            hint: 'Birth Time',
                            prefixIcon: Icons.access_time_outlined,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.5.h),

                      // Birth Place (with Google Places autocomplete)
                      Obx(() => Column(
                        children: [
                          GlassTextField(
                            controller: controller.birthPlaceController,
                            hint: 'Birth Place',
                            prefixIcon: Icons.location_on_outlined,
                            onChanged: (val) => controller.searchPlaces(val),
                          ),
                          if (controller.placesSuggestions.isNotEmpty)
                            GlassCard(
                              margin: EdgeInsets.only(top: 0.5.h),
                              padding: EdgeInsets.zero,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: controller.placesSuggestions.map((place) {
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      place.description ?? '',
                                      style: AppTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: const Icon(Icons.place, color: AppTheme.textMuted, size: 18),
                                    onTap: () => controller.selectPlace(place),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      )),
                      SizedBox(height: 1.5.h),

                      // Latitude
                      GlassTextField(
                        controller: controller.latController,
                        hint: 'Latitude',
                        prefixIcon: Icons.explore_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 1.5.h),

                      // Longitude
                      GlassTextField(
                        controller: controller.longController,
                        hint: 'Longitude',
                        prefixIcon: Icons.explore_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 1.5.h),

                      // Timezone
                      GlassTextField(
                        controller: controller.timezoneController,
                        hint: 'Timezone (e.g. +5.5)',
                        prefixIcon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 3.h),

                      // Submit Button
                      Obx(() => GlassButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () {
                                if (isEdit) {
                                  controller.updateMember(context);
                                } else {
                                  controller.addMember(context);
                                }
                              },
                        isLoading: controller.isSaving.value,
                        label: isEdit ? 'Update Client' : 'Add Client',
                        icon: isEdit ? Icons.check : Icons.person_add,
                      )),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.bgSecondary,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      controller.dobController.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.bgSecondary,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) {
      controller.birthTimeController.text =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
