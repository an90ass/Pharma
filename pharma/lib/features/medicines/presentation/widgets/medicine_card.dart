import 'package:flutter/material.dart';
import '../../domain/entities/medicine_entity.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicineEntity medicine;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.06),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon bubble
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _categoryColor(medicine.category).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: _categoryColor(medicine.category),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.tradeName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medicine.genericName,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action menu
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Chips row ───────────────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Chip(
                  label: medicine.form.label,
                  color: const Color(0xFF1565C0),
                ),
                _Chip(
                  label: medicine.category.label,
                  color: _categoryColor(medicine.category),
                ),
                _Chip(
                  label: medicine.strength,
                  color: const Color(0xFF37474F),
                ),
                if (medicine.isControlled)
                  _Chip(
                    label: 'Controlled',
                    color: const Color(0xFFF44336),
                    icon: Icons.warning_rounded,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Price + manufacturer row ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _PriceItem(
                    label: 'Sale',
                    value: 'Rs ${medicine.salePrice.toStringAsFixed(0)}',
                    valueColor: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _PriceItem(
                    label: 'Purchase',
                    value: 'Rs ${medicine.purchasePrice.toStringAsFixed(0)}',
                    valueColor: const Color(0xFF1565C0),
                  ),
                ),
                Expanded(
                  child: _PriceItem(
                    label: 'Margin',
                    value: '${medicine.profitMargin.toStringAsFixed(1)}%',
                    valueColor: const Color(0xFF7B1FA2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              medicine.manufacturer,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(MedicineCategory cat) => switch (cat) {
        MedicineCategory.otc => const Color(0xFF2196F3),
        MedicineCategory.prescription => const Color(0xFF9C27B0),
        MedicineCategory.controlled => const Color(0xFFF44336),
        MedicineCategory.generic => const Color(0xFF4CAF50),
        MedicineCategory.herbal => const Color(0xFF009688),
        MedicineCategory.supplement => const Color(0xFFFF9800),
      };
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 11),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  const _PriceItem(
      {required this.label, required this.value, required this.valueColor});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}