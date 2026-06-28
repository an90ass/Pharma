import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medicine_entity.dart';
import '../repositories/medicine_repository.dart';

/// Validates and persists a new medicine.
class AddMedicineUseCase implements UseCase<MedicineEntity, AddMedicineParams> {
  const AddMedicineUseCase(this._repo);
  final MedicineRepository _repo;

  @override
  Future<Either<Failure, MedicineEntity>> call(AddMedicineParams p) async {
    // ── Domain-level validation ─────────────────────────────────────────
    if (p.tradeName.trim().isEmpty) {
      return const Left(ValidationFailure('Trade name is required.'));
    }
    if (p.genericName.trim().isEmpty) {
      return const Left(ValidationFailure('Generic name is required.'));
    }
    if (p.manufacturer.trim().isEmpty) {
      return const Left(ValidationFailure('Manufacturer is required.'));
    }
    if (p.salePrice <= 0) {
      return const Left(ValidationFailure('Sale price must be greater than 0.'));
    }
    if (p.purchasePrice <= 0) {
      return const Left(ValidationFailure('Purchase price must be greater than 0.'));
    }
    if (p.salePrice < p.purchasePrice) {
      return const Left(ValidationFailure('Sale price cannot be less than purchase price.'));
    }
    if (p.packSize <= 0) {
      return const Left(ValidationFailure('Pack size must be at least 1.'));
    }
    if (p.reorderLevel < 0) {
      return const Left(ValidationFailure('Reorder level cannot be negative.'));
    }

    final medicine = MedicineEntity(
      id: '',              // Firestore assigns ID
      tradeName: p.tradeName.trim(),
      genericName: p.genericName.trim(),
      manufacturer: p.manufacturer.trim(),
      category: p.category,
      form: p.form,
      strength: p.strength.trim(),
      packSize: p.packSize,
      unit: p.unit,
      salePrice: p.salePrice,
      purchasePrice: p.purchasePrice,
      mrp: p.mrp ?? p.salePrice,
      reorderLevel: p.reorderLevel,
      reorderQty: p.reorderQty,
      isControlled: p.isControlled,
      isActive: true,
      createdAt: DateTime.now(),
      barcode: p.barcode?.trim(),
      supplierId: p.supplierId,
      taxCode: p.taxCode,
      description: p.description,
    );

    return _repo.addMedicine(medicine);
  }
}

class AddMedicineParams extends Equatable {
  const AddMedicineParams({
    required this.tradeName,
    required this.genericName,
    required this.manufacturer,
    required this.category,
    required this.form,
    required this.strength,
    required this.packSize,
    required this.unit,
    required this.salePrice,
    required this.purchasePrice,
    required this.reorderLevel,
    required this.reorderQty,
    this.mrp,
    this.isControlled = false,
    this.barcode,
    this.supplierId,
    this.taxCode,
    this.description,
  });

  final String tradeName;
  final String genericName;
  final String manufacturer;
  final MedicineCategory category;
  final MedicineForm form;
  final String strength;
  final int packSize;
  final String unit;
  final double salePrice;
  final double purchasePrice;
  final int reorderLevel;
  final int reorderQty;
  final double? mrp;
  final bool isControlled;
  final String? barcode;
  final String? supplierId;
  final String? taxCode;
  final String? description;

  @override
  List<Object?> get props => [
        tradeName, genericName, manufacturer, category, form,
        strength, packSize, unit, salePrice, purchasePrice,
        reorderLevel, reorderQty,
      ];
}