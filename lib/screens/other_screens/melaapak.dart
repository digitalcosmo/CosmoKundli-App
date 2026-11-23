import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/other_controller.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_places_autocomplete_widgets/api/autocomplete_types.dart';
import 'package:google_maps_places_autocomplete_widgets/widgets/address_autocomplete_textformfield.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';

import '../../custom_widgets/main_button.dart';
import '../../custom_widgets/main_dropdown.dart';
import '../../custom_widgets/main_text_filed.dart';
import '../../values/app_constants.dart';
import '../../values/app_messages.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class Melaapak extends StatefulWidget {
  Melaapak({super.key});

  @override
  State<Melaapak> createState() => _MelaapakState();
}

class _MelaapakState extends State<Melaapak> {
  final OtherController otherController = Get.find(tag: GetTags.otherTag);

  @override
  void dispose() {
    super.dispose();
    otherController.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "melaapak".tr,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: AppColors.smallText),
                ),
                Text(
                  ' - ${"partner_details".tr}',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      color: CkColors.text.withOpacity(0.50)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Services.to(AppRoutes.existingUserView),
                  behavior: HitTestBehavior.translucent,
                  child: SizedBox(
                    height: 4.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "existing_user".tr,
                          style: const TextStyle(
                              color: AppColors.smallText,
                              fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Services.to(AppRoutes.existingUserView);
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2.h,
            ),
            SizedBox(
              height: 2.h,
            ),
            Form(
              key: otherController.melapakFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainTextField(
                    validator: Validatorless.multiple([
                      Validatorless.required(
                          AppMessages.nameRequiredValidation),
                    ]),
                    hintText: "enter_first_name".tr,
                    textEditingController: otherController.oppName,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Obx(
                        () => MainTextField(
                          validator: Validatorless.multiple([
                            Validatorless.required(
                                AppMessages.dateRequiredValidation),
                          ]),
                          hintText: Services.formatDate(
                              date: otherController.selectedDate.value),
                          textEditingController: otherController.dob,
                          suffix: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () async {
                              otherController.selectedDate.value =
                                  (await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2040),
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                              ))!;
                              otherController.updateStartDate(otherController
                                  .selectedDate.value
                                  .toString());
                              otherController.dob.text = Services.formatDate(
                                  date: otherController.selectedDate.value);
                            },
                          ),
                        ),
                      )),
                      SizedBox(
                        width: 2.w,
                      ),
                      Expanded(
                        child: MainDropDown(
                          dropdownItems: AppConstants.genderList,
                          onChanged: (p0) {
                            otherController.selectedGender.value = p0;
                          },
                          hintText: "gender".tr,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: MainTextField(
                        validator: Validatorless.multiple([
                          Validatorless.required(
                              AppMessages.birthTimeRequiredValidation)
                        ]),
                        hintText: "birth_time_hour".tr,
                        textEditingController: otherController.btime_hrs,
                        suffix: IconButton(
                          icon: const Icon(Icons.access_time_rounded),
                          onPressed: () async {
                            await otherController.selectTime(context);
                          },
                        ),
                      )),
                      SizedBox(
                        width: 2.w,
                      ),
                      Expanded(
                          child: IgnorePointer(
                        child: MainTextField(
                          validator: Validatorless.multiple([
                            Validatorless.required(
                                AppMessages.birthTimeRequiredValidation)
                          ]),
                          hintText: "birth_time_minute".tr,
                          textEditingController: otherController.btime_min,
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: MainTextField(
                              suffix: IconButton(
                                  onPressed: () {
                                    otherController.showSecondsDialog(context);
                                  },
                                  icon: const Icon(
                                      Icons.arrow_drop_down_outlined)),
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                    AppMessages.birthPlaceRequiredValidation)
                              ]),
                              hintText: "birth_time_second".tr,
                              textEditingController:
                                  otherController.btime_sec)),
                      SizedBox(
                        width: 2.w,
                      ),
                      // Expanded(
                      //     child: MainTextField(
                      //         onSubmitted: (p0) async {
                      //           List<Location> locations =
                      //               await locationFromAddress(
                      //                   otherController.birth_place.text);
                      //           otherController.latitude.text =
                      //               locations[0].latitude.toString();
                      //           otherController.longitude.text =
                      //               locations[0].longitude.toString();
                      //         },
                      //         validator: Validatorless.multiple([
                      //           Validatorless.required(
                      //               AppMessages.birthPlaceRequiredValidation)
                      //         ]),
                      //         hintText: "search_birth_place".tr,
                      //         textEditingController:
                      //             otherController.birth_place)),

                      Expanded(
                        child: AddressAutocompleteTextFormField(
                          mapsApiKey: AppConstants.googleMapApiKey,
                          controller: otherController.birth_place,
                          onSuggestionClick: (val) {
                            otherController.latitude.text = val.lat.toString();
                            otherController.longitude.text = val.lng.toString();
                            otherController.timm_diff.text =
                                val.utcOffset.toString();
                          },
                          validator: (val) {
                            if (val!.isEmpty) {
                              return AppMessages.birthPlaceRequiredValidation;
                            }
                            return null;
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
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MainTextField(
                            readOnly: true,
                            validator: Validatorless.multiple([
                              Validatorless.required(
                                  AppMessages.latPlaceRequiredValidation)
                            ]),
                            hintText: "latitude".tr,
                            textEditingController: otherController.latitude),
                      ),
                      SizedBox(
                        width: 2.w,
                      ),
                      Expanded(
                        child: MainTextField(
                            readOnly: true,
                            validator: Validatorless.multiple(
                              [
                                Validatorless.required(
                                    AppMessages.longRequiredValidation)
                              ],
                            ),
                            hintText: "longitude".tr,
                            textEditingController: otherController.longitude),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  MainTextField(
                      readOnly: true,
                      validator: Validatorless.multiple([
                        Validatorless.required(
                            AppMessages.timeDiffRequiredValidation)
                      ]),
                      hintText: "time_diff".tr,
                      textEditingController: otherController.timm_diff),
                  SizedBox(
                    height: 3.h,
                  ),
                  Center(
                    child: MainButton(
                      text: 'submit'.tr,
                      onTap: () async {
                        bool isValidated = await Services.validateForm(
                            otherController.melapakFormKey);
                        if (isValidated) {
                          otherController.isNewUser.value = true;

                          Services.to(AppRoutes.ashtkootMelapakView);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
