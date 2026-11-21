import 'package:flutter/material.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';

class AppConstants {
  static const String appTitle = 'CosmoKundli';
  static const String googleMapApiKey = 'AIzaSyBtnZW2hOCC8fAN0Xc7zdCnXo5jCPJnWLM';

  static const List<int> dates = [
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
  ];

  static const List<String> genderList = ['Gender', 'Male', 'Female'];

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

  static const List<String> headers = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'
  ];

  static const List<String> chanchaHeaders = [
    'Su', 'Mo', 'Ma', 'Me', 'Ju', 'Ve', 'Sa', ' ', ' '
  ];

  static const List<String> rashiList = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  static const List<String> vargKundaliNames = [
    'Navamsha', 'Hora', 'Drekkana', 'Chaturthamsha', 'Saptamsha',
    'Dashamsha', 'Dwadashamsha', 'Shodashamsha', 'Vishamsha',
    'ChaturVishamsha', 'SaptaVishamsha', 'Trishamsha',
    'Khavedamsha', 'Akshavedamsha', 'Shashtiyamsha'
  ];

  static Map<String, Color> planetColors = {
    'Sun': AppTheme.sunColor,
    'Moon': AppTheme.moonColor,
    'Mars': AppTheme.marsColor,
    'Mercury': AppTheme.mercuryColor,
    'Jupiter': AppTheme.jupiterColor,
    'Venus': AppTheme.venusColor,
    'Saturn': AppTheme.saturnColor,
    'Rahu': AppTheme.rahuColor,
    'Ketu': AppTheme.ketuColor,
    'Ascendant': AppTheme.ascendantColor,
    'Lagan': AppTheme.ascendantColor,
  };

  static Color getPlanetColor(String? planet) {
    if (planet == null) return Colors.white;
    return planetColors[planet] ?? Colors.white;
  }
}
