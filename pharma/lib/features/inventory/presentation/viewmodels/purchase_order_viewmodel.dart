import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/usecases/purchase_order_usecases.dart';
import '../../../../core/usecases/usecase.dart';
import '../providers/inventory_providers.dart';

enum POActionStatus { idle, loading, success, error }

class POState {
  const POState({
    this.orders = const [],
    this.actionStatus = POActionStatus.idle,
    this.actionError,
    this.successMessage,
    this.selectedStatus,
  });

  final List<PurchaseOrderEntity> orders;
  final POActionStatus actionStatus;
  final String? actionError;
  final String? successMessage;
  final POStatus? selectedStatus;

  List<PurchaseOrderEntity> get filtered => selectedStatus == null
      ? orders
      : orders.where((o) => o.status == selectedStatus).toList();

  POState copyWith({
    List<PurchaseOrderEntity>? orders,
    POActionStatus? actionStatus,
    String? actionError,
    String? successMessage,
    POStatus? selectedStatus,
    bool clearFilter = false,
    bool clearMessages = false,
  }) {
    return POState(
      orders: orders ?? this.orders,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: clearMessages ? null : actionError ?? this.actionError,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
      selectedStatus:
          clearFilter ? null : selectedStatus ?? this.selectedStatus,
    );
  }
}

class POViewModel extends Notifier<POState> {
  late GetPurchaseOrdersUseCase _get;
  late CreatePurchaseOrderUseCase _create;
  late ReceivePurchaseOrderUseCase _receive;
  late CancelPurchaseOrderUseCase _cancel;

  @override
  POState build() {
    _get = ref.read(getPurchaseOrdersUseCaseProvider);
    _create = ref.read(createPurchaseOrderUseCaseProvider);
    _receive = ref.read(receivePurchaseOrderUseCaseProvider);
    _cancel = ref.read(cancelPurchaseOrderUseCaseProvider);
    Future.microtask(loadOrders);
    return const POState();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(actionStatus: POActionStatus.loading);
    final result = await _get(const NoParams());
    result.fold(
      (f) => state = state.copyWith(
          actionStatus: POActionStatus.error, actionError: f.message),
      (list) => state = state.copyWith(
          orders: list, actionStatus: POActionStatus.idle),
    );
  }

  void filterByStatus(POStatus? status) =>
      state = state.copyWith(
          selectedStatus: status, clearFilter: status == null);

  Future<bool> createOrder(CreatePOParams params) async {
    state = state.copyWith(
        actionStatus: POActionStatus.loading, clearMessages: true);
    final result = await _create(params);
    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: POActionStatus.error, actionError: f.message);
        return false;
      },
      (po) {
        state = state.copyWith(
          orders: [po, ...state.orders],
          actionStatus: POActionStatus.success,
          successMessage: 'Purchase order ${po.poNumber} created.',
        );
        return true;
      },
    );
  }

  Future<bool> receiveOrder(ReceivePOParams params) async {
    state = state.copyWith(
        actionStatus: POActionStatus.loading, clearMessages: true);
    final result = await _receive(params);
    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: POActionStatus.error, actionError: f.message);
        return false;
      },
      (po) {
        final updated = state.orders
            .map((o) => o.id == po.id ? po : o)
            .toList();
        state = state.copyWith(
          orders: updated,
          actionStatus: POActionStatus.success,
          successMessage: 'GRN completed for ${po.poNumber}.',
        );
        return true;
      },
    );
  }

  Future<bool> cancelOrder(String id) async {
    state = state.copyWith(
        actionStatus: POActionStatus.loading, clearMessages: true);
    final result = await _cancel(CancelPOParams(id));
    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: POActionStatus.error, actionError: f.message);
        return false;
      },
      (_) {
        final updated = state.orders
            .map((o) => o.id == id
                ? o.copyWith(status: POStatus.cancelled)
                : o)
            .toList();
        state = state.copyWith(
          orders: updated,
          actionStatus: POActionStatus.success,
          successMessage: 'Purchase order cancelled.',
        );
        return true;
      },
    );
  }

  void clearMessages() =>
      state = state.copyWith(clearMessages: true, actionStatus: POActionStatus.idle);
}

final poViewModelProvider =
    NotifierProvider<POViewModel, POState>(POViewModel.new);