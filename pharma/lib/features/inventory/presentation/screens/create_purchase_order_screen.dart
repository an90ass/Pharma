import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/usecases/purchase_order_usecases.dart';
import '../viewmodels/purchase_order_viewmodel.dart';

class CreatePurchaseOrderScreen extends ConsumerStatefulWidget {
  const CreatePurchaseOrderScreen({super.key});

  @override
  ConsumerState<CreatePurchaseOrderScreen> createState() =>
      _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState
    extends ConsumerState<CreatePurchaseOrderScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _supplierId    = TextEditingController();
  final _supplierName  = TextEditingController();
  final _notes         = TextEditingController();
  DateTime? _expectedDate;
  bool _isSubmitting   = false;

  final List<_POItemRow> _items = [];

  @override
  void initState() {
    super.initState();
    _addItem();   // start with one empty row
  }

  @override
  void dispose() {
    _supplierId.dispose();
    _supplierName.dispose();
    _notes.dispose();
    for (final item in _items) item.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() => _items.add(_POItemRow()));
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  double get _computedTotal => _items.fold(0.0, (sum, item) {
        final qty   = int.tryParse(item.qtyCtrl.text) ?? 0;
        final price = double.tryParse(item.priceCtrl.text) ?? 0;
        return sum + (qty * price);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Purchase Order',
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
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create PO',
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

            // ── Supplier ──────────────────────────────────────────────
            _Card(
              title: 'Supplier',
              icon: Icons.local_shipping_rounded,
              children: [
                _InputField(
                  label: 'Supplier ID *',
                  controller: _supplierId,
                  hint: 'Firestore supplier document ID',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Supplier name *',
                  controller: _supplierName,
                  hint: 'e.g. MedPak Distributors',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _DatePicker(
                  label: 'Expected delivery date',
                  value: _expectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2040),
                  onPicked: (d) => setState(() => _expectedDate = d),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Line items ────────────────────────────────────────────
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.list_alt_rounded,
                            size: 15, color: Color(0xFF1565C0)),
                        const SizedBox(width: 6),
                        const Text('Order items',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1565C0),
                                letterSpacing: 0.3)),
                        const SizedBox(width: 8),
                        Text('(${_items.length})',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF888888))),
                      ]),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add item',
                            style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),

                  // Column headers
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Expanded(flex: 3,
                          child: Text('Medicine', style: _headerStyle)),
                      SizedBox(width: 8),
                      Expanded(flex: 2,
                          child: Text('Medicine ID', style: _headerStyle)),
                      SizedBox(width: 8),
                      SizedBox(width: 70,
                          child: Text('Qty', style: _headerStyle)),
                      SizedBox(width: 8),
                      SizedBox(width: 80,
                          child: Text('Unit price', style: _headerStyle)),
                      SizedBox(width: 36),
                    ]),
                  ),

                  // Item rows
                  ...List.generate(_items.length, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _POItemRowWidget(
                          row: _items[i],
                          index: i,
                          canRemove: _items.length > 1,
                          onRemove: () => _removeItem(i),
                          onChanged: () => setState(() {}),
                        ),
                      )),

                  // Total row
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Estimated total:',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF888888))),
                      const SizedBox(width: 8),
                      Text(
                        NumberFormat.currency(
                                symbol: '\$ ', decimalDigits: 0)
                            .format(_computedTotal),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1565C0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Notes ─────────────────────────────────────────────────
            _Card(
              title: 'Notes',
              icon: Icons.notes_rounded,
              children: [
                _InputField(
                  label: 'Special instructions',
                  controller: _notes,
                  maxLines: 3,
                  hint: 'Any notes for the supplier…',
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      _snack('Add at least one item to the order.');
      return;
    }

    // Validate all items
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.nameCtrl.text.trim().isEmpty) {
        _snack('Medicine name is required for item ${i + 1}.');
        return;
      }
      if (item.idCtrl.text.trim().isEmpty) {
        _snack('Medicine ID is required for item ${i + 1}.');
        return;
      }
      if ((int.tryParse(item.qtyCtrl.text) ?? 0) <= 0) {
        _snack('Quantity must be > 0 for item ${i + 1}.');
        return;
      }
      if ((double.tryParse(item.priceCtrl.text) ?? 0) <= 0) {
        _snack('Unit price must be > 0 for item ${i + 1}.');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final params = CreatePOParams(
      supplierId:   _supplierId.text.trim(),
      supplierName: _supplierName.text.trim(),
      createdBy:    'current_user_id',    // replace with auth userId
      notes:        _notes.text.isEmpty ? null : _notes.text.trim(),
      expectedDate: _expectedDate,
      items: _items
          .map((r) => POItem(
                medicineId: r.idCtrl.text.trim(),
                tradeName:  r.nameCtrl.text.trim(),
                orderedQty: int.parse(r.qtyCtrl.text),
                unitPrice:  double.parse(r.priceCtrl.text),
              ))
          .toList(),
    );

    final ok = await ref
        .read(poViewModelProvider.notifier)
        .createOrder(params);

    setState(() => _isSubmitting = false);
    if (ok && mounted) Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFE53935),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  static const _headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Color(0xFFAAAAAA));
}

// ── Data class for each line-item row ─────────────────────────────────────────

class _POItemRow {
  final nameCtrl  = TextEditingController();
  final idCtrl    = TextEditingController();
  final qtyCtrl   = TextEditingController();
  final priceCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    idCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }
}

// ── Line-item row widget ──────────────────────────────────────────────────────

class _POItemRowWidget extends StatelessWidget {
  const _POItemRowWidget({
    required this.row,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });
  final _POItemRow row;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Medicine name
        Expanded(
          flex: 3,
          child: _CompactField(
            controller: row.nameCtrl,
            hint: 'Trade name',
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: 8),
        // Medicine ID
        Expanded(
          flex: 2,
          child: _CompactField(
            controller: row.idCtrl,
            hint: 'Doc ID',
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: 8),
        // Qty
        SizedBox(
          width: 70,
          child: _CompactField(
            controller: row.qtyCtrl,
            hint: 'Qty',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: 8),
        // Price
        SizedBox(
          width: 80,
          child: _CompactField(
            controller: row.priceCtrl,
            hint: '\$',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onChanged(),
          ),
        ),
        // Remove button
        SizedBox(
          width: 36,
          child: canRemove
              ? IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded,
                      size: 18, color: Color(0xFFE53935)),
                  onPressed: onRemove,
                  padding: const EdgeInsets.all(4),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}

class _CompactField extends StatelessWidget {
  const _CompactField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
      ),
    );
  }
}

// ── Shared form card & helpers ────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card(
      {required this.title,
      required this.icon,
      required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(children: [
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
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            const TextStyle(fontSize: 13, color: Color(0xFF666666)),
        hintStyle:
            const TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF44336))),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onPicked,
  });
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                  primary: Color(0xFF1565C0)),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: const Icon(Icons.calendar_today_rounded,
              size: 16, color: Color(0xFF1565C0)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        ),
        child: Text(
          value == null
              ? 'Select expected date'
              : '${value!.day}/${value!.month}/${value!.year}',
          style: TextStyle(
            fontSize: 14,
            color: value == null
                ? const Color(0xFFCCCCCC)
                : const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }
}