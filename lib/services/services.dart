import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/colors.dart';
import '../values/routes.dart';

class Services {
  static Future<void> to(String nextScreen) async {
    Get.toNamed(nextScreen);
  }

  static Future<void> off(BuildContext context, String nextScreen) async {
    Get.offNamed(nextScreen);
  }

  static void popUntilHomePage(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static offAll(String nextScreen) {
    Get.offAllNamed(nextScreen);
  }

  static Future<void> back() async {
    Get.back();
  }

  static snackBarSuccess(
    BuildContext context,
    String value,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: const Color(0xE610B981),
    ));
  }

  static snackBarError(
    BuildContext context,
    String value,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: const Color(0xE6EF4444),
    ));
  }

  static covertToJson(String jsonString) {
    Map<String, dynamic> a = jsonDecode(jsonString);
    return a;
  }

  static Future<bool> validateForm(GlobalKey<FormState> formKey) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return false;
    } else {
      formKey.currentState!.save();
      return true;
    }
  }

  static showConfirmDialog(
      {required BuildContext context,
      required String upperText,
      required GestureTapCallback onPressYesButton,
      double? upperTextFontSize = 20}) {
    showGeneralDialog(
        barrierColor: const Color(0x99000814),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Transform(
              transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
              child: Opacity(
                  opacity: a1.value,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        side: const BorderSide(color: CkColors.glassStroke)),
                    title: Text(
                      upperText,
                      style: TextStyle(fontSize: upperTextFontSize),
                    ),
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
                              "No",
                              style: TextStyle(color: CkColors.text),
                            ),

                          ),
                          ElevatedButton(
                            onPressed: () {
                              onPressYesButton();
                            },
                            child: const Text(
                              "Yes",
                              style: TextStyle(color: CkColors.orangeSoft, fontWeight: FontWeight.w700),
                            ),

                          ),
                        ],
                      ),
                    ),
                  )),
            ),
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

  static openBottomSheet(BuildContext context, Widget widget) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(60), // Adjust the radius as needed
        ),
      ),
      builder: (context) => widget,
      isDismissible: true,
    );
  }

  // static void showLogoutDialog(BuildContext context) {
  //   showGeneralDialog(
  //       barrierColor: CkColors.text.withOpacity(0.5),
  //       transitionBuilder: (context, a1, a2, widget) {
  //         final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
  //         return Transform(
  //           transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
  //           child: Opacity(
  //             opacity: a1.value,
  //             child: AlertDialog(
  //               title: const Text(
  //                 'Logout',
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //               backgroundColor: Colors.white,
  //               content: SizedBox(
  //                   height: 10.h,
  //                   width: 70.w,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       const Text('Are you sure you want to logout?'),
  //                       2.sbh,
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           TextButton(
  //                             onPressed: () {
  //                               Services.back();
  //                             },
  //                             child: Text(
  //                               'Cancel',
  //                               style: TextStyle(
  //                                 color: CkColors.textMuted,
  //                                 fontSize: 16.sp,
  //                               ),
  //                             ),
  //                           ),
  //                           TextButton(
  //                             onPressed: () {
  //                               Services.logOut();
  //                             },
  //                             child: Text(
  //                               'Logout',
  //                               style: TextStyle(
  //                                 color: AppColors.mainColor,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 16.sp,
  //                               ),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ],
  //                   )),
  //             ),
  //           ),
  //         );
  //       },
  //       transitionDuration: const Duration(milliseconds: 200),
  //       barrierDismissible: true,
  //       barrierLabel: '',
  //       context: context,
  //       pageBuilder: (context, animation1, animation2) {
  //         return Container();
  //       });
  // }

  static void logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    Services.offAll(AppRoutes.splashView);
  }

  // static dialNumber(String phone) async {
  //   Uri url = Uri(scheme: "tel", path: phone);
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url);
  //   } else {
  //     debugPrint("Can't open dial pad.");
  //   }
  // }

  // static Future<File?> pickSingleFile(File file) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     file = File(result.files.single.path!);
  //   }
  //   return null;
  // }

  static String formatDate(
      {required DateTime date, String format = 'yyyy-MM-dd'}) {
    DateFormat dateFormat = DateFormat(format);
    String formattedDate = dateFormat.format(date);
    return formattedDate;
  }

  static String formatPhoneNumber(String fullNumber) {
    String digitsOnly = fullNumber.replaceAll(RegExp(r'\D+'), '');
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(digitsOnly.length - 10);
    }

    return digitsOnly;
  }

  static hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static String getRashi(String name) {
    if (name.startsWith('A') ||
        name.startsWith('L') ||
        name.startsWith('E') ||
        name.startsWith('I') ||
        name.startsWith('O')) {
      return 'Mesh';
    } else if (name.startsWith('B') ||
        name.startsWith('V') ||
        name.startsWith('U') ||
        name.startsWith('W')) {
      return 'Vrishbha';
    } else if (name.startsWith('K') ||
        name.startsWith('CHH') ||
        name.startsWith('GH') ||
        name.startsWith('Q') ||
        name.startsWith('C')) {
      return 'Mithuna';
    } else if (name.startsWith('DD') || name.startsWith('H')) {
      return 'Kark';
    } else if (name.startsWith('M') || name.startsWith('TT')) {
      return 'Simha';
    } else if (name.startsWith('P') || name.startsWith('TTHH')) {
      return 'Kanya';
    } else if (name.startsWith('R') || name.startsWith('T')) {
      return 'Tula';
    } else if (name.startsWith('N') || name.startsWith('Y')) {
      return 'Vrishchik';
    } else if (name.startsWith('BH') ||
        name.startsWith('F') ||
        name.startsWith('DH')) {
      return 'Dhanu';
    } else if (name.startsWith('KH') || name.startsWith('J')) {
      return 'Makar';
    } else if (name.startsWith('G') ||
        name.startsWith('S') ||
        name.startsWith('SH')) {
      return 'Kumbh';
    } else if (name.startsWith('D') ||
        name.startsWith('CH') ||
        name.startsWith('Z') ||
        name.startsWith('TH')) {
      return 'Meen';
    } else {
      return 'Unavailable';
    }
  }

  static Color colorOfGrahs({required String type}) {
    // if(isHome == true)
    // {
    //   return AppStyles.graphDecoration(gradientColor: AppStyles.generalPrediction);
    // }
    switch (type) {
      case 'Rahu':
        return AppColors.lightgrey.withOpacity(0.1);
      case 'Jupiter':
        return AppColors.jupiter.withOpacity(0.25);
      case 'Saturn':
        return AppColors.sartun.withOpacity(0.25);
      case 'Mercury':
        return AppColors.mercury.withOpacity(0.25);
      case 'Ketu':
        return AppColors.ketu.withOpacity(0.25);
      case 'Venus':
        return AppColors.venus.withOpacity(0.25);
      case 'Sun':
        return AppColors.sun.withOpacity(0.25);
      case 'Moon':
        return AppColors.moon.withOpacity(0.25);
      case 'Mars':
        return AppColors.mars.withOpacity(0.25);
      default:
        return AppColors.lightgrey;
    }
  }

  // Value < 30 = "red";
  // Value < 40 = "orange";
  // Value < 50 = "yellow";
  // Value < 60 = "gray";
  // Value < 70 = "cyan";
  // Value < 80 = "blue";
  // Value >= 80 = "lightgreen";

  static Color cosmoGraphColor(double value) {
    if (value < 30) {
      return Colors.red;
    } else if (value < 40) {
      return Colors.orange;
    } else if (value < 50) {
      return Colors.yellow;
    } else if (value < 60) {
      return CkColors.textMuted;
    } else if (value < 70) {
      return Colors.cyan;
    } else if (value < 80) {
      return CkColors.linkBlue;
    } else {
      return Colors.lightGreen;
    }
  }

  static Color graphColors({required String type}) {
    // if(isHome == true)
    // {
    //   return AppStyles.graphDecoration(gradientColor: AppStyles.generalPrediction);
    // }
    switch (type) {
      case 'Jupiter':
        return const Color(0xffbda502);
      case 'Saturn':
        return const Color(0xff0000FE);
      case 'Mercury':
        return const Color(0xff008001);
      case 'Venus':
        return const Color(0xffFF00FE);
      case 'Sun':
        return const Color(0xffFEA500);
      case 'Moon':
        return const Color(0xffC0C0C0);
      case 'Mars':
        return const Color(0xffFE0000);
      default:
        return AppColors.lightgrey;
    }
  }

  static Color gocharColors({required double value}) {
    if (value >= 50) {
      return Colors.green;
    }
    if (value >= 30) {
      return const Color(0xfff6e84e);
    }
    if (value < 30) {
      return Colors.red;
    } else {
      return Colors.transparent;
    }
  }

  static Color gocharTextColors({required double value}) {
    if (value >= 50) {
      return Colors.green;
    }
    if (value >= 30) {
      return const Color(0xffbda502);
    }
    if (value < 30) {
      return Colors.red;
    } else {
      return Colors.transparent;
    }
  }
}
