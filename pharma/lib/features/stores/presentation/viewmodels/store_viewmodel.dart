import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/usecases/store_usecases.dart';
import '../providers/store_providers.dart';

enum StoreStatus { idle, loading, success, error }

class StoreState {
  const StoreState({
    this.stores = const [],
    this.activeStoreId,
    this.status = StoreStatus.idle,
    this.errorMessage,
  });
  final List<StoreEntity> stores;
  final String? activeStoreId;
  final StoreStatus status;
  final String? errorMessage;

  StoreEntity? get activeStore =>
      stores.where((s) => s.id == activeStoreId).isNotEmpty
          ? stores.firstWhere((s) => s.id == activeStoreId)
          : stores.isNotEmpty ? stores.first : null;

  StoreState copyWith({
    List<StoreEntity>? stores, String? activeStoreId,
    StoreStatus? status, String? errorMessage, bool clearError = false,
  }) => StoreState(
    stores: stores ?? this.stores,
    activeStoreId: activeStoreId ?? this.activeStoreId,
    status: status ?? this.status,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class StoreViewModel extends Notifier<StoreState> {
  @override
  StoreState build() {
    // Watch stores real-time
    final watchStores = ref.read(watchStoresUseCaseProvider);
    final sub1 = watchStores(const NoParams()).listen((either) {
      either.fold(
        (f) => state = state.copyWith(errorMessage: f.message),
        (list) => state = state.copyWith(stores: list),
      );
    });

    // Watch active store id
    final watchActive = ref.read(watchActiveStoreUseCaseProvider);
    final sub2 = watchActive(const NoParams()).listen((either) {
      either.fold((_) {}, (id) => state = state.copyWith(activeStoreId: id));
    });

    ref.onDispose(() { sub1.cancel(); sub2.cancel(); });
    return const StoreState();
  }

  Future<bool> addStore(AddStoreParams params) async {
    state = state.copyWith(status: StoreStatus.loading, clearError: true);
    final result = await ref.read(addStoreUseCaseProvider)(params);
    return result.fold(
      (f) {
        state = state.copyWith(status: StoreStatus.error, errorMessage: f.message);
        return false;
      },
      (store) {
        state = state.copyWith(status: StoreStatus.success);
        return true;
      },
    );
  }

  Future<void> switchStore(String storeId) async {
    final result = await ref
        .read(switchActiveStoreUseCaseProvider)(SwitchStoreParams(storeId));
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (_) => state = state.copyWith(activeStoreId: storeId),
    );
  }
}

final storeViewModelProvider =
    NotifierProvider<StoreViewModel, StoreState>(StoreViewModel.new);