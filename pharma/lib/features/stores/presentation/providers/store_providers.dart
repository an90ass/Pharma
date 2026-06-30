import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/active_store_local_datasource.dart';
import '../../data/datasources/store_remote_datasource.dart';
import '../../data/repositories/store_repository_impl.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/usecases/store_usecases.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main().');
});

final storeRemoteDataSourceProvider =
    Provider((ref) => StoreRemoteDataSource(ref.read(firestoreProvider)));

final activeStoreLocalDataSourceProvider =
    Provider((ref) => ActiveStoreLocalDataSource(
        ref.read(sharedPreferencesProvider)));

final storeRepositoryProvider = Provider<StoreRepository>((ref) =>
    StoreRepositoryImpl(
      ref.read(storeRemoteDataSourceProvider),
      ref.read(activeStoreLocalDataSourceProvider),
    ));

final getStoresUseCaseProvider =
    Provider((ref) => GetStoresUseCase(ref.read(storeRepositoryProvider)));
final watchStoresUseCaseProvider =
    Provider((ref) => WatchStoresUseCase(ref.read(storeRepositoryProvider)));
final addStoreUseCaseProvider =
    Provider((ref) => AddStoreUseCase(ref.read(storeRepositoryProvider)));
final switchActiveStoreUseCaseProvider =
    Provider((ref) => SwitchActiveStoreUseCase(ref.read(storeRepositoryProvider)));
final watchActiveStoreUseCaseProvider =
    Provider((ref) => WatchActiveStoreUseCase(ref.read(storeRepositoryProvider)));

/// Global active store ID — read by all existing datasources to scope queries.
final activeStoreIdProvider = StreamProvider<String?>((ref) {
  final uc = ref.read(watchActiveStoreUseCaseProvider);
  return uc(const NoParams())
      .map((either) => either.fold((_) => null, (id) => id));
});