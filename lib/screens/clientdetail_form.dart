import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'package:cosmo_kundali/controllers/clientdetail_controller.dart';
import 'package:cosmo_kundali/custom_widgets/main_button.dart';
import 'package:cosmo_kundali/custom_widgets/main_dropdown.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';

import '../custom_widgets/main_text_filed.dart';
import '../values/app_messages.dart';
import '../values/colors.dart';
import '../values/get_tags.dart';
import '../values/tr_strings.dart';

class ClientDetailForm extends StatefulWidget {
  const ClientDetailForm({super.key});

  @override
  State<ClientDetailForm> createState() => _ClientDetailFormState();
}

final ClientDetailController _clientDetailController =
    Get.put(ClientDetailController(), tag: GetTags.clientDetailTag);

class _ClientDetailFormState extends State<ClientDetailForm> {
  @override
  void dispose() {
    _clientDetailController.debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      appBar: AppBar(
        title: Text(
          TrStrings.clientDetails,
          style: TextStyle(
            color: AppColors.fontHeaderColor,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Services.to(AppRoutes.clientListView),
            child: Row(
              children: [
                Text(
                  'existing_clients'.tr,
                  style: TextStyle(
                    color: AppColors.fontHeaderColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                IconButton(
                  onPressed: () => Services.to(AppRoutes.clientListView),
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15.sp,
                    color: AppColors.fontHeaderColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.sp),
          child: Form(
            key: _clientDetailController.clientDetailFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MainTextField(
                        validator: Validatorless.required(
                            AppMessages.firstNameRequiredValidation),
                        hintText: "enter_first_name".tr,
                        textEditingController:
                            _clientDetailController.firstNameController,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: MainTextField(
                        hintText: "enter_middle_name".tr,
                        textEditingController:
                            _clientDetailController.middleNameController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                MainTextField(
                  validator: Validatorless.required(
                      AppMessages.lastNameRequiredValidation),
                  hintText: "enter_last_name".tr,
                  textEditingController:
                      _clientDetailController.lastNameController,
                ),
                SizedBox(height: 2.h),
                MainTextField(
                  keyboardType: TextInputType.phone,
                  validator: Validatorless.multiple([
                    Validatorless.required(AppMessages.numberValidation),
                    Validatorless.number(AppMessages.numberLengthValidation),
                  ]),
                  hintText: "enter_mobile_number".tr,
                  maxLength: 10,
                  textEditingController:
                      _clientDetailController.mobileNumberController,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => MainTextField(
                          readOnly: true,
                          validator: Validatorless.required(
                              AppMessages.dateRequiredValidation),
                          hintText: Services.formatDate(
                              date: _clientDetailController.selectedDate.value),
                          textEditingController:
                              _clientDetailController.dobController,
                          onTap: () async {
                            selectBirthDate();
                          },
                          suffix: IconButton(
                              onPressed: () {
                                selectBirthDate();
                              },
                              icon: Icon(Icons.calendar_month,
                                  color: CkColors.textMuted)),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: MainDropDown(
                        value: _clientDetailController.selectedGender.value,
                        dropdownItems: AppConstants.genderList,
                        onChanged: (p0) {
                          _clientDetailController.selectedGender.value = p0;
                          _clientDetailController.genderController.text = p0;
                        },
                        hintText: "gender".tr,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _clientDetailController.selectTime(context),
                        child: IgnorePointer(
                          child: MainTextField(
                            hintText: "birth_time_hour".tr,
                            textEditingController:
                                _clientDetailController.birthTimeHourController,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: IgnorePointer(
                        child: MainTextField(
                          hintText: "birth_time_minute".tr,
                          textEditingController:
                              _clientDetailController.birthTimeMinController,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _clientDetailController.showSecondsDialog(context),
                        child: IgnorePointer(
                          child: MainTextField(
                            isEnabled: true,
                            suffix: IconButton(
                                onPressed: () {},
                                icon:
                                    const Icon(Icons.arrow_drop_down_outlined)),
                            hintText: "birth_time_second".tr,
                            textEditingController:
                                _clientDetailController.birthTimeSecController,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: AddressAutocompleteTextFormField(
                        mapsApiKey: AppConstants.googleMapApiKey,
                        controller:
                            _clientDetailController.birthPlaceController,
                        onSuggestionClick: (val) {
                          _clientDetailController.latController.text =
                              val.lat.toString();
                          _clientDetailController.longController.text =
                              val.lng.toString();

                          _clientDetailController.birthPlaceController.text =
                              val.city.toString();
                          _clientDetailController.timmDiffController.text =
                              val.utcOffset.toString();
                        },
                        types: [
                          AutoCompleteType.cities,
                        ],
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.headerColor.withOpacity(0.26),
                            ),
                            borderRadius: BorderRadius.circular(14.sp),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.sp),
                          ),
                          counterText: '',
                          hintText: 'Birth Place',
                        ),
                        clearButton: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: MainTextField(
                        validator: Validatorless.required(
                            AppMessages.latPlaceRequiredValidation),
                        hintText: "latitude".tr,
                        readOnly: true,
                        textEditingController:
                            _clientDetailController.latController,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: MainTextField(
                        validator: Validatorless.required(
                            AppMessages.longRequiredValidation),
                        hintText: "longitude".tr,
                        readOnly: true,
                        textEditingController:
                            _clientDetailController.longController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                MainTextField(
                  validator: Validatorless.required(
                      AppMessages.timeDiffRequiredValidation),
                  hintText: "time_diff".tr,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  textEditingController:
                      _clientDetailController.timmDiffController,
                ),
                SizedBox(height: 3.h),
                Center(
                  child: MainButton(
                    text: "save_details".tr,
                    onTap: () {
                      bool isValidated =
                          _clientDetailController.validateFields();
                      if (isValidated) {
                        _clientDetailController.addMember(context: context);
                      } else {
                        Services.snackBarError(
                            context, "All fields are mandatory");
                      }
                    },
                  ),
                ),
                SizedBox(height: 1.h),
                Center(
                  child: MainButton(
                    text: "save_open_kundli".tr,
                    onTap: () async {
                      bool isValidated = await Services.validateForm(
                          _clientDetailController.clientDetailFormKey);
                      if (isValidated) {
                        _clientDetailController.addMember(
                            context: context, isOpenKundali: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int getUTCOffset(double longitude) {
    // Standard calculation (Longitude / 15) * 60
    int offsetMinutes = (longitude / 15 * 60).round();

    // List of known non-standard UTC offsets
    List<int> validOffsets = [
      -720,
      -660,
      -600,
      -570,
      -540,
      -480,
      -420,
      -360,
      -300,
      -270,
      -240,
      -210,
      -180,
      -150,
      -120,
      -60,
      0,
      60,
      120,
      180,
      210,
      240,
      270,
      300,
      330,
      345,
      360,
      390,
      420,
      450,
      480,
      510,
      525,
      540,
      570,
      600,
      630,
      660,
      720
    ];

    // Find the closest valid offset
    int closestOffset = validOffsets.reduce((a, b) =>
        (offsetMinutes - a).abs() < (offsetMinutes - b).abs() ? a : b);

    return closestOffset;
  }

  Future<void> selectBirthDate() async {
    _clientDetailController.selectedDate.value = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2040),
      helpText: "Select Birthdate",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    ))!;
    _clientDetailController
        .updateStartDate(_clientDetailController.selectedDate.value.toString());
    _clientDetailController.dobController.text =
        Services.formatDate(date: _clientDetailController.selectedDate.value);
  }
}
