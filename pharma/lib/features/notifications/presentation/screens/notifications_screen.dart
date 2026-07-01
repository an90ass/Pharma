import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pharma/features/inventory/presentation/viewmodels/inventory_viewmodel.dart';
import 'package:pharma/features/inventory/domain/entities/batch_entity.dart';
import 'package:pharma/features/medicines/presentation/viewmodels/medicine_viewmodel.dart';
import 'package:pharma/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:pharma/features/medicines/presentation/screens/edit_medicine_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryViewModelProvider);
    final vm = ref.read(inventoryViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF1565C0),
        onRefresh: () => vm.loadAlerts(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const _SectionTitle(label: 'Low stock'),
            const SizedBox(height: 8),
            if (state.lowStockItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No low stock alerts')),
              )
            else
              ...state.lowStockItems.map((s) => _LowStockTile(summary: s)),
            const SizedBox(height: 20),
            const _SectionTitle(label: 'Expiring soon'),
            const SizedBox(height: 8),
            if (state.expiringBatches.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No expiring batches')),
              )
            else
              ...state.expiringBatches.map((b) => _ExpiringTile(batch: b)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)));
}

class _LowStockTile extends ConsumerWidget {
  const _LowStockTile({required this.summary});
  final StockSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = const Color(0xFF1565C0);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () {
          // Open Inventory screen on Low Stock tab
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const InventoryScreen(initialTab: 0)));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(Icons.inventory_2, color: color),
        ),
        title: Text(summary.tradeName, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.12)),
              ),
              child: Text('Remaining: ${summary.totalQtyAvailable}',
                  style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Reorder: ${summary.reorderLevel}', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF1565C0)),
      ),
    );
  }
}

class _ExpiringTile extends ConsumerWidget {
  const _ExpiringTile({required this.batch});
  final BatchEntity batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('d MMM yyyy');
    final expiry = fmt.format(batch.expiryDate);
    final color = const Color(0xFFFF7043);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () {
          // Open Inventory screen on Expiring tab
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const InventoryScreen(initialTab: 1)));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: const Icon(Icons.hourglass_bottom_rounded, color: Color(0xFFFF5722)),
        ),
        title: Text(batch.tradeName, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('Batch ${batch.batchNo} • Expiry: $expiry', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF1565C0)),
      ),
    );
  }
}
