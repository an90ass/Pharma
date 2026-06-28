import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable prev/next date navigator for daily/weekly/monthly reports.
class DateNavigator extends StatelessWidget {
  const DateNavigator({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.canGoNext = true,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded,
                color: Color(0xFF1565C0)),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E)),
            ),
          ),
          IconButton(
            onPressed: canGoNext ? onNext : null,
            icon: Icon(Icons.chevron_right_rounded,
                color: canGoNext
                    ? const Color(0xFF1565C0)
                    : const Color(0xFFCCCCCC)),
          ),
        ],
      ),
    );
  }
}

String formatDailyLabel(DateTime date) =>
    DateFormat('EEEE, d MMM yyyy').format(date);

String formatWeeklyLabel(DateTime weekStart) {
  final end = weekStart.add(const Duration(days: 6));
  return '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM yyyy').format(end)}';
}

String formatMonthlyLabel(int year, int month) =>
    DateFormat('MMMM yyyy').format(DateTime(year, month));