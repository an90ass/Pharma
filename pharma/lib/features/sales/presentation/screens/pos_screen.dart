import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../medicines/domain/entities/medicine_entity.dart';
import '../../../medicines/presentation/viewmodels/medicine_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'cart_screen.dart';
import 'invoice_detail_screen.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final cartVm     = ref.read(cartViewModelProvider.notifier);

    // ✅ القائمة الكاملة تأتي من medicineViewModelProvider (نفس مصدر شاشة
    // المخزون) — مش من بحث منفصل. البحث هنا فلترة محلية فقط.
    final medicineState = ref.watch(medicineViewModelProvider);

    // فلترة فورية حسب نص البحث، بدون حد أدنى لعدد الحروف
    final query = _searchCtrl.text.trim().toLowerCase();
    final visibleMedicines = query.isEmpty
        ? medicineState.medicines
        : medicineState.medicines.where((m) {
            return m.tradeName.toLowerCase().contains(query) ||
                m.genericName.toLowerCase().contains(query) ||
                m.manufacturer.toLowerCase().contains(query) ||
                (m.barcode?.toLowerCase().contains(query) ?? false);
          }).toList();

    // Snackbar + توجيه للفاتورة عند نجاح الدفع
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
        cartVm.clearMessages();
      }
      if (next.actionStatus == CartActionStatus.success &&
          next.completedInvoice != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceDetailScreen(
              invoiceId: next.completedInvoice!.id,
              fromCheckout: true,
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _buildAppBar(context, cartState, cartVm),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search medicine by name or scan barcode…',
                hintStyle: const TextStyle(
                    fontSize: 13, color: Color(0xFFBBBBBB)),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF1565C0), size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFFE8E8E8))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1565C0), width: 1.5)),
              ),
            ),
          ),

          // ── Results counter ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Text(
                  query.isEmpty
                      ? '${medicineState.medicines.length} medicines'
                      : '${visibleMedicines.length} of ${medicineState.medicines.length} medicines',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888888)),
                ),
              ],
            ),
          ),

          // ── ملخص السلة (شريط رفيع دائم الظهور فوق القائمة) ─────────────
          if (!cartState.cart.isEmpty)
            _CartSummaryBar(state: cartState),

          const SizedBox(height: 8),

          // ── الكتالوج (يظهر دائمًا، يتفلتر فورًا) ───────────────────────
          Expanded(
            child: _CatalogGrid(
              isLoading: medicineState.actionStatus ==
                      MedicineActionStatus.loading &&
                  medicineState.medicines.isEmpty,
              medicines: visibleMedicines,
              hasQuery: query.isNotEmpty,
              onAddToCart: (m) => cartVm.addToCart(m) //_handleAddToCart(context, cartVm, cartState, m),
            ),
          ),
        ],
      ),

      // ── Cart FAB ──────────────────────────────────────────────────
      floatingActionButton: cartState.cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.shopping_cart_rounded,
                  color: Colors.white),
              label: Text(
                '${cartState.cart.totalQty} items · '
                'Rs ${cartState.cart.grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  /// عند إضافة دواء جديد للسلة لأول مرة، نطلب من المستخدم تحديد الكمية
  /// المتاحة يدويًا (لأن MedicineEntity لا يحتوي على بيانات مخزون فعلية).
  /// لو الدواء موجود بالسلة بالفعل، نزيد الكمية مباشرة بدون سؤال.
  void _handleAddToCart(
    BuildContext context,
    CartViewModel cartVm,
    CartState cartState,
    MedicineEntity medicine,
  ) {
    final alreadyInCart =
        cartState.cart.items.any((i) => i.medicineId == medicine.id);

    if (alreadyInCart) {
      cartVm.addToCart(medicine);
      return;
    }

    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          medicine.tradeName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the available stock quantity for this medicine '
              '(leave blank if you don\'t want to set a limit now):',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. 25',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0)),
            onPressed: () {
              final text = qtyCtrl.text.trim();
              final manualQty = text.isEmpty ? null : int.tryParse(text);
              Navigator.pop(context);
              cartVm.addToCart(medicine, manualAvailableQty: manualQty);
            },
            child: const Text('Add to cart'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CartState state, CartViewModel vm) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FC),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/'),
      ),
      title: const Text('POS — New Sale',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E))),
      actions: [
        if (!state.cart.isEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFE53935)),
            tooltip: 'Clear cart',
            onPressed: () => _confirmClear(context, vm),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _confirmClear(BuildContext context, CartViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear cart?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text(
            'All items in the cart will be removed.',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF44336)),
            onPressed: () {
              Navigator.pop(context);
              vm.clearCart();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ── شريط ملخص السلة (دائم الظهور فوق الكتالوج) ──────────────────────────────

class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF1565C0).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_rounded,
              size: 16, color: Color(0xFF1565C0)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${state.cart.totalQty} item${state.cart.totalQty == 1 ? '' : 's'} in cart',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1565C0)),
            ),
          ),
          Text(
            'Rs ${state.cart.grandTotal.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }
}

// ── شبكة الكتالوج (تظهر دائمًا) ───────────────────────────────────────────────

class _CatalogGrid extends StatelessWidget {
  const _CatalogGrid({
    required this.isLoading,
    required this.medicines,
    required this.hasQuery,
    required this.onAddToCart,
  });

  final bool isLoading;
  final List<MedicineEntity> medicines;
  final bool hasQuery;
  final void Function(MedicineEntity) onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1565C0)));
    }

    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery
                  ? Icons.search_off_rounded
                  : Icons.medication_rounded,
              size: 44,
              color: const Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 10),
            Text(
              hasQuery ? 'No results found' : 'No medicines in stock',
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: medicines.length,
      itemBuilder: (_, i) => _MedicineCatalogTile(
        medicine: medicines[i],
        onAdd: () => onAddToCart(medicines[i]),
      ),
    );
  }
}

// ── بطاقة دواء واحدة في الكتالوج ───────────────────────────────────────────────

class _MedicineCatalogTile extends StatelessWidget {
  const _MedicineCatalogTile({required this.medicine, required this.onAdd});
  final MedicineEntity medicine;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    // ⚠️ MedicineEntity لا يحتوي على كمية مخزون فعلية (محفوظة في نظام
    // Batches منفصل). البطاقة تظهر متاحة دائمًا؛ التحقق من الكمية يتم
    // عبر الـ Dialog اليدوي عند الإضافة (انظر _handleAddToCart).
    final inactive = !medicine.isActive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medicine.tradeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E)),
                ),
              ),
              if (medicine.isControlled)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Rx',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF6C00)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            medicine.genericName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 2),
          Text(
            '${medicine.strength} · ${medicine.form.label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rs ${medicine.salePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0)),
                ),
              ),
              GestureDetector(
                onTap: inactive ? null : onAdd,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: inactive
                        ? const Color(0xFFE0E0E0)
                        : const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: inactive
                        ? const Color(0xFF999999)
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (inactive)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Inactive',
                style: TextStyle(fontSize: 10, color: Color(0xFFE53935)),
              ),
            ),
        ],
      ),
    );
  }
}