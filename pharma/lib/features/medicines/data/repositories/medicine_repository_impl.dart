import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_remote_datasource.dart';
import '../models/medicine_model.dart';

/// Implements [MedicineRepository].
/// Catches all datasource exceptions → maps to typed [Failure].
/// Domain and Presentation layers never see raw exceptions.
class MedicineRepositoryImpl implements MedicineRepository {
  const MedicineRepositoryImpl(this._remote);
  final MedicineRemoteDataSource _remote;

  // ── Helper: map exceptions to Failures ──────────────────────────────
  Either<Failure, T> _handle<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    if (e is NetworkException) return const Left(NetworkFailure());
    if (e is NotFoundException) return const Left(NotFoundFailure());
    return Left(UnexpectedFailure(e.toString()));
  }

  @override
  Future<Either<Failure, List<MedicineEntity>>> getMedicines() async {
    try {
      return Right(await _remote.getMedicines());
    } catch (e) { return _handle(e); }
  }

  @override
  Stream<Either<Failure, List<MedicineEntity>>> watchMedicines() {
    return _remote.watchMedicines()
        .map<Either<Failure, List<MedicineEntity>>>(Right.new)
        .handleError((e) => _handle<List<MedicineEntity>>(e));
  }

  @override
  Future<Either<Failure, MedicineEntity>> getMedicineById(String id) async {
    try {
      return Right(await _remote.getMedicineById(id));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, List<MedicineEntity>>> searchMedicines(
      String query) async {
    try {
      return Right(await _remote.searchMedicines(query));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, List<MedicineEntity>>> filterMedicines({
    MedicineCategory? category,
    MedicineForm? form,
    bool? isControlled,
  }) async {
    try {
      return Right(await _remote.filterMedicines(
          category: category, form: form, isControlled: isControlled));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, MedicineEntity>> addMedicine(
      MedicineEntity medicine) async {
    try {
      final model = _toModel(medicine);
      return Right(await _remote.addMedicine(model));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, MedicineEntity>> updateMedicine(
      MedicineEntity medicine) async {
    try {
      final model = _toModel(medicine);
      return Right(await _remote.updateMedicine(model));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, void>> deleteMedicine(String id) async {
    try {
      await _remote.deleteMedicine(id);
      return const Right(null);
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteMedicine(String id) async {
    try {
      await _remote.permanentlyDeleteMedicine(id);
      return const Right(null);
    } catch (e) { return _handle(e); }
  }

  MedicineModel _toModel(MedicineEntity e) => MedicineModel(
        id: e.id,
        tradeName: e.tradeName,
        genericName: e.genericName,
        manufacturer: e.manufacturer,
        category: e.category,
        form: e.form,
        strength: e.strength,
        packSize: e.packSize,
        unit: e.unit,
        salePrice: e.salePrice,
        purchasePrice: e.purchasePrice,
        mrp: e.mrp,
        reorderLevel: e.reorderLevel,
        reorderQty: e.reorderQty,
        isControlled: e.isControlled,
        isActive: e.isActive,
        createdAt: e.createdAt,
        barcode: e.barcode,
        supplierId: e.supplierId,
        taxCode: e.taxCode,
        substitutes: e.substitutes,
        updatedAt: e.updatedAt,
        description: e.description,
      );
}