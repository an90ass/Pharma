import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine_entity.dart';

/// Abstract contract — data layer must implement this.
/// Domain has zero knowledge of Firestore or any SDK.
abstract class MedicineRepository {
  /// Fetch all active medicines (isActive = true).
  Future<Either<Failure, List<MedicineEntity>>> getMedicines();

  /// Real-time stream — emits on every Firestore change.
  Stream<Either<Failure, List<MedicineEntity>>> watchMedicines();

  /// Fetch single medicine by ID.
  Future<Either<Failure, MedicineEntity>> getMedicineById(String id);

  /// Search by tradeName, genericName, or barcode.
  Future<Either<Failure, List<MedicineEntity>>> searchMedicines(String query);

  /// Filter by category and/or form.
  Future<Either<Failure, List<MedicineEntity>>> filterMedicines({
    MedicineCategory? category,
    MedicineForm? form,
    bool? isControlled,
  });

  /// Create a new medicine document in Firestore.
  /// Returns the created entity (with server-assigned timestamps).
  Future<Either<Failure, MedicineEntity>> addMedicine(MedicineEntity medicine);

  /// Update an existing medicine document.
  Future<Either<Failure, MedicineEntity>> updateMedicine(MedicineEntity medicine);

  /// Soft-delete: sets isActive = false.
  Future<Either<Failure, void>> deleteMedicine(String id);

  /// Hard delete — use only in admin/test scenarios.
  Future<Either<Failure, void>> permanentlyDeleteMedicine(String id);
}