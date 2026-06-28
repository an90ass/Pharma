import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/reports_viewmodel.dart';
import '../../widgets/kpi_card.dart';
import '_shared_tab_widgets.dart';

class InventoryReportTab extends ConsumerWidget {
  const InventoryReportTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsViewModelProvider);
    final vm    = ref.read(reportsViewModelProvider.notifier);

    if (state.isLoading) return const ReportLoading();
    if (state.errorMessage != null) {
      return ReportError(
        message: state.errorMessage!,
        onRetry: () => vm.loadReport(ReportTab.inventory),
      );
    }
    final report = state.inventoryReport;
    if (report == null) return const SizedBox();

    final fmt = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: () => vm.loadReport(ReportTab.inventory),
      color: const Color(0xFF1565C0),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Stock value hero ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Total stock value',
                    style: TextStyle(
                        fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  fmt.format(report.totalStockValue),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  '${report.totalMedicines} medicines · ${report.totalBatches} active batches',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Alert KPIs ───────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              KpiCard(
                label: 'Low stock',
                value: report.lowStockCount,
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFFF9800),
                subtitle: 'need reorder',
              ),
              KpiCard(
                label: 'Expiring soon',
                value: report.expiringCount,
                icon: Icons.hourglass_bottom_rounded,
                color: const Color(0xFFF44336),
                subtitle: 'within 30 days',
              ),
              KpiCard(
                label: 'Expired',
                value: report.expiredCount,
                icon: Icons.dangerous_rounded,
                color: const Color(0xFF9E9E9E),
                subtitle: 'needs disposal',
              ),
              KpiCard(
                label: 'Total batches',
                value: report.totalBatches,
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFF7B1FA2),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Low stock list ───────────────────────────────────────────
          if (report.lowStockItems.isNotEmpty) ...[
            _SectionLabel(
              icon: Icons.warning_amber_rounded,
              title: 'Low Stock Items',
              count: report.lowStockItems.length,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 8),
            ...report.lowStockItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LowStockRow(item: item),
                )),
            const SizedBox(height: 16),
          ],

          // ── Expiring items list ───────────────────────────────────────
          if (report.expiringItems.isNotEmpty) ...[
            _SectionLabel(
              icon: Icons.hourglass_bottom_rounded,
              title: 'Expiring Soon',
              count: report.expiringItems.length,
              color: const Color(0xFFF44336),
            ),
            const SizedBox(height: 8),
            ...report.expiringItems.take(10).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ExpiringRow(item: item, fmt: fmt),
                )),
          ],

          if (report.lowStockItems.isEmpty &&
              report.expiringItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 44, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 12),
                  const Text('Inventory looks healthy!',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text(
                    'No low stock or expiring items.',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      );
}

class _LowStockRow extends StatelessWidget {
  const _LowStockRow({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final pct = item.reorderLevel == 0
        ? 0.0
        : (item.currentQty / item.reorderLevel).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFFFE0B2), width: 0.8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.tradeName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.grey.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFFF9800)),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.currentQty} / ${item.reorderLevel}',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFF9800)),
          ),
        ],
      ),
    );
  }
}

class _ExpiringRow extends StatelessWidget {
  const _ExpiringRow({required this.item, required this.fmt});
  final dynamic item;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    final urgent = item.daysLeft <= 7;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: urgent
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFFFE0B2),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: urgent
                  ? const Color(0xFFFFF3F3)
                  : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.hourglass_bottom_rounded,
                size: 18,
                color: urgent
                    ? const Color(0xFFF44336)
                    : const Color(0xFFFF9800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.tradeName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  'Batch ${item.batchNo} · ${item.qtyAvailable} units',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.daysLeft} days left',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: urgent
                        ? const Color(0xFFF44336)
                        : const Color(0xFFFF9800)),
              ),
              Text(fmt.format(item.stockValue),
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888))),
            ],
          ),
        ],
      ),
    );
  }
}