import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMap extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final DateTime startDate;
  final DateTime endDate;

  const MyHeatMap({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.datasets,
  });

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      startDate: startDate,
      endDate: endDate,
      datasets: datasets,
      colorMode: ColorMode.color,
      defaultColor: Theme.of(context).colorScheme.secondary,
      textColor: Colors.white,
      showColorTip: false,
      showText: false,
      scrollable: true,
      size: 30,
      colorsets: {
        1: Colors.green.shade300,
        2: Colors.yellow.shade300,
        3: Colors.red.shade400,
        4: Colors.blue.shade300,
      },
    );
  }
}
