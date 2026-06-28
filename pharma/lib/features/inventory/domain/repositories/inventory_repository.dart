import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/batch_entity.dart';
import '../entities/purchase_order_entity.dart';

/// Abstract contract for all inventory data operations.
/// The domain layer depends ONLY on this interface.
abstract class InventoryRepository {

  // ── Batch queries ─────────────────────────────────────────────────────

  /// All active batches for a specific medicine, sorted FIFO (oldest first).
  Future<Either<Failure, List<BatchEntity>>> getBatchesForMedicine(
      String medicineId);

  /// Real-time stream for a medicine's batches.
  Stream<Either<Failure, List<BatchEntity>>> watchBatchesForMedicine(
      String medicineId);

  /// Single batch by ID.
  Future<Either<Failure, BatchEntity>> getBatchById(String batchId);

  /// All batches expiring within [withinDays] that are still active.
  Future<Either<Failure, List<BatchEntity>>> getExpiringBatches(
      {int withinDays = 30});

  /// Real-time stream of expiring batches.
  Stream<Either<Failure, List<BatchEntity>>> watchExpiringBatches(
      {int withinDays = 30});

  /// Stock summaries for all medicines where qty <= reorderLevel.
  Future<Either<Failure, List<StockSummary>>> getLowStockMedicines();

  /// Real-time stream of low stock summaries.
  Stream<Either<Failure, List<StockSummary>>> watchLowStockMedicines();

  // ── Stock operations ──────────────────────────────────────────────────

  /// Creates a new batch document when stock is received (GRN).
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
  });

  /// Applies a manual stock adjustment (+/-) to a batch.
  Future<Either<Failure, StockAdjustmentEntity>> adjustStock({
    required String batchId,
    required String medicineId,
    required String tradeName,
    required AdjustmentType type,
    required int qty,
    required String reason,
    required String adjustedBy,
  });

  /// Deducts sold qty from a batch (called during invoice creation).
  /// Returns the updated batch.
  Future<Either<Failure, BatchEntity>> deductStock({
    required String batchId,
    required int qty,
  });

  // ── Purchase orders ───────────────────────────────────────────────────

  Future<Either<Failure, List<PurchaseOrderEntity>>> getPurchaseOrders();

  Stream<Either<Failure, List<PurchaseOrderEntity>>>
      watchPurchaseOrders();

  Future<Either<Failure, PurchaseOrderEntity>> getPurchaseOrderById(
      String id);

  Future<Either<Failure, PurchaseOrderEntity>> createPurchaseOrder(
      PurchaseOrderEntity po);

  Future<Either<Failure, PurchaseOrderEntity>> updatePurchaseOrder(
      PurchaseOrderEntity po);

  /// Marks PO items as received, creates batch documents, updates PO status.
  Future<Either<Failure, PurchaseOrderEntity>> receivePurchaseOrder({
    required String poId,
    required List<POItem> receivedItems,
    required String receivedBy,
  });

  Future<Either<Failure, void>> cancelPurchaseOrder(String id);
}