import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/usecases/update_medicine_usecase.dart';
import '../viewmodels/medicine_viewmodel.dart';
import '../widgets/medicine_form_fields.dart';

class EditMedicineScreen extends ConsumerStatefulWidget {
  const EditMedicineScreen({super.key, required this.medicine});

  /// The medicine to be edited — passed from MedicineListScreen.
  final MedicineEntity medicine;

  @override
  ConsumerState<EditMedicineScreen> createState() =>
      _EditMedicineScreenState();
}

class _EditMedicineScreenState extends ConsumerState<EditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _hasChanges = false;

  // ── Controllers pre-filled from entity ────────────────────────────────
  late final TextEditingController _tradeName;
  late final TextEditingController _genericName;
  late final TextEditingController _manufacturer;
  late final TextEditingController _strength;
  late final TextEditingController _packSize;
  late final TextEditingController _salePrice;
  late final TextEditingController _purchasePrice;
  late final TextEditingController _mrp;
  late final TextEditingController _reorderLevel;
  late final TextEditingController _reorderQty;
  late final TextEditingController _barcode;
  late final TextEditingController _taxCode;
  late final TextEditingController _description;

  late MedicineCategory _category;
  late MedicineForm _form;
  late String _unit;
  late bool _isControlled;
  late bool _isActive;

  static const _units = ['strip', 'bottle', 'vial', 'box', 'tube', 'sachet'];

  @override
  void initState() {
    super.initState();
    final m = widget.medicine;
    _tradeName = TextEditingController(text: m.tradeName);
    _genericName = TextEditingController(text: m.genericName);
    _manufacturer = TextEditingController(text: m.manufacturer);
    _strength = TextEditingController(text: m.strength);
    _packSize = TextEditingController(text: m.packSize.toString());
    _salePrice = TextEditingController(text: m.salePrice.toString());
    _purchasePrice = TextEditingController(text: m.purchasePrice.toString());
    _mrp = TextEditingController(text: m.mrp.toString());
    _reorderLevel = TextEditingController(text: m.reorderLevel.toString());
    _reorderQty = TextEditingController(text: m.reorderQty.toString());
    _barcode = TextEditingController(text: m.barcode ?? '');
    _taxCode = TextEditingController(text: m.taxCode ?? '');
    _description = TextEditingController(text: m.description ?? '');
    _category = m.category;
    _form = m.form;
    _unit = m.unit;
    _isControlled = m.isControlled;
    _isActive = m.isActive;

    // Track whether user has made any changes
    for (final c in [
      _tradeName, _genericName, _manufacturer, _strength, _packSize,
      _salePrice, _purchasePrice, _mrp, _reorderLevel, _reorderQty,
      _barcode, _taxCode, _description,
    ]) {
      c.addListener(() => setState(() => _hasChanges = true));
    }
  }

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
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              if (await _onBackPressed()) Navigator.pop(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Medicine',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                widget.medicine.tradeName,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF888888)),
              ),
            ],
          ),
          actions: [
            // Active/inactive toggle
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                children: [
                  Text(
                    _isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isActive
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE53935),
                    ),
                  ),
                  Switch.adaptive(
                    value: _isActive,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (v) =>
                        setState(() { _isActive = v; _hasChanges = true; }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed:
                    (_isSubmitting || !_hasChanges) ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
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
                    : const Text('Update',
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
              // Change indicator banner
              if (_hasChanges) _UnsavedBanner(),
              if (_hasChanges) const SizedBox(height: 12),

              // ── Basic info ───────────────────────────────────────
              _card(children: [
                const FormSectionHeader(
                    title: 'Basic information',
                    icon: Icons.info_outline_rounded),
                AppTextField(
                  label: 'Trade name *',
                  controller: _tradeName,
                  prefixIcon: Icons.medication_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Generic (INN) name *',
                  controller: _genericName,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Manufacturer *',
                  controller: _manufacturer,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Strength *',
                      controller: _strength,
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                ]),
              ]),
              const SizedBox(height: 12),

              // ── Classification ───────────────────────────────────
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
                      onChanged: (v) => setState(() {
                        _category = v ?? _category;
                        _hasChanges = true;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDropdownField<MedicineForm>(
                      label: 'Form *',
                      value: _form,
                      items: MedicineForm.values,
                      itemLabel: (f) => f.label,
                      onChanged: (v) => setState(() {
                        _form = v ?? _form;
                        _hasChanges = true;
                      }),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                AppDropdownField<String>(
                  label: 'Unit *',
                  value: _unit,
                  items: _units,
                  itemLabel: (u) => u,
                  onChanged: (v) => setState(() {
                    _unit = v ?? _unit;
                    _hasChanges = true;
                  }),
                ),
                const SizedBox(height: 12),
                _ControlledToggle(
                  value: _isControlled,
                  onChanged: (v) => setState(() {
                    _isControlled = v;
                    _hasChanges = true;
                  }),
                ),
              ]),
              const SizedBox(height: 12),

              // ── Pricing ──────────────────────────────────────────
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
                        return (n == null || n <= 0) ? 'Required' : null;
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
                        return (n == null || n <= 0) ? 'Required' : null;
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'MRP',
                  controller: _mrp,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
              ]),
              const SizedBox(height: 12),

              // ── Stock settings ───────────────────────────────────
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Reorder qty',
                      controller: _reorderQty,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                ]),
              ]),
              const SizedBox(height: 12),

              // ── Optional ─────────────────────────────────────────
              _card(children: [
                const FormSectionHeader(
                    title: 'Optional details',
                    icon: Icons.more_horiz_rounded),
                AppTextField(
                    label: 'Barcode', controller: _barcode),
                const SizedBox(height: 12),
                AppTextField(
                    label: 'Tax / HSN code', controller: _taxCode),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Description',
                  controller: _description,
                  maxLines: 3,
                ),
              ]),

              // ── Metadata ─────────────────────────────────────────
              const SizedBox(height: 12),
              _MetadataCard(medicine: widget.medicine),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Future<bool> _onBackPressed() async {
    if (!_hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard changes?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final sale = double.tryParse(_salePrice.text) ?? 0;
    final purchase = double.tryParse(_purchasePrice.text) ?? 0;
    if (sale < purchase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale price cannot be less than purchase price.'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final updated = widget.medicine.copyWith(
      tradeName: _tradeName.text.trim(),
      genericName: _genericName.text.trim(),
      manufacturer: _manufacturer.text.trim(),
      category: _category,
      form: _form,
      strength: _strength.text.trim(),
      packSize: int.tryParse(_packSize.text) ?? widget.medicine.packSize,
      unit: _unit,
      salePrice: sale,
      purchasePrice: purchase,
      mrp: double.tryParse(_mrp.text) ?? sale,
      reorderLevel:
          int.tryParse(_reorderLevel.text) ?? widget.medicine.reorderLevel,
      reorderQty:
          int.tryParse(_reorderQty.text) ?? widget.medicine.reorderQty,
      isControlled: _isControlled,
      isActive: _isActive,
      barcode: _barcode.text.isEmpty ? null : _barcode.text,
      taxCode: _taxCode.text.isEmpty ? null : _taxCode.text,
      description: _description.text.isEmpty ? null : _description.text,
      updatedAt: DateTime.now(),
    );

    final success = await ref
        .read(medicineViewModelProvider.notifier)
        .updateMedicine(UpdateMedicineParams(updated));

    setState(() => _isSubmitting = false);
    if (success && mounted) Navigator.pop(context);
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _UnsavedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFFFE082).withOpacity(0.8), width: 0.8),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_rounded, size: 14, color: Color(0xFFF9A825)),
          SizedBox(width: 8),
          Text(
            'You have unsaved changes',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE65100)),
          ),
        ],
      ),
    );
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
        color: value ? const Color(0xFFFFF3F3) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value ? const Color(0xFFFFCDD2) : const Color(0xFFE8E8E8),
          width: 0.8,
        ),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: const Text('Controlled substance',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: const Text('Requires prescription',
            style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
        activeColor: const Color(0xFFF44336),
        secondary: Icon(Icons.warning_rounded,
            color: value ? const Color(0xFFF44336) : const Color(0xFFAAAAAA)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.medicine});
  final MedicineEntity medicine;

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
          const FormSectionHeader(
              title: 'Record info', icon: Icons.info_outline_rounded),
          _MetaRow(label: 'Medicine ID', value: medicine.id),
          const SizedBox(height: 6),
          _MetaRow(
              label: 'Created',
              value: medicine.createdAt.toString().substring(0, 16)),
          if (medicine.updatedAt != null) ...[
            const SizedBox(height: 6),
            _MetaRow(
                label: 'Last updated',
                value: medicine.updatedAt!.toString().substring(0, 16)),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFFAAAAAA))),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                  fontFamily: 'monospace')),
        ),
      ],
    );
  }
}