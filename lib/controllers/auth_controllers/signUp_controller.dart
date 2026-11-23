import 'package:cosmo_kundali/models/auth_model/signup_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../repo/auth_repo.dart';
import '../../services/services.dart';
import '../../values/routes.dart';

class SignUnController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  RxBool obscureText1 = true.obs;
  RxBool obscureText2 = true.obs;
  RxBool isTAndC = false.obs;
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxString selectedCountry = 'IN'.obs;
  RxString selectedCountryCode = '+91'.obs;
  RxInt numberLength = 7.obs;
  final AuthRepo authRepo = AuthRepo();



  GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  void toggleObscureText() => obscureText1.value = !obscureText1.value;

  void toggleObscureText1() => obscureText2.value = !obscureText2.value;

  void setTAndC(bool newValue) => isTAndC.value = newValue;

  void setLoading(bool newValue) => isLoading.value = newValue;

  void setError(bool newValue) => isError.value = newValue;



  void signUp({required BuildContext context}) async
  {
    Map<String, dynamic> data = {
      "name": nameController.text,
      "mobile": mobileController.text,
      "email": emailController.text,
      "password": passwordController.text
    };
    try {
      setLoading(true);
      SignUpModel signUpModel = await authRepo.register(data);
      setLoading(false);
      if (signUpModel.status == true) {
        Services.snackBarSuccess(context, signUpModel.msg.toString());
        Services.to(AppRoutes.signInView);
      } else {
        Services.snackBarError(context, signUpModel.msg.toString());
      }
    } catch (e) {
      setLoading(false);
      setError(true);
      Services.snackBarError(context, e.toString());
    }
  }

}
