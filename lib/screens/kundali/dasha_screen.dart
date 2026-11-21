import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/models/dasha_model.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class DashaScreen extends StatefulWidget {
  const DashaScreen({super.key});
  @override
  State<DashaScreen> createState() => _DashaScreenState();
}

class _DashaScreenState extends State<DashaScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);

  @override
  void initState() {
    super.initState();
    if (!_ctrl.isDashaApiCalled.value) _ctrl.getDasha();
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppTheme.textPrimary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.textPrimary;
    }
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
          const CustomAppBar(title: 'Dasha'),
          Expanded(child: Obx(() {
            if (_ctrl.isLoading.value || _ctrl.dashaData.value == null) return const LoadingWidget();
            final d = _ctrl.dashaData.value!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(children: [
                // Balance header
                GlassCard(
                  padding: EdgeInsets.all(4.w),
                  child: Column(children: [
                    Text('Dasha Balance', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp)),
                    SizedBox(height: 1.w),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(d.dashaBalanceGrah ?? '', style: TextStyle(color: _parseColor(d.dashaBalanceColor), fontWeight: FontWeight.w700, fontSize: 18.sp)),
                      SizedBox(width: 2.w),
                      Text(d.dashaBalance ?? '', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15.sp)),
                    ]),
                    SizedBox(height: 2.w),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _subGrahChip(d.subGrah1, d.subGrahColor1),
                      SizedBox(width: 2.w),
                      _subGrahChip(d.subGrah2, d.subGrahColor2),
                      SizedBox(width: 2.w),
                      _subGrahChip(d.subGrah3, d.subGrahColor3),
                    ]),
                  ]),
                ).animate().fadeIn(duration: 300.ms),
                SizedBox(height: 3.w),
                // Dasha periods
                ...List.generate(d.list?.length ?? 0, (i) {
                  final dasha = d.list![i];
                  return _buildDashaTile(dasha, i);
                }),
              ]),
            );
          })),
        ])),
      ),
    );
  }

  Widget _subGrahChip(String? name, String? color) {
    if (name == null || name.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _parseColor(color).withValues(alpha: 0.5)),
        color: _parseColor(color).withValues(alpha: 0.15),
      ),
      child: Text(name, style: TextStyle(color: _parseColor(color), fontSize: 13.sp, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildDashaTile(DashaList dasha, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.w),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
            childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
            title: Text(dasha.title ?? '', style: TextStyle(color: _parseColor(dasha.color), fontWeight: FontWeight.w600, fontSize: 15.sp)),
            iconColor: AppTheme.textSecondary,
            collapsedIconColor: AppTheme.textSecondary,
            children: (dasha.list ?? []).map((grah) => _buildGrahRow(grah)).toList(),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 60).ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildGrahRow(GrahList grah) {
    final rows = grah.rows.where((r) => r != null).toList();
    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(grah.grah ?? '', style: TextStyle(color: _parseColor(grah.color), fontWeight: FontWeight.w600, fontSize: 14.sp)),
          Text('${grah.start ?? ''} - ${grah.end ?? ''}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5.sp)),
        ]),
        if (rows.isNotEmpty) ...[
          SizedBox(height: 1.5.w),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(top: 0.8.w),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r!.grah ?? '', style: TextStyle(color: _parseColor(r.color), fontSize: 13.sp)),
              Text('${r.start ?? ''} - ${r.end ?? ''}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
            ]),
          )),
        ],
      ]),
    );
  }
}
