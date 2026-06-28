import 'package:equatable/equatable.dart';

/// Represents a single received stock batch for a medicine.
///
/// Each GRN (Goods Receipt Note) creates one BatchEntity per line item.
/// FIFO is enforced by sorting on [receivedAt] ascending before any sale.
class BatchEntity extends Equatable {
  const BatchEntity({
    required this.id,
    required this.medicineId,
    required this.tradeName,
    required this.batchNo,
    required this.mfgDate,
    required this.expiryDate,
    required this.purchasePrice,
    required this.salePrice,
    required this.qtyReceived,
    required this.qtySold,
    required this.qtyAdjusted,
    required this.supplierId,
    required this.status,
    required this.receivedAt,
    this.purchaseOrderId,
    this.location,
    this.notes,
  });

  final String id;
  final String medicineId;
  final String tradeName;       // denormalized — avoid extra Firestore read
  final String batchNo;
  final DateTime mfgDate;
  final DateTime expiryDate;
  final double purchasePrice;
  final double salePrice;       // can override medicine's default sale price
  final int qtyReceived;
  final int qtySold;
  final int qtyAdjusted;        // +/- from manual stock adjustments
  final String supplierId;
  final BatchStatus status;
  final DateTime receivedAt;
  final String? purchaseOrderId;
  final String? location;       // shelf / rack / cold storage
  final String? notes;

  // ── Computed ─────────────────────────────────────────────────────────
  int get qtyAvailable => qtyReceived - qtySold + qtyAdjusted;
  bool get isDepleted => qtyAvailable <= 0;

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool get isNearExpiry {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 30;
  }

  int get daysUntilExpiry =>
      expiryDate.difference(DateTime.now()).inDays;

  ExpiryUrgency get expiryUrgency {
    if (isExpired) return ExpiryUrgency.expired;
    if (daysUntilExpiry <= 30) return ExpiryUrgency.critical;
    if (daysUntilExpiry <= 60) return ExpiryUrgency.warning;
    if (daysUntilExpiry <= 90) return ExpiryUrgency.notice;
    return ExpiryUrgency.safe;
  }

  double get stockValue => qtyAvailable * purchasePrice;

  BatchEntity copyWith({
    String? id,
    String? medicineId,
    String? tradeName,
    String? batchNo,
    DateTime? mfgDate,
    DateTime? expiryDate,
    double? purchasePrice,
    double? salePrice,
    int? qtyReceived,
    int? qtySold,
    int? qtyAdjusted,
    String? supplierId,
    BatchStatus? status,
    DateTime? receivedAt,
    String? purchaseOrderId,
    String? location,
    String? notes,
  }) {
    return BatchEntity(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      tradeName: tradeName ?? this.tradeName,
      batchNo: batchNo ?? this.batchNo,
      mfgDate: mfgDate ?? this.mfgDate,
      expiryDate: expiryDate ?? this.expiryDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      qtyReceived: qtyReceived ?? this.qtyReceived,
      qtySold: qtySold ?? this.qtySold,
      qtyAdjusted: qtyAdjusted ?? this.qtyAdjusted,
      supplierId: supplierId ?? this.supplierId,
      status: status ?? this.status,
      receivedAt: receivedAt ?? this.receivedAt,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id, medicineId, batchNo, expiryDate,
        qtyReceived, qtySold, qtyAdjusted, status,
      ];
}

// ── Supporting enums ──────────────────────────────────────────────────────────

enum BatchStatus {
  active('Active'),
  depleted('Depleted'),
  expired('Expired'),
  recalled('Recalled'),
  quarantine('Quarantine');

  const BatchStatus(this.label);
  final String label;

  static BatchStatus fromString(String? v) =>
      BatchStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => BatchStatus.active,
      );
}

enum ExpiryUrgency {
  safe,      // > 90 days
  notice,    // 61–90 days
  warning,   // 31–60 days
  critical,  // 1–30 days
  expired;   // past expiry date
}

/// Lightweight summary used in low-stock alerts and dashboard.
class StockSummary extends Equatable {
  const StockSummary({
    required this.medicineId,
    required this.tradeName,
    required this.genericName,
    required this.totalQtyAvailable,
    required this.reorderLevel,
    required this.batches,
  });

  final String medicineId;
  final String tradeName;
  final String genericName;
  final int totalQtyAvailable;
  final int reorderLevel;
  final List<BatchEntity> batches;

  bool get isLowStock => totalQtyAvailable <= reorderLevel;
  bool get isOutOfStock => totalQtyAvailable <= 0;

  @override
  List<Object?> get props =>
      [medicineId, totalQtyAvailable, reorderLevel];
}