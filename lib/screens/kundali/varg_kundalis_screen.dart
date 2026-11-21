import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/values/app_constants.dart';
import 'package:cosmo_kundli/values/urls.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';
import 'package:cosmo_kundli/widgets/kundali_chart_widget.dart';

class VargKundalisScreen extends StatefulWidget {
  const VargKundalisScreen({super.key});
  @override
  State<VargKundalisScreen> createState() => _VargKundalisScreenState();
}

class _VargKundalisScreenState extends State<VargKundalisScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);
  int _selectedIndex = 0;

  static final List<Map<String, String>> _vargList = [
    {'name': 'Navamsha', 'url': AppUrls.navamsha},
    {'name': 'Hora', 'url': AppUrls.hora},
    {'name': 'Drekkana', 'url': AppUrls.drekkana},
    {'name': 'Chaturthamsha', 'url': AppUrls.chaturthamsha},
    {'name': 'Saptamsha', 'url': AppUrls.saptamsha},
    {'name': 'Dashamsha', 'url': AppUrls.dashamsha},
    {'name': 'Dwadashamsha', 'url': AppUrls.dwadashamsha},
    {'name': 'Shodashamsha', 'url': AppUrls.shodashamsha},
    {'name': 'Vishamsha', 'url': AppUrls.vishamsha},
    {'name': 'ChaturVishamsha', 'url': AppUrls.chaturVishamsha},
    {'name': 'SaptaVishamsha', 'url': AppUrls.saptaVishamsha},
    {'name': 'Trishamsha', 'url': AppUrls.trishamsha},
    {'name': 'Khavedamsha', 'url': AppUrls.khavedamsha},
    {'name': 'Akshavedamsha', 'url': AppUrls.akshavedamsha},
    {'name': 'Shashtiyamsha', 'url': AppUrls.shashtiyamsha},
  ];

  @override
  void initState() {
    super.initState();
    _loadVarg(0);
  }

  void _loadVarg(int index) {
    setState(() => _selectedIndex = index);
    _ctrl.vargKundalis(_vargList[index]['url']!);
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
          const CustomAppBar(title: 'Varg Kundalis'),
          // Selector
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
            child: GlassCard(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
              child: DropdownButton<int>(
                value: _selectedIndex,
                isExpanded: true,
                dropdownColor: AppTheme.bgPrimary,
                underline: const SizedBox(),
                iconEnabledColor: AppTheme.textSecondary,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 15.sp),
                items: List.generate(_vargList.length, (i) => DropdownMenuItem(
                  value: i,
                  child: Text(_vargList[i]['name']!, style: TextStyle(color: AppTheme.textPrimary, fontSize: 15.sp)),
                )),
                onChanged: (v) { if (v != null) _loadVarg(v); },
              ),
            ),
          ),
          // Chart
          Expanded(child: Obx(() {
            if (_ctrl.isLoading.value) return const LoadingWidget();
            final data = _ctrl.vargKundalisData.value;
            if (data == null || data.kundaliModel == null || data.kundaliModel!.isEmpty) {
              return Center(child: Text('Select a Varg to view', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15.sp)));
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(children: [
                GlassCard(
                  padding: EdgeInsets.all(3.w),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: KundaliChartWidget(planets: data.kundaliModel!),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                SizedBox(height: 3.w),
                // Planet details table
                GlassCard(
                  padding: EdgeInsets.all(3.w),
                  child: Table(
                    border: TableBorder.all(color: AppTheme.glassBorder, width: 0.5),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06)),
                        children: [_header('Planet'), _header('Rashi'), _header('Degree')],
                      ),
                      ...data.kundaliModel!.map((p) => TableRow(children: [
                        _planetCell(p.name ?? '', p.color),
                        _cell(p.rashi ?? ''),
                        _cell(p.degree ?? ''),
                      ])),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),
              ]),
            );
          })),
        ])),
      ),
    );
  }

  Widget _header(String t) => Padding(padding: EdgeInsets.all(2.5.w), child: Text(t, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.sp)));
  Widget _cell(String t) => Padding(padding: EdgeInsets.all(2.5.w), child: Text(t, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5.sp)));
  Widget _planetCell(String name, String? color) {
    Color c = AppTheme.textPrimary;
    if (color != null && color.isNotEmpty) {
      try { c = Color(int.parse(color.replaceFirst('#', '0xFF'))); } catch (_) {}
    }
    return Padding(padding: EdgeInsets.all(2.5.w), child: Text(name, style: TextStyle(color: c, fontWeight: FontWeight.w500, fontSize: 13.5.sp)));
  }
}
