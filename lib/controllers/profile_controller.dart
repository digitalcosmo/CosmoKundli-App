import 'dart:convert';
import 'dart:io';
import 'package:cosmo_kundali/models/app_details.dart';
import 'package:cosmo_kundali/models/auth_model/forgot_password.dart';
import 'package:cosmo_kundali/models/auth_model/reset_password.dart';
import 'package:cosmo_kundali/models/change_password.dart';
import 'package:cosmo_kundali/models/credit_transaction.dart';
import 'package:cosmo_kundali/models/delete_account_model.dart';
import 'package:cosmo_kundali/models/display_details.dart';
import 'package:cosmo_kundali/models/profile_update.dart';
import 'package:cosmo_kundali/models/report_history.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:cosmo_kundali/values/routes.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../models/profile_details.dart';
import '../repo/profile_repo.dart';
import '../values/urls.dart';
import '../values/user_data.dart';


class ProfileController extends GetxController {

  late final XFile? image;
  FilePickerResult? result;
  Rx<File?> selectedFrontFile = Rx<File?>(null);
  Rx<File?> selectedBackFile = Rx<File?>(null);
  Rx<File?> selectedAppFile = Rx<File?>(null);
  RxBool isVisible = false.obs;
  RxString selectedLanguage = ''.obs;
  ProfileDetails? profileDetails;
  DisplayDetailsModel? displayDetail;
  AppDetails? appDetails;
  CreditTransaction? creditTransaction;
  ChangePassword? changePassword;
  ResetPassword? reset_password;
  ProfileUpdate? profileUpdate;
  ProfileRepo profileRepo = ProfileRepo();
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxInt index = 0.obs;
  RxString mId = ''.obs;
  RxList<TransactionList> transactionList = <TransactionList>[].obs;
  RxList<ReportList> reportList = <ReportList>[].obs;
  ReportHistoryModel? reportHistorymodel;
  ForgotPassword? _forgotPassword;
  RxString selectedGender = 'Gender'.obs;
  // RxString name = ''.obs;
  // RxString gender = ''.obs;
  // RxString dob = ''.obs;
  // RxString email = ''.obs;
  // RxString mobile = ''.obs;
  TextEditingController name = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController displayName = TextEditingController();
  TextEditingController displayMsg = TextEditingController();
  TextEditingController displayAddress = TextEditingController();
  TextEditingController displayEmail = TextEditingController();
  TextEditingController displayMobile = TextEditingController();
  TextEditingController appName = TextEditingController();
  TextEditingController appCode = TextEditingController();
  TextEditingController appDesc = TextEditingController();
  TextEditingController oldPass = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController newPass1 = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController resetEmailController = TextEditingController();
  RxString selectedFrontImage = ''.obs;
  RxString selectedBackImage = ''.obs;
  RxString selectedAppImage = ''.obs;
  RxString username = ''.obs;
  RxString emailId = ''.obs;
  RxString selectedDate = ''.obs;
  RxString isDownload = ''.obs;
  GlobalKey<FormState> appDetailsFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
     getMID();
    getProfile();
    displayDetails();
    fetchAppDetails();
    fetchReportHistory();
    super.onInit();
  }

  void setLoading(bool newValue) => isLoading.value = newValue;

  void setError(bool newValue) => isError.value = newValue;

  void setIndex(int newindex) => index.value = newindex;

  Future<File?> pickFile(BuildContext context, String file) async {
    try {
      result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        type: FileType.custom,
        allowMultiple: false,
      );

      if (result != null && result!.files.single.path != null) {
        File selectedFile = File(result!.files.single.path!);
        // selectedFile1.value = File(result!.files.single.path!);
        file = selectedFile.path.toString();
        return selectedFile;
        //await updateProfilePicture(context);
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> updateProfilePicture(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated')),
    );
  }

  Future<void> getProfile() async {
    Map<String, dynamic> data = {"uID": await UserData.getuID()};
    debugPrint("pprofile:" + data.toString());
    try {
      setLoading(true);
      profileDetails = await profileRepo.getProfileDetails(data);

      setLoading(false);
      if (profileDetails!.status == true) {
        username.value = profileDetails?.name ?? '';
        emailId.value = profileDetails?.email ?? '';
        name.text = profileDetails?.name.toString() ?? "";
        dob.text = profileDetails?.dOB.toString() ?? "";

        mobile.text = profileDetails?.mobile.toString() ?? "";
        emailController.text = profileDetails?.email.toString() ?? "";
        selectedGender.value = profileDetails?.gender.toString() ?? "";
        selectedDate.value = profileDetails!.dOB.toString();
        debugPrint(selectedDate.value.toString());
        debugPrint("get profile  :" + jsonEncode(profileDetails));

        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (s) {
      debugPrint(s.toString());
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  Future<void> displayDetails() async {
    String? uId = await UserData.getuID();

    Map<String, dynamic> data = {"uID": uId};
    debugPrint(data.toString());
    try {
      setLoading(true);
      displayDetail = await profileRepo.displayDetails(data);

      if (displayDetail!.status == true) {
        displayName.text = displayDetail?.name.toString() ?? "";
        displayMsg.text = displayDetail?.message.toString() ?? "";
        displayEmail.text = displayDetail?.email.toString() ?? "";
        displayAddress.text = displayDetail?.address.toString() ?? "";
        displayMobile.text = displayDetail?.mobile.toString() ?? "";
        selectedFrontImage.value = displayDetail?.frontImg.toString() ?? "";
        selectedBackImage.value = displayDetail?.backImg.toString() ?? "";

        // gender.value = profileDetails?.gender.toString() ?? "";
        setLoading(false);
        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
        setLoading(false);
      }
    } catch (s) {
      debugPrint(s.toString());
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  Future<void> fetchAppDetails() async {
    String? uid = await UserData.getuID();

    Map<String, dynamic> data = {"uID": uid};
    debugPrint(data.toString());
    try {
      setLoading(true);
      appDetails = await profileRepo.appDetails(data);

      setLoading(false);
      if (appDetails!.status == true) {
        appName.text = appDetails?.appName.toString() ?? "";
        appCode.text = appDetails?.appCode.toString() ?? "";
        appDesc.text = appDetails?.description.toString() ?? "";
        selectedAppImage.value = appDetails?.icon.toString() ?? "";

        // gender.value = profileDetails?.gender.toString() ?? "";

        // Services.to(AppRoutes.containView);
      } else {
        // Services.snackBarError(context, loginModel.msg);
      }
    } catch (s) {
      debugPrint(s.toString());
      setLoading(false);
      setError(true);
      //Services.snackBarError(context, e.toString());
    }
  }

  Future<void> fetchCreditTransactions() async {
    Map<String, dynamic> data = {"uID": await UserData.getuID()};

    try {
      setLoading(true);
      creditTransaction = await profileRepo.creditTransaction(data);
      debugPrint(jsonEncode(creditTransaction));

      setLoading(false);
      transactionList.value.clear();
      if (creditTransaction != null && creditTransaction!.status == true) {
        if (creditTransaction!.list != null &&
            creditTransaction!.list!.isNotEmpty) {
          transactionList.value.addAll(creditTransaction!.list!);
          transactionList.refresh();
        }
      } else {
        debugPrint("Error: ${creditTransaction?.status ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint(e.toString());
      setLoading(false);
      setError(true);
    }
  }

  Future<void> updatePassword(BuildContext context) async {
    String? userData = await UserData.getuID();

    Map<String, dynamic> data = {
      "uID": userData,
      "oldpassword": oldPass.text,
      "newpassword": newPass.text
    };
    try {
      setLoading(true);
      changePassword = await profileRepo.updatePassword(data);

      setLoading(false);

      if (changePassword != null && changePassword!.status == true) {
        oldPass.clear();
        newPass.clear();
        newPass1.clear();

        Services.back();
        Services.snackBarSuccess(
            context, changePassword?.message.toString() ?? "");
      } else {
        Services.snackBarError(
            context, changePassword?.message.toString() ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
      setLoading(false);
      setError(true);
    }
  }

  Future<void> resetPassword(BuildContext context) async {

    Map<String, dynamic> data = {
        "email": resetEmailController.text,
        "otp": otpController.text,
        "new_password": newPass.text
    };
    try {
      setLoading(true);
      reset_password = await profileRepo.reset_Password(data);

      setLoading(false);

      if ( reset_password!.status == true) {
        // oldPass.clear();
        // newPass.clear();
        // newPass1.clear();

        Services.snackBarSuccess(
            context, reset_password?.msg.toString() ?? "");
      } else {
        Services.snackBarError(
            context, reset_password?.msg.toString() ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
      setLoading(false);
      setError(true);
    }
  }

  Future<void> forgotPassword(BuildContext context) async {

    Map<String, dynamic> data = {
      "email": resetEmailController.text
    };
    try {
      setLoading(true);
      _forgotPassword = await profileRepo.forgot_password(data);


      if ( _forgotPassword!.status == true) {
        // oldPass.clear();
        // newPass.clear();
        // newPass1.clear();

        Services.snackBarSuccess(
            context, _forgotPassword?.msg.toString() ?? "");
        setLoading(false);

        Services.to(AppRoutes.updatePassword);
      } else {
        Services.snackBarError(
            context, _forgotPassword?.msg.toString() ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
      setLoading(false);
      setError(true);
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    String? userId = await UserData.getuID();

    Map<String, dynamic> data = {
      "uID": userId,
      "name": name.text,
      "gender": selectedGender.value,
      "dob": selectedDate.value,
      "mobile": mobile.text
    };
    debugPrint("UPDATE PROFILE ::" + data.toString());
    try {
      setLoading(true);
      profileUpdate = await profileRepo.updateProfileDetails(data);

      setLoading(false);

      if (profileUpdate != null && profileUpdate!.status == true) {
        Services.back();
        getProfile();
        Services.snackBarSuccess(
            context, profileUpdate?.message.toString() ?? "");
      } else {
        Services.snackBarError(
            context, profileUpdate?.message.toString() ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
      setLoading(false);
      setError(true);
    }
  }

  Future<void> updateAppDetail(BuildContext context) async {
    String? uId = await UserData.getuID();

    Map<String, dynamic> data = {
      "uID": uId,
      "description": appDesc.text.toString()
    };
    debugPrint("UPDATE PROFILE ::" + data.toString());
    try {
      setLoading(true);
      profileUpdate = await profileRepo.updateAppDetails(data);

      setLoading(false);

      if (profileUpdate != null && profileUpdate!.status == true) {
        Services.back();
        Services.snackBarSuccess(
            context, profileUpdate?.message.toString() ?? "");
      } else {
        Services.snackBarError(
            context, profileUpdate?.message.toString() ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
      setLoading(false);
      setError(true);
    }
  }

  Future<void> updateDisplayDetails(BuildContext context) async {
    String? userId = await UserData.getuID();

    Map<String, dynamic> data = {
      "uID": userId,
      "name": displayName.text,
      "message": displayMsg.text,
      "address": displayAddress.text,
      "mobile": displayMobile.text,
      "email": displayEmail.text
    };
    debugPrint("UPDATE PROFILE ::" + data.toString());
    try {
      setLoading(true);
      profileUpdate = await profileRepo.updateDisplayDetails(data);

      setLoading(false);

      if (profileUpdate != null && profileUpdate!.status == true) {
        Services.back();
        Services.snackBarSuccess(
            context, profileUpdate?.message.toString() ?? "");
      } else {
        Services.snackBarError(
            context, profileUpdate?.message.toString() ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
      setLoading(false);
      setError(true);
    }
  }

  void fetchReportHistory() async {
    String? uId = await UserData.getuID();

    Map<String, dynamic> data = {"uID": uId};
    try {
      setLoading(true);
      reportHistorymodel = await profileRepo.reportHistory(data);
      setLoading(false);
      debugPrint('Report History' + jsonEncode(reportHistorymodel));
      await Future.delayed(const Duration(seconds: 2));
      reportList.value.clear();
      if (reportHistorymodel?.status == true) {
        reportList.addAll(reportHistorymodel!.list!);
        setLoading(false);
      }
    } catch (e) {
      setLoading(false);
      debugPrint("Error fetching report history: $e");
    }
  }

  Future<void> updateFrontImage(BuildContext context) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: AppUrls.baseUrl));
      String url = AppUrls.updateFrontImage;
      String? userId = await UserData.getuID();

      setLoading(true);

      FormData formData = FormData.fromMap({
        'uID': mId.value,
        'Image': await MultipartFile.fromFile(selectedFrontFile.value!.path),
      });

      debugPrint(formData.fields.toString());

      dio.options.headers['Content-Type'] = 'multipart/form-data';

      Response response = await dio.post(
        url,
        data: formData,
        onSendProgress: (int sent, int total) {},
      );

      Map<String, dynamic> decodedResponse = response.data;

      if (context.mounted) {
        if (decodedResponse['status'] == true) {
          setLoading(false);
          Services.snackBarSuccess(context, decodedResponse['Message']);
          Services.back();
        } else {
          setLoading(false);
          Services.snackBarSuccess(context, decodedResponse['Message']);
        }
      }
      debugPrint('Upload response: ${response.data}');
    } catch (e, s) {
      setLoading(false);
      Services.snackBarError(context, 'Error while updating image');
      debugPrint('Error uploading file: $e $s');
    }
    // }
  }

  Future<void> updateBckImage(BuildContext context) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: AppUrls.baseUrl));
      String url = AppUrls.updateBackImage;
      String? userId = await UserData.getuID();

      setLoading(true);

      FormData formData = FormData.fromMap({
        'uID': mId.value,
        'Image': await MultipartFile.fromFile(selectedBackFile.value!.path),
      });

      debugPrint(formData.fields.toString());

      dio.options.headers['Content-Type'] = 'multipart/form-data';

      Response response = await dio.post(
        url,
        data: formData,
        onSendProgress: (int sent, int total) {},
      );

      Map<String, dynamic> decodedResponse = response.data;

      if (context.mounted) {
        if (decodedResponse['status'] == true) {
          setLoading(false);
          Services.snackBarSuccess(context, decodedResponse['Message']);
          Services.back();
        } else {
          setLoading(false);
          Services.snackBarSuccess(context, decodedResponse['Message']);
        }
      }
      debugPrint('Upload response: ${response.data}');
    } catch (e, s) {
      setLoading(false);
      Services.snackBarError(context, 'Error while updating image');
      debugPrint('Error uploading file: $e $s');
    }
    // }
  }

  Future<void> updateAppImage(BuildContext context) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: AppUrls.baseUrl));
      String url = AppUrls.appImageUpdate;

      setLoading(true);

      String? userId = await UserData.getuID();

      FormData formData = FormData.fromMap({
        'uID': userId,
        'Image': await MultipartFile.fromFile(selectedAppFile.value!.path),
      });

      debugPrint(formData.fields.toString());

      dio.options.headers['Content-Type'] = 'multipart/form-data';

      Response response = await dio.post(
        url,
        data: formData,
        onSendProgress: (int sent, int total) {},
      );

      Map<String, dynamic> decodedResponse = response.data;

      if (context.mounted) {
        if (decodedResponse['status'] == true) {
          setLoading(false);
          Services.snackBarSuccess(context, decodedResponse['Message']);
          Services.back();
        } else {
          setLoading(false);
          Services.snackBarSuccess(context, decodedResponse['Message']);
        }
      }
      debugPrint('Upload response: ${response.data}');
    } catch (e, s) {
      setLoading(false);
      Services.snackBarError(context, 'Error while updating image');
      debugPrint('Error uploading file: $e $s');
    }
    // }
  }


  getMID() async
  {
    //mId.value = Get.find<HomeController>(tag: GetTags.homeTag).mId.toString();
    mId.value = (await UserData.getmID()) ?? '';
  }


  Future<void> deactivateAccount(BuildContext context) async {
    String? userId = await UserData.getuID();

    Map<String, dynamic> data = {
      "uID": userId,
    };
    try {
      setLoading(true);
      DeleteAccountModel deleteAccountModel = await profileRepo.deleteAccount(data);

      setLoading(false);

      if (deleteAccountModel != null && deleteAccountModel.status == true) {

        Services.snackBarSuccess(context, deleteAccountModel.message.toString() ?? "");
        Services.logOut();
      } else {
        Services.snackBarError(context, deleteAccountModel.message.toString() ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
      setLoading(false);
      setError(true);
    }
  }

}


