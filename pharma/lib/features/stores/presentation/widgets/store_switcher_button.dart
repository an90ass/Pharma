import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/store_viewmodel.dart';
import '../screens/store_switcher_sheet.dart';

/// AppBar action button showing active store name.
/// Tap opens StoreSwitcherSheet.
class StoreSwitcherButton extends ConsumerWidget {
  const StoreSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeViewModelProvider);
    final storeName = state.activeStore?.name ?? 'Select store';

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => const StoreSwitcherSheet(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF1565C0).withOpacity(0.3), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_rounded,
                size: 14, color: Color(0xFF1565C0)),
            const SizedBox(width: 5),
            Text(storeName,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0))),
            const SizedBox(width: 3),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: Color(0xFF1565C0)),
          ],
        ),
      ),
    );
  }
}