import 'package:cosmo_kundli/models/sign_up_model.dart';
import 'package:cosmo_kundli/repos/auth_repo.dart';
import 'package:cosmo_kundli/services/services.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  final signUpFormKey = GlobalKey<FormState>();
  final obscureText = true.obs;
  final isLoading = false.obs;
  final AuthRepo _authRepo = AuthRepo();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  void toggleObscureText() => obscureText.value = !obscureText.value;

  Future<void> signUp(BuildContext context) async {
    if (!signUpFormKey.currentState!.validate()) return;

    final data = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'mobile': mobileController.text.trim(),
    };

    try {
      isLoading.value = true;
      final result = await _authRepo.register(data);
      isLoading.value = false;

      if (result.status == true) {
        Services.snackBarSuccess(context, result.msg ?? 'Registration successful');
        Get.offAllNamed(AppRoutes.login);
      } else {
        Services.snackBarError(context, result.msg ?? 'Registration failed');
      }
    } catch (e) {
      isLoading.value = false;
      Services.snackBarError(context, 'Something went wrong');
    }
  }
}
