import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invoice_item_entity.dart';

class InvoiceItemModel extends InvoiceItemEntity {
  const InvoiceItemModel({
    required super.medicineId,
    required super.tradeName,
    required super.genericName,
    required super.batchId,
    required super.batchNo,
    required super.expiryDate,
    required super.unitPrice,
    required super.qty,
    super.discountPct,
    super.taxPct,
  });

  factory InvoiceItemModel.fromMap(Map<String, dynamic> d) =>
      InvoiceItemModel(
        medicineId:  d['medicineId']  as String? ?? '',
        tradeName:   d['tradeName']   as String? ?? '',
        genericName: d['genericName'] as String? ?? '',
        batchId:     d['batchId']     as String? ?? '',
        batchNo:     d['batchNo']     as String? ?? '',
        expiryDate:  (d['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        unitPrice:   (d['unitPrice']  as num?)?.toDouble() ?? 0,
        qty:         (d['qty']        as num?)?.toInt()    ?? 1,
        discountPct: (d['discountPct'] as num?)?.toDouble() ?? 0,
        taxPct:      (d['taxPct']     as num?)?.toDouble() ?? 0,
      );

  factory InvoiceItemModel.fromEntity(InvoiceItemEntity e) =>
      InvoiceItemModel(
        medicineId:  e.medicineId,
        tradeName:   e.tradeName,
        genericName: e.genericName,
        batchId:     e.batchId,
        batchNo:     e.batchNo,
        expiryDate:  e.expiryDate,
        unitPrice:   e.unitPrice,
        qty:         e.qty,
        discountPct: e.discountPct,
        taxPct:      e.taxPct,
      );

  Map<String, dynamic> toMap() => {
        'medicineId':  medicineId,
        'tradeName':   tradeName,
        'genericName': genericName,
        'batchId':     batchId,
        'batchNo':     batchNo,
        'expiryDate':  Timestamp.fromDate(expiryDate),
        'unitPrice':   unitPrice,
        'qty':         qty,
        'discountPct': discountPct,
        'taxPct':      taxPct,
        'lineTotal':   lineTotal,      // denormalized for reports
      };
}