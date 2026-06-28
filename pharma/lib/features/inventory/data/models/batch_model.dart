import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/batch_entity.dart';

/// Firestore ↔ BatchEntity mapper.
class BatchModel extends BatchEntity {
  const BatchModel({
    required super.id,
    required super.medicineId,
    required super.tradeName,
    required super.batchNo,
    required super.mfgDate,
    required super.expiryDate,
    required super.purchasePrice,
    required super.salePrice,
    required super.qtyReceived,
    required super.qtySold,
    required super.qtyAdjusted,
    required super.supplierId,
    required super.status,
    required super.receivedAt,
    super.purchaseOrderId,
    super.location,
    super.notes,
  });

  factory BatchModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BatchModel(
      id: doc.id,
      medicineId: d['medicineId'] as String? ?? '',
      tradeName: d['tradeName'] as String? ?? '',
      batchNo: d['batchNo'] as String? ?? '',
      mfgDate: (d['mfgDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate:
          (d['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      purchasePrice: (d['purchasePrice'] as num?)?.toDouble() ?? 0,
      salePrice: (d['salePrice'] as num?)?.toDouble() ?? 0,
      qtyReceived: (d['qtyReceived'] as num?)?.toInt() ?? 0,
      qtySold: (d['qtySold'] as num?)?.toInt() ?? 0,
      qtyAdjusted: (d['qtyAdjusted'] as num?)?.toInt() ?? 0,
      supplierId: d['supplierId'] as String? ?? '',
      status: BatchStatus.fromString(d['status'] as String?),
      receivedAt:
          (d['receivedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      purchaseOrderId: d['purchaseOrderId'] as String?,
      location: d['location'] as String?,
      notes: d['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore({bool isNew = false}) => {
        'medicineId': medicineId,
        'tradeName': tradeName,
        'batchNo': batchNo,
        'mfgDate': Timestamp.fromDate(mfgDate),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'purchasePrice': purchasePrice,
        'salePrice': salePrice,
        'qtyReceived': qtyReceived,
        'qtySold': qtySold,
        'qtyAdjusted': qtyAdjusted,
        'qtyAvailable': qtyAvailable,   // denormalized for Firestore queries
        'supplierId': supplierId,
        'status': status.name,
        if (purchaseOrderId != null) 'purchaseOrderId': purchaseOrderId,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
        if (isNew)
          'receivedAt': FieldValue.serverTimestamp()
        else
          'receivedAt': Timestamp.fromDate(receivedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}