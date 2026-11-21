import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/profile_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class CreditTransactionScreen extends StatefulWidget {
  const CreditTransactionScreen({super.key});
  @override
  State<CreditTransactionScreen> createState() => _CreditTransactionScreenState();
}

class _CreditTransactionScreenState extends State<CreditTransactionScreen> {
  final ProfileController _ctrl = Get.find(tag: GetTags.profileTag);

  @override
  void initState() { super.initState(); _ctrl.fetchCreditTransactions(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.bgPrimary, AppTheme.bgSecondary]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Credit Transactions'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value) return const LoadingWidget();
                  if (_ctrl.transactionList.isEmpty) {
                    return Center(child: Text('No transactions', style: AppTheme.bodyMedium));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: _ctrl.transactionList.length,
                    itemBuilder: (_, i) {
                      final item = _ctrl.transactionList[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: GlassCard(
                          padding: EdgeInsets.all(3.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['Description'] ?? '', style: AppTheme.bodyMedium),
                                  SizedBox(height: 0.5.h),
                                  Text(item['Date'] ?? '', style: AppTheme.labelSmall.copyWith(color: Colors.white38)),
                                ],
                              ),
                              Text(
                                '${item['Credit'] ?? 0}',
                                style: AppTheme.headingSmall.copyWith(
                                  color: (item['Credit'] ?? 0) > 0 ? Colors.greenAccent : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: (50 * i).ms).fadeIn(duration: 300.ms),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
