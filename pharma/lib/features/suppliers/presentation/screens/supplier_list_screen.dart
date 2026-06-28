import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/usecases/supplier_usecases.dart';
import '../providers/supplier_providers.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _State();
}

class _State extends ConsumerState<SupplierListScreen> {
  final _searchCtrl = TextEditingController();
  String? _searchQuery;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _searchQuery = v.isEmpty ? null : v);
    });
  }

  List<dynamic> _filter(List<dynamic> list) {
    if (_searchQuery == null || _searchQuery!.isEmpty) return list;
    final q = _searchQuery!.toLowerCase();
    return list
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.phone.contains(_searchQuery!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(suppliersStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Suppliers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search suppliers...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _searchQuery != null
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = null);
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0))),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add supplier',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: stream.when(
        loading: () => const Center(
            child:
                CircularProgressIndicator(color: Color(0xFF1565C0))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 40, color: Color(0xFFE53935)),
              const SizedBox(height: 12),
              Text('$e',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF888888))),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    ref.refresh(suppliersStreamProvider),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0)),
              ),
            ],
          ),
        ),
        data: (suppliers) {
          final filtered = _filter(suppliers);
          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.store_outlined,
                      size: 48, color: Color(0xFFCCCCCC)),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery != null
                        ? 'No results for "$_searchQuery"'
                        : 'No suppliers yet',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_searchQuery == null)
                    const Text('Tap + to add your first supplier.',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF888888))),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _SupplierCard(
              supplier: filtered[i],
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();
    final contactCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          bool saving = false;
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text('Add Supplier',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _tf(nameCtrl, 'Company name *',
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Required'
                              : null),
                  const SizedBox(height: 10),
                  _tf(phoneCtrl, 'Phone *',
                      type: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Required'
                              : null),
                  const SizedBox(height: 10),
                  _tf(contactCtrl, 'Contact person'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14)),
                      onPressed: saving
                          ? null
                          : () async {
                              if (!formKey.currentState!
                                  .validate()) return;
                              setSheetState(() => saving = true);
                              try {
                                final uc = ref.read(
                                    addSupplierUseCaseProvider);
                                await uc(SupplierParams(
                                  name: nameCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  contactPerson: contactCtrl
                                          .text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : contactCtrl.text.trim(),
                                ));
                                if (sheetCtx.mounted) {
                                  Navigator.pop(sheetCtx);
                                }
                              
                              } catch (_) {
                                setSheetState(() => saving = false);
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tf(
    TextEditingController ctrl,
    String label, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE0E0E0))),
        ),
      );
}

// ── Supplier Card ─────────────────────────────────────────────────────────────

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({required this.supplier});
  final dynamic supplier;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFF2E7D32).withOpacity(0.1),
          child: Text(
            supplier.name[0].toUpperCase(),
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32)),
          ),
        ),
        title: Text(supplier.name,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${supplier.phone}${supplier.contactPerson != null ? ' · ${supplier.contactPerson}' : ''}',
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF888888)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(symbol: '\$ ', decimalDigits: 0)
                  .format(supplier.totalAmount),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32)),
            ),
            Text('${supplier.totalOrders} orders',
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF888888))),
          ],
        ),
      ),
    );
  }
}