import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class GetSuppliersUseCase implements UseCase<List<SupplierEntity>, GetSuppliersParams> {
  const GetSuppliersUseCase(this._repo);
  final SupplierRepository _repo;
  @override
  Future<Either<Failure, List<SupplierEntity>>> call(GetSuppliersParams p) =>
      _repo.getSuppliers(search: p.search);
}

class AddSupplierUseCase implements UseCase<SupplierEntity, SupplierParams> {
  const AddSupplierUseCase(this._repo);
  final SupplierRepository _repo;
  @override
  Future<Either<Failure, SupplierEntity>> call(SupplierParams p) async {
    if (p.name.trim().isEmpty)
      return const Left(ValidationFailure('Supplier name is required.'));
    return _repo.addSupplier(SupplierEntity(
      id: '', name: p.name.trim(), phone: p.phone.trim(),
      createdAt: DateTime.now(), email: p.email, address: p.address,
      ntn: p.ntn, contactPerson: p.contactPerson,
    ));
  }
}

class UpdateSupplierUseCase implements UseCase<SupplierEntity, SupplierEntity> {
  const UpdateSupplierUseCase(this._repo);
  final SupplierRepository _repo;
  @override
  Future<Either<Failure, SupplierEntity>> call(SupplierEntity s) =>
      _repo.updateSupplier(s);
}

class DeleteSupplierUseCase implements UseCase<void, String> {
  const DeleteSupplierUseCase(this._repo);
  final SupplierRepository _repo;
  @override
  Future<Either<Failure, void>> call(String id) => _repo.deleteSupplier(id);
}

class GetSuppliersParams extends Equatable {
  const GetSuppliersParams({this.search});
  final String? search;
  @override List<Object?> get props => [search];
}

class SupplierParams extends Equatable {
  const SupplierParams({required this.name, required this.phone,
      this.email, this.address, this.ntn, this.contactPerson});
  final String name, phone;
  final String? email, address, ntn, contactPerson;
  @override List<Object?> get props => [name, phone];
}