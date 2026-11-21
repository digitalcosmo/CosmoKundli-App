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
  void initState() {
    super.initState();
    _ctrl.fetchCreditTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
        )),
        child: SafeArea(child: Column(children: [
          const CustomAppBar(title: 'Credit Transactions'),
          Expanded(child: Obx(() {
            if (_ctrl.isLoading.value) return const LoadingWidget();
            final data = _ctrl.creditTransactionData.value;
            if (data == null) return Center(child: Text('No data', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15.sp)));
            final items = data.list ?? [];
            return Column(children: [
              // Remaining credit header
              Padding(
                padding: EdgeInsets.all(4.w),
                child: GlassCard(
                  padding: EdgeInsets.all(4.w),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Remaining Credit: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15.sp)),
                    Text(data.remainingCredit ?? '0', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 18.sp)),
                  ]),
                ).animate().fadeIn(duration: 300.ms),
              ),
              Expanded(
                child: items.isEmpty
                  ? Center(child: Text('No transactions', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15.sp)))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final isCredit = item.type?.toLowerCase() == 'credit';
                        return GlassCard(
                          margin: EdgeInsets.only(bottom: 2.w),
                          padding: EdgeInsets.all(3.5.w),
                          child: Row(children: [
                            Container(
                              width: 10.w, height: 10.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isCredit ? Colors.green : Colors.red).withValues(alpha: 0.15),
                              ),
                              child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? Colors.green : Colors.red, size: 5.w),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.details ?? '', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14.sp)),
                              SizedBox(height: 0.5.w),
                              Text(item.date ?? '', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5.sp)),
                            ])),
                            Text('${isCredit ? '+' : '-'}${item.qty ?? '0'}', style: TextStyle(
                              color: isCredit ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600, fontSize: 15.sp,
                            )),
                          ]),
                        ).animate().fadeIn(duration: 300.ms, delay: (i * 50).ms).slideX(begin: 0.03, end: 0);
                      },
                    ),
              ),
            ]);
          })),
        ])),
      ),
    );
  }
}
