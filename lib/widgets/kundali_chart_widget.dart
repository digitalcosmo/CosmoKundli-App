import 'package:flutter/material.dart';
import 'package:cosmo_kundli/theme/app_theme.dart';

/// Data model for a planet in the kundali chart
class KundaliPlanetData {
  final String planet;
  final String rashi;
  final String degree;
  final String color;

  KundaliPlanetData({
    required this.planet,
    required this.rashi,
    required this.degree,
    required this.color,
  });

  factory KundaliPlanetData.fromJson(Map<String, dynamic> json) {
    String deg = json['degree']?.toString().replaceAll(' ', '') ?? '';
    if (deg.length > 3) deg = deg.substring(0, 3);
    return KundaliPlanetData(
      planet: json['planet'] ?? '',
      rashi: json['rashi']?.toString() ?? '',
      degree: deg,
      color: json['color'] ?? '',
    );
  }
}

/// South Indian style birth chart diamond layout widget
class KundaliChartWidget extends StatelessWidget {
  final List<KundaliPlanetData> planetsData;
  final Map<int, int> rashiToGharMapping;
  final double? height;
  final double? width;

  const KundaliChartWidget({
    super.key,
    required this.planetsData,
    required this.rashiToGharMapping,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double canvasSize = constraints.maxWidth - 10;
        if (height != null && height! < canvasSize) canvasSize = height!;
        return Center(
          child: SizedBox(
            height: canvasSize,
            width: width ?? canvasSize,
            child: CustomPaint(
              size: Size(canvasSize, canvasSize),
              painter: _KundaliPainter(
                planetsData: planetsData,
                rashiToGharMapping: rashiToGharMapping,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build rashiToGharMapping from planets data (starting from Ascendant's rashi)
  static Map<int, int> buildRashiMapping(List<KundaliPlanetData> planets) {
    Map<int, int> mapping = {};
    final asPlanet = planets.where((p) => p.planet == 'As').firstOrNull;
    if (asPlanet == null) return mapping;

    int asRashi = int.tryParse(asPlanet.rashi) ?? 1;
    List<int> allRashis = List.generate(12, (i) => i + 1);
    List<int> rashiOrder = [
      ...allRashis.where((r) => r >= asRashi),
      ...allRashis.where((r) => r < asRashi),
    ];

    for (int i = 0; i < rashiOrder.length; i++) {
      mapping[rashiOrder[i]] = i + 1;
    }
    return mapping;
  }
}

class _KundaliPainter extends CustomPainter {
  final List<KundaliPlanetData> planetsData;
  final Map<int, int> rashiToGharMapping;

  _KundaliPainter({
    required this.planetsData,
    required this.rashiToGharMapping,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gmHighlight.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw the 12 houses (South Indian style diamond)
    _drawSquareHouse(canvas, size, paint, 50, 0, 75, 25, 50, 50, 25, 25);
    _drawTriangleHouse(canvas, size, paint, 0, 0, 50, 0, 25, 25);
    _drawTriangleHouse(canvas, size, paint, 0, 0, 25, 25, 0, 50);
    _drawSquareHouse(canvas, size, paint, 25, 25, 50, 50, 25, 75, 0, 50);
    _drawTriangleHouse(canvas, size, paint, 0, 50, 25, 75, 0, 100);
    _drawTriangleHouse(canvas, size, paint, 25, 75, 50, 100, 0, 100);
    _drawSquareHouse(canvas, size, paint, 50, 50, 75, 75, 50, 100, 25, 75);
    _drawTriangleHouse(canvas, size, paint, 75, 75, 100, 100, 50, 100);
    _drawTriangleHouse(canvas, size, paint, 75, 75, 100, 50, 100, 100);
    _drawSquareHouse(canvas, size, paint, 75, 25, 100, 50, 75, 75, 50, 50);
    _drawTriangleHouse(canvas, size, paint, 100, 0, 100, 50, 75, 25);
    _drawTriangleHouse(canvas, size, paint, 50, 0, 100, 0, 75, 25);

    // Group planets by rashi
    final Map<int, List<KundaliPlanetData>> groupedPlanets = {};
    for (var p in planetsData) {
      int rashi = int.tryParse(p.rashi) ?? 0;
      groupedPlanets.putIfAbsent(rashi, () => []).add(p);
    }

    // Draw rashi numbers and planets
    for (int rashi = 1; rashi <= 12; rashi++) {
      int ghar = rashiToGharMapping[rashi] ?? 0;
      final basePos = _getPositionForGhar(ghar, size);

      // Draw rashi number
      _drawText(
        canvas,
        rashi.toString(),
        basePos,
        AppTheme.textMuted,
        size.width * 0.035,
      );

      // Draw planets in this rashi
      if (groupedPlanets.containsKey(rashi)) {
        List<KundaliPlanetData> planets = groupedPlanets[rashi]!;
        double offsetX = basePos.dx - 20;
        double offsetY = basePos.dy + 20;

        for (var planet in planets) {
          Color planetColor = _getPlanetColor(planet.color);
          _drawText(
            canvas,
            '${planet.planet} ${planet.degree}',
            Offset(offsetX, offsetY),
            planetColor,
            size.width * 0.028,
          );
          offsetY += 15;
        }
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  Offset _getPositionForGhar(int ghar, Size size) {
    switch (ghar) {
      case 1:  return Offset(size.width * 0.49, size.height * 0.03);
      case 2:  return Offset(size.width * 0.2,  size.height * 0.01);
      case 3:  return Offset(size.width * 0.08, size.height * 0.14);
      case 4:  return Offset(size.width * 0.23, size.height * 0.27);
      case 5:  return Offset(size.width * 0.10, size.height * 0.65);
      case 6:  return Offset(size.width * 0.24, size.height * 0.77);
      case 7:  return Offset(size.width * 0.49, size.height * 0.55);
      case 8:  return Offset(size.width * 0.74, size.height * 0.8);
      case 9:  return Offset(size.width * 0.95, size.height * 0.55);
      case 10: return Offset(size.width * 0.73, size.height * 0.3);
      case 11: return Offset(size.width * 0.95, size.height * 0.07);
      case 12: return Offset(size.width * 0.80, size.height * 0.01);
      default: return Offset.zero;
    }
  }

  void _drawTriangleHouse(Canvas canvas, Size size, Paint paint,
      double x1, double y1, double x2, double y2, double x3, double y3) {
    Path path = Path()
      ..moveTo(x1 * size.width / 100, y1 * size.height / 100)
      ..lineTo(x2 * size.width / 100, y2 * size.height / 100)
      ..lineTo(x3 * size.width / 100, y3 * size.height / 100)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawSquareHouse(Canvas canvas, Size size, Paint paint,
      double x1, double y1, double x2, double y2,
      double x3, double y3, double x4, double y4) {
    Path path = Path()
      ..moveTo(x1 * size.width / 100, y1 * size.height / 100)
      ..lineTo(x2 * size.width / 100, y2 * size.height / 100)
      ..lineTo(x3 * size.width / 100, y3 * size.height / 100)
      ..lineTo(x4 * size.width / 100, y4 * size.height / 100)
      ..close();
    canvas.drawPath(path, paint);
  }

  Color _getPlanetColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':        return AppTheme.marsColor;
      case 'blue':       return AppTheme.saturnColor;
      case 'green':      return AppTheme.mercuryColor;
      case 'darkorange': return AppTheme.sunColor;
      case 'magenta':    return AppTheme.venusColor;
      case 'gray':       return AppTheme.rahuColor;
      case 'brown':      return AppTheme.ketuColor;
      default:           return AppTheme.textPrimary;
    }
  }

  @override
  bool shouldRepaint(covariant _KundaliPainter oldDelegate) {
    return oldDelegate.planetsData != planetsData ||
        oldDelegate.rashiToGharMapping != rashiToGharMapping;
  }
}
