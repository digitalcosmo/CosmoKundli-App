import 'package:flutter/cupertino.dart';

class GraphModel {
  String title;
  String icon;
  String level;
  double count;
  BoxDecoration boxDecoration;

  GraphModel(
      {required this.title,
      required this.icon,
      required this.level,
      required this.count,
      required this.boxDecoration});
}
