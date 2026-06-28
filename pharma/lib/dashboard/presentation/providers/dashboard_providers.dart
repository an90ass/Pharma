import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

/// Provides the singleton [FirebaseFirestore] instance.
/// Override in tests with a fake implementation.
final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

// ── Data layer ────────────────────────────────────────────────────────────────

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(
    ref.read(firestoreProvider),
  );
});

// ── Repository ────────────────────────────────────────────────────────────────

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.read(dashboardRemoteDataSourceProvider),
  );
});

// ── Use cases ─────────────────────────────────────────────────────────────────

final getDashboardStatsUseCaseProvider =
    Provider<GetDashboardStatsUseCase>((ref) {
  return GetDashboardStatsUseCase(
    ref.read(dashboardRepositoryProvider),
  );
});

final watchDashboardStatsUseCaseProvider =
    Provider<WatchDashboardStatsUseCase>((ref) {
  return WatchDashboardStatsUseCase(
    ref.read(dashboardRepositoryProvider),
  );
});

final getLowStockCountUseCaseProvider =
    Provider<GetLowStockCountUseCase>((ref) {
  return GetLowStockCountUseCase(
    ref.read(dashboardRepositoryProvider),
  );
});
