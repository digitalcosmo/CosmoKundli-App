import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AstrologyChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> housesData;

  AstrologyChartPainter(this.housesData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 20;
    final innerRadius = outerRadius / 2;

    // Outer circle
    paint.color = CkColors.text;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, outerRadius, paint);

    // Inner circle
    paint.color = CkColors.textMuted;
    canvas.drawCircle(center, innerRadius, paint);

    // Divide into 12 houses
    paint.color = CkColors.text;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (pi / 180);
      final x = center.dx + outerRadius * cos(angle);
      final y = center.dy + outerRadius * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    // Draw house numbers and planet symbols
    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    for (int i = 0; i < housesData.length; i++) {
      final angle = ((i * 30) + 15) * (pi / 180);
      final houseX = center.dx + (outerRadius * 0.9) * cos(angle);
      final houseY = center.dy + (outerRadius * 0.9) * sin(angle);

      // House number
      textPainter.text = TextSpan(
        text: '${i + 1}',
        style: TextStyle(color: CkColors.text, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(houseX - textPainter.width / 2, houseY - textPainter.height / 2));

      // Planet symbols within each house
      final planetData = housesData[i];
      final planetAngle = angle + 15 * (pi / 180); // Adjust to place inside the house segment
      final planetX = center.dx + (innerRadius * 1.1) * cos(planetAngle);
      final planetY = center.dy + (innerRadius * 1.1) * sin(planetAngle);

      textPainter.text = TextSpan(
        text: planetData['planet'],
        style: TextStyle(color: planetData['color'], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(planetX - textPainter.width / 2, planetY - textPainter.height / 2));
    }

    // Draw center date and time
    textPainter.text = TextSpan(
      text: '28-10-2024\n17:49:46\nMonday',
      style: TextStyle(color: CkColors.text, fontSize: 14),
    );
    textPainter.layout();
    textPainter.paint(canvas, center.translate(-textPainter.width / 2, -textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AstrologyChart extends StatelessWidget {
  final List<Map<String, dynamic>> housesData = [
    {'house': '1', 'planet': 'As', 'color': Colors.red},
    {'house': '2', 'planet': 'Ju', 'color': Colors.orange},
    {'house': '3', 'planet': 'Ma', 'color': Colors.red},
    {'house': '4', 'planet': 'Mo', 'color': CkColors.text},
    {'house': '5', 'planet': 'Su', 'color': Colors.red},
    {'house': '6', 'planet': 'Me', 'color': Colors.green},
    {'house': '7', 'planet': 'Ke', 'color': Colors.brown},
    {'house': '8', 'planet': 'Ve', 'color': Colors.pink},
    {'house': '9', 'planet': 'Me', 'color': Colors.green},
    {'house': '10', 'planet': 'Sa', 'color': CkColors.linkBlue},
    {'house': '11', 'planet': 'Ra', 'color': CkColors.textMuted},
    {'house': '12', 'planet': 'Sa', 'color': CkColors.linkBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return CkScaffold(
      appBar: AppBar(title: Text('Astrology Chart')),
      body: Center(
        child: CustomPaint(
          size: Size(300, 300),
          painter: AstrologyChartPainter(housesData),
        ),
      ),
    );
  }
}
