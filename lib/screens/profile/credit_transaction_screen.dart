import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/profile_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class CreditTransactionScreen extends StatelessWidget {
  CreditTransactionScreen({super.key});

  final controller = Get.find<ProfileController>(tag: GetTags.profileTag);

  @override
  Widget build(BuildContext context) {
    controller.fetchCreditTransactions();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                    ),
                    Text('Credit Transactions', style: AppTheme.headingLarge),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) return const LoadingWidget();

                  final transactions = controller.creditTransactions;
                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
                          SizedBox(height: 2.h),
                          Text('No transactions found', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isCredit = (tx['type'] ?? '').toString().toLowerCase() == 'credit';
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: GlassCard(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isCredit ? AppTheme.mercuryColor : AppTheme.error).withOpacity(0.15),
                                ),
                                child: Icon(
                                  isCredit ? Icons.add : Icons.remove,
                                  color: isCredit ? AppTheme.mercuryColor : AppTheme.error,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx['description'] ?? tx['remark'] ?? 'Transaction',
                                      style: AppTheme.bodyMedium,
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tx['date'] ?? tx['createdDate'] ?? '',
                                      style: AppTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCredit ? '+' : '-'}${tx['amount'] ?? tx['credits'] ?? '0'}',
                                style: AppTheme.headingSmall.copyWith(
                                  color: isCredit ? AppTheme.mercuryColor : AppTheme.error,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate(delay: Duration(milliseconds: 100 + index * 40))
                          .fadeIn(duration: 300.ms);
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
