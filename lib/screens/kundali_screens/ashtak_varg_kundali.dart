import '../../ui/ck_theme.dart';
import '../../ui/glass.dart';
import 'dart:convert';
import 'package:cosmo_kundali/screens/kundali_screens/birth_planet_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AshtakVargKundali extends StatefulWidget {
  final String? url;
  const AshtakVargKundali(this.url, {super.key});

  @override
  _AshtakVargKundaliState createState() => _AshtakVargKundaliState();
}

final List<KundaliModel> planetsData = [];

Map<int, int> rashiToGharMapping = {};

class _AshtakVargKundaliState extends State<AshtakVargKundali> {
  @override
  void initState() {
    super.initState();

    if (!kundaliController.isAshtakApiCalled) {
      getKundaliData(widget.url.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double canvasParentWidth = constraints.maxWidth - 10;

        return CustomPaint(
          size: Size(canvasParentWidth, canvasParentWidth),
          painter: CanvasPainterVargKundali(),
        );
      },
    );
  }

  bool isPlanetInRashi(List<KundaliModel> planets, String rashi) {
    for (var planet in planets) {
      if (planet.rashi == rashi) {
        return true;
      }
    }
    return false;
  }

  void getKundaliData(String url) async {
    Dio dio = Dio();

    Map<String, dynamic> data = {
      'mID': kundaliController.mId.value,
    };

    Response response = await dio.post(
      'https://software.cosmokundli.com/API/${widget.url}',
      data: data,
    );
    debugPrint('https://software.cosmokundli.com/API/${widget.url}');

    List<dynamic> planets = response.data['planets'];
    debugPrint(planets.length.toString());
    debugPrint(jsonEncode(planets));

    Map<String, dynamic>? asPlanet =
        planets.firstWhere((planet) => planet['planet'] == 'As');
    int asRashi = int.parse(asPlanet!['rashi']);
    List<int> allRashis = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    List<int> rashiOrder = [
      ...allRashis.where((r) => r >= asRashi),
      ...allRashis.where((r) => r < asRashi)
    ];

    List otherPlanets =
        planets.where((planet) => planet['planet'] != 'As').toList();

    otherPlanets.sort((a, b) {
      int rashiA = int.parse(a['rashi']);
      int rashiB = int.parse(b['rashi']);
      return rashiOrder.indexOf(rashiA).compareTo(rashiOrder.indexOf(rashiB));
    });

    List<Map<String, dynamic>> sortedPlanets = [asPlanet, ...otherPlanets];

    setState(() {
      planetsData.clear();
      for (int i = 0; i < sortedPlanets.length; i++) {
        planetsData.add(
          KundaliModel(
            color: sortedPlanets[i]['color'],
            degree: sortedPlanets[i]['degree'],
            planet: sortedPlanets[i]['planet'],
            rashi: sortedPlanets[i]['rashi'],
          ),
        );
      }
    });

    rashiToGharMapping.clear();

    for (int i = 0; i < rashiOrder.length; i++) {
      rashiToGharMapping[rashiOrder[i]] = i + 1;
    }

    rashiToGharMapping.forEach((rashi, ghar) {});

    debugPrint('Rashi maping is $rashiToGharMapping');
  }
}

