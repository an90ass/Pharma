import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/batch_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../models/batch_model.dart';
import '../models/purchase_order_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<BatchModel>> getBatchesForMedicine(String medicineId);
  Stream<List<BatchModel>> watchBatchesForMedicine(String medicineId);
  Future<BatchModel> getBatchById(String batchId);
  Future<List<BatchModel>> getExpiringBatches({int withinDays = 30});
  Stream<List<BatchModel>> watchExpiringBatches({int withinDays = 30});
  Future<List<StockSummary>> getLowStockMedicines();
  Stream<List<StockSummary>> watchLowStockMedicines();
  Future<BatchModel> receiveStock(BatchModel batch);
  Future<StockAdjustmentModel> adjustStock(StockAdjustmentModel adj);
  Future<BatchModel> deductStock({required String batchId, required int qty});
  Future<List<PurchaseOrderModel>> getPurchaseOrders();
  Stream<List<PurchaseOrderModel>> watchPurchaseOrders();
  Future<PurchaseOrderModel> getPurchaseOrderById(String id);
  Future<PurchaseOrderModel> createPurchaseOrder(PurchaseOrderModel po);
  Future<PurchaseOrderModel> updatePurchaseOrder(PurchaseOrderModel po);
  Future<PurchaseOrderModel> receivePurchaseOrder({
    required String poId,
    required List<POItem> receivedItems,
    required String receivedBy,
  });
  Future<void> cancelPurchaseOrder(String id);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  const InventoryRemoteDataSourceImpl(this._fs);
  final FirebaseFirestore _fs;

  // ── Collection refs ─────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _batches =>
      _fs.collection('batches');
  CollectionReference<Map<String, dynamic>> get _medicines =>
      _fs.collection('medicines');
  CollectionReference<Map<String, dynamic>> get _adjustments =>
      _fs.collection('stockAdjustments');
  CollectionReference<Map<String, dynamic>> get _pos =>
      _fs.collection('purchaseOrders');

  // ── BATCHES ──────────────────────────────────────────────────────────────

  @override
  Future<List<BatchModel>> getBatchesForMedicine(String medicineId) async {
    try {
      final snap = await _batches
          .where('medicineId', isEqualTo: medicineId)
          .where('status', isEqualTo: 'active')
          .orderBy('receivedAt')          // FIFO
          .get();
      return snap.docs.map(BatchModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Stream<List<BatchModel>> watchBatchesForMedicine(String medicineId) =>
      _batches
          .where('medicineId', isEqualTo: medicineId)
          .where('status', isEqualTo: 'active')
          .orderBy('receivedAt')
          .snapshots()
          .map((s) => s.docs.map(BatchModel.fromFirestore).toList())
          .handleError((e) => throw ServerException(e.toString()));

  @override
  Future<BatchModel> getBatchById(String batchId) async {
    try {
      final doc = await _batches.doc(batchId).get();
      if (!doc.exists) throw const NotFoundException();
      return BatchModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<BatchModel>> getExpiringBatches({int withinDays = 30}) async {
    try {
      final threshold =
          DateTime.now().add(Duration(days: withinDays));
      final snap = await _batches
          .where('status', isEqualTo: 'active')
          .where('qtyAvailable', isGreaterThan: 0)
          .where('expiryDate',
              isLessThanOrEqualTo: Timestamp.fromDate(threshold))
          .where('expiryDate',
              isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .orderBy('expiryDate')
          .get();
      return snap.docs.map(BatchModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Stream<List<BatchModel>> watchExpiringBatches({int withinDays = 30}) {
    final threshold = DateTime.now().add(Duration(days: withinDays));
    return _batches
        .where('status', isEqualTo: 'active')
        .where('qtyAvailable', isGreaterThan: 0)
        .where('expiryDate',
            isLessThanOrEqualTo: Timestamp.fromDate(threshold))
        .orderBy('expiryDate')
        .snapshots()
        .map((s) => s.docs.map(BatchModel.fromFirestore).toList())
        .handleError((e) => throw ServerException(e.toString()));
  }

  @override
  Future<List<StockSummary>> getLowStockMedicines() async {
    try {
      // medicines with isLowStock flag (maintained by Cloud Function on each sale)
      final snap = await _medicines
          .where('isActive', isEqualTo: true)
          .where('isLowStock', isEqualTo: true)
          .orderBy('tradeName')
          .get();
      return Future.wait(snap.docs.map((doc) async {
        final data = doc.data();
        final batches = await getBatchesForMedicine(doc.id);
        final total = batches.fold(0, (s, b) => s + b.qtyAvailable);
        return StockSummary(
          medicineId: doc.id,
          tradeName: data['tradeName'] as String? ?? '',
          genericName: data['genericName'] as String? ?? '',
          totalQtyAvailable: total,
          reorderLevel: (data['reorderLevel'] as num?)?.toInt() ?? 10,
          batches: batches,
        );
      }).toList());
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Stream<List<StockSummary>> watchLowStockMedicines() =>
      _medicines
          .where('isActive', isEqualTo: true)
          .where('isLowStock', isEqualTo: true)
          .snapshots()
          .asyncMap((_) => getLowStockMedicines())
          .handleError((e) => throw ServerException(e.toString()));

  // ── STOCK OPERATIONS ─────────────────────────────────────────────────────

  @override
  Future<BatchModel> receiveStock(BatchModel batch) async {
    try {
      final ref = _batches.doc();
      await ref.set(batch.toFirestore(isNew: true));
      // Optionally update medicine's isLowStock flag here or via Cloud Function
      final doc = await ref.get();
      return BatchModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<StockAdjustmentModel> adjustStock(StockAdjustmentModel adj) async {
    try {
      // Use a transaction to atomically update batch + create adjustment log
      final adjustRef = _adjustments.doc();
      final batchRef = _batches.doc(adj.batchId);

      await _fs.runTransaction((txn) async {
        final batchDoc = await txn.get(batchRef);
        if (!batchDoc.exists) throw const NotFoundException();
        txn.update(batchRef, {
          'qtyAdjusted': FieldValue.increment(adj.qty),
          'qtyAvailable': FieldValue.increment(adj.qty),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        txn.set(adjustRef, adj.toFirestore());
      });

      final doc = await adjustRef.get();
      return StockAdjustmentModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<BatchModel> deductStock(
      {required String batchId, required int qty}) async {
    try {
      final ref = _batches.doc(batchId);
      await _fs.runTransaction((txn) async {
        final doc = await txn.get(ref);
        if (!doc.exists) throw const NotFoundException();
        final current = (doc.data()!['qtyAvailable'] as num).toInt();
        if (current < qty) {
          throw InsufficientStockException(
              medicineName: doc.data()?['tradeName'] as String? ?? batchId);
        }
        txn.update(ref, {
          'qtySold': FieldValue.increment(qty),
          'qtyAvailable': FieldValue.increment(-qty),
          'status': current - qty <= 0 ? 'depleted' : 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      final updated = await ref.get();
      return BatchModel.fromFirestore(updated);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── PURCHASE ORDERS ──────────────────────────────────────────────────────

  @override
  Future<List<PurchaseOrderModel>> getPurchaseOrders() async {
    try {
      final snap = await _pos
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snap.docs.map(PurchaseOrderModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Stream<List<PurchaseOrderModel>> watchPurchaseOrders() =>
      _pos
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((s) => s.docs.map(PurchaseOrderModel.fromFirestore).toList())
          .handleError((e) => throw ServerException(e.toString()));

  @override
  Future<PurchaseOrderModel> getPurchaseOrderById(String id) async {
    try {
      final doc = await _pos.doc(id).get();
      if (!doc.exists) throw const NotFoundException();
      return PurchaseOrderModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<PurchaseOrderModel> createPurchaseOrder(
      PurchaseOrderModel po) async {
    try {
      final ref = _pos.doc();
      // Generate PO number: PO-YYYY-NNNN
      final poNumber =
          'PO-${DateTime.now().year}-${ref.id.substring(0, 4).toUpperCase()}';
      final data = po.toFirestore(isNew: true);
      data['poNumber'] = poNumber;
      await ref.set(data);
      final doc = await ref.get();
      return PurchaseOrderModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<PurchaseOrderModel> updatePurchaseOrder(
      PurchaseOrderModel po) async {
    try {
      await _pos.doc(po.id).update(po.toFirestore());
      final doc = await _pos.doc(po.id).get();
      return PurchaseOrderModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<PurchaseOrderModel> receivePurchaseOrder({
    required String poId,
    required List<POItem> receivedItems,
    required String receivedBy,
  }) async {
    try {
      final poRef = _pos.doc(poId);
      final poDoc = await poRef.get();
      if (!poDoc.exists) throw const NotFoundException();
      final po = PurchaseOrderModel.fromFirestore(poDoc);

      // Create batch docs for each received item
      final batch = _fs.batch();
      for (final item in receivedItems) {
        if (item.receivedQty <= 0) continue;
        final bRef = _batches.doc();
        final bModel = BatchModel(
          id: '',
          medicineId: item.medicineId,
          tradeName: item.tradeName,
          batchNo: item.batchNo ?? '',
          mfgDate: item.mfgDate ?? DateTime.now(),
          expiryDate: item.expiryDate ?? DateTime.now().add(const Duration(days: 365)),
          purchasePrice: item.unitPrice,
          salePrice: item.unitPrice * 1.2,   // default 20% markup
          qtyReceived: item.receivedQty,
          qtySold: 0,
          qtyAdjusted: 0,
          supplierId: po.supplierId,
          status: BatchStatus.active,
          receivedAt: DateTime.now(),
          purchaseOrderId: poId,
        );
        batch.set(bRef, bModel.toFirestore(isNew: true));
      }

      // Update PO status
      final updatedItems = po.items.map((orig) {
        final received = receivedItems.firstWhere(
          (r) => r.medicineId == orig.medicineId,
          orElse: () => orig,
        );
        return POItemModel.fromEntity(orig.copyWith(
            receivedQty: orig.receivedQty + received.receivedQty,
            batchNo: received.batchNo ?? orig.batchNo,
            expiryDate: received.expiryDate ?? orig.expiryDate,
            mfgDate: received.mfgDate ?? orig.mfgDate));
      }).toList();

      final allReceived = updatedItems.every((i) => i.isFullyReceived);
      batch.update(poRef, {
        'items': updatedItems
            .map((i) => POItemModel.fromEntity(i).toMap())
            .toList(),
        'status': allReceived ? 'received' : 'partial',
        if (allReceived) 'receivedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      final updated = await poRef.get();
      return PurchaseOrderModel.fromFirestore(updated);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> cancelPurchaseOrder(String id) async {
    try {
      await _pos.doc(id).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }
}