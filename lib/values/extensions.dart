import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

extension DoubleExtension on double {
  double firstTwoDigits() {
    return double.parse(toStringAsFixed(2));
  }
}

extension SizedBoxExtension on num
{

  SizedBox get sbh => SizedBox(height:toDouble().h);

  SizedBox get sbw => SizedBox(width:toDouble().w);

}


extension StringExtension on String {

  String firstTwoLetter() {
    if (this.length < 2) return this.capitalizeFirst!; // handle short strings
    return this.substring(0, 2).capitalizeFirst!;
  }

}
