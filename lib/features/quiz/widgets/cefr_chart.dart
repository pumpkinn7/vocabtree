import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CefrChart extends StatelessWidget {
  final Map<String, int> cefrDistribution;

  const CefrChart({super.key, required this.cefrDistribution});

  @override
  Widget build(BuildContext context) {
    final cefrOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2', 'N/A'];
    final colors = {
      'A1': Colors.red[200],
      'A2': Colors.orange[200],
      'B1': Colors.yellow[200],
      'B2': Colors.green[200],
      'C1': Colors.blue[200],
      'C2': Colors.purple[200],
      'N/A': Colors.grey[200],
    };

    double total = cefrDistribution.values.fold(0, (a, b) => a + b);

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: cefrOrder
                    .where((cefr) => cefrDistribution.containsKey(cefr))
                    .map((cefr) {
                  final count = cefrDistribution[cefr] ?? 0;
                  final percentage = (count / total) * 100;
                  return PieChartSectionData(
                    value: percentage,
                    title: '',
                    color: colors[cefr],
                    radius: 100,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cefrOrder
                .where((cefr) => cefrDistribution.containsKey(cefr))
                .map((cefr) {
              final count = cefrDistribution[cefr] ?? 0;
              final percentage = (count / total) * 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: colors[cefr],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$cefr: ${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
