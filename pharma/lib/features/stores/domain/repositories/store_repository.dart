import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store_entity.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<StoreEntity>>> getStores();
  Stream<Either<Failure, List<StoreEntity>>> watchStores();
  Future<Either<Failure, StoreEntity>> addStore(StoreEntity store);
  Future<Either<Failure, StoreEntity>> updateStore(StoreEntity store);
  Future<Either<Failure, void>> deactivateStore(String id);

  // Active store (persisted locally)
  Future<Either<Failure, String?>> getActiveStoreId();
  Future<Either<Failure, void>> setActiveStoreId(String id);
  Stream<Either<Failure, String?>> watchActiveStoreId();
}