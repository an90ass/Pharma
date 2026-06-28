import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/purchase_order_entity.dart';

class PurchaseOrderModel extends PurchaseOrderEntity {
  const PurchaseOrderModel({
    required super.id,
    required super.poNumber,
    required super.supplierId,
    required super.supplierName,
    required super.items,
    required super.status,
    required super.createdBy,
    required super.createdAt,
    super.approvedBy,
    super.notes,
    super.expectedDate,
    super.receivedAt,
    super.totalAmount,
  });

  factory PurchaseOrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawItems = d['items'] as List<dynamic>? ?? [];
    return PurchaseOrderModel(
      id: doc.id,
      poNumber: d['poNumber'] as String? ?? '',
      supplierId: d['supplierId'] as String? ?? '',
      supplierName: d['supplierName'] as String? ?? '',
      items: rawItems
          .map((e) => POItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      status: POStatus.fromString(d['status'] as String?),
      createdBy: d['createdBy'] as String? ?? '',
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedBy: d['approvedBy'] as String?,
      notes: d['notes'] as String?,
      expectedDate: (d['expectedDate'] as Timestamp?)?.toDate(),
      receivedAt: (d['receivedAt'] as Timestamp?)?.toDate(),
      totalAmount: (d['totalAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore({bool isNew = false}) => {
        'poNumber': poNumber,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'items': items
            .map((i) => POItemModel.fromEntity(i).toMap())
            .toList(),
        'status': status.name,
        'totalAmount': computedTotal,
        'createdBy': createdBy,
        if (approvedBy != null) 'approvedBy': approvedBy,
        if (notes != null) 'notes': notes,
        if (expectedDate != null)
          'expectedDate': Timestamp.fromDate(expectedDate!),
        if (receivedAt != null)
          'receivedAt': Timestamp.fromDate(receivedAt!),
        if (isNew)
          'createdAt': FieldValue.serverTimestamp()
        else
          'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class POItemModel extends POItem {
  const POItemModel({
    required super.medicineId,
    required super.tradeName,
    required super.orderedQty,
    required super.unitPrice,
    super.receivedQty,
    super.batchNo,
    super.expiryDate,
    super.mfgDate,
    super.notes,
  });

  factory POItemModel.fromMap(Map<String, dynamic> d) => POItemModel(
        medicineId: d['medicineId'] as String? ?? '',
        tradeName: d['tradeName'] as String? ?? '',
        orderedQty: (d['orderedQty'] as num?)?.toInt() ?? 0,
        unitPrice: (d['unitPrice'] as num?)?.toDouble() ?? 0,
        receivedQty: (d['receivedQty'] as num?)?.toInt() ?? 0,
        batchNo: d['batchNo'] as String?,
        expiryDate: (d['expiryDate'] as Timestamp?)?.toDate(),
        mfgDate: (d['mfgDate'] as Timestamp?)?.toDate(),
        notes: d['notes'] as String?,
      );

  factory POItemModel.fromEntity(POItem e) => POItemModel(
        medicineId: e.medicineId,
        tradeName: e.tradeName,
        orderedQty: e.orderedQty,
        unitPrice: e.unitPrice,
        receivedQty: e.receivedQty,
        batchNo: e.batchNo,
        expiryDate: e.expiryDate,
        mfgDate: e.mfgDate,
        notes: e.notes,
      );

  Map<String, dynamic> toMap() => {
        'medicineId': medicineId,
        'tradeName': tradeName,
        'orderedQty': orderedQty,
        'unitPrice': unitPrice,
        'receivedQty': receivedQty,
        if (batchNo != null) 'batchNo': batchNo,
        if (expiryDate != null)
          'expiryDate': Timestamp.fromDate(expiryDate!),
        if (mfgDate != null) 'mfgDate': Timestamp.fromDate(mfgDate!),
        if (notes != null) 'notes': notes,
      };
}

class StockAdjustmentModel extends StockAdjustmentEntity {
  const StockAdjustmentModel({
    required super.id,
    required super.batchId,
    required super.medicineId,
    required super.tradeName,
    required super.type,
    required super.qty,
    required super.reason,
    required super.adjustedBy,
    required super.createdAt,
  });

  factory StockAdjustmentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StockAdjustmentModel(
      id: doc.id,
      batchId: d['batchId'] as String? ?? '',
      medicineId: d['medicineId'] as String? ?? '',
      tradeName: d['tradeName'] as String? ?? '',
      type: AdjustmentType.fromString(d['type'] as String?),
      qty: (d['qty'] as num?)?.toInt() ?? 0,
      reason: d['reason'] as String? ?? '',
      adjustedBy: d['adjustedBy'] as String? ?? '',
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'batchId': batchId,
        'medicineId': medicineId,
        'tradeName': tradeName,
        'type': type.name,
        'qty': qty,
        'reason': reason,
        'adjustedBy': adjustedBy,
        'createdAt': FieldValue.serverTimestamp(),
      };
}