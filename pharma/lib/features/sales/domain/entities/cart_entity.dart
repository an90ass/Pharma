import 'package:equatable/equatable.dart';
import 'invoice_item_entity.dart';

/// In-memory cart state — lives only in the ViewModel until checkout.
class CartEntity extends Equatable {
  const CartEntity({
    this.items = const [],
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.prescriptionId,
    this.globalDiscountPct = 0,
    this.loyaltyPointsRedeemed = 0,
    this.notes,
  });

  final List<InvoiceItemEntity> items;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? prescriptionId;
  final double globalDiscountPct;   // applied on top of item discounts
  final int loyaltyPointsRedeemed;
  final String? notes;

  // ── Computed ─────────────────────────────────────────────────────────
  bool get isEmpty => items.isEmpty;
  int get totalQty => items.fold(0, (s, i) => s + i.qty);

  double get subtotal =>
      items.fold(0.0, (s, i) => s + i.subtotal);

  double get itemDiscountAmount =>
      items.fold(0.0, (s, i) => s + i.discountAmount);

  double get afterItemDiscount => subtotal - itemDiscountAmount;

  double get globalDiscountAmount =>
      afterItemDiscount * (globalDiscountPct / 100);

  double get taxableAmount =>
      afterItemDiscount - globalDiscountAmount;

  double get totalTax =>
      items.fold(0.0, (s, i) => s + i.taxAmount);

  double get loyaltyDiscount => loyaltyPointsRedeemed * 0.5; // 0.5 PKR per point

  double get grandTotal =>
      taxableAmount + totalTax - loyaltyDiscount;

  double get totalDiscount =>
      itemDiscountAmount + globalDiscountAmount + loyaltyDiscount;

  CartEntity copyWith({
    List<InvoiceItemEntity>? items,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? prescriptionId,
    double? globalDiscountPct,
    int? loyaltyPointsRedeemed,
    String? notes,
    bool clearCustomer = false,
  }) {
    return CartEntity(
      items:                  items                  ?? this.items,
      customerId:             clearCustomer ? null   : customerId   ?? this.customerId,
      customerName:           clearCustomer ? null   : customerName ?? this.customerName,
      customerPhone:          clearCustomer ? null   : customerPhone ?? this.customerPhone,
      prescriptionId:         prescriptionId         ?? this.prescriptionId,
      globalDiscountPct:      globalDiscountPct      ?? this.globalDiscountPct,
      loyaltyPointsRedeemed:  loyaltyPointsRedeemed  ?? this.loyaltyPointsRedeemed,
      notes:                  notes                  ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        items, customerId, globalDiscountPct,
        loyaltyPointsRedeemed, prescriptionId,
      ];
}