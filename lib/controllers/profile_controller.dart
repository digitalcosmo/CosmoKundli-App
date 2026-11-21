import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cosmo_kundli/models/app_details_model.dart';
import 'package:cosmo_kundli/models/change_password_model.dart';
import 'package:cosmo_kundli/models/credit_transaction_model.dart';
import 'package:cosmo_kundli/models/delete_account_model.dart';
import 'package:cosmo_kundli/models/display_details_model.dart';
import 'package:cosmo_kundli/models/forgot_password_model.dart';
import 'package:cosmo_kundli/models/image_update_model.dart';
import 'package:cosmo_kundli/models/profile_details_model.dart';
import 'package:cosmo_kundli/models/profile_update_model.dart';
import 'package:cosmo_kundli/models/report_history_model.dart';
import 'package:cosmo_kundli/models/reset_password_model.dart';
import 'package:cosmo_kundli/repos/profile_repo.dart';
import 'package:cosmo_kundli/services/services.dart';
import 'package:cosmo_kundli/values/urls.dart';
import 'package:cosmo_kundli/values/user_data.dart';

class ProfileController extends GetxController {
  final ProfileRepo _repo = ProfileRepo();

  RxString mId = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;

  // Profile
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  Rx<ProfileDetails?> profileData = Rx<ProfileDetails?>(null);

  // Display details
  TextEditingController displayNameController = TextEditingController();
  TextEditingController displayMsgController = TextEditingController();
  TextEditingController displayAddressController = TextEditingController();
  TextEditingController displayEmailController = TextEditingController();
  TextEditingController displayMobileController = TextEditingController();
  Rx<DisplayDetailsModel?> displayDetailsData = Rx<DisplayDetailsModel?>(null);

  // App details
  TextEditingController appNameController = TextEditingController();
  TextEditingController appCodeController = TextEditingController();
  TextEditingController appDescController = TextEditingController();
  Rx<AppDetailsModel?> appDetailsData = Rx<AppDetailsModel?>(null);

  // Password
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController newPass1Controller = TextEditingController();

  // Reset/Forgot password
  TextEditingController otpController = TextEditingController();
  TextEditingController resetEmailController = TextEditingController();

  // Images
  RxString selectedFrontImage = ''.obs;
  RxString selectedBackImage = ''.obs;
  RxString selectedAppImage = ''.obs;
  Rx<File?> selectedFrontFile = Rx<File?>(null);
  Rx<File?> selectedBackFile = Rx<File?>(null);
  Rx<File?> selectedAppFile = Rx<File?>(null);

  // Credit & Report
  Rx<CreditTransaction?> creditTransactionData = Rx<CreditTransaction?>(null);
  Rx<ReportHistoryModel?> reportHistoryData = Rx<ReportHistoryModel?>(null);

  @override
  void onInit() {
    _getMID();
    getProfile();
    displayDetails();
    fetchAppDetails();
    fetchReportHistory();
    super.onInit();
  }

  Future<void> _getMID() async {
    mId.value = await UserData.getmID() ?? '';
  }

  Future<String> get _uID async => await UserData.getuID() ?? '';

