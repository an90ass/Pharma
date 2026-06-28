import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Generic pie chart for payment-method or category breakdowns.
class BreakdownPieChart extends StatefulWidget {
  const BreakdownPieChart({super.key, required this.items});

  /// Each item: {label, value, percentage}
  final List<PieItem> items;

  @override
  State<BreakdownPieChart> createState() => _BreakdownPieChartState();
}

class PieItem {
  const PieItem({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
  final String label;
  final double value;
  final double percentage;
  final Color  color;
}

class _BreakdownPieChartState extends State<BreakdownPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('No data available',
              style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))),
        ),
      );
    }

    return Row(
      children: [
        // Pie
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response?.touchedSection == null) {
                        _touchedIndex = null;
                        return;
                      }
                      _touchedIndex =
                          response!.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: widget.items.asMap().entries.map((e) {
                  final isTouched = e.key == _touchedIndex;
                  return PieChartSectionData(
                    value: e.value.percentage,
                    color: e.value.color,
                    title: '${e.value.percentage.toStringAsFixed(0)}%',
                    radius: isTouched ? 56 : 48,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 12 : 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        // Legend
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                        color: item.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('\$ ${item.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF888888))),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

/// Predefined color palette for chart segments.
const chartColors = [
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFFFF9800),
  Color(0xFF7B1FA2),
  Color(0xFFE53935),
  Color(0xFF00897B),
  Color(0xFF6A1B9A),
  Color(0xFFEF6C00),
];