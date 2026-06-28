import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/profit_report_entity.dart';

/// Line chart showing revenue vs cost vs profit trend over months.
class ProfitLineChart extends StatelessWidget {
  const ProfitLineChart({super.key, required this.data});
  final List<ProfitDataPoint> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.show_chart_rounded,
                  size: 36, color: Color(0xFFCCCCCC)),
              const SizedBox(height: 8),
              const Text('No profit data available',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFFAAAAAA))),
            ],
          ),
        ),
      );
    }

    final maxVal = data
        .expand((d) => [d.revenue, d.cost])
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 100.0 : maxVal * 1.2;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              maxY: maxY,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (v, _) => Text(
                      _compact(v),
                      style: const TextStyle(
                          fontSize: 9, color: Color(0xFFAAAAAA)),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= data.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _shortLabel(data[idx].label),
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFFAAAAAA)),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1A1A2E),
                  getTooltipItems: (spots) => spots.map((s) {
                    final isProfit = s.barIndex == 0;
                    return LineTooltipItem(
                      '${isProfit ? "Profit" : "Revenue"}: \$ ${s.y.toStringAsFixed(0)}',
                      const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                // Profit line
                LineChartBarData(
                  spots: data.asMap().entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.profit))
                      .toList(),
                  isCurved: true,
                  color: const Color(0xFF2E7D32),
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF2E7D32).withOpacity(0.08),
                  ),
                ),
                // Revenue line
                LineChartBarData(
                  spots: data.asMap().entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
                      .toList(),
                  isCurved: true,
                  color: const Color(0xFF1565C0),
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  dashArray: [6, 4],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: const Color(0xFF2E7D32), label: 'Profit'),
            const SizedBox(width: 20),
            _LegendDot(color: const Color(0xFF1565C0), label: 'Revenue'),
          ],
        ),
      ],
    );
  }

  String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  String _shortLabel(String label) {
    // "2026-03" → "Mar"
    final parts = label.split('-');
    if (parts.length != 2) return label;
    const months = ['','Jan','Feb','Mar','Apr','May','Jun',
                     'Jul','Aug','Sep','Oct','Nov','Dec'];
    final m = int.tryParse(parts[1]) ?? 0;
    return m >= 1 && m <= 12 ? months[m] : label;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF555555))),
        ],
      );
}