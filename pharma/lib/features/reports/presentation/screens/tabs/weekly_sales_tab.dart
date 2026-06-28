import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/reports_viewmodel.dart';
import '../../widgets/date_navigator.dart';
import '_shared_tab_widgets.dart';

class WeeklySalesTab extends ConsumerWidget {
  const WeeklySalesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsViewModelProvider);
    final vm    = ref.read(reportsViewModelProvider.notifier);
    final date  = state.selectedDate ?? DateTime.now();
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final isCurrentWeek = weekStart.year == thisWeekStart.year &&
        weekStart.month == thisWeekStart.month &&
        weekStart.day == thisWeekStart.day;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: DateNavigator(
            label: formatWeeklyLabel(weekStart),
            onPrevious: vm.goToPreviousPeriod,
            onNext: vm.goToNextPeriod,
            canGoNext: !isCurrentWeek,
          ),
        ),
        Expanded(
          child: state.isLoading
              ? const ReportLoading()
              : state.errorMessage != null
                  ? ReportError(
                      message: state.errorMessage!,
                      onRetry: () => vm.loadReport(ReportTab.weekly))
                  : state.salesReport == null
                      ? const SizedBox()
                      : SalesReportBody(report: state.salesReport!),
        ),
      ],
    );
  }
}