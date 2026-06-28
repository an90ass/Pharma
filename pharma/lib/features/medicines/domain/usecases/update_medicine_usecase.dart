import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medicine_entity.dart';
import '../repositories/medicine_repository.dart';

/// Updates an existing medicine after domain validation.
class UpdateMedicineUseCase
    implements UseCase<MedicineEntity, UpdateMedicineParams> {
  const UpdateMedicineUseCase(this._repo);
  final MedicineRepository _repo;

  @override
  Future<Either<Failure, MedicineEntity>> call(UpdateMedicineParams p) async {
    if (p.medicine.id.isEmpty) {
      return const Left(ValidationFailure('Medicine ID is missing.'));
    }
    if (p.medicine.tradeName.trim().isEmpty) {
      return const Left(ValidationFailure('Trade name is required.'));
    }
    if (p.medicine.salePrice <= 0) {
      return const Left(ValidationFailure('Sale price must be greater than 0.'));
    }
    if (p.medicine.salePrice < p.medicine.purchasePrice) {
      return const Left(
          ValidationFailure('Sale price cannot be less than purchase price.'));
    }

    final updated = p.medicine.copyWith(updatedAt: DateTime.now());
    return _repo.updateMedicine(updated);
  }
}

class UpdateMedicineParams extends Equatable {
  const UpdateMedicineParams(this.medicine);
  final MedicineEntity medicine;
  @override
  List<Object> get props => [medicine];
}