import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_datasource.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  const SupplierRepositoryImpl(this._ds);
  final SupplierRemoteDataSource _ds;

  Either<Failure, T> _h<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    return Left(UnexpectedFailure(e.toString()));
  }

  SupplierModel _m(SupplierEntity e) => SupplierModel(
      id: e.id, name: e.name, phone: e.phone, createdAt: e.createdAt,
      email: e.email, address: e.address, ntn: e.ntn,
      contactPerson: e.contactPerson, totalOrders: e.totalOrders,
      totalAmount: e.totalAmount, isActive: e.isActive);

  @override Future<Either<Failure, List<SupplierEntity>>> getSuppliers({String? search}) async {
    try { return Right(await _ds.getSuppliers(search: search)); } catch (e) { return _h(e); }
  }
  @override Stream<Either<Failure, List<SupplierEntity>>> watchSuppliers() =>
      _ds.watchSuppliers()
         .map<Either<Failure, List<SupplierEntity>>>(Right.new)
         .handleError((e) => _h<List<SupplierEntity>>(e));
  @override Future<Either<Failure, SupplierEntity>> addSupplier(SupplierEntity s) async {
    try { return Right(await _ds.addSupplier(_m(s))); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, SupplierEntity>> updateSupplier(SupplierEntity s) async {
    try { return Right(await _ds.updateSupplier(_m(s))); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> deleteSupplier(String id) async {
    try { await _ds.deleteSupplier(id); return const Right(null); } catch (e) { return _h(e); }
  }
}