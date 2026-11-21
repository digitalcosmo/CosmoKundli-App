import 'package:dio/dio.dart';
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
import 'package:cosmo_kundli/network/network_api_services.dart';
import 'package:cosmo_kundli/values/urls.dart';

class ProfileRepo {
  Future<ProfileDetails> getProfileDetails(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.profileDetails, data);
    return ProfileDetails.fromJson(response);
  }

  Future<ProfileUpdate> updateProfileDetails(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.updateProfileDetails, data);
    return ProfileUpdate.fromJson(response);
  }

  Future<ProfileUpdate> updateAppDetails(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.updateAppDetails, data);
    return ProfileUpdate.fromJson(response);
  }

  Future<ProfileUpdate> updateDisplayDetails(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.updateDisplayDetails, data);
    return ProfileUpdate.fromJson(response);
  }

  Future<DisplayDetailsModel> displayDetails(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.displayDetails, data);
    return DisplayDetailsModel.fromJson(response);
  }

  Future<AppDetailsModel> appDetails(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.appDetails, data);
    return AppDetailsModel.fromJson(response);
  }

  Future<CreditTransaction> creditTransaction(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.creditTransaction, data);
    return CreditTransaction.fromJson(response);
  }

  Future<ChangePassword> updatePassword(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.changePassword, data);
    return ChangePassword.fromJson(response);
  }

  Future<ReportHistoryModel> reportHistory(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.reportHistory, data);
    return ReportHistoryModel.fromJson(response);
  }

  Future<ImageUpdate> updateAppImage(FormData formData) async {
    final response = await NetworkApiServices.imageApi(Urls.updateAppImage, formData);
    return ImageUpdate.fromJson(response);
  }

  Future<ImageUpdate> updateFrontImage(FormData formData) async {
    final response = await NetworkApiServices.imageApi(Urls.updateFrontImage, formData);
    return ImageUpdate.fromJson(response);
  }

  Future<ImageUpdate> updateBackImage(FormData formData) async {
    final response = await NetworkApiServices.imageApi(Urls.updateBackImage, formData);
    return ImageUpdate.fromJson(response);
  }

  Future<ResetPassword> resetPassword(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.resetPassword, data);
    return ResetPassword.fromJson(response);
  }

  Future<ForgotPassword> forgotPassword(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.forgotPassword, data);
    return ForgotPassword.fromJson(response);
  }

  Future<DeleteAccountModel> deleteAccount(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.deactivateAccount, data);
    return DeleteAccountModel.fromJson(response);
  }
}
