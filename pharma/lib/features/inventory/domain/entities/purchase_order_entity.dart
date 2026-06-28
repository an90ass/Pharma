import 'package:equatable/equatable.dart';

/// Represents a purchase order sent to a supplier.
///
/// Lifecycle: draft → sent → partial → received → closed
/// A GRN (Goods Receipt) transitions status to [received] or [partial].
class PurchaseOrderEntity extends Equatable {
  const PurchaseOrderEntity({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.approvedBy,
    this.notes,
    this.expectedDate,
    this.receivedAt,
    this.totalAmount,
  });

  final String id;
  final String poNumber;      // e.g. "PO-2026-0041"
  final String supplierId;
  final String supplierName;  // denormalized
  final List<POItem> items;
  final POStatus status;
  final String createdBy;     // userId
  final DateTime createdAt;
  final String? approvedBy;
  final String? notes;
  final DateTime? expectedDate;
  final DateTime? receivedAt;
  final double? totalAmount;

  // ── Computed ─────────────────────────────────────────────────────────
  double get computedTotal =>
      items.fold(0, (sum, i) => sum + (i.orderedQty * i.unitPrice));

  bool get isFullyReceived =>
      items.every((i) => i.receivedQty >= i.orderedQty);

  bool get isPartiallyReceived =>
      items.any((i) => i.receivedQty > 0) && !isFullyReceived;

  int get totalItemsOrdered =>
      items.fold(0, (sum, i) => sum + i.orderedQty);

  int get totalItemsReceived =>
      items.fold(0, (sum, i) => sum + i.receivedQty);

  PurchaseOrderEntity copyWith({
    String? id,
    String? poNumber,
    String? supplierId,
    String? supplierName,
    List<POItem>? items,
    POStatus? status,
    String? createdBy,
    DateTime? createdAt,
    String? approvedBy,
    String? notes,
    DateTime? expectedDate,
    DateTime? receivedAt,
    double? totalAmount,
  }) {
    return PurchaseOrderEntity(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      approvedBy: approvedBy ?? this.approvedBy,
      notes: notes ?? this.notes,
      expectedDate: expectedDate ?? this.expectedDate,
      receivedAt: receivedAt ?? this.receivedAt,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [id, poNumber, supplierId, status, createdAt];
}

// ── POItem ────────────────────────────────────────────────────────────────────

/// A single line item within a [PurchaseOrderEntity].
class POItem extends Equatable {
  const POItem({
    required this.medicineId,
    required this.tradeName,
    required this.orderedQty,
    required this.unitPrice,
    this.receivedQty = 0,
    this.batchNo,
    this.expiryDate,
    this.mfgDate,
    this.notes,
  });

  final String medicineId;
  final String tradeName;
  final int orderedQty;
  final double unitPrice;
  final int receivedQty;
  final String? batchNo;
  final DateTime? expiryDate;
  final DateTime? mfgDate;
  final String? notes;

  double get lineTotal => orderedQty * unitPrice;
  int get pendingQty => orderedQty - receivedQty;
  bool get isFullyReceived => receivedQty >= orderedQty;

  POItem copyWith({
    String? medicineId,
    String? tradeName,
    int? orderedQty,
    double? unitPrice,
    int? receivedQty,
    String? batchNo,
    DateTime? expiryDate,
    DateTime? mfgDate,
    String? notes,
  }) {
    return POItem(
      medicineId: medicineId ?? this.medicineId,
      tradeName: tradeName ?? this.tradeName,
      orderedQty: orderedQty ?? this.orderedQty,
      unitPrice: unitPrice ?? this.unitPrice,
      receivedQty: receivedQty ?? this.receivedQty,
      batchNo: batchNo ?? this.batchNo,
      expiryDate: expiryDate ?? this.expiryDate,
      mfgDate: mfgDate ?? this.mfgDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props =>
      [medicineId, orderedQty, unitPrice, receivedQty];
}

// ── Supporting enums ──────────────────────────────────────────────────────────

enum POStatus {
  draft('Draft'),
  sent('Sent'),
  partial('Partially Received'),
  received('Received'),
  cancelled('Cancelled');

  const POStatus(this.label);
  final String label;

  static POStatus fromString(String? v) => POStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => POStatus.draft,
      );

  bool get isEditable => this == draft;
  bool get canReceive => this == sent || this == partial;
}

// ── StockAdjustment ───────────────────────────────────────────────────────────

/// Records a manual stock change (damage, audit, correction).
class StockAdjustmentEntity extends Equatable {
  const StockAdjustmentEntity({
    required this.id,
    required this.batchId,
    required this.medicineId,
    required this.tradeName,
    required this.type,
    required this.qty,
    required this.reason,
    required this.adjustedBy,
    required this.createdAt,
  });

  final String id;
  final String batchId;
  final String medicineId;
  final String tradeName;
  final AdjustmentType type;
  final int qty;              // positive = add, negative = remove
  final String reason;
  final String adjustedBy;   // userId
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, batchId, qty, type, createdAt];
}

enum AdjustmentType {
  damaged('Damaged'),
  expired('Expired / Disposed'),
  auditCorrection('Audit Correction'),
  returnFromCustomer('Customer Return'),
  returnToSupplier('Supplier Return'),
  manualAdd('Manual Addition'),
  theft('Theft / Loss');

  const AdjustmentType(this.label);
  final String label;

  static AdjustmentType fromString(String? v) =>
      AdjustmentType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => AdjustmentType.auditCorrection,
      );

  /// Whether this adjustment type adds (+) or removes (-) stock
  bool get isAddition =>
      this == manualAdd || this == returnFromCustomer;
}