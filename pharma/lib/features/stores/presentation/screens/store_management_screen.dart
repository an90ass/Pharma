import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/store_usecases.dart';
import '../viewmodels/store_viewmodel.dart';

class StoreManagementScreen extends ConsumerWidget {
  const StoreManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Branches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStore(context, ref),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add branch',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: state.stores.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store_outlined,
                      size: 44, color: Color(0xFFCCCCCC)),
                  SizedBox(height: 12),
                  Text('No branches yet',
                      style: TextStyle(
                          fontSize: 15, color: Color(0xFF888888))),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final store = state.stores[i];
                final isActive = store.id == state.activeStoreId;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF1565C0).withOpacity(0.3)
                          : Colors.black.withOpacity(0.06),
                      width: isActive ? 1.2 : 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1565C0).withOpacity(0.1)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          store.isMain
                              ? Icons.store_rounded : Icons.storefront_rounded,
                          color: isActive
                              ? const Color(0xFF1565C0) : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(store.name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              if (store.isMain) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('Main',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1565C0))),
                                ),
                              ],
                            ]),
                            Text(store.address,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF888888))),
                            Text(store.phone,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF888888))),
                          ],
                        ),
                      ),
                      if (isActive)
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF1565C0), size: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showAddStore(BuildContext context, WidgetRef ref) {
    final nameCtrl    = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl   = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add branch',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _field(nameCtrl, 'Branch name *'),
            const SizedBox(height: 10),
            _field(addressCtrl, 'Address *'),
            const SizedBox(height: 10),
            _field(phoneCtrl, 'Phone', type: TextInputType.phone),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0)),
                onPressed: () async {
                  final ok = await ref
                      .read(storeViewModelProvider.notifier)
                      .addStore(AddStoreParams(
                        name:    nameCtrl.text,
                        address: addressCtrl.text,
                        phone:   phoneCtrl.text,
                      ));
                  if (ok && context.mounted) Navigator.pop(context);
                },
                child: const Text('Add branch'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {TextInputType type = TextInputType.text}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          filled: true, fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
        ),
      );
}