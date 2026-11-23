import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../models/five_fold_relationship_model.dart';

class MainTable extends StatelessWidget {
  final Map<String, Color> colors;
  final List<String> headers;
  final List<PlanetInfo> planetData;
  final String header;

  const MainTable({
    super.key,
    required this.colors,
    required this.headers,
    required this.planetData,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    // Extract planet names and corresponding property values as columns
    List<String> planetNames = planetData.map((e) => e.planet).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed property column
        DataTable(
          dataRowHeight: 26.sp,
          columnSpacing: 24.sp,
          border: TableBorder.all(color: CkColors.glassStroke, width: 4.sp),
          columns: [
            DataColumn(label: Text(header)),
          ],
          rows: planetData.map((planetInfo) {
            return DataRow(
              cells: [
                DataCell(Text(
                  planetInfo.planet,
                  style: TextStyle(
                    color: colors[planetInfo.planet],
                    fontWeight: FontWeight.w600,
                  ),
                )),
              ],
            );
          }).toList(),        ),
        // Scrollable section for planets as columns
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24.sp,
              dataRowHeight: 26.sp,
              border: TableBorder.all(color: CkColors.glassStroke, width: 4.sp),
              columns: planetNames.map((planetName) {
                return DataColumn(
                  label: Text(
                    planetName,
                    style: TextStyle(
                      color: colors[planetName],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              rows: headers.map((property) {
                return DataRow(
                  cells: planetData.map((planetInfo) {
                    switch (property.toLowerCase()) {
                      case 'sun':
                        return DataCell(Text(planetInfo.planets.sun));
                      case 'moon':
                        return DataCell(Text(planetInfo.planets.moon));
                      case 'mars':
                        return DataCell(Text(planetInfo.planets.mars));
                      case 'mercury':
                        return DataCell(Text(planetInfo.planets.mercury));
                      case 'jupiter':
                        return DataCell(Text(planetInfo.planets.jupiter));
                      case 'venus':
                        return DataCell(Text(planetInfo.planets.venus));
                      case 'saturn':
                        return DataCell(Text(planetInfo.planets.saturn));
                      case 'rahu':
                        return DataCell(Text(planetInfo.planets.rahu));
                      case 'ketu':
                        return DataCell(Text(planetInfo.planets.ketu));
                      default:
                        return DataCell(Text(''));
                    }
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}


//
// return SingleChildScrollView(
//   child: Column(
//     children: [
//       Row(
//         children: [
//           Image.asset(
//             AppImages.kundali,
//             height: 5.h,
//             width: 5.w,
//             color: AppColors.headerColor,
//           ),
//           SizedBox(
//             width: 2.w,
//           ),
//           Text(
//             "sun".tr,
//             style: TextStyle(
//                 fontSize: 17.sp,
//                 color: AppColors.headerColor,
//                 fontWeight: FontWeight.w500),
//           )
//         ],
//       ),
//       SizedBox(
//         height: 2.h,
//       ),
//       DataTable(
//         border: TableBorder.all(color: CkColors.glassStroke),
//         columns: [
//           DataColumn(
//             label: Container(
//               padding: EdgeInsets.all(8.0),
//               color: AppColors.headerColor,
//               child: Text(
//                 headers[0],
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           ...headers.sublist(1).map((header) {
//             return DataColumn(
//               label: Text(
//                 header,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             );
//           }).toList(),
//         ],
//         rows: rowsData.map((row) {
//           return DataRow(
//             cells: [
//               DataCell(
//                 Container(
//                   padding: EdgeInsets.all(8.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: CkColors.glassStroke),
//                   ),
//                   child: Text(
//                     row[0],
//                     style: TextStyle(
//                       color: _getRowColor(row[0]),
//                     ),
//                   ),
//                 ),
//               ),
//               ...row.sublist(1).map((cell) {
//                 return DataCell(
//                   Text(cell),
//                 );
//               }).toList(),
//             ],
//           );
//         }).toList(),
//       ),
//       SizedBox(
//         height: 2.h,
//       ),
//       Image.asset(AppImages.kundaliImage)
//     ],
//   ),
// );

