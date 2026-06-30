import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/store_viewmodel.dart';

class StoreSwitcherSheet extends ConsumerWidget {
  const StoreSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeViewModelProvider);
    final vm    = ref.read(storeViewModelProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2)),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Switch branch',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const Divider(height: 1),
        ...state.stores.map((store) => ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: store.id == state.activeStoreId
                      ? const Color(0xFF1565C0).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  store.isMain
                      ? Icons.store_rounded : Icons.storefront_rounded,
                  size: 18,
                  color: store.id == state.activeStoreId
                      ? const Color(0xFF1565C0)
                      : Colors.grey,
                ),
              ),
              title: Text(store.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: store.id == state.activeStoreId
                          ? FontWeight.w700 : FontWeight.w500)),
              subtitle: Text(store.address,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888))),
              trailing: store.id == state.activeStoreId
                  ? const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF1565C0))
                  : null,
              onTap: () {
                vm.switchStore(store.id);
                Navigator.pop(context);
              },
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}