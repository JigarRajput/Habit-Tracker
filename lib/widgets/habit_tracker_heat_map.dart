import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class HabitTrackerHeatMap extends StatelessWidget {
  final DateTime startDate;
  final Map<DateTime, int> datasets;
  const HabitTrackerHeatMap({
    super.key,
    required this.startDate,
    required this.datasets,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return HeatMap(
      colorTipSize: 20,
      startDate: startDate,
      endDate: DateTime.now(),
      colorMode: ColorMode.color,
      defaultColor: themeData.colorScheme.secondary,
      textColor: themeData.hintColor,
      showColorTip: false,
      showText: true,
      scrollable: true,
      size: 50,
      datasets: datasets,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      colorsets: {
        1: Colors.green.shade200,
        2: Colors.green.shade300,
        3: Colors.green.shade400,
        4: Colors.green.shade500,
        5: Colors.green.shade600,
      },
    );
  }
}
