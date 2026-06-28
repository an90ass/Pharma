import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medicine_entity.dart';
import '../repositories/medicine_repository.dart';

/// Fetches all active medicines (one-time).
class GetMedicinesUseCase implements UseCase<List<MedicineEntity>, NoParams> {
  const GetMedicinesUseCase(this._repo);
  final MedicineRepository _repo;

  @override
  Future<Either<Failure, List<MedicineEntity>>> call(NoParams _) =>
      _repo.getMedicines();
}

/// Real-time stream of all active medicines.
class WatchMedicinesUseCase
    implements StreamUseCase<List<MedicineEntity>, NoParams> {
  const WatchMedicinesUseCase(this._repo);
  final MedicineRepository _repo;

  @override
  Stream<Either<Failure, List<MedicineEntity>>> call(NoParams _) =>
      _repo.watchMedicines();
}

/// Search medicines by name or barcode.
class SearchMedicinesUseCase
    implements UseCase<List<MedicineEntity>, SearchParams> {
  const SearchMedicinesUseCase(this._repo);
  final MedicineRepository _repo;

  @override
  Future<Either<Failure, List<MedicineEntity>>> call(SearchParams params) {
    final query = params.query.trim();
    if (query.isEmpty) return _repo.getMedicines();
    return _repo.searchMedicines(query);
  }
}

class SearchParams extends Equatable {
  const SearchParams(this.query);
  final String query;
  @override
  List<Object> get props => [query];
}

/// Filter medicines by category / form / controlled flag.
class FilterMedicinesUseCase
    implements UseCase<List<MedicineEntity>, FilterParams> {
  const FilterMedicinesUseCase(this._repo);
  final MedicineRepository _repo;

  @override
  Future<Either<Failure, List<MedicineEntity>>> call(FilterParams params) =>
      _repo.filterMedicines(
        category: params.category,
        form: params.form,
        isControlled: params.isControlled,
      );
}

class FilterParams extends Equatable {
  const FilterParams({this.category, this.form, this.isControlled});
  final MedicineCategory? category;
  final MedicineForm? form;
  final bool? isControlled;
  @override
  List<Object?> get props => [category, form, isControlled];
}