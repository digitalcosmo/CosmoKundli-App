import 'package:cosmo_kundli/models/login_model.dart';
import 'package:cosmo_kundli/models/sign_up_model.dart';
import 'package:cosmo_kundli/models/verify_device_model.dart';
import 'package:cosmo_kundli/network/network_api_services.dart';
import 'package:cosmo_kundli/values/urls.dart';

class AuthRepo {
  Future<LoginModel> login(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.login, data);
    return LoginModel.fromJson(response);
  }

  Future<SignUpModel> register(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.signUp, data);
    return SignUpModel.fromJson(response);
  }

  Future<VerifyDeviceModel> verifyDevice(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.verifyDevice, data);
    return VerifyDeviceModel.fromJson(response);
  }
}
