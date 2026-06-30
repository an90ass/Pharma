import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

class GetStoresUseCase implements UseCase<List<StoreEntity>, NoParams> {
  const GetStoresUseCase(this._repo);
  final StoreRepository _repo;
  @override
  Future<Either<Failure, List<StoreEntity>>> call(NoParams _) =>
      _repo.getStores();
}

class WatchStoresUseCase implements StreamUseCase<List<StoreEntity>, NoParams> {
  const WatchStoresUseCase(this._repo);
  final StoreRepository _repo;
  @override
  Stream<Either<Failure, List<StoreEntity>>> call(NoParams _) =>
      _repo.watchStores();
}

class AddStoreUseCase implements UseCase<StoreEntity, AddStoreParams> {
  const AddStoreUseCase(this._repo);
  final StoreRepository _repo;
  @override
  Future<Either<Failure, StoreEntity>> call(AddStoreParams p) async {
    if (p.name.trim().isEmpty) {
      return const Left(ValidationFailure('Store name is required.'));
    }
    if (p.address.trim().isEmpty) {
      return const Left(ValidationFailure('Address is required.'));
    }
    final store = StoreEntity(
      id: '', name: p.name.trim(), address: p.address.trim(),
      phone: p.phone.trim(), isMain: false, isActive: true,
      createdAt: DateTime.now(), email: p.email,
      licenseNo: p.licenseNo, ntn: p.ntn,
    );
    return _repo.addStore(store);
  }
}

class SwitchActiveStoreUseCase implements UseCase<void, SwitchStoreParams> {
  const SwitchActiveStoreUseCase(this._repo);
  final StoreRepository _repo;
  @override
  Future<Either<Failure, void>> call(SwitchStoreParams p) =>
      _repo.setActiveStoreId(p.storeId);
}

class WatchActiveStoreUseCase implements StreamUseCase<String?, NoParams> {
  const WatchActiveStoreUseCase(this._repo);
  final StoreRepository _repo;
  @override
  Stream<Either<Failure, String?>> call(NoParams _) =>
      _repo.watchActiveStoreId();
}

class AddStoreParams extends Equatable {
  const AddStoreParams({
    required this.name, required this.address, required this.phone,
    this.email, this.licenseNo, this.ntn,
  });
  final String name, address, phone;
  final String? email, licenseNo, ntn;
  @override List<Object?> get props => [name, address, phone];
}

class SwitchStoreParams extends Equatable {
  const SwitchStoreParams(this.storeId);
  final String storeId;
  @override List<Object> get props => [storeId];
}