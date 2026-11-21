import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';
import 'package:cosmo_kundli/controllers/other_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/glass_dropdown.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/services/services.dart';

class MelapakNewUserScreen extends StatelessWidget {
  MelapakNewUserScreen({super.key});

  final controller = Get.find<OtherController>(tag: GetTags.otherTag);

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
              const CustomAppBar(title: 'Match with New Person'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: GlassCard(
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter Details', style: AppTheme.headingMedium),
                        SizedBox(height: 2.h),
                        // Name
                        GlassTextField(
                          controller: controller.melapakNameController,
                          hint: 'Full Name',
                          prefixIcon: Icons.person_outline,
                        ),
                        SizedBox(height: 2.h),
                        // Gender
                        Obx(() => GlassDropdown(
                              hint: 'Select Gender',
                              value: controller.melapakGender.value.isEmpty
                                  ? null
                                  : controller.melapakGender.value,
                              items: AppConstants.genderList,
                              onChanged: (val) => controller.melapakGender.value = val ?? '',
                              prefixIcon: Icons.wc_outlined,
                            )),
                        SizedBox(height: 2.h),
                        // Date of Birth
                        Obx(() => GlassTextField(
                              hint: 'Date of Birth',
                              prefixIcon: Icons.calendar_today_outlined,
                              readOnly: true,
                              controller: TextEditingController(
                                text: controller.melapakDob.value,
                              ),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: AppTheme.accent,
                                          surface: AppTheme.bgPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  controller.melapakDob.value =
                                      DateFormat('dd/MM/yyyy').format(date);
                                }
                              },
                            )),
                        SizedBox(height: 2.h),
                        // Birth Time
                        Obx(() => GlassTextField(
                              hint: 'Birth Time',
                              prefixIcon: Icons.access_time_outlined,
                              readOnly: true,
                              controller: TextEditingController(
                                text: controller.melapakBirthTime.value,
                              ),
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: AppTheme.accent,
                                          surface: AppTheme.bgPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (time != null) {
                                  controller.melapakBirthTime.value =
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                }
                              },
                            )),
                        SizedBox(height: 2.h),
                        // Birth Place with autocomplete
                        GlassTextField(
                          controller: controller.melapakPlaceController,
                          hint: 'Birth Place',
                          prefixIcon: Icons.location_on_outlined,
                          onChanged: (val) => controller.searchPlaces(val),
                        ),
                        // Place suggestions
                        Obx(() {
                          final suggestions = controller.placeSuggestions;
                          if (suggestions.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: EdgeInsets.only(top: 0.5.h),
                            constraints: BoxConstraints(maxHeight: 20.h),
                            decoration: AppTheme.glassDecoration,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: suggestions.length,
                              itemBuilder: (context, index) {
                                final place = suggestions[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    place['description']?.toString() ?? '',
                                    style: AppTheme.bodySmall,
                                  ),
                                  onTap: () => controller.selectPlace(place),
                                );
                              },
                            ),
                          );
                        }),
                        SizedBox(height: 3.h),
                        // Match button
                        Obx(() => GlassButton(
                              text: controller.isMelapakLoading.value
                                  ? 'Matching...'
                                  : 'Match Kundali',
                              icon: Icons.favorite_outline,
                              isLoading: controller.isMelapakLoading.value,
                              onPressed: controller.isMelapakLoading.value
                                  ? null
                                  : () => controller.matchWithNewUser(context),
                            )),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
