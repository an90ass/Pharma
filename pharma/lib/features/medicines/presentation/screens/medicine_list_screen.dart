import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/medicine_viewmodel.dart';
import '../widgets/medicine_card.dart';
import '../widgets/medicine_filter_bar.dart';
import '../widgets/medicine_search_bar.dart';
import 'add_medicine_screen.dart';
import 'edit_medicine_screen.dart';

class MedicineListScreen extends ConsumerWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(medicineViewModelProvider);
  
  final vm = ref.read(medicineViewModelProvider.notifier);
    // Show success/error snackbars
    ref.listen(medicineViewModelProvider, (prev, next) {
      if (next.actionStatus == MedicineActionStatus.success &&
          next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        vm.clearActionMessages();
      }
      if (next.actionStatus == MedicineActionStatus.error &&
          next.actionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.actionError!),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        vm.clearActionMessages();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _buildAppBar(context, state, vm),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context, ref),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add medicine',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => vm.restartWatching(),
        color: const Color(0xFF1565C0),
        child: _buildBody(context, ref, state, vm),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, MedicineState state, MedicineViewModel vm) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FC),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/'),
      ),
      title: const Text(
        'Medicines',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E),
        ),
      ),
      actions: [
        // Stats badge
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${state.filtered.length} of ${state.medicines.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      MedicineState state, MedicineViewModel vm) {
    return Column(
      children: [
        // ── Search + Filter bar ──────────────────────────────────────
        Container(
          color: const Color(0xFFF7F8FC),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              MedicineSearchBar(
                onChanged: vm.onSearchChanged,
              ),
              const SizedBox(height: 10),
              MedicineFilterBar(
                selectedCategory: state.selectedCategory,
                selectedForm: state.selectedForm,
                controlledOnly: state.controlledOnly,
                hasActiveFilters: state.hasActiveFilters,
                onCategoryChanged: vm.setCategory,
                onFormChanged: vm.setForm,
                onControlledToggled: vm.toggleControlledOnly,
                onClearAll: vm.clearFilters,
              ),
            ],
          ),
        ),

        // ── Content ──────────────────────────────────────────────────
        Expanded(
          child: _buildContent(context, ref, state, vm),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref,
      MedicineState state, MedicineViewModel vm) {
    if (state.actionStatus == MedicineActionStatus.loading &&
        state.medicines.isEmpty) {
      return const _MedicineShimmer();
    }

    if (state.actionStatus == MedicineActionStatus.error &&
        state.medicines.isEmpty) {
      return _ErrorState(
        message: state.actionError ?? 'Failed to load medicines.',
        onRetry: vm.restartWatching,
      );
    }

    if (state.filtered.isEmpty) {
      return _EmptyState(
        hasQuery: state.searchQuery.isNotEmpty || state.hasActiveFilters,
        onClear: () {
          vm.onSearchChanged('');
          vm.clearFilters();
        },
        onAdd: () => _openAdd(context, ref),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: state.filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final medicine = state.filtered[i];
        return MedicineCard(
          medicine: medicine,
          onTap: () => _openEdit(context, ref, medicine.id),
          onEdit: () => _openEdit(context, ref, medicine.id),
          onDelete: () => _confirmDelete(context, vm, medicine.id, medicine.tradeName),
        );
      },
    );
  }

  void _openAdd(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
  }

  void _openEdit(BuildContext context, WidgetRef ref, String id) {
    final medicine = ref
        .read(medicineViewModelProvider)
        .medicines
        .firstWhere((m) => m.id == id);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EditMedicineScreen(medicine: medicine)),
    );
  }

  void _confirmDelete(BuildContext context, MedicineViewModel vm,
      String id, String tradeName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete medicine',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Delete "$tradeName"? This cannot be undone. '
          'Existing invoices will not be affected.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              vm.deleteMedicine(id, tradeName);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasQuery,
    required this.onClear,
    required this.onAdd,
  });
  final bool hasQuery;
  final VoidCallback onClear;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.medication_rounded,
                  size: 36, color: Color(0xFF1565C0)),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No results found' : 'No medicines yet',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try a different search or clear filters.'
                  : 'Add your first medicine to get started.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 20),
            hasQuery
                ? OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Clear search'),
                  )
                : FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add medicine'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 40, color: Color(0xFFE53935)),
            const SizedBox(height: 12),
            const Text('Failed to load',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 20),
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
}

// ── Shimmer loading ────────────────────────────────────────────────────────────

class _MedicineShimmer extends StatefulWidget {
  const _MedicineShimmer();
  @override
  State<_MedicineShimmer> createState() => _MedicineShimmerState();
}

class _MedicineShimmerState extends State<_MedicineShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.05, end: 0.13).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: 148,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(_anim.value),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}