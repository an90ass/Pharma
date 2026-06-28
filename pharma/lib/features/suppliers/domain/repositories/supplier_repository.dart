import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/supplier_entity.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers({String? search});
  Stream<Either<Failure, List<SupplierEntity>>> watchSuppliers();
  Future<Either<Failure, SupplierEntity>> addSupplier(SupplierEntity s);
  Future<Either<Failure, SupplierEntity>> updateSupplier(SupplierEntity s);
  Future<Either<Failure, void>> deleteSupplier(String id);
}