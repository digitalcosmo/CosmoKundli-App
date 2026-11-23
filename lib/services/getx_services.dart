import 'package:cosmo_kundali/controllers/kundali_controller.dart';
import 'package:get/get.dart';
import '../controllers/auth_controllers/signIn_controller.dart';
import '../controllers/auth_controllers/signUp_controller.dart';
import '../controllers/clientdetail_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/mbAlgo_controller.dart';
import '../controllers/other_controller.dart';
import '../controllers/profile_controller.dart';
import '../values/get_tags.dart';

class ServiceController {

  static void initControllers() {
    final  signInController = Get.lazyPut(() => SignInController(), tag: GetTags.signInTag);
    final  signUpController = Get.lazyPut(() => SignUnController(), tag: GetTags.signUpTag);
    final  clientdetailController = Get.lazyPut(() => ClientDetailController(), tag: GetTags.clientDetailTag);
    final  homeController = Get.lazyPut(() => HomeController(), tag: GetTags.homeTag);
    final  kundaliController = Get.lazyPut(() => KundaliController(), tag: GetTags.kundaliTag);
    final  languageController = Get.lazyPut(() => LanguageController(), tag: GetTags.langTag);
    final  mbalgoController = Get.lazyPut(() => MbalgoController(), tag: GetTags.mbAlgoTag);
    final  profileController = Get.lazyPut( ()=> ProfileController(),tag: GetTags.profileTag);
    final  otherController = Get.lazyPut( ()=> OtherController(),tag: GetTags.otherTag);

  }
}
