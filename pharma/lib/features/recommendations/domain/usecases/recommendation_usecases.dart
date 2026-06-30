import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medicine_recommendation.dart';
import '../repositories/recommendation_repository.dart';

class GetFrequentlyBoughtTogetherUseCase
    implements UseCase<List<MedicineRecommendation>, RecommendationParams> {
  const GetFrequentlyBoughtTogetherUseCase(this._repo);
  final RecommendationRepository _repo;
  @override
  Future<Either<Failure, List<MedicineRecommendation>>> call(
      RecommendationParams p) =>
      _repo.getFrequentlyBoughtTogether(p.medicineId, limit: p.limit);
}

class GetSubstitutesUseCase
    implements UseCase<List<MedicineRecommendation>, RecommendationParams> {
  const GetSubstitutesUseCase(this._repo);
  final RecommendationRepository _repo;
  @override
  Future<Either<Failure, List<MedicineRecommendation>>> call(
      RecommendationParams p) =>
      _repo.getSubstitutes(p.medicineId, limit: p.limit);
}

class GetReorderSuggestionsUseCase
    implements UseCase<List<MedicineRecommendation>, NoParams> {
  const GetReorderSuggestionsUseCase(this._repo);
  final RecommendationRepository _repo;
  @override
  Future<Either<Failure, List<MedicineRecommendation>>> call(NoParams _) =>
      _repo.getReorderSuggestions();
}

class GetCartRecommendationsUseCase
    implements UseCase<List<MedicineRecommendation>, CartRecommendationParams> {
  const GetCartRecommendationsUseCase(this._repo);
  final RecommendationRepository _repo;
  @override
  Future<Either<Failure, List<MedicineRecommendation>>> call(
      CartRecommendationParams p) =>
      _repo.getCartRecommendations(p.cartMedicineIds, limit: p.limit);
}

class RecommendationParams extends Equatable {
  const RecommendationParams(this.medicineId, {this.limit = 5});
  final String medicineId;
  final int limit;
  @override List<Object> get props => [medicineId, limit];
}

class CartRecommendationParams extends Equatable {
  const CartRecommendationParams(this.cartMedicineIds, {this.limit = 5});
  final List<String> cartMedicineIds;
  final int limit;
  @override List<Object> get props => [cartMedicineIds, limit];
}