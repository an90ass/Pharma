import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../viewmodels/purchase_order_viewmodel.dart';
import '../widgets/po_status_badge.dart';
import 'create_purchase_order_screen.dart';

class PurchaseOrdersScreen extends ConsumerWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(poViewModelProvider);
    final vm    = ref.read(poViewModelProvider.notifier);

    // Snackbar feedback
    ref.listen(poViewModelProvider, (_, next) {
      if (next.actionStatus == POActionStatus.success &&
          next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
        vm.clearMessages();
      }
      if (next.actionStatus == POActionStatus.error &&
          next.actionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.actionError!),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
        vm.clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Purchase Orders',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1565C0)),
            onPressed: vm.loadOrders,
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const CreatePurchaseOrderScreen())),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New PO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // ── Status filter tabs ──────────────────────────────────────
          Container(
            color: const Color(0xFFF7F8FC),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: state.selectedStatus == null,
                    onTap: () => vm.filterByStatus(null),
                    count: state.orders.length,
                  ),
                  const SizedBox(width: 8),
                  ...POStatus.values.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: s.label,
                          selected: state.selectedStatus == s,
                          onTap: () => vm.filterByStatus(s),
                          count: state.orders
                              .where((o) => o.status == s)
                              .length,
                          status: s,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          Expanded(child: _buildBody(context, ref, state, vm)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      POState state, POViewModel vm) {
    if (state.actionStatus == POActionStatus.loading &&
        state.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.actionStatus == POActionStatus.error &&
        state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 40, color: Color(0xFFE53935)),
            const SizedBox(height: 12),
            Text(state.actionError ?? 'Failed to load',
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF888888))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: vm.loadOrders,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0)),
            ),
          ],
        ),
      );
    }
    if (state.filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_rounded,
                size: 48, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            const Text('No purchase orders',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Create a new PO to get started.',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF888888))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadOrders,
      color: const Color(0xFF1565C0),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: state.filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _POCard(
          po: state.filtered[i],
          onCancel: state.filtered[i].status.isEditable ||
                  state.filtered[i].status == POStatus.sent
              ? () => _confirmCancel(context, vm, state.filtered[i])
              : null,
        ),
      ),
    );
  }

  void _confirmCancel(
      BuildContext context, POViewModel vm, PurchaseOrderEntity po) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel order?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Cancel PO ${po.poNumber}? This action cannot be undone.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              vm.cancelOrder(po.id);
            },
            child: const Text('Cancel PO'),
          ),
        ],
      ),
    );
  }
}

// ── PO Card ───────────────────────────────────────────────────────────────────

class _POCard extends StatelessWidget {
  const _POCard({required this.po, this.onCancel});
  final PurchaseOrderEntity po;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.black.withOpacity(0.06), width: 0.8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      color: Color(0xFF1565C0), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(po.poNumber,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 2),
                      Text(po.supplierName,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF888888))),
                    ],
                  ),
                ),
                POStatusBadge(status: po.status),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────
          Divider(
              height: 1,
              color: Colors.black.withOpacity(0.05)),

          // ── Metrics row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _MetricItem(
                  label: 'Items',
                  value: '${po.items.length}',
                  icon: Icons.medication_rounded,
                ),
                const _Dot(),
                _MetricItem(
                  label: 'Total',
                  value: fmt.format(po.computedTotal),
                  icon: Icons.attach_money_rounded,
                ),
                const _Dot(),
                _MetricItem(
                  label: 'Date',
                  value: DateFormat('d MMM yy').format(po.createdAt),
                  icon: Icons.calendar_today_rounded,
                ),
                if (po.expectedDate != null) ...[
                  const _Dot(),
                  _MetricItem(
                    label: 'Expected',
                    value: DateFormat('d MMM').format(po.expectedDate!),
                    icon: Icons.local_shipping_rounded,
                  ),
                ],
              ],
            ),
          ),

          // ── Progress bar for partial/received ────────────────────────
          if (po.status == POStatus.partial ||
              po.status == POStatus.received) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${po.totalItemsReceived} / ${po.totalItemsOrdered} units received',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF888888)),
                      ),
                      Text(
                        '${((po.totalItemsReceived / po.totalItemsOrdered) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: po.totalItemsOrdered == 0
                          ? 0
                          : po.totalItemsReceived /
                              po.totalItemsOrdered,
                      backgroundColor:
                          Colors.grey.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32)),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Cancel action ─────────────────────────────────────────────
          if (onCancel != null) ...[
            Divider(height: 1, color: Colors.black.withOpacity(0.05)),
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined,
                  size: 14, color: Color(0xFFE53935)),
              label: const Text('Cancel order',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFFE53935))),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFFAAAAAA))),
          const SizedBox(height: 2),
          Row(children: [
            Icon(icon, size: 12, color: const Color(0xFF555555)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.black.withOpacity(0.07),
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.count,
    this.status,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int count;
  final POStatus? status;

  @override
  Widget build(BuildContext context) {
    const active = Color(0xFF1565C0);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? active.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? active : Colors.black.withOpacity(0.1),
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? active : const Color(0xFF555555),
                )),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? active.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selected ? active : const Color(0xFF888888),
                    )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}