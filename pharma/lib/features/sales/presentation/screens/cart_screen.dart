import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'package:pharma/features/recommendations/presentation/widgets/recommendation_card.dart';
import 'package:pharma/features/recommendations/presentation/viewmodels/recommendation_viewmodel.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/payment_method_selector.dart';
import 'invoice_detail_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartViewModelProvider);
    final vm    = ref.read(cartViewModelProvider.notifier);

    ref.listen(cartViewModelProvider, (_, next) {
      if (next.actionStatus == CartActionStatus.error &&
          next.actionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.actionError!),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
        vm.clearMessages();
      }
      if (next.actionStatus == CartActionStatus.success &&
          next.completedInvoice != null) {
            print('Navigating to invoice detail for invoice ID: ${next.completedInvoice!.id}');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceDetailScreen(
              invoiceId: next.completedInvoice!.id,
              fromCheckout: true,
            ),
          ),
          (route) => route.isFirst,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Cart & Checkout',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF1565C0),
          labelColor: const Color(0xFF1565C0),
          unselectedLabelColor: const Color(0xFF888888),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Items'),
            Tab(text: 'Payment'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ── Tab 1: Items ─────────────────────────────────────────────
          _ItemsTab(state: state, vm: vm),
          // ── Tab 2: Payment ───────────────────────────────────────────
          _PaymentTab(state: state, vm: vm, tab: _tab),
        ],
      ),
    );
  }
}

// ── Items tab ─────────────────────────────────────────────────────────────────

class _ItemsTab extends ConsumerWidget {
  const _ItemsTab({required this.state, required this.vm});
  final CartState state;
  final CartViewModel vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.cart.isEmpty) {
      return const Center(
        child: Text('Cart is empty',
            style: TextStyle(fontSize: 15, color: Color(0xFF888888))),
      );
    }

    // Load cart recommendations based on current cart items
    final recVm = ref.read(recommendationViewModelProvider.notifier);
    final itemIds = state.cart.items.map((i) => i.medicineId).toList();
    Future.microtask(() => recVm.loadCartRecommendations(itemIds));

    final recState = ref.watch(recommendationViewModelProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Customer row
        _CustomerRow(state: state, vm: vm),
        const SizedBox(height: 12),

        // Items
        ...state.cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CartItemTile(
                item: item,
                onQtyChanged: (qty) =>
                    vm.updateQty(item.medicineId, qty),
                onRemove: () => vm.removeFromCart(item.medicineId),
                onDiscountChanged: (pct) =>
                    vm.updateItemDiscount(item.medicineId, pct),
              ),
            )),

        // Totals card
        const SizedBox(height: 8),
        _TotalsCard(state: state, vm: vm),

        // Recommendations carousel
        const SizedBox(height: 16),
        RecommendationCarousel(
          title: 'You may also like',
          description: 'Products commonly bought with current items, substitutes, or reorder suggestions.',
          recs: recState.cartRecs,
          onAdd: (rec) => vm.addRecommendationToCart(rec),
        ),
      ],
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.state, required this.vm});
  final CartState state;
  final CartViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (state.cart.customerName != null) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFF1565C0).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_rounded,
                size: 16, color: Color(0xFF1565C0)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${state.cart.customerName} · '
                '${state.cart.customerPhone ?? ''}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1565C0)),
              ),
            ),
            GestureDetector(
              onTap: vm.clearCustomer,
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Color(0xFF1565C0)),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _showAddCustomer(context),
      icon: const Icon(Icons.person_add_rounded, size: 16),
      label: const Text('Add customer (optional)',
          style: TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1565C0),
        side: BorderSide(
            color: const Color(0xFF1565C0).withOpacity(0.4)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }

  void _showAddCustomer(BuildContext context) {
    final nameCtrl  = TextEditingController();
    final phoneCtrl = TextEditingController();
    final idCtrl    = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16,
            MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add customer',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _SimpleField(ctrl: idCtrl, label: 'Customer ID'),
            const SizedBox(height: 10),
            _SimpleField(ctrl: nameCtrl, label: 'Name'),
            const SizedBox(height: 10),
            _SimpleField(
                ctrl: phoneCtrl,
                label: 'Phone',
                type: TextInputType.phone),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  vm.setCustomer(
                    id:    idCtrl.text.trim(),
                    name:  nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                  );
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0)),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleField extends StatelessWidget {
  const _SimpleField(
      {required this.ctrl,
      required this.label,
      this.type = TextInputType.text});
  final TextEditingController ctrl;
  final String label;
  final TextInputType type;

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF1565C0), width: 1.5)),
        ),
      );
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.state, required this.vm});
  final CartState state;
  final CartViewModel vm;

  @override
  Widget build(BuildContext context) {
    final cart = state.cart;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _TRow('Subtotal',
              '\$ ${cart.subtotal.toStringAsFixed(0)}'),
          if (cart.totalDiscount > 0)
            _TRow('Total discount',
                '- \$ ${cart.totalDiscount.toStringAsFixed(0)}',
                color: const Color(0xFF2E7D32)),
          if (cart.totalTax > 0)
            _TRow('Tax',
                '+ \$ ${cart.totalTax.toStringAsFixed(0)}'),
          const Divider(height: 16),
          _TRow('Grand total',
              '\$ ${cart.grandTotal.toStringAsFixed(0)}',
              bold: true,
              color: const Color(0xFF1565C0)),
          const SizedBox(height: 10),
          // Global discount slider
          Row(children: [
            const Text('Global disc:',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(width: 6),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14),
                  activeTrackColor: const Color(0xFF1565C0),
                  thumbColor: const Color(0xFF1565C0),
                ),
                child: Slider(
                  value: cart.globalDiscountPct,
                  min: 0, max: 30, divisions: 30,
                  onChanged: vm.setGlobalDiscount,
                ),
              ),
            ),
            Text('${cart.globalDiscountPct.toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0))),
          ]),
        ],
      ),
    );
  }
}

