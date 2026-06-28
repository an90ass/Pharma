import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/reports_viewmodel.dart';
import '../../widgets/breakdown_pie_chart.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/profit_line_chart.dart';
import '_shared_tab_widgets.dart';

class ProfitReportTab extends ConsumerWidget {
  const ProfitReportTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsViewModelProvider);
    final vm    = ref.read(reportsViewModelProvider.notifier);

    if (state.isLoading) return const ReportLoading();
    if (state.errorMessage != null) {
      return ReportError(
        message: state.errorMessage!,
        onRetry: () => vm.loadReport(ReportTab.profit),
      );
    }
    final report = state.profitReport;
    if (report == null) return const SizedBox();

    final fmt = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: () => vm.loadReport(ReportTab.profit),
      color: const Color(0xFF1565C0),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Net profit hero ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: report.netProfit >= 0
                    ? const [Color(0xFF2E7D32), Color(0xFF43A047)]
                    : const [Color(0xFFE53935), Color(0xFFEF5350)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Net Profit (last 6 months)',
                    style: TextStyle(
                        fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  fmt.format(report.netProfit),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${report.profitMarginPct.toStringAsFixed(1)}% margin',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── KPI grid ─────────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              KpiCard(
                label: 'Total revenue',
                value: report.totalRevenue,
                icon: Icons.payments_rounded,
                color: const Color(0xFF1565C0),
                isCurrency: true,
              ),
              KpiCard(
                label: 'Cost of goods',
                value: report.totalCogs,
                icon: Icons.local_shipping_rounded,
                color: const Color(0xFFFF9800),
                isCurrency: true,
              ),
              KpiCard(
                label: 'Gross profit',
                value: report.grossProfit,
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF2E7D32),
                isCurrency: true,
              ),
              KpiCard(
                label: 'Discounts given',
                value: report.totalDiscount,
                icon: Icons.percent_rounded,
                color: const Color(0xFF7B1FA2),
                isCurrency: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Trend chart ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.black.withOpacity(0.06), width: 0.8),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.show_chart_rounded,
                      size: 15, color: Color(0xFF1565C0)),
                  const SizedBox(width: 6),
                  const Text('Revenue vs Profit (6 months)',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                ]),
                const SizedBox(height: 12),
                ProfitLineChart(data: report.monthlyTrend),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Category profit breakdown ───────────────────────────────
          if (report.categoryBreakdown.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.black.withOpacity(0.06), width: 0.8),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.category_rounded,
                        size: 15, color: Color(0xFF1565C0)),
                    const SizedBox(width: 6),
                    const Text('Profit by category',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                  ]),
                  const SizedBox(height: 12),
                  BreakdownPieChart(
                    items: report.categoryBreakdown
                        .asMap()
                        .entries
                        .map((e) => PieItem(
                              label: e.value.category,
                              value: e.value.profit,
                              percentage: e.value.percentage,
                              color: chartColors[e.key % chartColors.length],
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}