import 'package:cosmo_kundali/models/app_details.dart';
import 'package:cosmo_kundali/models/auth_model/forgot_password.dart';
import 'package:cosmo_kundali/models/auth_model/reset_password.dart';
import 'package:cosmo_kundali/models/change_password.dart';
import 'package:cosmo_kundali/models/credit_transaction.dart';
import 'package:cosmo_kundali/models/delete_account_model.dart';
import 'package:cosmo_kundali/models/display_details.dart';
import 'package:cosmo_kundali/models/image_update.dart';
import 'package:cosmo_kundali/models/profile_details.dart';
import 'package:cosmo_kundali/models/profile_update.dart';
import '../models/report_history.dart';
import '../network/network_api_services.dart';
import '../values/urls.dart';

class ProfileRepo
{
  final NetworkApiServices networkApiServices = NetworkApiServices();


  Future<ProfileDetails> getProfileDetails (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.profileDetails);
    return ProfileDetails.fromJson(response);
  }


  Future<ProfileUpdate> updateProfileDetails (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.profileUpdate);
    return ProfileUpdate.fromJson(response);
  }

  Future<ProfileUpdate> updateAppDetails(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.appDetailsUpdate);
    return ProfileUpdate.fromJson(response);
  }

  Future<ProfileUpdate> updateDisplayDetails(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.displayDetailsUpdate);
    return ProfileUpdate.fromJson(response);
  }


  Future<DisplayDetailsModel> displayDetails (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.displayDetails);
    return DisplayDetailsModel.fromJson(response);
  }

  Future<AppDetails> appDetails (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.appDetails);
    return AppDetails.fromJson(response);
  }

  Future<CreditTransaction> creditTransaction (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.creditTransaction);
    return CreditTransaction.fromJson(response);
  }

  Future<ChangePassword> updatePassword (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.changePassword);
    return ChangePassword.fromJson(response);
  }

  Future<ReportHistoryModel> reportHistory(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.reportHistory);
    return ReportHistoryModel.fromJson(response);
  }

  Future<ImageUpdate> updateAppImage(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.appImageUpdate);
    return ImageUpdate.fromJson(response);
  }

  Future<ResetPassword> reset_Password (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.reset_password);
    return ResetPassword.fromJson(response);
  }

  Future<ForgotPassword> forgot_password (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.forgot_pass);
    return ForgotPassword.fromJson(response);
  }




  Future<DeleteAccountModel> deleteAccount (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.DeactivateAccount);
    return DeleteAccountModel.fromJson(response);
  }


}