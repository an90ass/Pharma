import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/medicine_search_result.dart';
import '../../domain/usecases/search_medicine_usecase.dart';
import '../providers/sales_providers.dart';

class POSSearchState {
  const POSSearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  final List<MedicineSearchResult> results;
  final bool isLoading;
  final String? error;

  POSSearchState copyWith({
    List<MedicineSearchResult>? results,
    bool? isLoading,
    String? error,
  }) {
    return POSSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class POSSearchViewModel extends StateNotifier<POSSearchState> {
  POSSearchViewModel(this._searchMedicine) : super(const POSSearchState()) {
    search('');
  }

  final SearchMedicineUseCase _searchMedicine;

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true);
    final res = await _searchMedicine(SearchMedicineParams(query));
    res.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (list) => state = state.copyWith(isLoading: false, results: list),
    );
  }
}

final posSearchViewModelProvider =
    StateNotifierProvider<POSSearchViewModel, POSSearchState>((ref) {
  final useCase = ref.watch(searchMedicineUseCaseProvider);
  return POSSearchViewModel(useCase);
});
