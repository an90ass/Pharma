import 'package:flutter/material.dart';
import '../../domain/entities/invoice_item_entity.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
    required this.onDiscountChanged,
  });
  final InvoiceItemEntity item;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;
  final ValueChanged<double> onDiscountChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.tradeName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '${item.genericName} · Batch ${item.batchNo}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFFE53935)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                    minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Qty + price row ─────────────────────────────────────────
          Row(
            children: [
              // Qty stepper
              _QtyStepper(
                qty: item.qty,
                onDecrement: () => onQtyChanged(item.qty - 1),
                onIncrement: () => onQtyChanged(item.qty + 1),
              ),
              const Spacer(),
              // Unit price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${item.unitPrice.toStringAsFixed(0)} × ${item.qty}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF888888)),
                  ),
                  Text(
                    'Rs ${item.lineTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0)),
                  ),
                ],
              ),
            ],
          ),
          // ── Discount slider ─────────────────────────────────────────
          if (item.discountPct > 0 || true) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Disc:',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA))),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14),
                      activeTrackColor: const Color(0xFF1565C0),
                      thumbColor: const Color(0xFF1565C0),
                    ),
                    child: Slider(
                      value: item.discountPct,
                      min: 0, max: 30,
                      divisions: 30,
                      onChanged: onDiscountChanged,
                    ),
                  ),
                ),
                Text(
                  '${item.discountPct.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.black.withOpacity(0.1), width: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(icon: Icons.remove_rounded, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('$qty',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          _Btn(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF1565C0)),
        ),
      );
}