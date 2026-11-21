import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/routes.dart';
import 'package:cosmo_kundli/screens/auth/splash_screen.dart';
import 'package:cosmo_kundli/screens/auth/login_screen.dart';
import 'package:cosmo_kundli/screens/auth/sign_up_screen.dart';
import 'package:cosmo_kundli/screens/home/home_screen.dart';
import 'package:cosmo_kundli/screens/client_detail/client_list_screen.dart';
import 'package:cosmo_kundli/screens/client_detail/add_client_screen.dart';
import 'package:cosmo_kundli/screens/kundali/birth_kundli_screen.dart';
import 'package:cosmo_kundli/screens/kundali/five_fold_screen.dart';
import 'package:cosmo_kundli/screens/kundali/shadbal_screen.dart';
import 'package:cosmo_kundli/screens/kundali/varg_kundalis_screen.dart';
import 'package:cosmo_kundli/screens/kundali/ashtak_varg_screen.dart';
import 'package:cosmo_kundli/screens/kundali/chancha_chakra_screen.dart';
import 'package:cosmo_kundli/screens/kundali/dasha_screen.dart';
import 'package:cosmo_kundli/screens/kundali/tara_chakra_screen.dart';
import 'package:cosmo_kundli/screens/kundali/sani_panoti_screen.dart';
import 'package:cosmo_kundli/screens/kundali/grah_coordinates_screen.dart';
import 'package:cosmo_kundli/screens/mb_algo/star_power_screen.dart';
import 'package:cosmo_kundli/screens/mb_algo/cosmo_power_screen.dart';
import 'package:cosmo_kundli/screens/mb_algo/periodic_monthly_screen.dart';
import 'package:cosmo_kundli/screens/mb_algo/gochar_prabhav_screen.dart';
import 'package:cosmo_kundli/screens/mb_algo/gochar_table_screen.dart';
import 'package:cosmo_kundli/screens/others/melapak_screen.dart';
import 'package:cosmo_kundli/screens/others/melapak_details_screen.dart';
import 'package:cosmo_kundli/screens/others/melapak_new_user_screen.dart';
import 'package:cosmo_kundli/screens/profile/profile_screen.dart';
import 'package:cosmo_kundli/screens/profile/display_details_screen.dart';
import 'package:cosmo_kundli/screens/profile/app_details_screen.dart';
import 'package:cosmo_kundli/screens/profile/change_password_screen.dart';
import 'package:cosmo_kundli/screens/profile/credit_transaction_screen.dart';
import 'package:cosmo_kundli/screens/profile/report_history_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const CosmoKundliApp());
  });
}

class CosmoKundliApp extends StatelessWidget {
  const CosmoKundliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          title: 'CosmoKundli',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splash,
          getPages: [
            GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
            GetPage(name: AppRoutes.login, page: () => LoginScreen()),
            GetPage(name: AppRoutes.signUp, page: () => SignUpScreen()),
            GetPage(name: AppRoutes.home, page: () => HomeScreen()),
            GetPage(name: AppRoutes.clientList, page: () => ClientListScreen()),
            GetPage(name: AppRoutes.addClient, page: () => AddClientScreen()),
            GetPage(name: AppRoutes.editClient, page: () => AddClientScreen()),
            GetPage(name: AppRoutes.birthKundli, page: () => BirthKundliScreen()),
            GetPage(name: AppRoutes.fiveFold, page: () => FiveFoldScreen()),
            GetPage(name: AppRoutes.shadbal, page: () => ShadbalScreen()),
            GetPage(name: AppRoutes.vargKundalis, page: () => VargKundalisScreen()),
            GetPage(name: AppRoutes.ashtakVarg, page: () => AshtakVargScreen()),
            GetPage(name: AppRoutes.chanchaChakra, page: () => ChanchaChakraScreen()),
            GetPage(name: AppRoutes.dasha, page: () => DashaScreen()),
            GetPage(name: AppRoutes.taraChakra, page: () => TaraChakraScreen()),
            GetPage(name: AppRoutes.saniPanoti, page: () => SaniPanotiScreen()),
            GetPage(name: AppRoutes.grahCoordinates, page: () => GrahCoordinatesScreen()),
            GetPage(name: AppRoutes.starPower, page: () => StarPowerScreen()),
            GetPage(name: AppRoutes.cosmoPower, page: () => CosmoPowerScreen()),
            GetPage(name: AppRoutes.periodicMonthly, page: () => PeriodicMonthlyScreen()),
            GetPage(name: AppRoutes.gocharPrabhav, page: () => GocharPrabhavScreen()),
            GetPage(name: AppRoutes.gocharTable, page: () => GocharTableScreen()),
            GetPage(name: AppRoutes.melapak, page: () => MelapakScreen()),
            GetPage(name: AppRoutes.melapakDetails, page: () => MelapakDetailsScreen()),
            GetPage(name: AppRoutes.melapakNewUser, page: () => MelapakNewUserScreen()),
            GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
            GetPage(name: AppRoutes.displayDetails, page: () => DisplayDetailsScreen()),
            GetPage(name: AppRoutes.appDetails, page: () => AppDetailsScreen()),
            GetPage(name: AppRoutes.changePassword, page: () => ChangePasswordScreen()),
            GetPage(name: AppRoutes.creditTransaction, page: () => CreditTransactionScreen()),
            GetPage(name: AppRoutes.reportHistory, page: () => ReportHistoryScreen()),
          ],
        );
      },
    );
  }
}
