import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../viewmodels/medicine_viewmodel.dart';
import '../widgets/medicine_form_fields.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // ── Controllers ────────────────────────────────────────────────────────
  final _tradeName = TextEditingController();
  final _genericName = TextEditingController();
  final _manufacturer = TextEditingController();
  final _strength = TextEditingController();
  final _packSize = TextEditingController(text: '10');
  final _salePrice = TextEditingController();
  final _purchasePrice = TextEditingController();
  final _mrp = TextEditingController();
  final _reorderLevel = TextEditingController(text: '10');
  final _reorderQty = TextEditingController(text: '50');
  final _barcode = TextEditingController();
  final _taxCode = TextEditingController();
  final _description = TextEditingController();

  // ── Dropdown values ────────────────────────────────────────────────────
  MedicineCategory _category = MedicineCategory.otc;
  MedicineForm _form = MedicineForm.tablet;
  String _unit = 'strip';
  bool _isControlled = false;

  static const _units = ['strip', 'bottle', 'vial', 'box', 'tube', 'sachet'];

  @override
  void dispose() {
    for (final c in [
      _tradeName, _genericName, _manufacturer, _strength, _packSize,
      _salePrice, _purchasePrice, _mrp, _reorderLevel, _reorderQty,
      _barcode, _taxCode, _description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

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
        title: const Text(
          'Add Medicine',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
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
                          strokeWidth: 2, color: Colors.white),
                    )
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
            // ── Basic info ─────────────────────────────────────────────
            _card(children: [
              const FormSectionHeader(
                  title: 'Basic information',
                  icon: Icons.info_outline_rounded),
              AppTextField(
                label: 'Trade name *',
                controller: _tradeName,
                hint: 'e.g. Panadol',
                prefixIcon: Icons.medication_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Generic (INN) name *',
                controller: _genericName,
                hint: 'e.g. Paracetamol',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Manufacturer *',
                controller: _manufacturer,
                hint: 'e.g. GSK Pakistan',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: AppTextField(
                    label: 'Strength *',
                    controller: _strength,
                    hint: '500mg',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Pack size *',
                    controller: _packSize,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter valid size';
                      return null;
                    },
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 12),

            // ── Category & form ────────────────────────────────────────
            _card(children: [
              const FormSectionHeader(
                  title: 'Classification',
                  icon: Icons.category_rounded),
              Row(children: [
                Expanded(
                  child: AppDropdownField<MedicineCategory>(
                    label: 'Category *',
                    value: _category,
                    items: MedicineCategory.values,
                    itemLabel: (c) => c.label,
                    onChanged: (v) =>
                        setState(() => _category = v ?? _category),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdownField<MedicineForm>(
                    label: 'Form *',
                    value: _form,
                    items: MedicineForm.values,
                    itemLabel: (f) => f.label,
                    onChanged: (v) => setState(() => _form = v ?? _form),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              AppDropdownField<String>(
                label: 'Unit *',
                value: _unit,
                items: _units,
                itemLabel: (u) => u,
                onChanged: (v) => setState(() => _unit = v ?? _unit),
              ),
              const SizedBox(height: 12),
              // Controlled substance toggle
              _ControlledToggle(
                value: _isControlled,
                onChanged: (v) => setState(() => _isControlled = v),
              ),
            ]),
            const SizedBox(height: 12),

            // ── Pricing ────────────────────────────────────────────────
            _card(children: [
              const FormSectionHeader(
                  title: 'Pricing (PKR)',
                  icon: Icons.attach_money_rounded),
              Row(children: [
                Expanded(
                  child: AppTextField(
                    label: 'Sale price *',
                    controller: _salePrice,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Purchase price *',
                    controller: _purchasePrice,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Required';
                      return null;
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              AppTextField(
                label: 'MRP (max retail price)',
                controller: _mrp,
                hint: 'Leave blank to use sale price',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ]),
            const SizedBox(height: 12),

            // ── Stock settings ─────────────────────────────────────────
            _card(children: [
              const FormSectionHeader(
                  title: 'Stock settings',
                  icon: Icons.inventory_2_rounded),
              Row(children: [
                Expanded(
                  child: AppTextField(
                    label: 'Reorder level',
                    controller: _reorderLevel,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    hint: 'Alert below this qty',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Reorder qty',
                    controller: _reorderQty,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    hint: 'Suggested PO qty',
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 12),

            // ── Optional fields ────────────────────────────────────────
            _card(children: [
              const FormSectionHeader(
                  title: 'Optional details',
                  icon: Icons.more_horiz_rounded),
              AppTextField(
                label: 'Barcode',
                controller: _barcode,
                hint: 'EAN-13 or custom',
                prefixIcon: Icons.barcode_reader,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Tax / HSN code',
                controller: _taxCode,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Description / notes',
                controller: _description,
                maxLines: 3,
              ),
            ]),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final sale = double.tryParse(_salePrice.text) ?? 0;
    final purchase = double.tryParse(_purchasePrice.text) ?? 0;
    if (sale < purchase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Sale price cannot be less than purchase price.'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final params = AddMedicineParams(
      tradeName: _tradeName.text,
      genericName: _genericName.text,
      manufacturer: _manufacturer.text,
      category: _category,
      form: _form,
      strength: _strength.text,
      packSize: int.tryParse(_packSize.text) ?? 1,
      unit: _unit,
      salePrice: sale,
      purchasePrice: purchase,
      mrp: double.tryParse(_mrp.text),
      reorderLevel: int.tryParse(_reorderLevel.text) ?? 10,
      reorderQty: int.tryParse(_reorderQty.text) ?? 50,
      isControlled: _isControlled,
      barcode: _barcode.text.isEmpty ? null : _barcode.text,
      taxCode: _taxCode.text.isEmpty ? null : _taxCode.text,
      description: _description.text.isEmpty ? null : _description.text,
    );

    final success = await ref
        .read(medicineViewModelProvider.notifier)
        .addMedicine(params);

    setState(() => _isSubmitting = false);
    if (success && mounted) Navigator.pop(context);
  }
}

class _ControlledToggle extends StatelessWidget {
  const _ControlledToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFFFFF3F3)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFE8E8E8),
          width: 0.8,
        ),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: const Text(
          'Controlled substance',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: const Text(
          'Requires prescription — restricted sale',
          style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
        activeColor: const Color(0xFFF44336),
        secondary: Icon(
          Icons.warning_rounded,
          color: value ? const Color(0xFFF44336) : const Color(0xFFAAAAAA),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}