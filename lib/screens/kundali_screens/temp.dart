import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:convert';

import 'package:cosmo_kundali/controllers/home_controller.dart';
import 'package:cosmo_kundali/values/get_tags.dart';
import 'package:cosmo_kundali/values/images.dart';
import 'package:cosmo_kundali/values/styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:responsive_sizer/responsive_sizer.dart';

// Common Kundali Widget
class KundaliWidget extends StatefulWidget {
  final String mid;
  final Widget? backgroundImage; // Optional background image
  final double height; // Customizable height
  final double? width; // Optional width

  const KundaliWidget({
    super.key,
    required this.mid,
    this.backgroundImage,
    this.height = 47.0,
    this.width,
  });

  @override
  State<KundaliWidget> createState() => _KundaliWidgetState();
}

class _KundaliWidgetState extends State<KundaliWidget> {
  final List<KundaliModel> planetsData = [];
  Map<int, int> rashiToGharMapping = {};
  final HomeController homeController = Get.find(tag: GetTags.homeTag);

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        getKundaliData();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double canvasParentWidth = constraints.maxWidth - 10;
        return Center(
          child: SizedBox(
            height: widget.height.h,
            width: widget.width?.w ?? 100.w,
            child: CustomPaint(
              size: Size(canvasParentWidth, canvasParentWidth),
              painter: CanvasPainter(
                planetsData: planetsData,
                rashiToGharMapping: rashiToGharMapping,
              ),
              child: widget.backgroundImage != null
                  ? Padding(
                      padding: EdgeInsets.all(35.sp),
                      child: Opacity(
                        opacity: 0.3,
                        child: widget.backgroundImage,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  void getKundaliData() async {
    try {
      Dio dio = Dio();
      Map<String, dynamic> data = {'mID': widget.mid};
      debugPrint('Rashi Data $data');

      Response response = await dio.post(
        'https://software.cosmokundli.com/API/BirthChart',
        data: data,
      );

      List<dynamic> planets = response.data['planets'];
      Map<String, dynamic>? asPlanet =
          planets.firstWhere((planet) => planet['planet'] == 'As');
      int asRashi = int.parse(asPlanet!['rashi']);

      List<int> allRashis = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
      List<int> rashiOrder = [
        ...allRashis.where((r) => r >= asRashi),
        ...allRashis.where((r) => r < asRashi)
      ];

      debugPrint('Rashi Order ${rashiOrder}');
      List otherPlanets =
          planets.where((planet) => planet['planet'] != 'As').toList();

      otherPlanets.sort((a, b) {
        int rashiA = int.parse(a['rashi']);
        int rashiB = int.parse(b['rashi']);
        return rashiOrder.indexOf(rashiA).compareTo(rashiOrder.indexOf(rashiB));
      });

      List<Map<String, dynamic>> sortedPlanets = [asPlanet, ...otherPlanets];

      if (mounted) {
        setState(() {
          planetsData.clear();
          for (int i = 0; i < sortedPlanets.length; i++) {
            planetsData.add(
              KundaliModel(
                color: sortedPlanets[i]['color'],
                degree: sortedPlanets[i]['degree']
                    .toString()
                    .replaceAll(' ', '')
                    .substring(0, 3),
                planet: sortedPlanets[i]['planet'],
                rashi: sortedPlanets[i]['rashi'],
              ),
            );
          }
        });
      }

      debugPrint(jsonEncode(planetsData));
      rashiToGharMapping.clear();

      for (int i = 0; i < rashiOrder.length; i++) {
        rashiToGharMapping[rashiOrder[i]] = i + 1;
      }

      debugPrint('Rashi mapping is $rashiToGharMapping');
    } catch (e, s) {
      debugPrint('Error $e $s');
    }
  }
}

// Modified CanvasPainter to accept data as parameters
class CanvasPainter extends CustomPainter {
  final List<KundaliModel> planetsData;
  final Map<int, int> rashiToGharMapping;

  CanvasPainter({
    required this.planetsData,
    required this.rashiToGharMapping,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CkColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Ghar outlines (unchanged)
    drawSquareHouse(canvas, size, paint, 50, 0, 75, 25, 50, 50, 25, 25);
    drawTriangleHouse(canvas, size, paint, 0, 0, 50, 0, 25, 25);
    drawTriangleHouse(canvas, size, paint, 0, 0, 25, 25, 0, 50);
    drawSquareHouse(canvas, size, paint, 25, 25, 50, 50, 25, 75, 0, 50);
    drawTriangleHouse(canvas, size, paint, 0, 50, 25, 75, 0, 100);
    drawTriangleHouse(canvas, size, paint, 25, 75, 50, 100, 0, 100);
    drawSquareHouse(canvas, size, paint, 50, 50, 75, 75, 50, 100, 25, 75);
    drawTriangleHouse(canvas, size, paint, 75, 75, 100, 100, 50, 100);
    drawTriangleHouse(canvas, size, paint, 75, 75, 100, 50, 100, 100);
    drawSquareHouse(canvas, size, paint, 75, 25, 100, 50, 75, 75, 50, 50);
    drawTriangleHouse(canvas, size, paint, 100, 0, 100, 50, 75, 25);
    drawTriangleHouse(canvas, size, paint, 50, 0, 100, 0, 75, 25);

    final Map<int, List<KundaliModel>> groupedPlanets = {};
    for (var planetData in planetsData) {
      int rashi = int.parse(planetData.rashi!);
      if (groupedPlanets.containsKey(rashi)) {
        groupedPlanets[rashi]!.add(planetData);
      } else {
        groupedPlanets[rashi] = [planetData];
      }
    }

    for (int rashi = 1; rashi <= 12; rashi++) {
      int ghar = rashiToGharMapping[rashi] ?? 0;
      final basePosition = _getPositionForGhar(ghar, size);
      var offsetRashi = Offset(basePosition.dx, basePosition.dy);
      drawUniqueRashiNumber(canvas, size, rashi.toString(), offsetRashi);

      if (groupedPlanets.containsKey(rashi)) {
        List<KundaliModel> planets = groupedPlanets[rashi]!;
        var offsetX = basePosition.dx - 20;
        var offsetY = basePosition.dy + 20;

        for (var planetData in planets) {
          drawPlanet(canvas, size, planetData, Offset(offsetX, offsetY));
          offsetY += 15;
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Example usage of the widget
class CanvasExample extends StatelessWidget {
  final String mid;

  const CanvasExample({super.key, required this.mid});

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          KundaliWidget(
            mid: mid,
            backgroundImage: Image.asset(AppImages.kundaliBg),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Supporting functions and classes (unchanged)
void drawPlanet(
    Canvas canvas, Size size, KundaliModel planetData, Offset offset) {
  final planetColor = _getColor(planetData.color!);
  final textPainter = TextPainter(
    text: TextSpan(
      text: '${planetData.planet} ${planetData.degree}',
      style: TextStyle(color: planetColor, fontSize: AppStyles.planetFontSize),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, offset);
}

void drawUniqueRashiNumber(
    Canvas canvas, Size size, String rashi, Offset position) {
  final textPainterRashi = TextPainter(
    text: TextSpan(
      text: rashi,
      style:  TextStyle(color: CkColors.text, fontSize: AppStyles.planetNumberFontSize),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainterRashi.layout();
  textPainterRashi.paint(canvas, position);
}

Offset _getPositionForGhar(int ghar, Size size) {
  switch (ghar) {
    case 1:
      return Offset(size.width * 0.49, size.height * 0.03);
    case 2:
      return Offset(size.width * 0.2, size.height * 0.01);
    case 3:
      return Offset(size.width * 0.08, size.height * 0.14);
    case 4:
      return Offset(size.width * 0.23, size.height * 0.27);
    case 5:
      return Offset(size.width * 0.10, size.height * 0.65);
    case 6:
      return Offset(size.width * 0.24, size.height * 0.77);
    case 7:
      return Offset(size.width * 0.49, size.height * 0.55);
    case 8:
      return Offset(size.width * 0.74, size.height * 0.8);
    case 9:
      return Offset(size.width * 0.95, size.height * 0.55);
    case 10:
      return Offset(size.width * 0.73, size.height * 0.3);
    case 11:
      return Offset(size.width * 0.95, size.height * 0.07);
    case 12:
      return Offset(size.width * 0.80, size.height * 0.01);
    default:
      return Offset(0, 0);
  }
}

void drawTriangleHouse(Canvas canvas, Size size, Paint paint, double x1,
    double y1, double x2, double y2, double x3, double y3) {
  Path path = Path()
    ..moveTo(x1 * size.width / 100, y1 * size.height / 100)
    ..lineTo(x2 * size.width / 100, y2 * size.height / 100)
    ..lineTo(x3 * size.width / 100, y3 * size.height / 100)
    ..close();
  canvas.drawPath(path, paint);
}

void drawSquareHouse(
    Canvas canvas,
    Size size,
    Paint paint,
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
    double x4,
    double y4) {
  Path path = Path()
    ..moveTo(x1 * size.width / 100, y1 * size.height / 100)
    ..lineTo(x2 * size.width / 100, y2 * size.height / 100)
    ..lineTo(x3 * size.width / 100, y3 * size.height / 100)
    ..lineTo(x4 * size.width / 100, y4 * size.height / 100)
    ..close();
  canvas.drawPath(path, paint);
}

Color _getColor(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'red':
      return Colors.red;
    case 'blue':
      return CkColors.linkBlue;
    case 'green':
      return Colors.green;
    case 'darkorange':
      return Colors.orange;
    case 'magenta':
      return Colors.purple;
    case 'gray':
      return CkColors.textMuted;
    case 'brown':
      return Colors.brown;
    default:
      return CkColors.text;
  }
}

class KundaliModel {
  String? planet;
  String? rashi;
  String? degree;
  String? color;

  KundaliModel({this.planet, this.rashi, this.degree, this.color});

  KundaliModel.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    rashi = json['rashi'];
    degree = json['degree'].toString().replaceAll(' ', '').substring(0, 3);
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['planet'] = planet;
    data['rashi'] = rashi;
    data['degree'] = degree.toString().replaceAll(' ', '').substring(0, 3);
    data['color'] = color;
    return data;
  }
}
