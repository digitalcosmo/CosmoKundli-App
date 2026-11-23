import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import 'package:flutter/material.dart';

class CustomBarGraph extends StatelessWidget {
  final List<Color> barColors; // Colors for each bar
  final List<double> barPercentages; // Percentage values for each bar (0-100)
  final List<String> labels; // Labels for each bar (e.g., days of the week)

  CustomBarGraph({
    super.key,
    required this.barColors,
    required this.barPercentages,
    required this.labels,
  }) {
    assert(barColors.length == barPercentages.length &&
        barColors.length == labels.length);
    assert(barPercentages
        .every((percentage) => percentage >= 0 && percentage <= 100));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Histogram bars and y-axis labels
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels (0 to 100)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(11, (index) {
                    return Text(
                      '${100 - index * 10}',
                      style: const TextStyle(fontSize: 12),
                    );
                  }),
                ),
                const SizedBox(width: 10),
                // Histogram bars wrapped in SingleChildScrollView for horizontal scrolling
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Get the available height for the bars
                      double availableHeight = constraints.maxHeight;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(barPercentages.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add spacing between bars
                                    child: _buildBar(
                                      barPercentages[index],
                                      barColors[index],
                                      availableHeight,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            // X-axis labels (e.g., Mon, Tue, etc.)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(labels.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Match bar spacing
                                  child: SizedBox(
                                    width: 40, // Match bar width for alignment
                                    child: Text(
                                      labels[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build each bar
  Widget _buildBar(double percentage, Color color, double availableHeight) {
    // Calculate the bar height as a fraction of the available height
    double barHeight = (percentage / 100) * availableHeight - 12;

    return Container(
      width: 40,
      height: barHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: color,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        // Move the percentage text to the top of the bar
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: FittedBox(
            child: Text(
              percentage.toString(),
              style: const TextStyle(
                fontSize: 10,
                color: CkColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}