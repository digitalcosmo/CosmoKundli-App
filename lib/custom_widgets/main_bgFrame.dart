import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../ui/glass.dart';

class MainBgframe extends StatelessWidget {
  final Widget child;
  const MainBgframe({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(15.sp),
          child: child,
        ),
      ),
    );
  }
}
