

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../ui/ck_theme.dart';
import '../ui/glass.dart';

class MainLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const MainLoader({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      color: const Color(0xFF000814),
      opacity: .35,
      progressIndicator: const Glass(
        width: 72,
        height: 72,
        radius: 22,
        tint: Color(0x330E2F66),
        alignment: Alignment.center,
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
              strokeWidth: 2.6, color: CkColors.orangeSoft),
        ),
      ),
      child: child,
    );
  }
}