  // ── File picker ──

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      switch (type) {
        case 'front':
          selectedFrontFile.value = file;
          break;
        case 'back':
          selectedBackFile.value = file;
          break;
        case 'app':
          selectedAppFile.value = file;
          break;
      }
    }
  }

  // ── Profile ──

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {"uID": uID};
      profileData.value = await _repo.getProfileDetails(data);
      if (profileData.value?.status == true) {
        nameController.text = profileData.value?.name ?? '';
        dobController.text = profileData.value?.dob ?? '';
        emailController.text = profileData.value?.email ?? '';
        mobileController.text = profileData.value?.mobile ?? '';
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {
        "uID": uID,
        "name": nameController.text,
        "dob": dobController.text,
        "email": emailController.text,
        "mobile": mobileController.text,
      };
      ProfileUpdate result = await _repo.updateProfileDetails(data);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Updated');
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  // ── Display Details ──

  Future<void> displayDetails() async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {"uID": uID};
      displayDetailsData.value = await _repo.displayDetails(data);
      if (displayDetailsData.value?.status == true) {
        displayNameController.text = displayDetailsData.value?.displayName ?? '';
        displayMsgController.text = displayDetailsData.value?.displayMsg ?? '';
        displayAddressController.text = displayDetailsData.value?.displayAddress ?? '';
        displayEmailController.text = displayDetailsData.value?.displayEmail ?? '';
        displayMobileController.text = displayDetailsData.value?.displayMobile ?? '';
        selectedFrontImage.value = displayDetailsData.value?.frontImage ?? '';
        selectedBackImage.value = displayDetailsData.value?.backImage ?? '';
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> updateDisplayDetails(BuildContext context) async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {
        "uID": uID,
        "display_name": displayNameController.text,
        "display_msg": displayMsgController.text,
        "display_address": displayAddressController.text,
        "display_email": displayEmailController.text,
        "display_mobile": displayMobileController.text,
      };
      ProfileUpdate result = await _repo.updateDisplayDetails(data);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Updated');
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  // ── App Details ──

  Future<void> fetchAppDetails() async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {"uID": uID};
      appDetailsData.value = await _repo.appDetails(data);
      if (appDetailsData.value?.status == true) {
        appNameController.text = appDetailsData.value?.appName ?? '';
        appCodeController.text = appDetailsData.value?.appCode ?? '';
        appDescController.text = appDetailsData.value?.appDesc ?? '';
        selectedAppImage.value = appDetailsData.value?.appImage ?? '';
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> updateAppDetail(BuildContext context) async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {
        "uID": uID,
        "app_name": appNameController.text,
        "app_code": appCodeController.text,
        "app_desc": appDescController.text,
      };
      ProfileUpdate result = await _repo.updateAppDetails(data);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Updated');
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  // ── Password ──

  Future<void> updatePassword(BuildContext context) async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {
        "uID": uID,
        "old_password": oldPassController.text,
        "new_password": newPassController.text,
      };
      ChangePassword result = await _repo.updatePassword(data);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Password changed');
        oldPassController.clear();
        newPassController.clear();
        newPass1Controller.clear();
      } else {
        Services.snackBarError(context, result.msg ?? 'Failed');
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> data = {
        "email": resetEmailController.text,
        "otp": otpController.text,
        "new_password": newPassController.text,
      };
      ResetPassword result = await _repo.resetPassword(data);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Password reset');
      } else {
        Services.snackBarError(context, result.msg ?? 'Failed');
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  Future<void> forgotPassword(BuildContext context) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> data = {"email": resetEmailController.text};
      ForgotPassword result = await _repo.forgotPassword(data);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'OTP sent');
      } else {
        Services.snackBarError(context, result.msg ?? 'Failed');
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  // ── Image uploads ──

  Future<void> updateFrontImage(BuildContext context) async {
    if (selectedFrontFile.value == null) return;
    try {
      isLoading.value = true;
      String uID = await _uID;
      FormData formData = FormData.fromMap({
        "uID": uID,
        "front_image": await MultipartFile.fromFile(
          selectedFrontFile.value!.path,
          filename: selectedFrontFile.value!.path.split('/').last,
        ),
      });
      ImageUpdate result = await _repo.updateFrontImage(formData);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Image updated');
        displayDetails();
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  Future<void> updateBackImage(BuildContext context) async {
    if (selectedBackFile.value == null) return;
    try {
      isLoading.value = true;
      String uID = await _uID;
      FormData formData = FormData.fromMap({
        "uID": uID,
        "back_image": await MultipartFile.fromFile(
          selectedBackFile.value!.path,
          filename: selectedBackFile.value!.path.split('/').last,
        ),
      });
      ImageUpdate result = await _repo.updateBackImage(formData);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Image updated');
        displayDetails();
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  Future<void> updateAppImage(BuildContext context) async {
    if (selectedAppFile.value == null) return;
    try {
      isLoading.value = true;
      String uID = await _uID;
      FormData formData = FormData.fromMap({
        "uID": uID,
        "app_image": await MultipartFile.fromFile(
          selectedAppFile.value!.path,
          filename: selectedAppFile.value!.path.split('/').last,
        ),
      });
      ImageUpdate result = await _repo.updateAppImage(formData);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Image updated');
        fetchAppDetails();
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  // ── Credits & Reports ──

  Future<void> fetchCreditTransactions() async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {"uID": uID};
      creditTransactionData.value = await _repo.creditTransaction(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  Future<void> fetchReportHistory() async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {"uID": uID};
      reportHistoryData.value = await _repo.reportHistory(data);
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      isError.value = true;
    }
  }

  // ── Deactivate ──

  Future<void> deactivateAccount(BuildContext context) async {
    try {
      isLoading.value = true;
      String uID = await _uID;
      Map<String, dynamic> data = {"uID": uID};
      DeleteAccountModel result = await _repo.deleteAccount(data);
      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Account deactivated');
        Services.logOut();
      }
      isLoading.value = false;
    } catch (e, s) {
      debugPrint(e.toString());
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }
}
