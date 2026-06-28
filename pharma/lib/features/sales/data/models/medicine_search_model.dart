import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medicine_search_result.dart';

class MedicineSearchModel extends MedicineSearchResult {
  const MedicineSearchModel({
    required super.medicineId,
    required super.tradeName,
    required super.genericName,
    required super.manufacturer,
    required super.strength,
    required super.form,
    required super.category,
    required super.salePrice,
    required super.isControlled,
    required super.availableBatches,
  });

  factory MedicineSearchModel.fromFirestore(
    DocumentSnapshot doc,
    List<BatchStock> batches,
  ) {
    final d = doc.data() as Map<String, dynamic>;
    return MedicineSearchModel(
      medicineId:       doc.id,
      tradeName:        d['tradeName']   as String? ?? '',
      genericName:      d['genericName'] as String? ?? '',
      manufacturer:     d['manufacturer'] as String? ?? '',
      strength:         d['strength']    as String? ?? '',
      form:             d['form']        as String? ?? '',
      category:         d['category']    as String? ?? '',
      salePrice:        (d['salePrice']  as num?)?.toDouble() ?? 0,
      isControlled:     d['isControlled'] as bool? ?? false,
      availableBatches: batches,
    );
  }
}

class BatchStockModel extends BatchStock {
  const BatchStockModel({
    required super.batchId,
    required super.batchNo,
    required super.expiryDate,
    required super.qtyAvailable,
    required super.salePrice,
  });

  factory BatchStockModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BatchStockModel(
      batchId:      doc.id,
      batchNo:      d['batchNo']      as String? ?? '',
      expiryDate:   (d['expiryDate']  as Timestamp?)?.toDate() ?? DateTime.now(),
      qtyAvailable: (d['qtyAvailable'] as num?)?.toInt() ?? 0,
      salePrice:    (d['salePrice']   as num?)?.toDouble() ?? 0,
    );
  }
}