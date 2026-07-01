import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../medicines/domain/entities/medicine_entity.dart';
import '../../../../../features/recommendations/domain/entities/medicine_recommendation.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_item_entity.dart';
import '../../domain/usecases/process_sale_usecase.dart';
import '../providers/sales_providers.dart';


enum CartActionStatus { idle, loading, success, error }

class CartState {
  const CartState({
    this.cart = const CartEntity(),
    this.selectedPayments = const [],
    this.actionStatus = CartActionStatus.idle,
    this.actionError,
    this.completedInvoice,
  });

  final CartEntity cart;
  final List<PaymentEntry> selectedPayments;
  final CartActionStatus actionStatus;
  final String? actionError;
  final InvoiceEntity? completedInvoice;

  double get totalPaid =>
      selectedPayments.fold(0.0, (s, p) => s + p.amount);
  double get changeAmount => totalPaid - cart.grandTotal;
  bool get canCheckout =>
      !cart.isEmpty && totalPaid >= cart.grandTotal - 0.01;

  CartState copyWith({
    CartEntity? cart,
    List<PaymentEntry>? selectedPayments,
    CartActionStatus? actionStatus,
    String? actionError,
    InvoiceEntity? completedInvoice,
    bool clearError = false,
    bool clearInvoice = false,
  }) {
    return CartState(
      cart:              cart              ?? this.cart,
      selectedPayments:  selectedPayments  ?? this.selectedPayments,
      actionStatus:      actionStatus      ?? this.actionStatus,
      actionError:       clearError  ? null : actionError    ?? this.actionError,
      completedInvoice:  clearInvoice? null : completedInvoice ?? this.completedInvoice,
    );
  }
}

class CartViewModel extends Notifier<CartState> {
  late ProcessSaleUseCase _processSale;

  @override
  CartState build() {
    _processSale = ref.read(processSaleUseCaseProvider);
    return const CartState();
  }


  void addToCart(MedicineEntity medicine, {int? manualAvailableQty}) {
    final unitPrice = medicine.salePrice;

    final existingIdx = state.cart.items
        .indexWhere((i) => i.medicineId == medicine.id);

    List<InvoiceItemEntity> updated;
    if (existingIdx >= 0) {
      final existing = state.cart.items[existingIdx];
      final newQty   = existing.qty + 1;

      if (manualAvailableQty != null && newQty > manualAvailableQty) {
        state = state.copyWith(
          actionError:
              'الكمية المتاحة فقط $manualAvailableQty لـ "${medicine.tradeName}".',
        );
        return;
      }
      updated = List.from(state.cart.items)
        ..[existingIdx] = existing.copyWith(qty: newQty);
    } else {
      if (manualAvailableQty != null && manualAvailableQty <= 0) {
        state = state.copyWith(
          actionError: '"${medicine.tradeName}" غير متوفر في المخزون.',
        );
        return;
      }
      final newItem = InvoiceItemEntity(
        medicineId:  medicine.id,
        tradeName:   medicine.tradeName,
        genericName: medicine.genericName,
        // ⚠️ مؤقت: لا توجد بيانات batch حقيقية بعد. استبدلها عند ربط
        // نظام المخزون الفعلي بـ batchId/batchNo/expiryDate الحقيقيين.
        batchId:     medicine.id,
        batchNo:     '',
        expiryDate:  DateTime.now(), //now
        unitPrice:   unitPrice,
        qty:         1,
      );
      updated = [...state.cart.items, newItem];
    }

    state = state.copyWith(
      cart: state.cart.copyWith(items: updated),
      clearError: true,
    );
  }

  void updateQty(String medicineId, int qty) {
    if (qty <= 0) { removeFromCart(medicineId); return; }
    final updated = state.cart.items
        .map((i) => i.medicineId == medicineId ? i.copyWith(qty: qty) : i)
        .toList();
    state = state.copyWith(cart: state.cart.copyWith(items: updated));
  }

  void updateItemDiscount(String medicineId, double pct) {
    final updated = state.cart.items
        .map((i) => i.medicineId == medicineId
            ? i.copyWith(discountPct: pct.clamp(0, 100))
            : i)
        .toList();
    state = state.copyWith(cart: state.cart.copyWith(items: updated));
  }

  void removeFromCart(String medicineId) {
    final updated = state.cart.items
        .where((i) => i.medicineId != medicineId)
        .toList();
    state = state.copyWith(cart: state.cart.copyWith(items: updated));
  }

  void setGlobalDiscount(double pct) =>
      state = state.copyWith(
          cart: state.cart.copyWith(
              globalDiscountPct: pct.clamp(0, 100)));

  void setCustomer({
    required String id,
    required String name,
    required String phone,
  }) =>
      state = state.copyWith(
          cart: state.cart.copyWith(
              customerId: id, customerName: name, customerPhone: phone));

  void clearCustomer() =>
      state = state.copyWith(cart: state.cart.copyWith(clearCustomer: true));

  void setPrescription(String? rxId) =>
      state = state.copyWith(
          cart: state.cart.copyWith(prescriptionId: rxId));

  void redeemLoyaltyPoints(int pts) =>
      state = state.copyWith(
          cart: state.cart.copyWith(loyaltyPointsRedeemed: pts));

  // ── PAYMENT ──────────────────────────────────────────────────────────────
  void setPayment(PaymentMethod method, double amount) {
    final updated = state.selectedPayments
        .where((p) => p.method != method)
        .toList();
    if (amount > 0) updated.add(PaymentEntry(method: method, amount: amount));
    state = state.copyWith(selectedPayments: updated);
  }

  void clearPayments() => state = state.copyWith(selectedPayments: []);

  // ── CHECKOUT ─────────────────────────────────────────────────────────────
  Future<bool> checkout({required String soldBy}) async {
    state = state.copyWith(
        actionStatus: CartActionStatus.loading, clearError: true);

    final result = await _processSale(ProcessSaleParams(
      cart:     state.cart,
      payments: state.selectedPayments,
      soldBy:   soldBy,
    ));

    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: CartActionStatus.error, actionError: f.message);
        return false;
      },
      (invoice) {
        state = state.copyWith(
          actionStatus:     CartActionStatus.success,
          completedInvoice: invoice,
          cart:             const CartEntity(),
          selectedPayments: [],
        );
        return true;
      },
    );
  }

  void clearCart() =>
      state = state.copyWith(
          cart: const CartEntity(),
          selectedPayments: [],
          clearError: true,
          clearInvoice: true);

  void clearMessages() =>
      state = state.copyWith(
          clearError: true, actionStatus: CartActionStatus.idle);

  /// Convenience: add a recommendation item to cart using recommendation data.
  void addRecommendationToCart(MedicineRecommendation rec) {
    final existingIdx = state.cart.items
        .indexWhere((i) => i.medicineId == rec.medicineId);

    List<InvoiceItemEntity> updated;
    if (existingIdx >= 0) {
      final existing = state.cart.items[existingIdx];
      updated = List.from(state.cart.items)
        ..[existingIdx] = existing.copyWith(qty: existing.qty + 1);
    } else {
      final newItem = InvoiceItemEntity(
        medicineId:  rec.medicineId,
        tradeName:   rec.tradeName,
        genericName: rec.genericName,
        batchId:     rec.medicineId,
        batchNo:     '',
        expiryDate:  DateTime.now(),
        unitPrice:   rec.salePrice,
        qty:         1,
      );
      updated = [...state.cart.items, newItem];
    }

    state = state.copyWith(cart: state.cart.copyWith(items: updated));
  }
}

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(CartViewModel.new);