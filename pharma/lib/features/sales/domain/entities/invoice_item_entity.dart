import 'package:equatable/equatable.dart';

/// A single line item within an invoice or cart.
class InvoiceItemEntity extends Equatable {
  const InvoiceItemEntity({
    required this.medicineId,
    required this.tradeName,
    required this.genericName,
    required this.batchId,
    required this.batchNo,
    required this.expiryDate,
    required this.unitPrice,
    required this.qty,
    this.discountPct = 0,
    this.taxPct = 0,
  });

  final String medicineId;
  final String tradeName;
  final String genericName;
  final String batchId;
  final String batchNo;
  final DateTime expiryDate;
  final double unitPrice;
  final int qty;
  final double discountPct;   // 0–100
  final double taxPct;        // 0–100

  // ── Computed ─────────────────────────────────────────────────────────
  double get subtotal => unitPrice * qty;
  double get discountAmount => subtotal * (discountPct / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxPct / 100);
  double get lineTotal => taxableAmount + taxAmount;

  InvoiceItemEntity copyWith({
    String? medicineId,
    String? tradeName,
    String? genericName,
    String? batchId,
    String? batchNo,
    DateTime? expiryDate,
    double? unitPrice,
    int? qty,
    double? discountPct,
    double? taxPct,
  }) {
    return InvoiceItemEntity(
      medicineId:  medicineId  ?? this.medicineId,
      tradeName:   tradeName   ?? this.tradeName,
      genericName: genericName ?? this.genericName,
      batchId:     batchId     ?? this.batchId,
      batchNo:     batchNo     ?? this.batchNo,
      expiryDate:  expiryDate  ?? this.expiryDate,
      unitPrice:   unitPrice   ?? this.unitPrice,
      qty:         qty         ?? this.qty,
      discountPct: discountPct ?? this.discountPct,
      taxPct:      taxPct      ?? this.taxPct,
    );
  }

  @override
  List<Object?> get props =>
      [medicineId, batchId, qty, unitPrice, discountPct, taxPct];
}