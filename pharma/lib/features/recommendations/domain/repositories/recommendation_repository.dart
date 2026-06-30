import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine_recommendation.dart';

abstract class RecommendationRepository {
  /// Medicines frequently bought alongside [medicineId].
  Future<Either<Failure, List<MedicineRecommendation>>>
      getFrequentlyBoughtTogether(String medicineId, {int limit = 5});

  /// Possible generic substitutes for [medicineId].
  Future<Either<Failure, List<MedicineRecommendation>>>
      getSubstitutes(String medicineId, {int limit = 5});

  /// Medicines running low that should be reordered soon.
  Future<Either<Failure, List<MedicineRecommendation>>>
      getReorderSuggestions({int limit = 10});

  /// Combined smart suggestions for the cart (given current cart items).
  Future<Either<Failure, List<MedicineRecommendation>>>
      getCartRecommendations(List<String> cartMedicineIds, {int limit = 5});
}