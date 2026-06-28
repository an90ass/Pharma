import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/medicine_repository.dart';

/// Soft-deletes a medicine (isActive = false).
/// Medicine data is preserved for invoice history.
class DeleteMedicineUseCase implements UseCase<void, DeleteMedicineParams> {
  const DeleteMedicineUseCase(this._repo);
  final MedicineRepository _repo;

  @override
  Future<Either<Failure, void>> call(DeleteMedicineParams p) {
    if (p.id.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('Medicine ID is required.')));
    }
    return _repo.deleteMedicine(p.id);
  }
}

class DeleteMedicineParams extends Equatable {
  const DeleteMedicineParams(this.id);
  final String id;
  @override
  List<Object> get props => [id];
}