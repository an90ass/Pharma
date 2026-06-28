import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/sales_report_entity.dart';

/// Bar chart showing revenue per day/week/month.
class RevenueBarChart extends StatelessWidget {
  const RevenueBarChart({super.key, required this.data});
  final List<SalesDataPoint> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyChart(message: 'No sales data for this period');
    }

    final maxRevenue = data
        .map((d) => d.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxRevenue == 0 ? 100.0 : maxRevenue * 1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1565C0),
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '\$ ${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, _) => Text(
                  _compactNumber(value),
                  style: const TextStyle(
                      fontSize: 9, color: Color(0xFFAAAAAA)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[idx].label,
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
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.revenue,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _compactNumber(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bar_chart_rounded,
                  size: 36, color: Color(0xFFCCCCCC)),
              const SizedBox(height: 8),
              Text(message,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFAAAAAA))),
            ],
          ),
        ),
      );
}