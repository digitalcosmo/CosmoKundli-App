import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'package:cosmo_kundali/custom_widgets/main_bgFrame.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/profile_controller.dart';
import '../../services/services.dart';
import '../../values/get_tags.dart';
import '../../values/images.dart';

class TransactionHistory extends StatefulWidget {
  TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final ProfileController profileController = Get.put(ProfileController(),tag: GetTags.profileTag);



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.fetchCreditTransactions();
  }

  @override
  Widget build(BuildContext context) {

    return MainBgframe(
      child: Obx(
        ()=> Container(
          padding: EdgeInsets.all(11.sp),
          child:
          profileController.transactionList.value.isEmpty || profileController.creditTransaction != null?
          Column(children: [
            SizedBox(
              height: 5.h,
            ),
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Services.back();
                    },
                    child: Image.asset(
                      AppImages.previousGradient,
                      width: 5.w,
                      height: 5.h,
                    )),
                SizedBox(
                  width: 2.w,
                ),
                Text(
                  "transaction_history".tr,
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
                )
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("remaining_credit".tr+": ",style: TextStyle( fontSize: 17.sp),),
                SizedBox(
                  child: Text(profileController.creditTransaction?.remainingCredit ?? '0',
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),),
                ),
              ],
            ),
            SizedBox(
              height: 3.h,
            ),
             Obx(
               ()=> profileController.transactionList.value.isEmpty ?
                  SizedBox():
                         Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 20.sp,
                      dataRowHeight: 32.sp,
                      horizontalMargin: 10.sp,
                      headingRowColor: MaterialStateProperty.all(CkColors.text.withOpacity(0.25)),
                      border: TableBorder.all(
                        color: CkColors.text.withOpacity(0.50),
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      columns: [
                        DataColumn(label: Text("Date".tr)),
                        DataColumn(label: Text("Details".tr)),
                        DataColumn(label: Text("Type".tr)),
                        DataColumn(label: Text("Qty".tr)),

                      ],
                      rows: profileController.transactionList.map((report) {
                        return DataRow(cells: [
                          DataCell(SizedBox(
                            width: 25.w,
                            child: Text(
                              report.date.toString(),
                              softWrap: true,
                            ),
                          )),
                          DataCell(SizedBox(
                            width: 27.w,
                            child: Text(
                              report.details.toString(),
                              softWrap: true,
                            ),
                          )),
                          DataCell(Text(report.type.toString())),
                          DataCell(Text(report.qty.toString())),

                        ]);
                      }).toList(),
                    ),
                  ),
                ),
                         ),
             ),
          ])
          :Center(child: SingleChildScrollView(),),
        ),
      ),
    );
  }
}

class Report {
  final String date;
  final String details;
  final String type;
  final int qty;

  Report(
      {required this.date,
      required this.details,
      required this.type,
      required this.qty});
}
