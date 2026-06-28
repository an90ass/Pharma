import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../providers/dashboard_providers.dart';

/// ViewModel for the dashboard screen.
///
/// Extends [AsyncNotifier] so that [AsyncValue] (loading/error/data)
/// is handled automatically — no manual state boilerplate.
///
/// Access via: ref.watch(dashboardViewModelProvider)
class DashboardViewModel extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    return _fetchStats();
  }

  /// Manual refresh — triggered by pull-to-refresh or refresh button.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }

  Future<DashboardStats> _fetchStats() async {
    final getStats = ref.read(getDashboardStatsUseCaseProvider);
    final result = await getStats(const NoParams());
        print('resultresult: $result');

    return result.fold(
      (failure) => throw Exception(failure.message),
      (stats) => stats,
    );
  }
}

/// Provider exposed to the widget tree.
final dashboardViewModelProvider =
    AsyncNotifierProvider<DashboardViewModel, DashboardStats>(
  DashboardViewModel.new,
);
