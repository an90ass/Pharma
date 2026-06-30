import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/medicine_recommendation.dart';
import '../../domain/usecases/recommendation_usecases.dart';
import '../providers/recommendation_providers.dart';

class RecommendationState {
  const RecommendationState({
    this.cartRecs = const [],
    this.reorderRecs = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  final List<MedicineRecommendation> cartRecs;
  final List<MedicineRecommendation> reorderRecs;
  final bool isLoading;
  final String? errorMessage;
  RecommendationState copyWith({
    List<MedicineRecommendation>? cartRecs,
    List<MedicineRecommendation>? reorderRecs,
    bool? isLoading, String? errorMessage,
  }) => RecommendationState(
    cartRecs:    cartRecs    ?? this.cartRecs,
    reorderRecs: reorderRecs ?? this.reorderRecs,
    isLoading:   isLoading   ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

class RecommendationViewModel extends Notifier<RecommendationState> {
  @override RecommendationState build() {
    Future.microtask(loadReorderSuggestions);
    return const RecommendationState();
  }

  Future<void> loadCartRecommendations(List<String> cartMedicineIds) async {
    if (cartMedicineIds.isEmpty) {
      state = state.copyWith(cartRecs: []);
      return;
    }
    state = state.copyWith(isLoading: true);
    final result = await ref.read(getCartRecommendationsUseCaseProvider)(
        CartRecommendationParams(cartMedicineIds));
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (list) => state = state.copyWith(cartRecs: list, isLoading: false),
    );
  }

  Future<void> loadReorderSuggestions() async {
    final result = await ref
        .read(getReorderSuggestionsUseCaseProvider)(const NoParams());
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (list) => state = state.copyWith(reorderRecs: list),
    );
  }
}

final recommendationViewModelProvider =
    NotifierProvider<RecommendationViewModel, RecommendationState>(
        RecommendationViewModel.new);