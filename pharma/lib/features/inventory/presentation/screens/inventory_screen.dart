import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../widgets/batch_card.dart';
import '../widgets/low_stock_card.dart';
import 'receive_stock_screen.dart';
import 'purchase_orders_screen.dart';
import 'adjust_stock_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryViewModelProvider);
    final vm = ref.read(inventoryViewModelProvider.notifier);

    // Snackbar feedback
    ref.listen(inventoryViewModelProvider, (_, next) {
      if (next.actionStatus == InventoryActionStatus.success &&
          next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        vm.clearMessages();
      }
      if (next.actionStatus == InventoryActionStatus.error &&
          next.actionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.actionError!),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Inventory',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded,
                color: Color(0xFF1565C0)),
            tooltip: 'Purchase orders',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const PurchaseOrdersScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF1565C0)),
            onPressed: vm.loadAlerts,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tab,
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorColor: const Color(0xFF1565C0),
          labelColor: const Color(0xFF1565C0),
          unselectedLabelColor: const Color(0xFF888888),
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Low Stock'),
                if (state.lowStockItems.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _AlertBubble(count: state.lowStockItems.length,
                      color: const Color(0xFFF44336)),
                ],
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Expiring'),
                if (state.expiringBatches.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _AlertBubble(count: state.expiringBatches.length,
                      color: const Color(0xFFFF9800)),
                ],
              ]),
            ),
            const Tab(text: 'Receive Stock'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: vm.loadAlerts,
        color: const Color(0xFF1565C0),
        child: TabBarView(
          controller: _tab,
          children: [
            _LowStockTab(state: state),
            _ExpiringTab(state: state, vm: vm),
            const _ReceiveTab(),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Low Stock ────────────────────────────────────────────────────────────

class _LowStockTab extends StatelessWidget {
  const _LowStockTab({required this.state});
  final InventoryState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.lowStockItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.lowStockItems.isEmpty) {
      return const _EmptyAlert(
        icon: Icons.check_circle_outline_rounded,
        color: Color(0xFF4CAF50),
        title: 'All stock levels OK',
        subtitle: 'No medicines are below their reorder level.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.lowStockItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => LowStockCard(
        summary: state.lowStockItems[i],
        onOrder: () => Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const PurchaseOrdersScreen())),
      ),
    );
  }
}

// ── Tab: Expiring ─────────────────────────────────────────────────────────────

class _ExpiringTab extends StatelessWidget {
  const _ExpiringTab({required this.state, required this.vm});
  final InventoryState state;
  final InventoryViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.expiringBatches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Days filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [30, 60, 90].map((days) {
                final active = state.expiryDaysFilter == days;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => vm.setExpiryDaysFilter(days),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF1565C0)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? const Color(0xFF1565C0)
                              : Colors.black.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        '$days days',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (state.expiringBatches.isEmpty)
          const Expanded(
            child: _EmptyAlert(
              icon: Icons.verified_rounded,
              color: Color(0xFF4CAF50),
              title: 'No expiring medicines',
              subtitle: 'All batches are within acceptable expiry range.',
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: state.expiringBatches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final batch = state.expiringBatches[i];
                return BatchCard(
                  batch: batch,
                  onAdjust: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AdjustStockScreen(batch: batch))),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Tab: Receive ──────────────────────────────────────────────────────────────

class _ReceiveTab extends StatelessWidget {
  const _ReceiveTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add_box_rounded,
                  size: 36, color: Color(0xFF1565C0)),
            ),
            const SizedBox(height: 16),
            const Text('Receive stock',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Record new stock received from a supplier. '
              'Each receipt creates a new batch with expiry tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const ReceiveStockScreen())),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Receive new stock'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _AlertBubble extends StatelessWidget {
  const _AlertBubble({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          count > 9 ? '9+' : '$count',
          style: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }
}

class _EmptyAlert extends StatelessWidget {
  const _EmptyAlert({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888888))),
          ],
        ),
      ),
    );
  }
}