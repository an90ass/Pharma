import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/purchase_order_entity.dart';
import '../repositories/inventory_repository.dart';

/// Records a manual stock adjustment on a specific batch.
///
/// Negative qty = remove stock (damage, expiry disposal, theft).
/// Positive qty = add stock (correction, customer return).
class AdjustStockUseCase
    implements UseCase<StockAdjustmentEntity, AdjustStockParams> {
  const AdjustStockUseCase(this._repo);
  final InventoryRepository _repo;

  @override
  Future<Either<Failure, StockAdjustmentEntity>> call(
      AdjustStockParams p) async {
    if (p.qty == 0) {
      return const Left(ValidationFailure('Adjustment quantity cannot be zero.'));
    }
    if (p.reason.trim().isEmpty) {
      return const Left(ValidationFailure('Reason is required for stock adjustment.'));
    }
    if (p.adjustedBy.trim().isEmpty) {
      return const Left(ValidationFailure('User ID is required.'));
    }

    return _repo.adjustStock(
      batchId: p.batchId,
      medicineId: p.medicineId,
      tradeName: p.tradeName,
      type: p.type,
      qty: p.qty,
      reason: p.reason.trim(),
      adjustedBy: p.adjustedBy,
    );
  }
}

class AdjustStockParams extends Equatable {
  const AdjustStockParams({
    required this.batchId,
    required this.medicineId,
    required this.tradeName,
    required this.type,
    required this.qty,
    required this.reason,
    required this.adjustedBy,
  });

  final String batchId;
  final String medicineId;
  final String tradeName;
  final AdjustmentType type;
  final int qty;
  final String reason;
  final String adjustedBy;

  @override
  List<Object?> get props => [batchId, type, qty, reason];
}