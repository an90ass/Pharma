import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../models/invoice_model.dart';
import '../models/medicine_search_model.dart';

abstract class SalesRemoteDataSource {
  Future<List<MedicineSearchModel>> searchMedicines(String query);
  Future<MedicineSearchModel> getMedicineByBarcode(String barcode);
  Future<InvoiceModel> createInvoice({
    required CartEntity cart,
    required List<PaymentEntry> payments,
    required String soldBy,
    String? branchId,
  });
  Future<List<InvoiceSummaryModel>> getInvoiceSummaries({
    DateTime? from, DateTime? to, int limit, String? lastInvoiceId,
  });
  Stream<List<InvoiceSummaryModel>> watchTodayInvoices();
  Future<InvoiceModel> getInvoiceById(String id);
  Future<List<InvoiceSummaryModel>> searchInvoices(String query);
  Future<InvoiceModel> returnInvoice({
    required String invoiceId, required String processedBy, String? reason,
  });
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  const SalesRemoteDataSourceImpl(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> get _medicines =>
      _fs.collection('medicines');
  CollectionReference<Map<String, dynamic>> get _batches =>
      _fs.collection('batches');
  CollectionReference<Map<String, dynamic>> get _invoices =>
      _fs.collection('invoices');
  CollectionReference<Map<String, dynamic>> get _customers =>
      _fs.collection('customers');

  // ── SEARCH ────────────────────────────────────────────────────────────
  @override
  Future<List<MedicineSearchModel>> searchMedicines(String query) async {
    try {
      final token = query.toLowerCase();
      final snap = await _medicines
          .where('isActive', isEqualTo: true)
          .where('searchTokens', arrayContains: token)
          .limit(20)
          .get();

      final results = await Future.wait(snap.docs.map((doc) async {
        final batches = await _getAvailableBatches(doc.id);
        return MedicineSearchModel.fromFirestore(doc, batches);
      }));
      return results;
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<MedicineSearchModel> getMedicineByBarcode(String barcode) async {
    try {
      final snap = await _medicines
          .where('barcode', isEqualTo: barcode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) throw const NotFoundException();
      final doc     = snap.docs.first;
      final batches = await _getAvailableBatches(doc.id);
      return MedicineSearchModel.fromFirestore(doc, batches);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<List<BatchStockModel>> _getAvailableBatches(
      String medicineId) async {
    final snap = await _batches
        .where('medicineId', isEqualTo: medicineId)
        .where('status', isEqualTo: 'active')
        .where('qtyAvailable', isGreaterThan: 0)
        .orderBy('qtyAvailable')
        .orderBy('receivedAt')      // FIFO
        .get();
    return snap.docs.map(BatchStockModel.fromFirestore).toList();
  }

  // ── CREATE INVOICE ────────────────────────────────────────────────────
  @override
  Future<InvoiceModel> createInvoice({
    required CartEntity cart,
    required List<PaymentEntry> payments,
    required String soldBy,
    String? branchId,
  }) async {
    try {
      final invoiceRef  = _invoices.doc();
      final invoiceNo   =
          'INV-${DateTime.now().year}-${invoiceRef.id.substring(0, 6).toUpperCase()}';
      final earned      = (cart.grandTotal / 100).floor(); // 1 pt per Rs 100

      final batch = _fs.batch();


      // 1. Create invoice document
      final model = InvoiceModel(
        id:                   invoiceRef.id,
        invoiceNo:            invoiceNo,
        items:                cart.items,
        subtotal:             cart.subtotal,
        itemDiscountAmount:   cart.itemDiscountAmount,
        globalDiscountPct:    cart.globalDiscountPct,
        globalDiscountAmount: cart.globalDiscountAmount,
        totalTax:             cart.totalTax,
        loyaltyPointsRedeemed: cart.loyaltyPointsRedeemed,
        loyaltyDiscount:      cart.loyaltyDiscount,
        grandTotal:           cart.grandTotal,
        payments:             payments,
        status:               InvoiceStatus.paid,
        soldBy:               soldBy,
        createdAt:            DateTime.now(),
        customerId:           cart.customerId,
        customerName:         cart.customerName,
        customerPhone:        cart.customerPhone,
        prescriptionId:       cart.prescriptionId,
        loyaltyPointsEarned:  earned,
        notes:                cart.notes,
        branchId:             branchId,
      );
      batch.set(invoiceRef, model.toFirestore(isNew: true));
      print("Updating batch: ${cart.items}");
     // 2. Deduct stock from each batch
      for (final item in cart.items) {
        print("Updating batch: itrem $item");
        final bRef = _batches.doc(item.batchId);
        batch.update(bRef, {
          'qtySold':      FieldValue.increment(item.qty),
          'qtyAvailable': FieldValue.increment(-item.qty),
          'updatedAt':    FieldValue.serverTimestamp(),
        });
      }

      // 3. Update customer loyalty + totalPurchases
      if (cart.customerId != null) {
        final cRef = _customers.doc(cart.customerId);
        batch.update(cRef, {
          'loyaltyPoints':  FieldValue.increment(
              earned - cart.loyaltyPointsRedeemed),
          'totalPurchases': FieldValue.increment(cart.grandTotal),
          'updatedAt':      FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // 4. Mark low-stock flag on medicines (best-effort, non-blocking)
      _updateLowStockFlags(cart.items.map((i) => i.medicineId).toList());

      final created = await invoiceRef.get();
      return InvoiceModel.fromFirestore(created);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  void _updateLowStockFlags(List<String> medicineIds) {
    for (final id in medicineIds.toSet()) {
      _batches
          .where('medicineId', isEqualTo: id)
          .where('status', isEqualTo: 'active')
          .get()
          .then((snap) {
        final total =
            snap.docs.fold<int>(0, (s, d) => s + ((d['qtyAvailable'] as num?)?.toInt() ?? 0));
        _medicines.doc(id).get().then((med) {
          if (!med.exists) return;
          final reorder = (med['reorderLevel'] as num?)?.toInt() ?? 10;
          _medicines.doc(id).update({'isLowStock': total <= reorder});
        });
      }).catchError((_) {});
    }
  }

  // ── SALES HISTORY ─────────────────────────────────────────────────────
  @override
  Future<List<InvoiceSummaryModel>> getInvoiceSummaries({
    DateTime? from,
    DateTime? to,
    int limit = 30,
    String? lastInvoiceId,
  }) async {
    try {
      Query<Map<String, dynamic>> q =
          _invoices.orderBy('createdAt', descending: true);
      if (from != null) {
        q = q.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(from));
      }
      if (to != null) {
        q = q.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(to));
      }
      if (lastInvoiceId != null) {
        final last = await _invoices.doc(lastInvoiceId).get();
        q = q.startAfterDocument(last);
      }
      final snap = await q.limit(limit).get();
      return snap.docs.map(InvoiceSummaryModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Stream<List<InvoiceSummaryModel>> watchTodayInvoices() {
    final start = DateTime.now();
    final todayStart =
        DateTime(start.year, start.month, start.day);
    return _invoices
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map(InvoiceSummaryModel.fromFirestore).toList())
        .handleError((e) => throw ServerException(e.toString()));
  }

  @override
  Future<InvoiceModel> getInvoiceById(String id) async {
    try {
      final doc = await _invoices.doc(id).get();
      if (!doc.exists) throw const NotFoundException();
      return InvoiceModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<InvoiceSummaryModel>> searchInvoices(String query) async {
    try {
      // Search by invoiceNo prefix OR customerPhone
      final byNo = await _invoices
          .where('invoiceNo',
              isGreaterThanOrEqualTo: query.toUpperCase())
          .where('invoiceNo',
              isLessThanOrEqualTo: '${query.toUpperCase()}\uf8ff')
          .limit(10)
          .get();
      final byPhone = await _invoices
          .where('customerPhone', isEqualTo: query)
          .limit(10)
          .get();

      final combined = <String, DocumentSnapshot>{};
      for (final doc in [...byNo.docs, ...byPhone.docs]) {
        combined[doc.id] = doc;
      }
      return combined.values
          .map(InvoiceSummaryModel.fromFirestore)
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<InvoiceModel> returnInvoice({
    required String invoiceId,
    required String processedBy,
    String? reason,
  }) async {
    try {
      final ref = _invoices.doc(invoiceId);
      await ref.update({
        'status':     InvoiceStatus.returned.name,
        'returnedAt': FieldValue.serverTimestamp(),
        'returnedBy': processedBy,
        if (reason != null) 'returnReason': reason,
        'updatedAt':  FieldValue.serverTimestamp(),
      });
      final doc = await ref.get();
      return InvoiceModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }
}