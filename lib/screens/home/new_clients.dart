import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/controllers/clientdetail_controller.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';

import '../../custom_widgets/main_button.dart';
import '../../custom_widgets/main_dropdown.dart';
import '../../custom_widgets/main_text_filed.dart';
import '../../services/services.dart';
import '../../values/app_constants.dart';
import '../../values/app_messages.dart';
import '../../values/get_tags.dart';
import '../../values/routes.dart';

class NewClients extends StatelessWidget {
  NewClients({super.key});

  final ClientDetailController clientdetailController =
      Get.find(tag: GetTags.clientDetailTag);

  final GlobalKey<FormState> _clientDetailFormKeyTab = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Form(
        key: _clientDetailFormKeyTab,
        child: Material(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //  Text(
                            //    "first_name".tr,
                            //   style: TextStyle(color: CkColors.text),
                            // ),
                            // SizedBox(
                            //   height: 1.h,
                            // ),
                            MainTextField(
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                    AppMessages.nameRequiredValidation),
                              ]),
                              hintText: "enter_first_name".tr,
                              textEditingController:
                                  clientdetailController.firstNameController,
                            ),
                          ]),
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //  Text(
                          //    "middle_name".tr,
                          //   style: TextStyle(color: CkColors.text),
                          // ),
                          // SizedBox(
                          //   height: 1.h,
                          // ),
                          MainTextField(
                            validator: Validatorless.multiple([
                              Validatorless.required(
                                  AppMessages.nameRequiredValidation),
                            ]),
                            hintText: "enter_middle_name".tr,
                            textEditingController:
                                clientdetailController.middleNameController,
                          ),
                        ],
                      ),
                    )
                  ]),
                  SizedBox(
                    height: 2.h,
                  ),
                  //  Text(
                  //    "last_name".tr,
                  //   style: const TextStyle(color: CkColors.text),
                  // ),
                  // SizedBox(
                  //   height: 1.h,
                  // ),
                  MainTextField(
                    validator: Validatorless.multiple([
                      Validatorless.required(
                          AppMessages.nameRequiredValidation),
                    ]),
                    hintText: "enter_last_name".tr,
                    textEditingController:
                        clientdetailController.lastNameController,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  //  Text(
                  //    "mobile_number".tr,
                  //   style: TextStyle(color: CkColors.text),
                  // ),
                  SizedBox(
                    height: 1.h,
                  ),
                  MainTextField(
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: Validatorless.multiple([
                      Validatorless.required(
                          AppMessages.nameRequiredValidation),
                      Validatorless.number(AppMessages.numberLengthValidation),
                    ]),
                    hintText: "enter_mobile_number".tr,
                    textEditingController:
                        clientdetailController.mobileNumberController,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),

                  Row(
                    children: [
                      Expanded(
                          child: Obx(
                        () => GestureDetector(
                          onTap: () async {
                            clientdetailController.selectedDate.value =
                                (await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                            ))!;
                            clientdetailController.updateStartDate(
                                clientdetailController.selectedDate.value
                                    .toString());
                            clientdetailController.dobController.text =
                                Services.formatDate(
                                    date: clientdetailController
                                        .selectedDate.value);
                          },
                          child: MainTextField(
                            validator: Validatorless.multiple([
                              Validatorless.required(
                                  AppMessages.dateRequiredValidation),
                            ]),
                            hintText: Services.formatDate(
                                date:
                                    clientdetailController.selectedDate.value),
                            isEnabled: false,
                            textEditingController:
                                clientdetailController.dobController,
                            suffix: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () async {},
                            ),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: 2.w,
                      ),
                      Expanded(
                        child: Obx(
                          () => MainDropDown(
                            value:
                                clientdetailController.selectedGender.value ??
                                    'male',
                            dropdownItems: AppConstants.genderList,
                            onChanged: (p0) {
                              clientdetailController.selectedGender.value = p0;
                              clientdetailController.genderController.text =
                                  clientdetailController.selectedGender.value;
                            },
                            hintText: "gender".tr,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await clientdetailController.selectTime(context);
                          },
                          child: MainTextField(
                            validator: Validatorless.multiple([
                              Validatorless.required(
                                  AppMessages.birthTimeRequiredValidation)
                            ]),
                            hintText: "birth_time_hour".tr,
                            isEnabled: false,
                            textEditingController:
                                clientdetailController.birthTimeHourController,
                            suffix: IconButton(
                              icon: const Icon(Icons.access_time_rounded),
                              onPressed: () async {},
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2.w,
                      ),
                      Expanded(
                          child: MainTextField(
                              onSubmitted: (p0) async {
                                List<Location> locations =
                                    await locationFromAddress(
                                        clientdetailController
                                            .birthPlaceController.text);
                                clientdetailController.latController.text =
                                    locations[0].latitude.toString();
                                clientdetailController.longController.text =
                                    locations[0].longitude.toString();
                              },
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                    AppMessages.birthPlaceRequiredValidation)
                              ]),
                              hintText: "birth_place".tr,
                              textEditingController:
                                  clientdetailController.birthPlaceController)),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: IgnorePointer(
                        child: MainTextField(
                          validator: Validatorless.multiple([
                            Validatorless.required(
                                AppMessages.birthTimeRequiredValidation)
                          ]),
                          hintText: "birth_time_minute".tr,
                          textEditingController:
                              clientdetailController.birthTimeMinController,
                        ),
                      )),
                      SizedBox(
                        width: 2.w,
                      ),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          clientdetailController.showSecondsDialog(context);
                        },
                        child: MainTextField(
                            suffix: IconButton(
                                onPressed: () {},
                                icon:
                                    const Icon(Icons.arrow_drop_down_outlined)),
                            validator: Validatorless.multiple(
                              [
                                Validatorless.required(
                                    AppMessages.birthPlaceRequiredValidation)
                              ],
                            ),
                            isEnabled: false,
                            hintText: "birth_time_second".tr,
                            textEditingController:
                                clientdetailController.birthTimeSecController),
                      )),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //      Text( "latitude".tr),
                  //     SizedBox(width: 30.w),
                  //      Text("longitude".tr),
                  //   ],
                  // ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: MainTextField(
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                    AppMessages.latPlaceRequiredValidation)
                              ]),
                              hintText: "latitude".tr,
                              textEditingController:
                                  clientdetailController.latController)),
                      SizedBox(
                        width: 2.w,
                      ),
                      Expanded(
                          child: MainTextField(
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                    AppMessages.longRequiredValidation)
                              ]),
                              hintText: "longitude".tr,
                              textEditingController:
                                  clientdetailController.longController)),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),

                  MainTextField(
                      validator: Validatorless.multiple([
                        Validatorless.required(
                            AppMessages.timeDiffRequiredValidation)
                      ]),
                      hintText: "time_diff".tr,
                      keyboardType: TextInputType.number,
                      textEditingController:
                          clientdetailController.timmDiffController),
                  SizedBox(
                    height: 3.h,
                  ),
                  Center(
                    child: MainButton(
                      text: "save_details".tr,
                      onTap: () async {
                        // Services.to(AppRoutes.clientListView);

                        bool isValidated = await Services.validateForm(
                            _clientDetailFormKeyTab);
                        if (isValidated) {
                          clientdetailController.addMember(context: context);
                          Services.back();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Center(
                    child: MainButton(
                      text: "save_open_kundli".tr,
                      onTap: () async {
                        bool isValidated = await Services.validateForm(
                            _clientDetailFormKeyTab);
                        if (isValidated) {
                          clientdetailController.addMember(context: context);
                          Services.to(AppRoutes.containView);

                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => ContainView(
                          //         index: 1.obs,
                          //       ),
                          //     ));
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
