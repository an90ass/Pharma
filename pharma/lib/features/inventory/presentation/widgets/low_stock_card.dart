import 'package:flutter/material.dart';
import '../../domain/entities/batch_entity.dart';

class LowStockCard extends StatelessWidget {
  const LowStockCard({
    super.key,
    required this.summary,
    required this.onOrder,
  });

  final StockSummary summary;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final pct = summary.reorderLevel == 0
        ? 0.0
        : (summary.totalQtyAvailable / summary.reorderLevel).clamp(0.0, 2.0);
    final isOut = summary.isOutOfStock;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOut
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFFFE0B2),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isOut
                      ? const Color(0xFFFFF3F3)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  isOut
                      ? Icons.remove_shopping_cart_rounded
                      : Icons.warning_amber_rounded,
                  size: 18,
                  color: isOut
                      ? const Color(0xFFF44336)
                      : const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.tradeName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      summary.genericName,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOut
                      ? const Color(0xFFF44336)
                      : const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOut ? 'OUT' : 'LOW',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stock level bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${summary.totalQtyAvailable} available',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555)),
                        ),
                        Text(
                          'Reorder at ${summary.reorderLevel}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFFAAAAAA)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOut
                              ? const Color(0xFFF44336)
                              : pct < 0.5
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFF4CAF50),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onOrder,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                label: const Text('Order',
                    style: TextStyle(fontSize: 12)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}