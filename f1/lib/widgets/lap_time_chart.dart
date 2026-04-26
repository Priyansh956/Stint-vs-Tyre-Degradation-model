import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/stint_analysis.dart';

class LapTimeChart extends StatelessWidget {
  final StintAnalysis stint;

  const LapTimeChart({super.key, required this.stint});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      stint.lapInStint.length,
      (i) => FlSpot(
        stint.lapInStint[i].toDouble(),
        stint.lapTime[i],
      ),
    );

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(show: true),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
