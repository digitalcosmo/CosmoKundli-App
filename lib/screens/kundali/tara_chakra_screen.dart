import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cosmo_kundli/controllers/kundali_controller.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';
import 'package:cosmo_kundli/values/get_tags.dart';
import 'package:cosmo_kundli/widgets/glass_card.dart';
import 'package:cosmo_kundli/widgets/app_bar_widget.dart';
import 'package:cosmo_kundli/widgets/loading_widget.dart';

class TaraChakraScreen extends StatefulWidget {
  const TaraChakraScreen({super.key});
  @override
  State<TaraChakraScreen> createState() => _TaraChakraScreenState();
}

class _TaraChakraScreenState extends State<TaraChakraScreen> {
  final KundaliController _ctrl = Get.find(tag: GetTags.kundaliTag);

  @override
  void initState() {
    super.initState();
    if (!_ctrl.isTaraChakraApiCalled) _ctrl.taraChakraApiCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppTheme.bgPrimary, AppTheme.bgSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Tara Chakra'),
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value || _ctrl.taraChakraData == null) {
                    return const LoadingWidget();
                  }
                  final items = _ctrl.taraChakraData!.list ?? [];
                  if (items.isEmpty) {
                    return Center(child: Text('No data', style: AppTheme.bodyMedium));
                  }

                  int maxNak = 1;
                  for (var item in items) {
                    final count = item.nakshatra?.split(',').length ?? 0;
                    if (count > maxNak) maxNak = count;
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: GlassCard(
                      padding: EdgeInsets.all(2.w),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 14,
                          dataRowMinHeight: 32,
                          dataRowMaxHeight: 42,
                          headingRowColor: WidgetStatePropertyAll(
                            AppTheme.gmHighlight.withOpacity(0.1),
                          ),
                          border: TableBorder.all(color: AppTheme.gmBorder, width: 0.5),
                          columns: [
                            DataColumn(label: Text('Tara', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700))),
                            ...List.generate(maxNak, (i) => DataColumn(
                              label: Text(i == 0 ? 'Nakshatra' : '', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                            )),
                          ],
                          rows: items.map((item) {
                            final nakshatras = item.nakshatra?.split(',') ?? [];
                            final cells = <DataCell>[
                              DataCell(Text(item.tara ?? '', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600))),
                            ];
                            for (int i = 0; i < maxNak; i++) {
                              cells.add(DataCell(Text(
                                i < nakshatras.length ? nakshatras[i].trim() : '',
                                style: AppTheme.bodySmall,
                              )));
                            }
                            return DataRow(cells: cells);
                          }).toList(),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
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
