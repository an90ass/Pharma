import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/invoice_entity.dart';

class InvoiceSummaryTile extends StatelessWidget {
  const InvoiceSummaryTile({
    super.key,
    required this.invoice,
    required this.onTap,
  });
  final InvoiceSummary invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(invoice.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.black.withOpacity(0.06), width: 0.8),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  color: Color(0xFF1565C0), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(invoice.invoiceNo,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(invoice.status.label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${invoice.customerName} · '
                    '${invoice.itemCount} item${invoice.itemCount != 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d MMM yyyy · h:mm a')
                            .format(invoice.createdAt),
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFFBBBBBB)),
                      ),
                      Text(
                        NumberFormat.currency(
                                symbol: 'Rs ', decimalDigits: 0)
                            .format(invoice.grandTotal),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(InvoiceStatus s) => switch (s) {
        InvoiceStatus.paid     => const Color(0xFF2E7D32),
        InvoiceStatus.credit   => const Color(0xFFFF9800),
        InvoiceStatus.returned => const Color(0xFFE53935),
        InvoiceStatus.void_    => const Color(0xFF9E9E9E),
      };
}