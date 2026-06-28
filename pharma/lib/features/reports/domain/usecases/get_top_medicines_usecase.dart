import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/top_medicine_entity.dart';
import '../repositories/reports_repository.dart';

class GetTopSellingMedicinesUseCase
    implements UseCase<List<TopMedicineEntity>, TopMedicinesParams> {
  const GetTopSellingMedicinesUseCase(this._repo);
  final ReportsRepository _repo;

  @override
  Future<Either<Failure, List<TopMedicineEntity>>> call(
      TopMedicinesParams p) =>
      _repo.getTopSellingMedicines(
        from: p.from, to: p.to, limit: p.limit);
}

class TopMedicinesParams extends Equatable {
  const TopMedicinesParams({
    required this.from,
    required this.to,
    this.limit = 10,
  });
  final DateTime from;
  final DateTime to;
  final int limit;
  @override List<Object> get props => [from, to, limit];
}