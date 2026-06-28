import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/reports_viewmodel.dart';
import '../../widgets/date_navigator.dart';
import '_shared_tab_widgets.dart';

class MonthlySalesTab extends ConsumerWidget {
  const MonthlySalesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsViewModelProvider);
    final vm    = ref.read(reportsViewModelProvider.notifier);
    final now   = DateTime.now();
    final year  = state.selectedYear  ?? now.year;
    final month = state.selectedMonth ?? now.month;
    final isCurrentMonth = year == now.year && month == now.month;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: DateNavigator(
            label: formatMonthlyLabel(year, month),
            onPrevious: vm.goToPreviousPeriod,
            onNext: vm.goToNextPeriod,
            canGoNext: !isCurrentMonth,
          ),
        ),
        Expanded(
          child: state.isLoading
              ? const ReportLoading()
              : state.errorMessage != null
                  ? ReportError(
                      message: state.errorMessage!,
                      onRetry: () => vm.loadReport(ReportTab.monthly))
                  : state.salesReport == null
                      ? const SizedBox()
                      : SalesReportBody(report: state.salesReport!),
        ),
      ],
    );
  }
}