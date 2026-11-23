import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'package:cosmo_kundali/models/shadbal_graph.dart';
import 'package:cosmo_kundali/services/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:d_chart/bar_custom/view.dart';
import 'package:flutter/material.dart';

class MainGraph extends StatelessWidget {
  final ShabdalGraphModel graphModel;

  const MainGraph({super.key, required this.graphModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 9.w),
      child: SizedBox(
        height: 20.h,
        width: 100.w,
        child: DChartBarCustom(
          showMeasureLine: true,
          // valuePadding: EdgeInsets.all(10.sp),
          loadingDuration: const Duration(milliseconds: 1500),
          showLoading: false,
          valueAlign: Alignment.bottomCenter,
          showDomainLabel: true,
          spaceDomainLabeltoChart: 10,
          spaceMeasureLabeltoChart: 15,
          spaceMeasureLinetoChart: 15,
          spaceBetweenItem: 10,
          max: 100.0,
          domainLabelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          showDomainLine: true,
          listData: List.generate(
            graphModel.list!.length,
            (index) {
              return DChartBarDataCustom(
                value: double.parse(graphModel.list![index].value.toString()),
                label: graphModel.list![index].title.toString(),
                labelCustom: SizedBox(
                  width: 20.w,
                  child: Text(
                    graphModel.list![index].title.toString(),
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 14.sp,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                barDecoration: BoxDecoration(
                  color: Services.graphColors(
                      type: graphModel.list![index].title
                          .toString()
                          .capitalizeFirst
                          .toString()),
                ),
                showValue: true,
                valueCustom: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Text(
                        graphModel.list![index].value.toString(),
                        style: TextStyle(
                            color: CkColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
                valueStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
