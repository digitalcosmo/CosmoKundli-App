import 'dart:async';
import 'dart:convert';

import 'package:cosmo_kundali/models/add_member_model.dart';
import 'package:cosmo_kundali/models/delete_member.dart';
import 'package:cosmo_kundali/models/google_place_model.dart';
import 'package:cosmo_kundali/models/member_details.dart';
import 'package:cosmo_kundali/models/member_list_model.dart';
import 'package:cosmo_kundali/repo/auto_complete_repo.dart';
import 'package:cosmo_kundali/repo/member_repo.dart';
import 'package:cosmo_kundali/values/app_constants.dart';
import 'package:cosmo_kundali/values/user_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/services.dart';
import '../values/get_tags.dart';
import '../values/routes.dart';
import 'home_controller.dart';

class ClientDetailController extends GetxController {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();
  TextEditingController timmDiffController = TextEditingController();
  TextEditingController birthPlaceController = TextEditingController();
  TextEditingController birthTimeHourController = TextEditingController();
  TextEditingController birthTimeMinController = TextEditingController();
  TextEditingController birthTimeSecController = TextEditingController();
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxString selectedBday = 'Date of Birth'.obs;
  RxString selectedGender = 'Gender'.obs;
  GlobalKey<FormState> clientDetailFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> editClientFormKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  AddMemberModel? addMemberModel;
  MemberListModel? memberListModel;
  DeleteMemberModel? _deleteMemberModel;
  MemberDetails? memberDetails;
  AddMemberRepo addMemberRepo = AddMemberRepo();
  TimeOfDay? selectedTime;
  RxList<Members> memberList = <Members>[].obs;
  RxString mId = ''.obs;
  String selectedMemberName = '';
  final HomeController homeController = Get.find(tag: GetTags.homeTag);

  void setMemberName(String newMemberName) {
    selectedMemberName = newMemberName;
  }

  final GooglePlaceRepo googlePlaceRepo = GooglePlaceRepo();
  RxList<Predictions> googlePlaceList = <Predictions>[].obs;
  Timer? debounce;

  void debounceSearch(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(Duration(seconds: 3), () {
      fetchPlaces(query: query);
    });
  }

  void setGooglePlaceList(List<Predictions> newList) {
    googlePlaceList.value = newList;
  }

  var firstNameError = ''.obs;
  var lastNameError = ''.obs;
  var mobileNumberError = ''.obs;
  var dobError = ''.obs;
  var birthPlaceError = ''.obs;
  var latError = ''.obs;
  var longError = ''.obs;

  @override
  void onInit() {
    mId.value = Get.put<HomeController>(HomeController(), tag: GetTags.homeTag)
        .mId
        .toString();
    dobController.text = Services.formatDate(date: selectedDate.value);
    super.onInit();
  }

  bool validateFields() {
    bool isValid = true;

    if (firstNameController.text.trim().isEmpty) {
      firstNameError.value = "First name is required";
      isValid = false;
    } else {
      firstNameError.value = "";
    }

    if (lastNameController.text.trim().isEmpty) {
      lastNameError.value = "Last name is required";
      isValid = false;
    } else {
      lastNameError.value = "";
    }

    if (mobileNumberController.text.trim().isEmpty ||
        mobileNumberController.text.trim().length != 10) {
      mobileNumberError.value = "Enter a valid 10-digit number";
      isValid = false;
    } else {
      mobileNumberError.value = "";
    }

    if (dobController.text.trim().isEmpty) {
      dobError.value = "Date of birth is required";
      isValid = false;
    } else {
      dobError.value = "";
    }

    if (birthPlaceController.text.trim().isEmpty) {
      birthPlaceError.value = "Birth place is required";
      isValid = false;
    } else {
      birthPlaceError.value = "";
    }

    if (latController.text.trim().isEmpty) {
      latError.value = "Latitude is required";
      isValid = false;
    } else {
      latError.value = "";
    }

    if (longController.text.trim().isEmpty) {
      longError.value = "Longitude is required";
      isValid = false;
    } else {
      longError.value = "";
    }

    return isValid;
  }

  void updateStartDate(String newValue) {
    selectedBday.value = newValue;
  }

  void setLoading(bool newValue) => isLoading.value = newValue;

  void setError(bool newValue) => isError.value = newValue;

