import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/batch_entity.dart';

class BatchCard extends StatelessWidget {
  const BatchCard({
    super.key,
    required this.batch,
    this.onAdjust,
    this.compact = false,
  });

  final BatchEntity batch;
  final VoidCallback? onAdjust;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final urgency = batch.expiryUrgency;
    final urgencyColor = _urgencyColor(urgency);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: urgency == ExpiryUrgency.safe || urgency == ExpiryUrgency.notice
              ? Colors.black.withOpacity(0.06)
              : urgencyColor.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Batch no + expiry urgency dot
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                    color: urgencyColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Batch: ${batch.batchNo}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              // Qty chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: batch.qtyAvailable <= 0
                      ? const Color(0xFFFFF3F3)
                      : const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${batch.qtyAvailable} units',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: batch.qtyAvailable <= 0
                        ? const Color(0xFFE53935)
                        : const Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Expires',
                  value: DateFormat('d MMM yyyy').format(batch.expiryDate),
                  valueColor: urgencyColor,
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.attach_money_rounded,
                  label: 'Purchase',
                  value: '\$ ${batch.purchasePrice.toStringAsFixed(0)}',
                  valueColor: const Color(0xFF555555),
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.sell_rounded,
                  label: 'Sale',
                  value: '\$ ${batch.salePrice.toStringAsFixed(0)}',
                  valueColor: const Color(0xFF2E7D32),
                ),
              ],
            ),
            if (batch.location != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: Color(0xFFAAAAAA)),
                const SizedBox(width: 4),
                Text(
                  batch.location!,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFFAAAAAA)),
                ),
              ]),
            ],
            // Expiry countdown pill
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ExpiryPill(urgency: urgency, daysLeft: batch.daysUntilExpiry),
                if (onAdjust != null)
                  TextButton.icon(
                    onPressed: onAdjust,
                    icon: const Icon(Icons.tune_rounded, size: 14),
                    label: const Text('Adjust',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      foregroundColor: const Color(0xFF1565C0),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _urgencyColor(ExpiryUrgency u) => switch (u) {
        ExpiryUrgency.safe => const Color(0xFF4CAF50),
        ExpiryUrgency.notice => const Color(0xFF2196F3),
        ExpiryUrgency.warning => const Color(0xFFFF9800),
        ExpiryUrgency.critical => const Color(0xFFF44336),
        ExpiryUrgency.expired => const Color(0xFF9E9E9E),
      };
}

class _InfoItem extends StatelessWidget {
  const _InfoItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.valueColor});
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
        const SizedBox(height: 2),
        Row(children: [
          Icon(icon, size: 12, color: valueColor),
          const SizedBox(width: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ]),
      ],
    );
  }
}

class _ExpiryPill extends StatelessWidget {
  const _ExpiryPill({required this.urgency, required this.daysLeft});
  final ExpiryUrgency urgency;
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final color = switch (urgency) {
      ExpiryUrgency.safe => const Color(0xFF4CAF50),
      ExpiryUrgency.notice => const Color(0xFF2196F3),
      ExpiryUrgency.warning => const Color(0xFFFF9800),
      ExpiryUrgency.critical => const Color(0xFFF44336),
      ExpiryUrgency.expired => const Color(0xFF9E9E9E),
    };
    final label = urgency == ExpiryUrgency.expired
        ? 'Expired'
        : '$daysLeft days left';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_bottom_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}