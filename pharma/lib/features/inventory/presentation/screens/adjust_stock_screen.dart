import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/batch_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';
import '../viewmodels/inventory_viewmodel.dart';

class AdjustStockScreen extends ConsumerStatefulWidget {
  const AdjustStockScreen({super.key, required this.batch});
  final BatchEntity batch;

  @override
  ConsumerState<AdjustStockScreen> createState() => _AdjustStockScreenState();
}

class _AdjustStockScreenState extends ConsumerState<AdjustStockScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _qtyCtrl  = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;
  AdjustmentType _type = AdjustmentType.auditCorrection;
  bool _isAddition = false;   // true = +qty, false = -qty

  @override
  void initState() {
    super.initState();
    _isAddition = _type.isAddition;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Adjust Stock',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Apply',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── Batch summary card ────────────────────────────────────
            _BatchSummaryCard(batch: batch),
            const SizedBox(height: 12),

            // ── Adjustment type ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.black.withOpacity(0.06), width: 0.8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel(
                      title: 'Reason', icon: Icons.category_rounded),
                  const SizedBox(height: 12),
                  // Type grid
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: AdjustmentType.values.map((type) {
                      final selected = _type == type;
                      final isAdd = type.isAddition;
                      final color = isAdd
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF44336);
                      return GestureDetector(
                        onTap: () => setState(() {
                          _type = type;
                          _isAddition = type.isAddition;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withOpacity(0.1)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? color
                                  : Colors.black.withOpacity(0.08),
                              width: selected ? 1.2 : 0.8,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                isAdd
                                    ? Icons.add_circle_outline_rounded
                                    : Icons.remove_circle_outline_rounded,
                                size: 14,
                                color:
                                    selected ? color : const Color(0xFF888888),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  type.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? color
                                        : const Color(0xFF555555),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Qty + reason ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.black.withOpacity(0.06), width: 0.8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel(
                      title: 'Quantity & notes',
                      icon: Icons.edit_note_rounded),
                  const SizedBox(height: 12),

                  // Direction toggle + qty
                  Row(children: [
                    // +/- toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _isAddition = !_isAddition),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isAddition
                              ? const Color(0xFF2E7D32).withOpacity(0.1)
                              : const Color(0xFFF44336).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isAddition
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFF44336),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          _isAddition
                              ? Icons.add_rounded
                              : Icons.remove_rounded,
                          color: _isAddition
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFF44336),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) {
                            return 'Enter qty > 0';
                          }
                          if (!_isAddition &&
                              n > batch.qtyAvailable) {
                            return 'Cannot remove more than available (${batch.qtyAvailable})';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(
                              color: Color(0xFFCCCCCC), fontSize: 20),
                          labelText: 'Quantity *',
                          labelStyle: const TextStyle(
                              fontSize: 13, color: Color(0xFF666666)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE8E8E8))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1565C0), width: 1.5)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFF44336))),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),

                  // Preview pill
                  if (_qtyCtrl.text.isNotEmpty) ...[
                    _PreviewPill(
                      currentQty: batch.qtyAvailable,
                      adjustQty: int.tryParse(_qtyCtrl.text) ?? 0,
                      isAddition: _isAddition,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Reason text field
                  TextFormField(
                    controller: _reasonCtrl,
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Reason is required'
                            : null,
                    decoration: InputDecoration(
                      labelText: 'Reason / notes *',
                      labelStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF666666)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE0E0E0))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE8E8E8))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF1565C0), width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFF44336))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final rawQty = int.parse(_qtyCtrl.text);
    final finalQty = _isAddition ? rawQty.abs() : -rawQty.abs();

    // We pass the absolute qty; the repository applies sign based on type
    final params = AdjustStockParams(
      batchId:    widget.batch.id,
      medicineId: widget.batch.medicineId,
      tradeName:  widget.batch.tradeName,
      type:       _type,
      qty:        finalQty,
      reason:     _reasonCtrl.text.trim(),
      adjustedBy: 'current_user_id', // replace with auth userId
    );

    final ok = await ref
        .read(inventoryViewModelProvider.notifier)
        .adjustStock(params);

    setState(() => _isSubmitting = false);
    if (ok && mounted) Navigator.pop(context);
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _BatchSummaryCard extends StatelessWidget {
  const _BatchSummaryCard({required this.batch});
  final BatchEntity batch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(batch.tradeName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text('Batch: ${batch.batchNo}',
              style: const TextStyle(
                  fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 12),
          Row(children: [
            _SumItem(
              label: 'Available',
              value: '${batch.qtyAvailable}',
              icon: Icons.inventory_rounded,
            ),
            const SizedBox(width: 20),
            _SumItem(
              label: 'Expires',
              value: DateFormat('d MMM yy').format(batch.expiryDate),
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(width: 20),
            _SumItem(
              label: 'Location',
              value: batch.location ?? 'N/A',
              icon: Icons.location_on_rounded,
            ),
          ]),
        ],
      ),
    );
  }
}

class _SumItem extends StatelessWidget {
  const _SumItem(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.white54)),
        const SizedBox(height: 2),
        Row(children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ]),
      ],
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({
    required this.currentQty,
    required this.adjustQty,
    required this.isAddition,
  });
  final int currentQty;
  final int adjustQty;
  final bool isAddition;

  @override
  Widget build(BuildContext context) {
    final newQty = isAddition
        ? currentQty + adjustQty
        : currentQty - adjustQty;
    final color =
        newQty <= 0 ? const Color(0xFFF44336) : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.preview_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            'After adjustment: $currentQty '
            '${isAddition ? '+' : '-'} $adjustQty = ',
            style: TextStyle(fontSize: 13, color: color),
          ),
          Text(
            '$newQty units',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 15, color: const Color(0xFF1565C0)),
      const SizedBox(width: 6),
      Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1565C0),
              letterSpacing: 0.3)),
      const SizedBox(width: 8),
      const Expanded(child: Divider()),
    ]);
  }
}