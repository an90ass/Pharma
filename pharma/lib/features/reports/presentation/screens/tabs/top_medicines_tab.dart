import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/reports_viewmodel.dart';
import '../../widgets/top_medicine_tile.dart';
import '_shared_tab_widgets.dart';

class TopMedicinesTab extends ConsumerWidget {
  const TopMedicinesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsViewModelProvider);
    final vm    = ref.read(reportsViewModelProvider.notifier);

    if (state.isLoading) return const ReportLoading();
    if (state.errorMessage != null) {
      return ReportError(
        message: state.errorMessage!,
        onRetry: () => vm.loadReport(ReportTab.topMedicines),
      );
    }
    if (state.topMedicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_outline_rounded,
                size: 44, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            const Text('No sales data yet',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Top medicines will appear once sales begin.',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF888888))),
          ],
        ),
      );
    }

    final totalRevenue = state.topMedicines
        .fold(0.0, (s, m) => s + m.totalRevenue);
    final totalQty = state.topMedicines
        .fold(0, (s, m) => s + m.totalQtySold);

    return RefreshIndicator(
      onRefresh: () => vm.loadReport(ReportTab.topMedicines),
      color: const Color(0xFF1565C0),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last 30 days',
                          style: TextStyle(
                              fontSize: 11, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(
                                symbol: '\$ ', decimalDigits: 0)
                            .format(totalRevenue),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      Text('from top ${state.topMedicines.length} medicines',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.medication_rounded,
                        color: Colors.white70, size: 28),
                    const SizedBox(height: 4),
                    Text('$totalQty units',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const Text('sold total',
                        style: TextStyle(
                            fontSize: 10, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ranked list
          ...state.topMedicines.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TopMedicineTile(medicine: m),
              )),
        ],
      ),
    );
  }
}