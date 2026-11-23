import 'package:cosmo_kundali/models/auth_model/login_model.dart';
import 'package:cosmo_kundali/models/verify_device_model.dart';
import 'package:cosmo_kundali/values/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../repo/auth_repo.dart';
import '../../services/services.dart';
import '../../values/colors.dart';
import '../../values/routes.dart';

class SignInController extends GetxController {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxBool obscureText = true.obs;
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  final _mobileDeviceIdentifierPlugin = MobileDeviceIdentifier();
  String? deviceId;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initDeviceId();
  }

  final AuthRepo authRepo = AuthRepo();

  void setLoading(bool newValue) => isLoading.value = newValue;

  void setError(bool newValue) => isError.value = newValue;

  void toggleObscureText() => obscureText.value = !obscureText.value;

  Future<void> initDeviceId() async {
    try {
      deviceId = await _mobileDeviceIdentifierPlugin.getDeviceId() ??
          'Unknown platform version';
    } on PlatformException {
      deviceId = 'Failed to get platform version.';
    }
  }

  void login({required BuildContext context}) async {
    debugPrint(deviceId);

    Map<String, dynamic> data = {
      "email": emailController.text,
      "password": passwordController.text,
      "device_id": deviceId
    };
    try {
      setLoading(true);
      LoginModel loginModel = await authRepo.login(data);
      setLoading(false);
      if (loginModel.status == true) {
        Services.snackBarSuccess(context, loginModel.msg!);
        Services.offAll(AppRoutes.clientDetailView);
        UserData.setuID(loginModel.uID!);
        UserData.setLoggedIn(true);
        debugPrint('Login Features ${loginModel.feature!}');
        debugPrint('Login Features ${loginModel.feature!.runtimeType.toString()}');
        UserData.setFeatures(loginModel.feature!);
      } else if (loginModel.status == false) {
        Services.snackBarError(context, loginModel.msg!);
      } else {
        Services.snackBarError(context, loginModel.msg!);
      }
    } catch (e, s) {
      setLoading(false);
      setError(true);
      debugPrint(s.toString());
    }
  }

  void verifyDevice({required BuildContext context}) async {
    Map<String, dynamic> data = {
      "uID": await UserData.getuID(),
      "device_id": deviceId
    };
    try {
      setLoading(true);
      VerifyDeviceModel verifyDeviceModel = await authRepo.verifyDevice(data);
      setLoading(false);
      if (verifyDeviceModel.status == false) {
        Services.logOut();
        // Services.snackBarError(context,
        //     'Your account has been logged out because a new login was detected');
        showGeneralDialog(
            transitionBuilder: (context, a1, a2, widget) {
              final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
              return Transform(
                transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                child: Opacity(
                    opacity: a1.value,
                    child: AlertDialog(

                      title: Text('Your account has been logged out because a new login was detected',style: TextStyle(fontSize: 17.sp,),textAlign: TextAlign.center,),
                      content: SizedBox(
                        height: 8.h,
                        width: 70.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "OK",
                                style: TextStyle(color: AppColors.mainColor),
                              ),
                              style: ButtonStyle(
                                  backgroundColor:
                                  WidgetStatePropertyAll(Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )),
              );
            },
            transitionDuration: const Duration(milliseconds: 200),
            barrierDismissible: false,
            barrierLabel: '',
            context: context,
            pageBuilder: (context, animation1, animation2) {
              return Container();
            });
      }

      //
      // else {
      //  // Services.snackBarError(context, verifyDeviceModel.msg!);
      // }
    } catch (e) {
      setLoading(false);
      setError(true);
    }
  }
}
