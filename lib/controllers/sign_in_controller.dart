import 'package:cosmo_kundli/models/login_model.dart';
import 'package:cosmo_kundli/models/verify_device_model.dart';
import 'package:cosmo_kundli/repos/auth_repo.dart';
import 'package:cosmo_kundli/services/services.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/values/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  final obscureText = true.obs;
  final isLoading = false.obs;
  final isError = false.obs;
  final _mobileDeviceIdentifierPlugin = MobileDeviceIdentifier();
  String? deviceId;
  final AuthRepo _authRepo = AuthRepo();

  @override
  void onInit() {
    super.onInit();
    initDeviceId();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> initDeviceId() async {
    try {
      deviceId = await _mobileDeviceIdentifierPlugin.getDeviceId() ?? 'unknown';
    } on PlatformException {
      deviceId = 'unknown';
    }
  }

  void toggleObscureText() => obscureText.value = !obscureText.value;

  Future<void> login(BuildContext context) async {
    if (!loginFormKey.currentState!.validate()) return;

    final data = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'device_id': deviceId,
    };

    try {
      isLoading.value = true;
      final loginModel = await _authRepo.login(data);
      isLoading.value = false;

      if (loginModel.status == true) {
        Services.snackBarSuccess(context, loginModel.msg ?? 'Login successful');
        UserData.setuID(loginModel.uID!);
        UserData.setLoggedIn(true);
        if (loginModel.feature != null) {
          UserData.setFeatures(loginModel.feature!);
        }
        Get.offAllNamed(AppRoutes.home);
      } else {
        Services.snackBarError(context, loginModel.msg ?? 'Login failed');
      }
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      Services.snackBarError(context, 'Something went wrong');
    }
  }

  Future<void> verifyDevice(BuildContext context) async {
    final data = {
      'uID': await UserData.getuID(),
      'device_id': deviceId,
    };

    try {
      final result = await _authRepo.verifyDevice(data);
      if (result.status == false) {
        Services.logOut();
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF112d6a),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text(
                'Your account has been logged out because a new login was detected',
                style: TextStyle(fontSize: 15, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK', style: TextStyle(color: Color(0xFF6C63FF))),
                ),
              ],
            ),
          );
        }
      }
    } catch (_) {}
  }
}
