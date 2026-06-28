import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/top_medicine_entity.dart';

/// Ranked list tile for the Top Selling Medicines report.
class TopMedicineTile extends StatelessWidget {
  const TopMedicineTile({super.key, required this.medicine});
  final TopMedicineEntity medicine;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);
    final rankColor = switch (medicine.rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => const Color(0xFFE0E0E0),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: rankColor, width: 1.5),
            ),
            child: Center(
              child: Text('${medicine.rank}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: rankColor == const Color(0xFFFFD700)
                          ? const Color(0xFFB8860B)
                          : const Color(0xFF555555))),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine.tradeName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text(
                  '${medicine.genericName} · ${medicine.category}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  _Pill(
                    icon: Icons.shopping_bag_rounded,
                    label: '${medicine.totalQtySold} sold',
                    color: const Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 6),
                  _Pill(
                    icon: Icons.trending_up_rounded,
                    label: '${medicine.profitMargin.toStringAsFixed(0)}% margin',
                    color: const Color(0xFF2E7D32),
                  ),
                ]),
              ],
            ),
          ),
          // Revenue
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt.format(medicine.totalRevenue),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1565C0))),
              Text('${fmt.format(medicine.totalProfit)} profit',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF2E7D32))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      );
}