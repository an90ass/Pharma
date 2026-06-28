import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/usecases/get_sales_history_usecase.dart';
import '../../domain/usecases/process_sale_usecase.dart';
import '../providers/sales_providers.dart';

enum HistoryStatus { idle, loading, success, error }

class SalesHistoryState {
  const SalesHistoryState({
    this.invoices = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.status = HistoryStatus.idle,
    this.errorMessage,
    this.hasMore = true,
    this.selectedFrom,
    this.selectedTo,
    this.lastId,
  });

  final List<InvoiceSummary> invoices;
  final List<InvoiceSummary> searchResults;
  final String searchQuery;
  final HistoryStatus status;
  final String? errorMessage;
  final bool hasMore;
  final DateTime? selectedFrom;
  final DateTime? selectedTo;
  final String? lastId;

  bool get isSearching => searchQuery.isNotEmpty;
  List<InvoiceSummary> get displayed =>
      isSearching ? searchResults : invoices;

  SalesHistoryState copyWith({
    List<InvoiceSummary>? invoices,
    List<InvoiceSummary>? searchResults,
    String? searchQuery,
    HistoryStatus? status,
    String? errorMessage,
    bool? hasMore,
    DateTime? selectedFrom,
    DateTime? selectedTo,
    String? lastId,
    bool clearError = false,
  }) {
    return SalesHistoryState(
      invoices:       invoices       ?? this.invoices,
      searchResults:  searchResults  ?? this.searchResults,
      searchQuery:    searchQuery    ?? this.searchQuery,
      status:         status         ?? this.status,
      errorMessage:   clearError ? null : errorMessage ?? this.errorMessage,
      hasMore:        hasMore        ?? this.hasMore,
      selectedFrom:   selectedFrom   ?? this.selectedFrom,
      selectedTo:     selectedTo     ?? this.selectedTo,
      lastId:         lastId         ?? this.lastId,
    );
  }
}

class SalesHistoryViewModel extends Notifier<SalesHistoryState> {
  late GetSalesHistoryUseCase _getHistory;
  late SearchInvoicesUseCase _searchInvoices;
  late ReturnInvoiceUseCase _returnInvoice;

  @override
  SalesHistoryState build() {
    _getHistory    = ref.read(getSalesHistoryUseCaseProvider);
    _searchInvoices= ref.read(searchInvoicesUseCaseProvider);
    _returnInvoice = ref.read(returnInvoiceUseCaseProvider);
    Future.microtask(loadHistory);
    return const SalesHistoryState();
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
          invoices: [], lastId: null, hasMore: true, clearError: true);
    }
    if (!state.hasMore) return;
    state = state.copyWith(status: HistoryStatus.loading);

    final result = await _getHistory(SalesHistoryParams(
      from:          state.selectedFrom,
      to:            state.selectedTo,
      lastInvoiceId: refresh ? null : state.lastId,
    ));

    result.fold(
      (f) => state = state.copyWith(
          status: HistoryStatus.error, errorMessage: f.message),
      (list) {
        final merged = refresh
            ? list
            : [...state.invoices, ...list];
        state = state.copyWith(
          invoices: merged,
          status:   HistoryStatus.success,
          hasMore:  list.length == 30,
          lastId:   list.isNotEmpty ? list.last.id : state.lastId,
        );
      },
    );
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, searchResults: []);
    if (query.trim().isEmpty) return;
    state = state.copyWith(status: HistoryStatus.loading);
    final result = await _searchInvoices(SearchInvoiceParams(query));
    result.fold(
      (f) => state = state.copyWith(
          status: HistoryStatus.error, errorMessage: f.message),
      (list) => state = state.copyWith(
          searchResults: list, status: HistoryStatus.success),
    );
  }

  void setDateFilter(DateTime? from, DateTime? to) {
    state = state.copyWith(selectedFrom: from, selectedTo: to);
    loadHistory(refresh: true);
  }

  void clearSearch() =>
      state = state.copyWith(searchQuery: '', searchResults: []);

  Future<bool> returnInvoice(String id, String processedBy) async {
    state = state.copyWith(status: HistoryStatus.loading);
    final result = await _returnInvoice(
        ReturnInvoiceParams(invoiceId: id, processedBy: processedBy));
    return result.fold(
      (f) {
        state = state.copyWith(
            status: HistoryStatus.error, errorMessage: f.message);
        return false;
      },
      (updated) {
        final list = state.invoices
            .map((i) => i.id == id
                ? InvoiceSummary(
                    id:           updated.id,
                    invoiceNo:    updated.invoiceNo,
                    grandTotal:   updated.grandTotal,
                    customerName: updated.customerName ?? 'Walk-in',
                    status:       updated.status,
                    itemCount:    updated.items.length,
                    createdAt:    updated.createdAt,
                  )
                : i)
            .toList();
        state = state.copyWith(
            invoices: list, status: HistoryStatus.success);
        return true;
      },
    );
  }
}

final salesHistoryViewModelProvider =
    NotifierProvider<SalesHistoryViewModel, SalesHistoryState>(
        SalesHistoryViewModel.new);