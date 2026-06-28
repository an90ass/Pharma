import 'package:equatable/equatable.dart';
import 'invoice_item_entity.dart';

/// A completed, persisted sales transaction.
class InvoiceEntity extends Equatable {
  const InvoiceEntity({
    required this.id,
    required this.invoiceNo,
    required this.items,
    required this.subtotal,
    required this.itemDiscountAmount,
    required this.globalDiscountPct,
    required this.globalDiscountAmount,
    required this.totalTax,
    required this.loyaltyPointsRedeemed,
    required this.loyaltyDiscount,
    required this.grandTotal,
    required this.payments,
    required this.status,
    required this.soldBy,
    required this.createdAt,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.prescriptionId,
    this.loyaltyPointsEarned = 0,
    this.notes,
    this.returnedAt,
    this.branchId,
  });

  final String id;
  final String invoiceNo;         // e.g. INV-2026-00142
  final List<InvoiceItemEntity> items;
  final double subtotal;
  final double itemDiscountAmount;
  final double globalDiscountPct;
  final double globalDiscountAmount;
  final double totalTax;
  final int loyaltyPointsRedeemed;
  final double loyaltyDiscount;
  final double grandTotal;
  final List<PaymentEntry> payments;
  final InvoiceStatus status;
  final String soldBy;            // userId
  final DateTime createdAt;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? prescriptionId;
  final int loyaltyPointsEarned;
  final String? notes;
  final DateTime? returnedAt;
  final String? branchId;

  // ── Computed ─────────────────────────────────────────────────────────
  double get totalPaid =>
      payments.fold(0.0, (s, p) => s + p.amount);

  double get changeAmount => totalPaid - grandTotal;

  double get totalDiscount =>
      itemDiscountAmount + globalDiscountAmount + loyaltyDiscount;

  int get totalQty =>
      items.fold(0, (s, i) => s + i.qty);

  InvoiceEntity copyWith({InvoiceStatus? status, DateTime? returnedAt}) {
    return InvoiceEntity(
      id: id, invoiceNo: invoiceNo, items: items,
      subtotal: subtotal, itemDiscountAmount: itemDiscountAmount,
      globalDiscountPct: globalDiscountPct,
      globalDiscountAmount: globalDiscountAmount,
      totalTax: totalTax,
      loyaltyPointsRedeemed: loyaltyPointsRedeemed,
      loyaltyDiscount: loyaltyDiscount, grandTotal: grandTotal,
      payments: payments, status: status ?? this.status,
      soldBy: soldBy, createdAt: createdAt,
      customerId: customerId, customerName: customerName,
      customerPhone: customerPhone, prescriptionId: prescriptionId,
      loyaltyPointsEarned: loyaltyPointsEarned, notes: notes,
      returnedAt: returnedAt ?? this.returnedAt, branchId: branchId,
    );
  }

  @override
  List<Object?> get props => [id, invoiceNo, status, createdAt];
}

// ── PaymentEntry ──────────────────────────────────────────────────────────────

class PaymentEntry extends Equatable {
  const PaymentEntry({required this.method, required this.amount});
  final PaymentMethod method;
  final double amount;
  @override List<Object?> get props => [method, amount];
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum InvoiceStatus {
  paid('Paid'),
  credit('Credit'),
  returned('Returned'),
  void_('Void');

  const InvoiceStatus(this.label);
  final String label;
  static InvoiceStatus fromString(String? v) =>
      InvoiceStatus.values.firstWhere((e) => e.name == v,
          orElse: () => InvoiceStatus.paid);
}

enum PaymentMethod {
  cash('Cash'),
  card('Card'),
  jazzCash('JazzCash'),
  easypaisa('Easypaisa'),
  bankTransfer('Bank Transfer'),
  storeCredit('Store Credit');

  const PaymentMethod(this.label);
  final String label;
  static PaymentMethod fromString(String? v) =>
      PaymentMethod.values.firstWhere((e) => e.name == v,
          orElse: () => PaymentMethod.cash);
}

/// Quick summary for Sales History list — avoid loading full invoice.
class InvoiceSummary extends Equatable {
  const InvoiceSummary({
    required this.id,
    required this.invoiceNo,
    required this.grandTotal,
    required this.customerName,
    required this.status,
    required this.itemCount,
    required this.createdAt,
  });
  final String id;
  final String invoiceNo;
  final double grandTotal;
  final String customerName;
  final InvoiceStatus status;
  final int itemCount;
  final DateTime createdAt;
  @override List<Object?> get props => [id, invoiceNo, createdAt];
}