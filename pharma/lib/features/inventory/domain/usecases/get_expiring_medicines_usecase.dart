import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/batch_entity.dart';
import '../repositories/inventory_repository.dart';

/// Returns all active batches expiring within [withinDays] days.
class GetExpiringMedicinesUseCase
    implements UseCase<List<BatchEntity>, ExpiryParams> {
  const GetExpiringMedicinesUseCase(this._repo);
  final InventoryRepository _repo;

  @override
  Future<Either<Failure, List<BatchEntity>>> call(ExpiryParams p) {
    if (p.withinDays <= 0) {
      return Future.value(
        const Left(ValidationFailure('Days must be greater than 0.')),
      );
    }
    return _repo.getExpiringBatches(withinDays: p.withinDays);
  }
}

/// Real-time stream of expiring batches.
class WatchExpiringMedicinesUseCase
    implements StreamUseCase<List<BatchEntity>, ExpiryParams> {
  const WatchExpiringMedicinesUseCase(this._repo);
  final InventoryRepository _repo;

  @override
  Stream<Either<Failure, List<BatchEntity>>> call(ExpiryParams p) =>
      _repo.watchExpiringBatches(withinDays: p.withinDays);
}

class ExpiryParams extends Equatable {
  const ExpiryParams({this.withinDays = 30});
  final int withinDays;

  @override
  List<Object> get props => [withinDays];
}