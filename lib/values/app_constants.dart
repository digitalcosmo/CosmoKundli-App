import 'package:cosmo_kundali/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'images.dart';

class AppConstants {
  static const String appTitle = 'Cosmo Kundali';
  static const String googleMapApiKey =
      'AIzaSyBtnZW2hOCC8fAN0Xc7zdCnXo5jCPJnWLM';
  static const List dates = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31
  ];
  static const List<String> genderList = [
    'Gender',
    'Male',
    'Female',
  ];
  static const List<String> kundaliList = [
    'Kundali',
    'Five Fold Friendship',
    'Shadbal',
    'Varg Kundalis',
    'Ashtakvarg',
    'Chanchachakra',
    'Dasha',
    'Tara Chakra',
    'Sani Panoti'
  ];
  static const List grahs = [
    "Rahu",
    "Jupiter",
    "Saturn",
    "Mercury",
    "Ketu",
    "Venus",
    "Sun",
    "Moon",
    "Mars",
  ];

  static Map<String, Color> grah_colors = {
    'Sun': Colors.red,
    'Moon': Colors.black,
    'Mars': Colors.red,
    'Mercury': Colors.green,
    'Jupiter': Colors.orange,
    'Venus': Colors.purple,
    'Saturn': Colors.blue,
    'Rahu': Colors.grey,
    'Ketu': Colors.red,
    'Lagan': AppColors.jupiter
  };

  static const List<String> headers = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Rahu',
    'Ketu',
  ];

  static const List<String> chancha_headers = [
    'Su',
    'Mo',
    'Ma',
    'Me',
    'Ju',
    'Ve',
    'Sa',
    ' ',
    ' '
  ];

  static const List<String> sunSigns = [
    'Saturn',
    'Jupiter',
    'Mars',
    'Sun',
    'Venus',
    'Mercury',
    'Moon',
    'Lagan',
    'Total'
  ];

  static const List<String> gocharGrah = [
    'Lagan',
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Rahu',
    'Ketu'
  ];

  static const Map<String, Color> sunSign_colors = {
    'Ketu': Colors.red,
    'Saturn': Colors.blue,
    'Jupiter': Colors.orange,
    'Mars': Colors.red,
    'Sun': Colors.red,
    'Venus': Colors.purple,
    'Mercury': Colors.green,
    'Moon': Colors.black,
    'Lagan': AppColors.lagan,
  };

  static const List<String> mbAlgoTabs = [
    "Star Power - 9 Month",
    "Start Power Report",
    "Cosmo Power - 9 Month",
    "Cosmo Power Report",
    "Periodic Monthly Report",
    "Gochar Prabhav"
  ];

  static const List<String> otherTabs = [
    "Gochar (Animated)",
    "Melaapak",
  ];

  static const List<Map<String, String>> langList = [
    {
      "lan_code": "hin",
      "lan_name": "Hindi",
      "country_code": "IN",
    },
    {
      "lan_code": "guj",
      "lan_name": "Gujarati",
      "country_code": "IN",
    },
    {
      "lan_code": "en",
      "lan_name": "English",
      "country_code": "US",
    }
  ];

  static const List<Map<String, String>> iconList = [
    {
      "name": "Career",
      "icon": AppImages.career,
    },
    {
      "name": "Finance",
      "icon": AppImages.finance,
    },
    {
      "name": "Health",
      "icon": AppImages.health,
    },
    {
      "name": "Social",
      "icon": AppImages.profile,
    },
    {
      "name": "Love",
      "icon": AppImages.love,
    }
  ];

  static List<String> weekDays = [
    "monday".tr,
    "tuesday".tr,
    "wednesday".tr,
    "thursday".tr,
    "friday".tr,
    "saturday".tr,
    "sunday".tr
  ];

  static const List<String> graph_items = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
  ];

  static const List<Map<String, dynamic>> dummyResponse = [
    {
      'title': 'sun',
      'value': 99.2,
    },
    {
      'title': 'moon',
      'value': 30.2,
    },
    {
      'title': 'mars',
      'value': 90.3,
    },
    {
      'title': 'mercury',
      'value': 45,
    },
    {
      'title': 'jupiter',
      'value': 10.9,
    },
    {
      'title': 'venus',
      'value': 58.2,
    },
    {
      'title': 'saturn',
      'value': 85.2,
    },
  ];

  static Color getRowColor(String rowTitle) {
    switch (rowTitle.toLowerCase()) {
      case "saturn":
        return Colors.blue;
      case "jupiter":
        return Colors.orange;
      case "mars":
        return Colors.red;
      case "sun":
        return Colors.amber;
      case "venus":
        return Colors.pink;
      case "mercury":
        return Colors.green;
      case "moon":
        return Colors.grey;
      case "lagan":
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  static Color getBoxColor(String rowTitle) {
    switch (rowTitle.toLowerCase()) {
      case "saturn":
        return const Color(0xff0000ff);
      case "jupiter":
        return Colors.orangeAccent;
      case "mars":
        return const Color(0xffff0000);
      case "sun":
        return Colors.red;
      case "venus":
        return Colors.purple;
      case "mercury":
        return Colors.green;
      case "moon":
        return Colors.black;
      case "lagan":
        return const Color(0xffa52a2a);
      case "rahu":
        return Colors.grey;
      case "ketu":
        return const Color(0xffa52a2a);
      default:
        return Colors.black;
    }
  }

  static Map<int, String> rashiMap = {
    1: 'मेष (Aries)',
    2: 'वृषभ (Taurus)',
    3: 'मिथुन (Gemini)',
    4: 'कर्क (Cancer)',
    5: 'सिंह (Leo)',
    6: 'कन्या (Virgo)',
    7: 'तुला (Libra)',
    8: 'वृश्चिक (Scorpio)',
    9: 'धनु (Sagittarius)',
    10: 'मकर (Capricorn)',
    11: 'कुंभ (Aquarius)',
    12: 'मीन (Pisces)',
  };

  static Color periodicColor(String title) {
    switch (title.toLowerCase()) {
      case "sun":
        return Colors.orange;
      case "moon":
        return const Color(0xffc0c0c0);
      case "mars":
        return Colors.red;
      case "mercury":
        return Colors.green;
      case "jupiter":
        return Colors.yellow;
      case "venus":
        return Colors.purpleAccent;
      case "saturn":
        return const Color(0xff0000ff);
      case "rahu":
        return const Color(0xff808080);
      case "ketu":
        return const Color(0xffa52a2a);
      default:
        return Colors.black;
    }
  }
}
