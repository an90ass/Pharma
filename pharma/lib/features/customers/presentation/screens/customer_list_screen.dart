import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/customer_viewmodel.dart';
import 'add_customer_screen.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerViewModelProvider);
    final vm    = ref.read(customerViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Customers',
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
              onChanged: vm.search,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen())),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add customer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : state.filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 44, color: Color(0xFFCCCCCC)),
                      const SizedBox(height: 12),
                      Text(
                        state.searchQuery.isEmpty
                            ? 'No customers yet' : 'No results found',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF888888))),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: state.filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = state.filtered[i];
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
                              const Color(0xFF1565C0).withOpacity(0.1),
                          child: Text(c.name[0].toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1565C0))),
                        ),
                        title: Text(c.name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(c.phone,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF888888))),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat.currency(
                                      symbol: '\$ ', decimalDigits: 0)
                                  .format(c.totalPurchases),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: Color(0xFF1565C0)),
                            ),
                            Text('${c.loyaltyPoints} pts',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF888888))),
                          ],
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),
    );
  }
}