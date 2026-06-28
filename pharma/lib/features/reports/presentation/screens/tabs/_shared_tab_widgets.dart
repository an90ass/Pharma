import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/sales_report_entity.dart';
import '../../viewmodels/reports_viewmodel.dart';
import '../../widgets/breakdown_pie_chart.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/revenue_bar_chart.dart';

/// Shared loading state for all report tabs.
class ReportLoading extends StatelessWidget {
  const ReportLoading({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)));
}

/// Shared error state for all report tabs.
class ReportError extends StatelessWidget {
  const ReportError({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 40, color: Color(0xFFE53935)),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF888888))),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0)),
              ),
            ],
          ),
        ),
      );
}

/// Shared KPI grid + chart + payment breakdown — used by Daily/Weekly/Monthly.
class SalesReportBody extends StatelessWidget {
  const SalesReportBody({super.key, required this.report});
  final SalesReportEntity report;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── KPI grid ────────────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: [
            KpiCard(
              label: 'Total revenue',
              value: report.totalRevenue,
              icon: Icons.payments_rounded,
              color: const Color(0xFF1565C0),
              isCurrency: true,
            ),
            KpiCard(
              label: 'Gross profit',
              value: report.grossProfit,
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF2E7D32),
              isCurrency: true,
              subtitle: '${report.profitMarginPct.toStringAsFixed(1)}% margin',
            ),
            KpiCard(
              label: 'Invoices',
              value: report.totalInvoices,
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF7B1FA2),
              subtitle: 'Avg ${fmt.format(report.avgInvoiceValue)}',
            ),
            KpiCard(
              label: 'Items sold',
              value: report.totalItemsSold,
              icon: Icons.medication_rounded,
              color: const Color(0xFFFF9800),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Revenue chart ───────────────────────────────────────────
        _SectionCard(
          title: 'Revenue trend',
          icon: Icons.bar_chart_rounded,
          child: RevenueBarChart(data: report.dailyBreakdown),
        ),
        const SizedBox(height: 16),

        // ── Discount/Tax summary ────────────────────────────────────
        if (report.totalDiscount > 0 || report.totalTax > 0)
          _SectionCard(
            title: 'Adjustments',
            icon: Icons.percent_rounded,
            child: Column(
              children: [
                if (report.totalDiscount > 0)
                  _AdjustRow(
                    label: 'Total discount given',
                    value: fmt.format(report.totalDiscount),
                    color: const Color(0xFF2E7D32),
                  ),
                if (report.totalTax > 0)
                  _AdjustRow(
                    label: 'Total tax collected',
                    value: fmt.format(report.totalTax),
                    color: const Color(0xFF1565C0),
                  ),
              ],
            ),
          ),
        if (report.totalDiscount > 0 || report.totalTax > 0)
          const SizedBox(height: 16),

        // ── Payment breakdown pie ────────────────────────────────────
        if (report.paymentBreakdown.isNotEmpty)
          _SectionCard(
            title: 'Payment methods',
            icon: Icons.pie_chart_rounded,
            child: BreakdownPieChart(
              items: report.paymentBreakdown.asMap().entries.map((e) {
                return PieItem(
                  label: _methodLabel(e.value.method),
                  value: e.value.amount,
                  percentage: e.value.percentage,
                  color: chartColors[e.key % chartColors.length],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _methodLabel(String method) => switch (method) {
        'cash'         => 'Cash',
        'card'         => 'Card',
        'jazzCash'     => 'JazzCash',
        'easypaisa'    => 'Easypaisa',
        'bankTransfer' => 'Bank Transfer',
        'storeCredit'  => 'Store Credit',
        _              => method,
      };
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
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
              Icon(icon, size: 15, color: const Color(0xFF1565C0)),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
            ]),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class _AdjustRow extends StatelessWidget {
  const _AdjustRow(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF888888))),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      );
}