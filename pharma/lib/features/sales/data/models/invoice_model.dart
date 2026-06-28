import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_item_entity.dart';
import 'invoice_item_model.dart';

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNo,
    required super.items,
    required super.subtotal,
    required super.itemDiscountAmount,
    required super.globalDiscountPct,
    required super.globalDiscountAmount,
    required super.totalTax,
    required super.loyaltyPointsRedeemed,
    required super.loyaltyDiscount,
    required super.grandTotal,
    required super.payments,
    required super.status,
    required super.soldBy,
    required super.createdAt,
    super.customerId,
    super.customerName,
    super.customerPhone,
    super.prescriptionId,
    super.loyaltyPointsEarned,
    super.notes,
    super.returnedAt,
    super.branchId,
  });

  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawItems  = d['items']    as List<dynamic>? ?? [];
    final rawPay    = d['payments'] as List<dynamic>? ?? [];
    return InvoiceModel(
      id:                   doc.id,
      invoiceNo:            d['invoiceNo']            as String? ?? '',
      items: rawItems
          .map((e) => InvoiceItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      subtotal:             (d['subtotal']            as num?)?.toDouble() ?? 0,
      itemDiscountAmount:   (d['itemDiscountAmount']  as num?)?.toDouble() ?? 0,
      globalDiscountPct:    (d['globalDiscountPct']   as num?)?.toDouble() ?? 0,
      globalDiscountAmount: (d['globalDiscountAmount'] as num?)?.toDouble() ?? 0,
      totalTax:             (d['totalTax']            as num?)?.toDouble() ?? 0,
      loyaltyPointsRedeemed:(d['loyaltyPointsRedeemed'] as num?)?.toInt() ?? 0,
      loyaltyDiscount:      (d['loyaltyDiscount']     as num?)?.toDouble() ?? 0,
      grandTotal:           (d['grandTotal']          as num?)?.toDouble() ?? 0,
      payments: rawPay.map((e) {
        final m = e as Map<String, dynamic>;
        return PaymentEntry(
          method: PaymentMethod.fromString(m['method'] as String?),
          amount: (m['amount'] as num?)?.toDouble() ?? 0,
        );
      }).toList(),
      status:               InvoiceStatus.fromString(d['status'] as String?),
      soldBy:               d['soldBy']               as String? ?? '',
      createdAt:            (d['createdAt']            as Timestamp?)?.toDate() ?? DateTime.now(),
      customerId:           d['customerId']            as String?,
      customerName:         d['customerName']          as String?,
      customerPhone:        d['customerPhone']         as String?,
      prescriptionId:       d['prescriptionId']        as String?,
      loyaltyPointsEarned:  (d['loyaltyPointsEarned'] as num?)?.toInt() ?? 0,
      notes:                d['notes']                 as String?,
      returnedAt:           (d['returnedAt']           as Timestamp?)?.toDate(),
      branchId:             d['branchId']              as String?,
    );
  }

  Map<String, dynamic> toFirestore({bool isNew = false}) => {
        'invoiceNo':            invoiceNo,
        'items': items
            .map((i) => InvoiceItemModel.fromEntity(i).toMap())
            .toList(),
        'subtotal':             subtotal,
        'itemDiscountAmount':   itemDiscountAmount,
        'globalDiscountPct':    globalDiscountPct,
        'globalDiscountAmount': globalDiscountAmount,
        'totalTax':             totalTax,
        'loyaltyPointsRedeemed': loyaltyPointsRedeemed,
        'loyaltyDiscount':      loyaltyDiscount,
        'grandTotal':           grandTotal,
        'payments': payments.map((p) => {
              'method': p.method.name,
              'amount': p.amount,
            }).toList(),
        'status':               status.name,
        'soldBy':               soldBy,
        if (customerId    != null) 'customerId':     customerId,
        if (customerName  != null) 'customerName':   customerName,
        if (customerPhone != null) 'customerPhone':  customerPhone,
        if (prescriptionId != null) 'prescriptionId': prescriptionId,
        'loyaltyPointsEarned':  loyaltyPointsEarned,
        if (notes     != null) 'notes':     notes,
        if (branchId  != null) 'branchId':  branchId,
        if (isNew)
          'createdAt': FieldValue.serverTimestamp()
        else
          'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class InvoiceSummaryModel extends InvoiceSummary {
  const InvoiceSummaryModel({
    required super.id,
    required super.invoiceNo,
    required super.grandTotal,
    required super.customerName,
    required super.status,
    required super.itemCount,
    required super.createdAt,
  });

  factory InvoiceSummaryModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final items = d['items'] as List<dynamic>? ?? [];
    return InvoiceSummaryModel(
      id:           doc.id,
      invoiceNo:    d['invoiceNo']    as String? ?? '',
      grandTotal:   (d['grandTotal']  as num?)?.toDouble() ?? 0,
      customerName: d['customerName'] as String? ?? 'Walk-in',
      status:       InvoiceStatus.fromString(d['status'] as String?),
      itemCount:    items.length,
      createdAt:    (d['createdAt']   as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}