import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/screens/kundali_screens/navmansh_kundali.dart';
import 'package:flutter/material.dart';


class Navmansh extends StatelessWidget {
  const Navmansh({super.key});

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Center(child: NavmanshKundali()),
    );
  }
}
