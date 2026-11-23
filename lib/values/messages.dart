import 'package:cosmo_kundali/values/languages/tr_english.dart';
import 'package:cosmo_kundali/values/languages/tr_gujarati.dart';
import 'package:cosmo_kundali/values/languages/tr_hindi.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': TrEnglish.en,
        'hin_IN': TrHindi.hin,
        'guj_IN': TrGujarati.guj,
      };
}
