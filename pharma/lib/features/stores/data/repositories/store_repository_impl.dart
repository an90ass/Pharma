import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/active_store_local_datasource.dart';
import '../datasources/store_remote_datasource.dart';
import '../models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  const StoreRepositoryImpl(this._remote, this._local);
  final StoreRemoteDataSource _remote;
  final ActiveStoreLocalDataSource _local;

  Either<Failure, T> _h<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    if (e is CacheException)  return Left(CacheFailure(e.message));
    return Left(UnexpectedFailure(e.toString()));
  }

  StoreModel _toModel(StoreEntity e) => StoreModel(
      id: e.id, name: e.name, address: e.address, phone: e.phone,
      isMain: e.isMain, isActive: e.isActive, createdAt: e.createdAt,
      email: e.email, licenseNo: e.licenseNo, ntn: e.ntn);

  @override Future<Either<Failure, List<StoreEntity>>> getStores() async {
    try { return Right(await _remote.getStores()); } catch (e) { return _h(e); }
  }
  @override Stream<Either<Failure, List<StoreEntity>>> watchStores() =>
      _remote.watchStores()
          .map<Either<Failure, List<StoreEntity>>>(Right.new)
          .handleError((e) => _h<List<StoreEntity>>(e));
  @override Future<Either<Failure, StoreEntity>> addStore(StoreEntity s) async {
    try { return Right(await _remote.addStore(_toModel(s))); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, StoreEntity>> updateStore(StoreEntity s) async {
    try { return Right(await _remote.updateStore(_toModel(s))); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> deactivateStore(String id) async {
    try { await _remote.deactivateStore(id); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, String?>> getActiveStoreId() async {
    try { return Right(_local.getActiveStoreId()); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> setActiveStoreId(String id) async {
    try { await _local.setActiveStoreId(id); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Stream<Either<Failure, String?>> watchActiveStoreId() =>
      _local.watchActiveStoreId()
          .map<Either<Failure, String?>>(Right.new)
          .handleError((e) => _h<String?>(e));
}