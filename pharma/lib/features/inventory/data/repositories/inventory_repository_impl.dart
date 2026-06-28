import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/batch_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';
import '../models/batch_model.dart';
import '../models/purchase_order_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._remote);
  final InventoryRemoteDataSource _remote;

  // ── Exception → Failure mapper ─────────────────────────────────────────
  Either<Failure, T> _handle<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    if (e is NetworkException) return const Left(NetworkFailure());
    if (e is NotFoundException) return const Left(NotFoundFailure());
    if (e is InsufficientStockException) {
      return Left(InsufficientStockFailure(e.medicineName));
    }
    return Left(UnexpectedFailure(e.toString()));
  }

  // ── Batch queries ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<BatchEntity>>> getBatchesForMedicine(
      String medicineId) async {
    try {
      return Right(await _remote.getBatchesForMedicine(medicineId));
    } catch (e) { return _handle(e); }
  }

  @override
  Stream<Either<Failure, List<BatchEntity>>> watchBatchesForMedicine(
      String medicineId) =>
      _remote
          .watchBatchesForMedicine(medicineId)
          .map<Either<Failure, List<BatchEntity>>>(Right.new)
          .handleError((e) => _handle<List<BatchEntity>>(e));

  @override
  Future<Either<Failure, BatchEntity>> getBatchById(String batchId) async {
    try {
      return Right(await _remote.getBatchById(batchId));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, List<BatchEntity>>> getExpiringBatches(
      {int withinDays = 30}) async {
    try {
      return Right(await _remote.getExpiringBatches(withinDays: withinDays));
    } catch (e) { return _handle(e); }
  }

  @override
  Stream<Either<Failure, List<BatchEntity>>> watchExpiringBatches(
      {int withinDays = 30}) =>
      _remote
          .watchExpiringBatches(withinDays: withinDays)
          .map<Either<Failure, List<BatchEntity>>>(Right.new)
          .handleError((e) => _handle<List<BatchEntity>>(e));

  @override
  Future<Either<Failure, List<StockSummary>>> getLowStockMedicines() async {
    try {
      return Right(await _remote.getLowStockMedicines());
    } catch (e) { return _handle(e); }
  }

  @override
  Stream<Either<Failure, List<StockSummary>>> watchLowStockMedicines() =>
      _remote
          .watchLowStockMedicines()
          .map<Either<Failure, List<StockSummary>>>(Right.new)
          .handleError((e) => _handle<List<StockSummary>>(e));

  // ── Stock operations ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, BatchEntity>> receiveStock({
    required String medicineId,
    required String tradeName,
    required String batchNo,
    required DateTime mfgDate,
    required DateTime expiryDate,
    required double purchasePrice,
    required double salePrice,
    required int qty,
    required String supplierId,
    String? purchaseOrderId,
    String? location,
    String? notes,
  }) async {
    try {
      final model = BatchModel(
        id: '',
        medicineId: medicineId,
        tradeName: tradeName,
        batchNo: batchNo,
        mfgDate: mfgDate,
        expiryDate: expiryDate,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        qtyReceived: qty,
        qtySold: 0,
        qtyAdjusted: 0,
        supplierId: supplierId,
        status: BatchStatus.active,
        receivedAt: DateTime.now(),
        purchaseOrderId: purchaseOrderId,
        location: location,
        notes: notes,
      );
      return Right(await _remote.receiveStock(model));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, StockAdjustmentEntity>> adjustStock({
    required String batchId,
    required String medicineId,
    required String tradeName,
    required AdjustmentType type,
    required int qty,
    required String reason,
    required String adjustedBy,
  }) async {
    try {
      final model = StockAdjustmentModel(
        id: '',
        batchId: batchId,
        medicineId: medicineId,
        tradeName: tradeName,
        type: type,
        qty: type.isAddition ? qty.abs() : -qty.abs(),
        reason: reason,
        adjustedBy: adjustedBy,
        createdAt: DateTime.now(),
      );
      return Right(await _remote.adjustStock(model));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, BatchEntity>> deductStock({
    required String batchId,
    required int qty,
  }) async {
    try {
      return Right(await _remote.deductStock(batchId: batchId, qty: qty));
    } catch (e) { return _handle(e); }
  }

  // ── Purchase orders ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<PurchaseOrderEntity>>> getPurchaseOrders() async {
    try { return Right(await _remote.getPurchaseOrders()); }
    catch (e) { return _handle(e); }
  }

  @override
  Stream<Either<Failure, List<PurchaseOrderEntity>>> watchPurchaseOrders() =>
      _remote.watchPurchaseOrders()
          .map<Either<Failure, List<PurchaseOrderEntity>>>(Right.new)
          .handleError((e) => _handle<List<PurchaseOrderEntity>>(e));

  @override
  Future<Either<Failure, PurchaseOrderEntity>> getPurchaseOrderById(
      String id) async {
    try { return Right(await _remote.getPurchaseOrderById(id)); }
    catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, PurchaseOrderEntity>> createPurchaseOrder(
      PurchaseOrderEntity po) async {
    try {
      return Right(await _remote.createPurchaseOrder(
          PurchaseOrderModel(
            id: po.id,
            poNumber: po.poNumber,
            supplierId: po.supplierId,
            supplierName: po.supplierName,
            items: po.items,
            status: po.status,
            createdBy: po.createdBy,
            createdAt: po.createdAt,
            approvedBy: po.approvedBy,
            notes: po.notes,
            expectedDate: po.expectedDate,
          )));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, PurchaseOrderEntity>> updatePurchaseOrder(
      PurchaseOrderEntity po) async {
    try {
      return Right(await _remote.updatePurchaseOrder(
          PurchaseOrderModel(
            id: po.id,
            poNumber: po.poNumber,
            supplierId: po.supplierId,
            supplierName: po.supplierName,
            items: po.items,
            status: po.status,
            createdBy: po.createdBy,
            createdAt: po.createdAt,
            approvedBy: po.approvedBy,
            notes: po.notes,
            expectedDate: po.expectedDate,
            receivedAt: po.receivedAt,
            totalAmount: po.totalAmount,
          )));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, PurchaseOrderEntity>> receivePurchaseOrder({
    required String poId,
    required List<POItem> receivedItems,
    required String receivedBy,
  }) async {
    try {
      return Right(await _remote.receivePurchaseOrder(
        poId: poId,
        receivedItems: receivedItems,
        receivedBy: receivedBy,
      ));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, void>> cancelPurchaseOrder(String id) async {
    try {
      await _remote.cancelPurchaseOrder(id);
      return const Right(null);
    } catch (e) { return _handle(e); }
  }
}