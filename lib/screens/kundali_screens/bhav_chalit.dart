import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:flutter/material.dart';

import 'bhav_chalit_kundali.dart';

class BhavChalit extends StatelessWidget {
  const BhavChalit({super.key});

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Center(child: BhavChalitKundali()),
    );
  }
}
