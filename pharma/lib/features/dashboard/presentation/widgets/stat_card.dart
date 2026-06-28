import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable KPI summary card used throughout the dashboard.
///
/// Shows an icon, label, value, and optional trend/badge.
/// [isAlert] turns the card red when attention is needed (low stock, expiry).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isCurrency = false,
    this.isAlert = false,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final num value;
  final IconData icon;
  final Color color;
  final bool isCurrency;
  final bool isAlert;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = isAlert
        ? const Color(0xFFFFF3F3)
        : theme.colorScheme.surface;
    final borderColor = isAlert
        ? const Color(0xFFFFCDD2)
        : theme.colorScheme.outlineVariant.withOpacity(0.5);
    final effectiveColor = isAlert ? const Color(0xFFE53935) : color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: effectiveColor, size: 18),
                ),
                if (isAlert)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCDD2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Alert',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _formatValue(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: effectiveColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatValue() {
    if (isCurrency) {
      final formatter =
          NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);
      return formatter.format(value);
    }
    return NumberFormat.compact().format(value);
  }
}
