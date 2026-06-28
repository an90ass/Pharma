import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/batch_entity.dart';
import '../repositories/inventory_repository.dart';

/// Creates a new stock batch when goods are physically received.
///
/// Validates:
/// - Qty must be > 0
/// - Expiry date must be in the future
/// - Purchase price must be > 0
/// - Expiry must be after manufacture date
class ReceiveStockUseCase implements UseCase<BatchEntity, ReceiveStockParams> {
  const ReceiveStockUseCase(this._repo);
  final InventoryRepository _repo;

  @override
  Future<Either<Failure, BatchEntity>> call(ReceiveStockParams p) async {
    // ── Domain validation ───────────────────────────────────────────────
    if (p.qty <= 0) {
      return const Left(ValidationFailure('Quantity must be greater than 0.'));
    }
    if (p.purchasePrice <= 0) {
      return const Left(ValidationFailure('Purchase price must be greater than 0.'));
    }
    if (p.salePrice <= 0) {
      return const Left(ValidationFailure('Sale price must be greater than 0.'));
    }
    if (p.batchNo.trim().isEmpty) {
      return const Left(ValidationFailure('Batch number is required.'));
    }
    final now = DateTime.now();
    if (p.expiryDate.isBefore(now)) {
      return const Left(ValidationFailure('Cannot receive already-expired stock.'));
    }
    if (p.expiryDate.isBefore(p.mfgDate)) {
      return const Left(ValidationFailure('Expiry date must be after manufacture date.'));
    }
    if (p.mfgDate.isAfter(now)) {
      return const Left(ValidationFailure('Manufacture date cannot be in the future.'));
    }

    return _repo.receiveStock(
      medicineId: p.medicineId,
      tradeName: p.tradeName,
      batchNo: p.batchNo.trim(),
      mfgDate: p.mfgDate,
      expiryDate: p.expiryDate,
      purchasePrice: p.purchasePrice,
      salePrice: p.salePrice,
      qty: p.qty,
      supplierId: p.supplierId,
      purchaseOrderId: p.purchaseOrderId,
      location: p.location,
      notes: p.notes,
    );
  }
}

class ReceiveStockParams extends Equatable {
  const ReceiveStockParams({
    required this.medicineId,
    required this.tradeName,
    required this.batchNo,
    required this.mfgDate,
    required this.expiryDate,
    required this.purchasePrice,
    required this.salePrice,
    required this.qty,
    required this.supplierId,
    this.purchaseOrderId,
    this.location,
    this.notes,
  });

  final String medicineId;
  final String tradeName;
  final String batchNo;
  final DateTime mfgDate;
  final DateTime expiryDate;
  final double purchasePrice;
  final double salePrice;
  final int qty;
  final String supplierId;
  final String? purchaseOrderId;
  final String? location;
  final String? notes;

  @override
  List<Object?> get props => [
        medicineId, batchNo, expiryDate, qty, purchasePrice, supplierId,
      ];
}