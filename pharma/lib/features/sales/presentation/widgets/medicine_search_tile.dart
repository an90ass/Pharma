import 'package:flutter/material.dart';
import '../../domain/entities/medicine_search_result.dart';

class MedicineSearchTile extends StatelessWidget {
  const MedicineSearchTile({
    super.key,
    required this.medicine,
    required this.onAddToCart,
  });
  final MedicineSearchResult medicine;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final inStock = medicine.isInStock;
    return InkWell(
      onTap: inStock ? onAddToCart : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: inStock
                ? Colors.black.withOpacity(0.06)
                : const Color(0xFFFFCDD2),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: inStock
                    ? const Color(0xFFE8F0FE)
                    : const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.medication_rounded,
                color: inStock
                    ? const Color(0xFF1565C0)
                    : const Color(0xFFE53935),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.tradeName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    '${medicine.genericName} · ${medicine.strength} · ${medicine.form}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF888888)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: inStock
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3F3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        inStock
                            ? '${medicine.totalQtyAvailable} in stock'
                            : 'Out of stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: inStock
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE53935),
                        ),
                      ),
                    ),
                    if (medicine.isControlled) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Rx',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE65100))),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price + add
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs ${medicine.salePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0)),
                ),
                const SizedBox(height: 6),
                if (inStock)
                  Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 18),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}