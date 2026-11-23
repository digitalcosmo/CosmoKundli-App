import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_places_autocomplete_widgets/api/autocomplete_types.dart';
import 'package:google_maps_places_autocomplete_widgets/widgets/address_autocomplete_textformfield.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:validatorless/validatorless.dart';

import '../../controllers/clientdetail_controller.dart';
import '../../custom_widgets/main_button.dart';
import '../../custom_widgets/main_dropdown.dart';
import '../../custom_widgets/main_text_filed.dart';
import '../../services/services.dart';
import '../../values/app_constants.dart';
import '../../values/app_messages.dart';
import '../../values/colors.dart';
import '../../values/get_tags.dart';

class EditClients extends StatefulWidget {
  const EditClients({super.key});

  @override
  State<EditClients> createState() => _EditClientsState();
}



class _EditClientsState extends State<EditClients> {

  final ClientDetailController clientdetailController =
  Get.find(tag: GetTags.clientDetailTag);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1),(){
      clientdetailController.fetchMemberDetails(mId: clientdetailController.mId.toString());

    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    clientdetailController.fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(clientdetailController.mId.value);

    return  CkScaffold(
      body: Form(
        key: clientdetailController.editClientFormKey,
        child: Material(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h,),
                  Text("edit_clients".tr,style: TextStyle(
                    fontSize: 20.sp
                  ),),
                  SizedBox(height: 4.h,),
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
                                  lastDate: DateTime(2050),
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
                                readOnly: true,
                                validator: Validatorless.multiple([
                                  Validatorless.required(
                                      AppMessages.dateRequiredValidation),
                                ]),
                                hintText: Services.formatDate(
                                    date:
                                    clientdetailController.selectedDate.value),
                                isEnabled: true,
                                textEditingController:
                                clientdetailController.dobController,
                                suffix: IconButton(
                                  icon: const Icon(Icons.calendar_month),
                                  onPressed: () async {
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
                            value: clientdetailController.selectedGender.value == ''? 'Gender' : clientdetailController.selectedGender.value,
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
                          onTap: () =>
                              clientdetailController.selectTime(context),
                          child: IgnorePointer(
                            child: MainTextField(
                              hintText: "birth_time_hour".tr,
                              textEditingController:
                              clientdetailController.birthTimeHourController,
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
                            clientdetailController.birthTimeMinController,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              clientdetailController.showSecondsDialog(context),
                          child: IgnorePointer(
                            child: MainTextField(
                              isEnabled: true,
                              suffix: IconButton(
                                  onPressed: () {},
                                  icon:
                                  const Icon(Icons.arrow_drop_down_outlined)),
                              hintText: "birth_time_second".tr,
                              textEditingController:
                              clientdetailController.birthTimeSecController,
                            ),
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
                      // Expanded(
                      //   child: InkWell(
                      //     onTap: () async {
                      //       await clientdetailController.selectTime(context);
                      //     },
                      //     child: InkWell(
                      //       child: IgnorePointer(
                      //         child: MainTextField(
                      //           validator: Validatorless.multiple([
                      //             Validatorless.required(
                      //                 AppMessages.birthTimeRequiredValidation)
                      //           ]),
                      //           hintText: "birth_time_hour".tr,
                      //           textEditingController:
                      //           clientdetailController.birthTimeHourController,
                      //           suffix: IconButton(
                      //             icon: const Icon(Icons.access_time_rounded),
                      //             onPressed: () async {},
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   width: 2.w,
                      // ),
                      Expanded(
                        child: AddressAutocompleteTextFormField(
                          mapsApiKey: AppConstants.googleMapApiKey,
                          controller:
                          clientdetailController.birthPlaceController,
                          onSuggestionClick: (val) {
                            clientdetailController.latController.text =
                                val.lat.toString();
                            clientdetailController.longController.text =
                                val.lng.toString();

                            clientdetailController.birthPlaceController.text =
                                val.city.toString();
                            clientdetailController.timmDiffController.text =
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
                            onTap: (){
                              clientdetailController
                                  .showSecondsDialog(context);
                            },
                            child: InkWell(
                              child: IgnorePointer(
                                
                                child: MainTextField(
                                    suffix: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons.arrow_drop_down_outlined)),
                                    validator: Validatorless.multiple(
                                      [
                                        Validatorless.required(
                                            AppMessages.birthPlaceRequiredValidation)
                                      ],
                                    ),
                                    hintText: "birth_time_second".tr,
                                    textEditingController: clientdetailController
                                        .birthTimeSecController),
                              ),
                            ),
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
                      text: "update".tr,
                      onTap: () async {
                        // Services.to(AppRoutes.clientListView);

                        bool isValidated = await Services.validateForm(
                            clientdetailController.editClientFormKey);
                        if (isValidated) {
                          clientdetailController.editDetails(context: context);


                        }
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
