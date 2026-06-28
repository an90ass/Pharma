import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/customer_usecases.dart';
import '../viewmodels/customer_viewmodel.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key, this.prefillPhone});
  final String? prefillPhone;

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  late final _phoneCtrl;
  final _emailCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cnicCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.prefillPhone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _addressCtrl.dispose(); _cnicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerViewModelProvider);
    final vm    = ref.read(customerViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Add customer',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_nameCtrl,    'Full name *',  Icons.person_rounded),
              const SizedBox(height: 12),
              _field(_phoneCtrl,   'Phone *',      Icons.phone_rounded,
                  type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_emailCtrl,   'Email',        Icons.email_rounded,
                  required: false, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Address',      Icons.location_on_rounded,
                  required: false),
              const SizedBox(height: 12),
              _field(_cnicCtrl,    'CNIC',         Icons.badge_rounded,
                  required: false),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final ok = await vm.addCustomer(CustomerParams(
                            name:    _nameCtrl.text.trim(),
                            phone:   _phoneCtrl.text.trim(),
                            email:   _emailCtrl.text.trim().isEmpty
                                ? null : _emailCtrl.text.trim(),
                            address: _addressCtrl.text.trim().isEmpty
                                ? null : _addressCtrl.text.trim(),
                            cnic:    _cnicCtrl.text.trim().isEmpty
                                ? null : _cnicCtrl.text.trim(),
                          ));
                          if (ok && context.mounted) Navigator.pop(context);
                        },
                  child: const Text('Save customer',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool required = true, TextInputType type = TextInputType.text}) =>
      TextFormField(
        controller: ctrl, keyboardType: type,
        validator: required
            ? (v) => v!.isEmpty ? '$label is required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF888888)),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
        ),
      );
}