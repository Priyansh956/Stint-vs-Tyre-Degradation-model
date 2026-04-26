import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/stint_analysis.dart';

class ResidualChart extends StatelessWidget {
  final StintAnalysis stint;

  const ResidualChart({super.key, required this.stint});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      stint.lapInStint.length,
      (i) => FlSpot(
        stint.lapInStint[i].toDouble(),
        stint.residuals[i],
      ),
    );

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(show: true),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
                color: Colors.grey,
                strokeWidth: 1,
              )
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