class _TRow extends StatelessWidget {
  const _TRow(this.label, this.value,
      {this.bold = false,
      this.color = const Color(0xFF1A1A2E)});
  final String label;
  final String value;
  final bool bold;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: bold
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF888888),
                    fontWeight: bold
                        ? FontWeight.w700
                        : FontWeight.w400)),
            Text(value,
                style: TextStyle(
                    fontSize: bold ? 15 : 13,
                    fontWeight:
                        bold ? FontWeight.w700 : FontWeight.w500,
                    color: color)),
          ],
        ),
      );
}

// ── Payment tab ───────────────────────────────────────────────────────────────

class _PaymentTab extends StatelessWidget {
  const _PaymentTab(
      {required this.state,
      required this.vm,
      required this.tab});
  final CartState state;
  final CartViewModel vm;
  final TabController tab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        // Order summary chip
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.cart.totalQty} items',
                style: const TextStyle(
                    fontSize: 13, color: Colors.white70),
              ),
              Text(
                '\$ ${state.cart.grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment selector
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.black.withOpacity(0.06), width: 0.8),
          ),
          padding: const EdgeInsets.all(16),
          child: PaymentMethodSelector(
            grandTotal: state.cart.grandTotal,
            selectedPayments: state.selectedPayments,
            onPaymentChanged: vm.setPayment,
          ),
        ),
        const SizedBox(height: 20),

        // Checkout button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: state.canCheckout &&
                    state.actionStatus != CartActionStatus.loading
                ? () => vm.checkout(soldBy: 'current_user_id')
                : null,
            icon: state.actionStatus == CartActionStatus.loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_rounded),
            label: Text(
              state.actionStatus == CartActionStatus.loading
                  ? 'Processing…'
                  : 'Complete Sale  '
                    '\$ ${state.cart.grandTotal.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: state.canCheckout
                  ? const Color(0xFF2E7D32)
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        if (!state.canCheckout && !state.cart.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.selectedPayments.isEmpty
                  ? 'Select a payment method above.'
                  : 'Payment amount is less than total due.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFFE53935)),
            ),
          ),
      ],
    );
  }
}