class CanvasPainterVargKundali extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CkColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Ghar outlines
    drawSquareHouse(
        canvas, size, paint, 50, 0, 75, 25, 50, 50, 25, 25); // Ghar 1
    drawTriangleHouse(canvas, size, paint, 0, 0, 50, 0, 25, 25); // Ghar 2
    drawTriangleHouse(canvas, size, paint, 0, 0, 25, 25, 0, 50); // Ghar 3
    drawSquareHouse(
        canvas, size, paint, 25, 25, 50, 50, 25, 75, 0, 50); // Ghar 4
    drawTriangleHouse(canvas, size, paint, 0, 50, 25, 75, 0, 100); // Ghar 5
    drawTriangleHouse(canvas, size, paint, 25, 75, 50, 100, 0, 100); // Ghar 6
    drawSquareHouse(
        canvas, size, paint, 50, 50, 75, 75, 50, 100, 25, 75); // Ghar 7
    drawTriangleHouse(canvas, size, paint, 75, 75, 100, 100, 50, 100); // Ghar 8
    drawTriangleHouse(canvas, size, paint, 75, 75, 100, 50, 100, 100); // Ghar 9
    drawSquareHouse(
        canvas, size, paint, 75, 25, 100, 50, 75, 75, 50, 50); // Ghar 10
    drawTriangleHouse(canvas, size, paint, 100, 0, 100, 50, 75, 25); // Ghar 11
    drawTriangleHouse(canvas, size, paint, 50, 0, 100, 0, 75, 25); // Ghar 12

    // Group planets by Rashi
    final Map<int, List<KundaliModel>> groupedPlanets = {};

    for (var planetData in planetsData) {
      int rashi = int.parse(planetData.rashi!);
      if (groupedPlanets.containsKey(rashi)) {
        groupedPlanets[rashi]!.add(planetData);
      } else {
        groupedPlanets[rashi] = [planetData];
      }
    }

    // Iterate through all Rashis (1 to 12) and display Rashi number, whether it has a planet or not
    for (int rashi = 1; rashi <= 12; rashi++) {
      int ghar = rashiToGharMapping[rashi] ?? 0;

      // Get the base position for the ghar
      final basePosition = _getPositionForGhar(ghar, size);

      // Draw the Rashi number for each Ghar
      var offsetRashi = Offset(basePosition.dx, basePosition.dy);
      drawUniqueRashi(
          canvas, size, rashi.toString(), offsetRashi); // Draw the Rashi number

      // Check if this Rashi has planets
      if (groupedPlanets.containsKey(rashi)) {
        List<KundaliModel> planets = groupedPlanets[rashi]!;

        // Draw each planet in a column format below the Rashi number
        for (int i = 0; i < planets.length; i++) {
          var planetData = planets[i];
          var offsetPlanet = Offset(
              basePosition.dx,
              basePosition.dy +
                  (i * 20) +
                  20); // Adjust the vertical position, ensuring it starts below the Rashi
          drawPlanet(canvas, size, planetData, offsetPlanet);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

void drawPlanet(
    Canvas canvas, Size size, KundaliModel planetData, Offset offset) {
  final planetColor = _getColor(planetData.color!);

  final textPainter = TextPainter(
    text: TextSpan(
      text: planetData.planet!,
      style: TextStyle(color: planetColor, fontSize: 14),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();
  textPainter.paint(canvas, offset);
}

void drawUniqueRashi(
  Canvas canvas,
  Size size,
  String rashi,
  Offset position,
) {
  final textPainterRashi = TextPainter(
    text: TextSpan(
      text: rashi, // Show rashi number
      style: const TextStyle(color: CkColors.text, fontSize: 14),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainterRashi.layout();
  textPainterRashi.paint(
      canvas, position); // Paint the Rashi number at the given position
}

Offset _getPositionForGhar(int ghar, Size size) {
  switch (ghar) {
    case 1:
      return Offset(size.width * 0.5, size.height * 0.1); //set
    case 2:
      return Offset(size.width * 0.2, size.height * 0.01); //set
    case 3:
      return Offset(size.width * 0.06, size.height * 0.20); //set
    case 4:
      return Offset(size.width * 0.2, size.height * 0.5); //set
    case 5:
      return Offset(size.width * 0.07, size.height * 0.7); //set
    case 6:
      return Offset(size.width * 0.2, size.height * 0.82); //set
    case 7:
      return Offset(size.width * 0.5, size.height * 0.7); //set
    case 8:
      return Offset(size.width * 0.75, size.height * 0.85); //set
    case 9:
      return Offset(size.width * 0.9, size.height * 0.75); //set
    case 10:
      return Offset(size.width * 0.7, size.height * 0.4); //set
    case 11:
      return Offset(size.width * 0.9, size.height * 0.20); //set
    case 12:
      return Offset(size.width * 0.70, size.height * 0.05); // set
    default:
      return Offset(0, 0);
  }
}

class CanvasBCCPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CkColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CanvasNKPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CkColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
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
    degree = json['degree'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['planet'] = this.planet;
    data['rashi'] = this.rashi;
    data['degree'] = this.degree;
    data['color'] = this.color;
    return data;
  }
}
