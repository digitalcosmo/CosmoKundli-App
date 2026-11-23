import 'package:cosmo_kundali/models/auth_model/login_model.dart';
import 'package:cosmo_kundali/models/auth_model/signup_model.dart';
import 'package:cosmo_kundali/models/verify_device_model.dart';
import '../network/network_api_services.dart';
import '../values/urls.dart';

class AuthRepo {
  final NetworkApiServices networkApiServices = NetworkApiServices();

  Future<LoginModel> login(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.login);
    print(response);
    return LoginModel.fromJson(response);
  }

  Future<SignUpModel> register(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.signUp);
    print(response);
    return SignUpModel.fromJson(response);
  }

  Future<VerifyDeviceModel> verifyDevice (Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.verifyDevice);
    print(response);
    return VerifyDeviceModel.fromJson(response);
  }


// Future<VerifyOTPModel> verifyOTP(Map<String, dynamic> data) async {
  //   Map<String, dynamic> response =
  //   await networkApiServices.postApi(data, AppUrls.verifyOtp);
  //   return VerifyOTPModel.fromJson(response);
  // }
}