  void addMember(
      {required BuildContext context, bool isOpenKundali = false}) async {
    Map<String, dynamic> data = {
      "uID": await UserData.getuID(),
      "first_name": firstNameController.text,
      "middle_name": middleNameController.text,
      "country_code": '91',
      "surname": lastNameController.text,
      "mobile": mobileNumberController.text,
      "gender": genderController.text,
      "dob": dobController.text,
      "btime_hrs": birthTimeHourController.text,
      "btime_min": birthTimeMinController.text,
      "btime_sec": birthTimeSecController.text,
      "birth_place": birthPlaceController.text,
      "latitude": latController.text,
      "longitude": longController.text,
      "timm_diff": timmDiffController.text
    };
    try {
      debugPrint("Data :" + data.toString());
      setLoading(true);
      addMemberModel = await addMemberRepo.addMember(data);
      setLoading(false);
      if (addMemberModel!.status == true) {
        homeController.setMId(addMemberModel!.mID!.toString());
        mId.value = addMemberModel!.mID.toString();

        if (isOpenKundali) {
          homeController.selectedUserName.value =
              firstNameController.text + lastNameController.text;

          DateFormat inputFormat = DateFormat("yyyy-MM-dd");
          DateTime dateTime = inputFormat.parse(dobController.text);
          DateFormat outputFormat = DateFormat("dd/MM/yyyy");
          String formattedDate = outputFormat.format(dateTime);

          homeController.selectedBirthDate.value = formattedDate;
          Services.to(AppRoutes.containView);
        }
        Services.snackBarSuccess(context, addMemberModel!.msg!);
        clearValues();
      } else {
        Services.snackBarError(context, 'Something went wrong');
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      setLoading(false);
      Services.snackBarError(context, 'Something went wrong');
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void deleteMember({required BuildContext context, String? mId}) async {
    Map<String, dynamic> data = {"uID": await UserData.getuID(), "mID": mId};

    debugPrint('Delete API Called With $data');

    try {
      setLoading(true);
      _deleteMemberModel = await addMemberRepo.deleteMember(data);
      setLoading(false);
      if (_deleteMemberModel!.status == true) {
        fetchMembers();
        Services.snackBarSuccess(context, _deleteMemberModel!.msg.toString());
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e, s) {
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void fetchMemberDetails({String? mId}) async {
    Map<String, dynamic> data = {"mID": mId};
    try {
      setLoading(true);
      memberDetails = await addMemberRepo.fetchMemberDetails(data);
      setLoading(false);
      if (memberDetails!.status == true) {
        firstNameController.text = memberDetails?.firstName.toString() ?? '';
        lastNameController.text = memberDetails?.surname.toString() ?? '';
        middleNameController.text = memberDetails?.middleName.toString() ?? '';
        mobileNumberController.text = memberDetails?.mobile.toString() ?? '';
        latController.text = memberDetails?.latitude.toString() ?? '';
        longController.text = memberDetails?.longitude.toString() ?? '';
        birthTimeHourController.text = memberDetails?.btimeHrs.toString() ?? '';
        birthTimeMinController.text = memberDetails?.btimeMin.toString() ?? '';
        birthTimeSecController.text = memberDetails?.btimeSec.toString() ?? '';
        timmDiffController.text = memberDetails?.timmDiff.toString() ?? '';
        birthPlaceController.text = memberDetails?.birthPlace.toString() ?? '';
        dobController.text =  memberDetails?.dob.toString() ?? '';
        genderController.text=   memberDetails?.gender.toString() ?? '';
        selectedGender.value =
            memberDetails?.gender.toString().capitalizeFirst ?? '';
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e, s) {
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void onClickEdit({required int index, String? mid}) {
    firstNameController.text = memberList.value[index].Name;
    selectedBday.value = memberList.value[index].DOB;
    mId.value = mid!;
  }

  void editDetails({required BuildContext context}) async {
    Map<String, dynamic> data = {
      "uID": await UserData.getuID(),
      "mID": mId.value,
      "first_name": firstNameController.text,
      "middle_name": middleNameController.text,
      "country_code": '91',
      "surname": lastNameController.text,
      "mobile": mobileNumberController.text,
      "gender": genderController.text.toString(),
      "dob": dobController.text,
      "btime_hrs": birthTimeHourController.text,
      "btime_min": birthTimeMinController.text,
      "btime_sec": birthTimeSecController.text,
      "birth_place": birthPlaceController.text,
      "latitude": latController.text,
      "longitude": longController.text,
      "timm_diff": timmDiffController.text
    };
    try {
      debugPrint("Edit data :"+data.toString());
      setLoading(true);
      addMemberModel = await addMemberRepo.updateMember(data);
      setLoading(false);
      if (addMemberModel!.status == true) {
        Services.snackBarSuccess(context, addMemberModel!.msg!);
        Services.back();
        clearValues();
        //bbServices.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e, s) {
      debugPrint("Edit data :"+data.toString());

      debugPrint(e.toString());
      debugPrint(s.toString());
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  void clearValues() {
    firstNameController.clear();
    middleNameController.clear();
    lastNameController.clear();
    mobileNumberController.clear();
    selectedGender.value = 'Gender';
    birthTimeHourController.clear();
    birthPlaceController.clear();
    birthTimeMinController.clear();
    birthTimeSecController.clear();
    latController.clear();
    longController.clear();
    timmDiffController.clear();
  }

  void fetchMembers() async {

    Map<String, dynamic> data = {"uID": await UserData.getuID()};

    debugPrint("Fetch MEmber :"+data.toString());
    try {
      setLoading(true);
      memberListModel = await addMemberRepo.fetchMemberList(data);

      setLoading(false);
      if (memberListModel!.status == true) {
        memberList.value = memberListModel?.members ?? [];
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (e, s) {
      print(e);
      print(s);

      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  Future<void> selectTime(BuildContext context) async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (birthTimeHourController != null) {
      final formattedTime =
          "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}";
      birthTimeHourController.text = time.hour.toString();
      birthTimeMinController.text = time.minute.toString();
    }
  }

  Future<void> showSecondsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: ListView.builder(
              itemCount: 60,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(index.toString().padLeft(2, '0')),
                  onTap: () {
                    birthTimeSecController.text = index.toString();
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void fetchPlaces({required String query}) async {
    Map<String, dynamic> qp = {
      'key': AppConstants.googleMapApiKey,
      'types': 'geocode',
      'input': query,
      'radius': '1000',
    };
    GooglePlaceModel response = await googlePlaceRepo.fetchPlaces(qp: qp);
    setGooglePlaceList(response.predictions!);
    debugPrint(jsonEncode(response));
  }

  void search(String query) {
    memberList.value = memberListModel!.members
        .where((item) => item.Name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    debugPrint(jsonEncode(memberList));
  }
}
