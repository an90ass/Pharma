import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/recommendation_datasource.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../domain/usecases/recommendation_usecases.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final recommendationDataSourceProvider =
    Provider((ref) => RecommendationDataSource(ref.read(firestoreProvider)));

final recommendationRepositoryProvider =
    Provider<RecommendationRepository>((ref) =>
        RecommendationRepositoryImpl(ref.read(recommendationDataSourceProvider)));

final getFrequentlyBoughtUseCaseProvider =
    Provider((ref) => GetFrequentlyBoughtTogetherUseCase(
        ref.read(recommendationRepositoryProvider)));
final getSubstitutesUseCaseProvider =
    Provider((ref) => GetSubstitutesUseCase(
        ref.read(recommendationRepositoryProvider)));
final getReorderSuggestionsUseCaseProvider =
    Provider((ref) => GetReorderSuggestionsUseCase(
        ref.read(recommendationRepositoryProvider)));
final getCartRecommendationsUseCaseProvider =
    Provider((ref) => GetCartRecommendationsUseCase(
        ref.read(recommendationRepositoryProvider)));