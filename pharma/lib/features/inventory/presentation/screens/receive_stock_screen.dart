import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/receive_stock_usecase.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../../../medicines/presentation/viewmodels/medicine_viewmodel.dart';
import '../../../medicines/domain/entities/medicine_entity.dart';

class ReceiveStockScreen extends ConsumerStatefulWidget {
  const ReceiveStockScreen({super.key, this.medicineId, this.tradeName});

  /// Pre-fill when navigated from a low-stock alert or PO.
  final String? medicineId;
  final String? tradeName;

  @override
  ConsumerState<ReceiveStockScreen> createState() =>
      _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends ConsumerState<ReceiveStockScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
  final _medicineId   = TextEditingController();
  final _tradeName    = TextEditingController();
  final _batchNo      = TextEditingController();
  final _qty          = TextEditingController();
  final _purchasePrice = TextEditingController();
  final _salePrice    = TextEditingController();
  final _supplierId   = TextEditingController();
  final _location     = TextEditingController();
  final _notes        = TextEditingController();

  DateTime? _mfgDate;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.medicineId != null) {
      _medicineId.text = widget.medicineId!;
    }
    if (widget.tradeName != null) {
      _tradeName.text = widget.tradeName!;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _medicineId, _tradeName, _batchNo, _qty,
      _purchasePrice, _salePrice, _supplierId, _location, _notes,
    ]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicines = ref.watch(medicineViewModelProvider).medicines;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Receive Stock',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save',
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

            // ── Medicine info ─────────────────────────────────────────
            _SectionCard(title: 'Medicine', icon: Icons.medication_rounded,
              children: [
                Autocomplete<MedicineEntity>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<MedicineEntity>.empty();
                    }
                    return medicines.where((MedicineEntity option) {
                      return option.tradeName.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                             option.genericName.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (MedicineEntity option) => option.tradeName,
                  onSelected: (MedicineEntity selection) {
                    setState(() {
                      _medicineId.text = selection.id;
                      _tradeName.text = selection.tradeName;
                      _purchasePrice.text = selection.purchasePrice.toStringAsFixed(2);
                      _salePrice.text = selection.salePrice.toStringAsFixed(2);
                      if (selection.supplierId != null) {
                        _supplierId.text = selection.supplierId!;
                      }
                    });
                  },
                  fieldViewBuilder: (context, fieldTextEditingController, focusNode, onFieldSubmitted) {
                    if (fieldTextEditingController.text.isEmpty && _tradeName.text.isNotEmpty) {
                      fieldTextEditingController.text = _tradeName.text;
                    }
                    return TextFormField(
                      controller: fieldTextEditingController,
                      focusNode: focusNode,
                      onFieldSubmitted: (val) => onFieldSubmitted(),
                      onChanged: (val) {
                        if (val.trim().isEmpty || val != _tradeName.text) {
                          setState(() {
                            _medicineId.clear();
                            _tradeName.clear();
                          });
                        }
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Search Medicine (Trade or Generic Name) *',
                        hintText: 'Type to search...',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1565C0), size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFF44336))),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFF44336), width: 1.5)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (_medicineId.text.isEmpty) {
                          return 'Please select a medicine from search results';
                        }
                        return null;
                      },
                    );
                  },
                ),
                if (_medicineId.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                            const SizedBox(width: 6),
                            const Text(
                              'Selected Medicine Details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Name: ${_tradeName.text}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${_medicineId.text}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // ── Batch details ─────────────────────────────────────────
            _SectionCard(title: 'Batch details', icon: Icons.inventory_2_rounded,
              children: [
                _Field(
                  label: 'Batch number *',
                  controller: _batchNo,
                  hint: 'As printed on packaging',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Quantity *',
                  controller: _qty,
                  hint: 'Units received',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n <= 0) ? 'Must be > 0' : null;
                  },
                ),
                const SizedBox(height: 12),
                // Date pickers row
                Row(children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Mfg date *',
                      value: _mfgDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      onPicked: (d) => setState(() => _mfgDate = d),
                      validator: () =>
                          _mfgDate == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Expiry date *',
                      value: _expiryDate,
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime(2040),
                      onPicked: (d) => setState(() => _expiryDate = d),
                      validator: () =>
                          _expiryDate == null ? 'Required' : null,
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 12),

            // ── Pricing ───────────────────────────────────────────────
            _SectionCard(title: 'Pricing (\$)', icon: Icons.attach_money_rounded,
              children: [
                Row(children: [
                  Expanded(
                    child: _Field(
                      label: 'Purchase price *',
                      controller: _purchasePrice,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n <= 0) ? 'Required' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      label: 'Sale price *',
                      controller: _salePrice,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n <= 0) ? 'Required' : null;
                      },
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 12),

            // ── Supplier & optional ───────────────────────────────────
            _SectionCard(title: 'Supplier & storage', icon: Icons.local_shipping_rounded,
              children: [
                _Field(
                  label: 'Supplier ID *',
                  controller: _supplierId,
                  hint: 'Firestore supplier document ID',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Storage location',
                  controller: _location,
                  hint: 'e.g. Shelf A3, Cold Storage',
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Notes',
                  controller: _notes,
                  maxLines: 3,
                  hint: 'Any remarks about this batch',
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
    if (_mfgDate == null) {
      _showError('Manufacture date is required.');
      return;
    }
    if (_expiryDate == null) {
      _showError('Expiry date is required.');
      return;
    }

    setState(() => _isSubmitting = true);

    final params = ReceiveStockParams(
      medicineId:    _medicineId.text.trim(),
      tradeName:     _tradeName.text.trim(),
      batchNo:       _batchNo.text.trim(),
      mfgDate:       _mfgDate!,
      expiryDate:    _expiryDate!,
      purchasePrice: double.parse(_purchasePrice.text),
      salePrice:     double.parse(_salePrice.text),
      qty:           int.parse(_qty.text),
      supplierId:    _supplierId.text.trim(),
      location:      _location.text.isEmpty ? null : _location.text.trim(),
      notes:         _notes.text.isEmpty ? null : _notes.text.trim(),
    );

    final ok = await ref
        .read(inventoryViewModelProvider.notifier)
        .receiveStock(params);

    setState(() => _isSubmitting = false);
    if (ok && mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFE53935),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ── Shared form sub-widgets ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.8),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
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
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFFF44336), width: 1.5)),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onPicked,
    required this.validator,
  });
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onPicked;
  final String? Function() validator;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: (_) => validator(),
      builder: (field) => GestureDetector(
        onTap: () async {
          // ✅ التصحيح: initialDate يجب أن يقع دائمًا ضمن
          // [firstDate, lastDate]. الاعتماد المباشر على DateTime.now()
          // يفشل في حقل "Expiry date" لأن firstDate هناك = غدًا، وهو
          // بعد اليوم الحالي — فيكون DateTime.now() قبل firstDate.
          var initial = value ?? DateTime.now();
          if (initial.isBefore(firstDate)) initial = firstDate;
          if (initial.isAfter(lastDate)) initial = lastDate;

          final picked = await showDatePicker(
            context: context,
            initialDate: initial,
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
          if (picked != null) {
            onPicked(picked);
            field.didChange(picked);
          }
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
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
            errorText: field.errorText,
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF44336))),
          ),
          child: Text(
            value == null
                ? 'Select date'
                : '${value!.day}/${value!.month}/${value!.year}',
            style: TextStyle(
              fontSize: 14,
              color: value == null
                  ? const Color(0xFFCCCCCC)
                  : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
    );
  }
}