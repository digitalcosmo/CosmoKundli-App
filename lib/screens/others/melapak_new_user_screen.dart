import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/other_controller.dart';
import 'package:cosmo_kundli/network/network_api_services.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/urls.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/glass_text_field.dart';
import 'package:cosmo_kundli/widgets/glass_button.dart';
import 'package:cosmo_kundli/widgets/glass_dropdown.dart';

class MelapakNewUserScreen extends StatefulWidget {
  const MelapakNewUserScreen({super.key});

  @override
  State<MelapakNewUserScreen> createState() => _MelapakNewUserScreenState();
}

class _MelapakNewUserScreenState extends State<MelapakNewUserScreen> {
  final controller = Get.find<OtherController>(tag: GetTags.otherTag);
  final RxList<dynamic> placesSuggestions = <dynamic>[].obs;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    controller.clearData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _searchPlaces(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () async {
      if (query.isEmpty) {
        placesSuggestions.clear();
        return;
      }
      try {
        final response = await NetworkApiServices.getApi(
          '${Urls.googlePlaceAutoComplete}?input=$query&key=${Urls.googleApiKey}',
        );
        if (response != null && response['predictions'] != null) {
          placesSuggestions.value = response['predictions'];
        }
      } catch (_) {}
    });
  }

  Future<void> _selectPlace(dynamic place) async {
    controller.birthPlaceController.text = place['description'] ?? '';
    placesSuggestions.clear();
    try {
      final response = await NetworkApiServices.getApi(
        '${Urls.googlePlaceDetails}?place_id=${place['place_id']}&key=${Urls.googleApiKey}',
      );
      if (response != null && response['result'] != null) {
        final location = response['result']['geometry']['location'];
        controller.latitudeController.text = location['lat'].toString();
        controller.longitudeController.text = location['lng'].toString();
        final utcOffset = response['result']['utc_offset'];
        if (utcOffset != null) {
          final hours = utcOffset ~/ 60;
          final mins = (utcOffset % 60).abs();
          controller.timmDiffController.text = '$hours:${mins.toString().padLeft(2, '0')}';
        }
      }
    } catch (_) {}
  }

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
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                    ),
                    Expanded(child: Text('New User Matching', style: AppTheme.headingLarge)),
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
                        controller: controller.oppNameController,
                        label: 'Name',
                        hint: 'Enter full name',
                        prefix: const Icon(Icons.person_outline, color: AppTheme.textMuted, size: 20),
                      ),
                      SizedBox(height: 1.5.h),

                      // Gender
                      GlassDropdown<String>(
                        hint: 'Gender',
                        items: const ['Male', 'Female']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        selectedValue: controller.genderController.text.isEmpty ? null : controller.genderController.text,
                        onChanged: (val) => controller.genderController.text = val ?? '',
                      ),
                      SizedBox(height: 1.5.h),

                      // Date of Birth
                      GestureDetector(
                        onPressed: () => _pickDate(context),
                        child: AbsorbPointer(
                          child: GlassTextField(
                            controller: controller.dobController,
                            label: 'Date of Birth',
                            hint: 'Select date',
                            prefix: const Icon(Icons.calendar_today_outlined, color: AppTheme.textMuted, size: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.5.h),

                      // Birth Time (hrs / min / sec)
                      Text('Birth Time', style: AppTheme.labelSmall),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Expanded(
                            child: GlassTextField(
                              controller: controller.btimeHrsController,
                              hint: 'HH',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(':', style: AppTheme.headingMedium),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: GlassTextField(
                              controller: controller.btimeMinController,
                              hint: 'MM',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(':', style: AppTheme.headingMedium),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: GlassTextField(
                              controller: controller.btimeSecController,
                              hint: 'SS',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.5.h),

                      // Birth Place with Google Places
                      Obx(() => Column(
                        children: [
                          GlassTextField(
                            controller: controller.birthPlaceController,
                            label: 'Birth Place',
                            hint: 'Search birth place',
                            prefix: const Icon(Icons.location_on_outlined, color: AppTheme.textMuted, size: 20),
                            onChanged: (val) => _searchPlaces(val),
                          ),
                          if (placesSuggestions.isNotEmpty)
                            GlassCard(
                              margin: EdgeInsets.only(top: 0.5.h),
                              padding: EdgeInsets.zero,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: placesSuggestions.map((place) {
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      place['description'] ?? '',
                                      style: AppTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: const Icon(Icons.place, color: AppTheme.textMuted, size: 18),
                                    onPressed: () => _selectPlace(place),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      )),
                      SizedBox(height: 1.5.h),

                      // Latitude
                      GlassTextField(
                        controller: controller.latitudeController,
                        label: 'Latitude',
                        hint: 'Latitude',
                        prefix: const Icon(Icons.explore_outlined, color: AppTheme.textMuted, size: 20),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 1.5.h),

                      // Longitude
                      GlassTextField(
                        controller: controller.longitudeController,
                        label: 'Longitude',
                        hint: 'Longitude',
                        prefix: const Icon(Icons.explore_outlined, color: AppTheme.textMuted, size: 20),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 1.5.h),

                      // Timezone diff
                      GlassTextField(
                        controller: controller.timmDiffController,
                        label: 'Timezone Difference',
                        hint: 'e.g. +5:30',
                        prefix: const Icon(Icons.timer_outlined, color: AppTheme.textMuted, size: 20),
                      ),
                      SizedBox(height: 3.h),

                      // Submit
                      Obx(() => GlassButton(
                        text: 'Match Kundali',
                        icon: Icons.compare_arrows,
                        isLoading: controller.isLoading.value,
                        onPressed: () => controller.addNewMember(context),
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
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
