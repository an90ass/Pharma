import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/dashboard_stats.dart';

/// A single row in the recent activity feed.
class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.activity});

  final RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _activityConfig(activity.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bubble
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(config.icon, color: config.color, size: 18),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.description,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (activity.amount != null)
                      Text(
                        NumberFormat.currency(
                          symbol: 'Rs ',
                          decimalDigits: 0,
                        ).format(activity.amount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: config.color,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${activity.performedBy} · ${_timeAgo(activity.timestamp)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _ActivityConfig _activityConfig(ActivityType type) {
    return switch (type) {
      ActivityType.sale => _ActivityConfig(
          Icons.point_of_sale_rounded, const Color(0xFF2196F3)),
      ActivityType.purchase => _ActivityConfig(
          Icons.local_shipping_rounded, const Color(0xFF9C27B0)),
      ActivityType.stockAdjustment => _ActivityConfig(
          Icons.tune_rounded, const Color(0xFFFF9800)),
      ActivityType.newMedicine => _ActivityConfig(
          Icons.medication_rounded, const Color(0xFF4CAF50)),
      ActivityType.newCustomer => _ActivityConfig(
          Icons.person_add_rounded, const Color(0xFF00BCD4)),
      ActivityType.prescriptionAdded => _ActivityConfig(
          Icons.description_rounded, const Color(0xFF3F51B5)),
      ActivityType.lowStockAlert => _ActivityConfig(
          Icons.warning_rounded, const Color(0xFFF44336)),
      ActivityType.expiryAlert => _ActivityConfig(
          Icons.hourglass_bottom_rounded, const Color(0xFFFF5722)),
    };
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM').format(time);
  }
}

class _ActivityConfig {
  const _ActivityConfig(this.icon, this.color);
  final IconData icon;
  final Color color;
}
