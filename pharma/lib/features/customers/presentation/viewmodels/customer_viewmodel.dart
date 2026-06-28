import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/customer_usecases.dart';
import '../providers/customer_providers.dart';

enum CustomerStatus { idle, loading, success, error }

class CustomerState {
  const CustomerState({
    this.customers = const [],
    this.filtered = const [],
    this.status = CustomerStatus.idle,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  final List<CustomerEntity> customers;
  final List<CustomerEntity> filtered;
  final CustomerStatus status;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  bool get isLoading => status == CustomerStatus.loading;

  CustomerState copyWith({
    List<CustomerEntity>? customers,
    List<CustomerEntity>? filtered,
    CustomerStatus? status,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      CustomerState(
        customers: customers ?? this.customers,
        filtered: filtered ?? this.filtered,
        status: status ?? this.status,
        searchQuery: searchQuery ?? this.searchQuery,
        errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
        successMessage:
            clearMessages ? null : successMessage ?? this.successMessage,
      );
}

class CustomerViewModel extends Notifier<CustomerState> {
  StreamSubscription? _sub;

  @override
  CustomerState build() {
    // ✅ Stream مباشر — listener يعدّل state بعد انتهاء build()
    _sub = ref.watch(watchCustomersUseCaseProvider)().listen(
      (result) {
        result.fold(
          (f) => state = state.copyWith(
            status: CustomerStatus.error,
            errorMessage: f.message,
          ),
          (list) => state = state.copyWith(
            status: CustomerStatus.idle,
            customers: list,
            filtered: _filter(list, state.searchQuery),
          ),
        );
      },
      onError: (e) => state = state.copyWith(
        status: CustomerStatus.error,
        errorMessage: e.toString(),
      ),
    );

    ref.onDispose(() => _sub?.cancel());

    return const CustomerState(status: CustomerStatus.loading);
  }

  // ── SEARCH ───────────────────────────────────────────────────────────────

  void search(String q) => state = state.copyWith(
        searchQuery: q,
        filtered: _filter(state.customers, q),
      );

  // ── ADD ──────────────────────────────────────────────────────────────────

  Future<bool> addCustomer(CustomerParams params) async {
    state = state.copyWith(
        status: CustomerStatus.loading, clearMessages: true);
    final result = await ref.read(addCustomerUseCaseProvider)(params);
    return result.fold(
      (f) {
        state = state.copyWith(
            status: CustomerStatus.error, errorMessage: f.message);
        return false;
      },
      (newCustomer) {
        // ✅ Stream يحدّث القائمة تلقائياً
        state = state.copyWith(
          status: CustomerStatus.success,
          successMessage: '${newCustomer.name} added successfully.',
        );
        return true;
      },
    );
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────

  Future<bool> updateCustomer(CustomerEntity customer) async {
    state = state.copyWith(
        status: CustomerStatus.loading, clearMessages: true);
    final result =
        await ref.read(updateCustomerUseCaseProvider)(customer);
    return result.fold(
      (f) {
        state = state.copyWith(
            status: CustomerStatus.error, errorMessage: f.message);
        return false;
      },
      (updated) {
        // ✅ Stream يحدّث القائمة تلقائياً
        state = state.copyWith(
          status: CustomerStatus.success,
          successMessage: '${updated.name} updated successfully.',
        );
        return true;
      },
    );
  }

  // ── DELETE ───────────────────────────────────────────────────────────────

  Future<bool> deleteCustomer(String id, String name) async {
    state = state.copyWith(
        status: CustomerStatus.loading, clearMessages: true);
    final result = await ref.read(deleteCustomerUseCaseProvider)(id);
    return result.fold(
      (f) {
        state = state.copyWith(
            status: CustomerStatus.error, errorMessage: f.message);
        return false;
      },
      (_) {
        // ✅ Stream يحدّث القائمة تلقائياً
        state = state.copyWith(
          status: CustomerStatus.success,
          successMessage: '$name deleted.',
        );
        return true;
      },
    );
  }

  void clearMessages() => state = state.copyWith(
      clearMessages: true, status: CustomerStatus.idle);

  // ── Private ──────────────────────────────────────────────────────────────

  List<CustomerEntity> _filter(List<CustomerEntity> all, String q) {
    if (q.isEmpty) return all;
    final lower = q.toLowerCase();
    return all
        .where((c) =>
            c.name.toLowerCase().contains(lower) ||
            c.phone.contains(lower))
        .toList();
  }
}

final customerViewModelProvider =
    NotifierProvider<CustomerViewModel, CustomerState>(
  CustomerViewModel.new,
);