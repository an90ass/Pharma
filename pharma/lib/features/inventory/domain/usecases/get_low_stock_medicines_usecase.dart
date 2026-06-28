import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/batch_entity.dart';
import '../repositories/inventory_repository.dart';

/// Returns all medicines where total available qty <= reorder level.
class GetLowStockMedicinesUseCase
    implements UseCase<List<StockSummary>, NoParams> {
  const GetLowStockMedicinesUseCase(this._repo);
  final InventoryRepository _repo;

  @override
  Future<Either<Failure, List<StockSummary>>> call(NoParams _) =>
      _repo.getLowStockMedicines();
}

/// Real-time stream of low stock medicines.
class WatchLowStockMedicinesUseCase
    implements StreamUseCase<List<StockSummary>, NoParams> {
  const WatchLowStockMedicinesUseCase(this._repo);
  final InventoryRepository _repo;

  @override
  Stream<Either<Failure, List<StockSummary>>> call(NoParams _) =>
      _repo.watchLowStockMedicines();
}