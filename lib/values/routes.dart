import 'package:cosmo_kundali/screens/home/edit_clients.dart';
import 'package:cosmo_kundali/screens/other_screens/ashatkoot_melapak.dart';
import 'package:cosmo_kundali/screens/auth/signIn_screen.dart';
import 'package:cosmo_kundali/screens/clientdetail_form.dart';
import 'package:cosmo_kundali/screens/existing_client.dart';
import 'package:cosmo_kundali/screens/other_screens/existing_user.dart';
import 'package:cosmo_kundali/screens/bottom_pages/kundali_screen.dart';
import 'package:cosmo_kundali/screens/kundali_screens/birth_planet_info.dart';
import 'package:cosmo_kundali/screens/kundali_screens/chancha_kundali.dart';
import 'package:cosmo_kundali/screens/bottom_pages/mb_algo.dart';
import 'package:cosmo_kundali/screens/profile_screens/app_details.dart';
import 'package:cosmo_kundali/screens/profile_screens/change_language.dart';
import 'package:cosmo_kundali/screens/profile_screens/change_password.dart';
import 'package:cosmo_kundali/screens/profile_screens/display_detail.dart';
import 'package:cosmo_kundali/screens/profile_screens/edit_profile.dart';
import 'package:cosmo_kundali/screens/profile_screens/reset_password.dart';
import 'package:cosmo_kundali/screens/profile_screens/transaction_history.dart';
import 'package:cosmo_kundali/screens/profile_screens/update_password.dart';
import 'package:cosmo_kundali/screens/spalsh_screen.dart';
import 'package:get/get.dart';
import '../screens/auth/signUp_screen.dart';
import '../screens/bottom_pages/contain_view.dart';
import '../screens/kundali_screens/bhav_chalit_kundali.dart';
import '../screens/kundali_screens/navmansh_kundali.dart';
import '../screens/kundali_screens/vimshottari_view.dart';
import '../screens/profile_screens/report_history.dart';

class AppRoutes {
  static List<GetPage<dynamic>> routeList = [
    GetPage(name: splashView, page: () => const SpalshScreen()),
    GetPage(name: signUpView, page: () => SignupScreen()),
    GetPage(name: signInView, page: () => SignInScreen()),
    GetPage(name: clientDetailView, page: () => ClientDetailForm()),
    GetPage(name: clientListView, page: () => const ExistingClientScreen()),
    GetPage(
        name: containView,
        page: () => ContainView(
              index: 1.obs,
            )),
    GetPage(name: kundaliView, page: () => KundaliScreen()),
    GetPage(name: chanchakundaliView, page: () => ChanchaKundali()),
    GetPage(name: mbAlgoView, page: () => MbAlgo()),
    GetPage(name: existingUserView, page: () => ExistingUserMelaPak()),
    GetPage(name: ashtkootMelapakView, page: () => AshatkootMelapak()),
    GetPage(name: editProfile, page: () => EditProfile()),
    GetPage(name: displayDetails, page: () => DisplayDetail()),
    GetPage(name: appDetails, page: () => AppDetails()),
    GetPage(name: transactionHistory, page: () => TransactionHistory()),
    GetPage(name: reportHistory, page: () => ReportHistory()),
    GetPage(name: changePassword, page: () => ChangePassword()),
    GetPage(name: resetPassword, page: () => ResetPassword()),
    GetPage(name: updatePassword, page: () => UpdatePassword()),
    GetPage(name: changeLanguage, page: () => ChangeLanguage()),
    GetPage(name: clientListView, page: () => ExistingClientScreen()),
    GetPage(name: birthPlanetInfo, page: () => BirthPlanetInfo()),
    GetPage(name: bhavChaitKundali, page: () => BhavChalitKundali()),
    GetPage(name: navamanshKundali, page: () => NavmanshKundali()),
    GetPage(name: vimshottariView, page: () => VimshottariView()),
    GetPage(name: editClientsView, page: () => EditClients()),
  ];

  static const String splashView = '/splashView';
  static const String signUpView = '/signUpView';
  static const String signInView = '/signInView';
  static const String clientDetailView = '/clientDetailView';
  static const String clientListView = '/clientListView';
  static const String containView = '/containView';
  static const String kundaliView = '/kundaliView';
  static const String chanchakundaliView = '/chanchakundaliView';
  static const String mbAlgoView = '/mbAlgoView';
  static const String existingUserView = '/existingUserView';
  static const String ashtkootMelapakView = '/ashtkootMelapakView';
  static const String editProfile = '/editProfile';
  static const String displayDetails = '/displayDetails';
  static const String appDetails = '/appDetails';
  static const String transactionHistory = '/transactionHistory';
  static const String reportHistory = '/reportHistory';
  static const String changePassword = '/changePassword';
  static const String resetPassword = '/resetPassword';
  static const String updatePassword = '/updatePassword';
  static const String changeLanguage = '/changeLanguage';
  static const String birthPlanetInfo = '/birthPlanetInfo';
  static const String bhavChaitKundali = '/bhavChalit';
  static const String navamanshKundali = '/navamansh';
  static const String vimshottariView = '/vimshottariView';
  static const String editClientsView = '/editClientsView';
}
