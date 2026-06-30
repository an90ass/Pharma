import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/medicine_recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  const RecommendationRepositoryImpl(this._ds);
  final RecommendationDataSource _ds;

  Either<Failure, T> _h<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    return Left(UnexpectedFailure(e.toString()));
  }

  @override
  Future<Either<Failure, List<MedicineRecommendation>>>
      getFrequentlyBoughtTogether(String medicineId, {int limit = 5}) async {
    try { return Right(await _ds.getFrequentlyBoughtTogether(medicineId, limit)); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, List<MedicineRecommendation>>>
      getSubstitutes(String medicineId, {int limit = 5}) async {
    try { return Right(await _ds.getSubstitutes(medicineId, limit)); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, List<MedicineRecommendation>>>
      getReorderSuggestions({int limit = 10}) async {
    try { return Right(await _ds.getReorderSuggestions(limit)); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, List<MedicineRecommendation>>>
      getCartRecommendations(List<String> cartMedicineIds, {int limit = 5}) async {
    try {
      final Map<String, MedicineRecommendation> combined = {};
      for (final id in cartMedicineIds.take(3)) {
        final recs = await _ds.getFrequentlyBoughtTogether(id, limit);
        for (final r in recs) {
          if (cartMedicineIds.contains(r.medicineId)) continue;
          combined[r.medicineId] = r;
        }
      }
      final sorted = combined.values.toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      return Right(sorted.take(limit).toList());
    } catch (e) { return _h(e); }
  }
}