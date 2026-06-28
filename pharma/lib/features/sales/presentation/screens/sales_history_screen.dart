import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/invoice_entity.dart';
import '../viewmodels/sales_history_viewmodel.dart';
import '../widgets/invoice_summary_tile.dart';
import 'invoice_detail_screen.dart';

class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() =>
      _SalesHistoryScreenState();
}

class _SalesHistoryScreenState
    extends ConsumerState<SalesHistoryScreen> {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final state = ref.read(salesHistoryViewModelProvider);
      if (state.status != HistoryStatus.loading && state.hasMore) {
        ref.read(salesHistoryViewModelProvider.notifier)
            .loadHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesHistoryViewModelProvider);
    final vm    = ref.read(salesHistoryViewModelProvider.notifier);

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
        title: const Text('Sales History',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded,
                color: Color(0xFF1565C0)),
            tooltip: 'Filter by date',
            onPressed: () => _showDateFilter(context, vm, state),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF1565C0)),
            onPressed: () => vm.loadHistory(refresh: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Stats bar ───────────────────────────────────────────────
          _StatsBar(invoices: state.invoices),

          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) {
                vm.search(q);
                setState(() {});
              },
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by invoice no or phone…',
                hintStyle: const TextStyle(
                    fontSize: 13, color: Color(0xFFBBBBBB)),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF1565C0), size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          vm.clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE8E8E8))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1565C0), width: 1.5)),
              ),
            ),
          ),

          // ── Status filter chips ─────────────────────────────────────
          if (!state.isSearching)
            _StatusFilterRow(state: state, vm: vm),

          // ── List ────────────────────────────────────────────────────
          Expanded(child: _buildList(context, state, vm)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, SalesHistoryState state,
      SalesHistoryViewModel vm) {
    if (state.status == HistoryStatus.loading &&
        state.displayed.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == HistoryStatus.error &&
        state.displayed.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 40, color: Color(0xFFE53935)),
            const SizedBox(height: 12),
            Text(state.errorMessage ?? 'Failed to load',
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF888888))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => vm.loadHistory(refresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0)),
            ),
          ],
        ),
      );
    }
    if (state.displayed.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_rounded,
                size: 44, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            Text(
              state.isSearching
                  ? 'No invoices found'
                  : 'No sales yet today',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadHistory(refresh: true),
      color: const Color(0xFF1565C0),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: state.displayed.length +
            (state.hasMore && !state.isSearching ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          if (i == state.displayed.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return InvoiceSummaryTile(
            invoice: state.displayed[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InvoiceDetailScreen(
                  invoiceId: state.displayed[i].id,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDateFilter(BuildContext context, SalesHistoryViewModel vm,
      SalesHistoryState state) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: state.selectedFrom != null
          ? DateTimeRange(
              start: state.selectedFrom!,
              end: state.selectedTo ?? DateTime.now())
          : null,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0)),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      vm.setDateFilter(range.start, range.end);
    }
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.invoices});
  final List<InvoiceSummary> invoices;

  @override
  Widget build(BuildContext context) {
    final total =
        invoices.fold(0.0, (s, i) => s + i.grandTotal);
    final paid = invoices
        .where((i) => i.status == InvoiceStatus.paid)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _StatItem(
              label: 'Invoices',
              value: '${invoices.length}'),
          _Divider(),
          _StatItem(
              label: 'Paid',
              value: '$paid'),
          _Divider(),
          _StatItem(
              label: 'Total',
              value: NumberFormat.currency(
                      symbol: 'Rs ', decimalDigits: 0)
                  .format(total)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Colors.white60)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1, height: 28,
        color: Colors.white.withOpacity(0.2),
        margin: const EdgeInsets.symmetric(horizontal: 8));
}

// ── Status filter row ─────────────────────────────────────────────────────────

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.state, required this.vm});
  final SalesHistoryState state;
  final SalesHistoryViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            active: state.selectedFrom == null,
            onTap: () => vm.setDateFilter(null, null),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Today',
            active: false,
            onTap: () {
              final now = DateTime.now();
              vm.setDateFilter(
                DateTime(now.year, now.month, now.day),
                now,
              );
            },
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'This month',
            active: false,
            onTap: () {
              final now = DateTime.now();
              vm.setDateFilter(
                DateTime(now.year, now.month, 1), now);
            },
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label,
      required this.active,
      required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const c = Color(0xFF1565C0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? c.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? c : Colors.black.withOpacity(0.1),
            width: active ? 1.2 : 0.8,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? c : const Color(0xFF555555))),
      ),
    );
  }
}