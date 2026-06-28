import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma/features/medicines/presentation/viewmodels/medicine_viewmodel.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../providers/dashboard_providers.dart';

// dashboard_viewmodel.dart

class DashboardViewModel extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    ref.listen(medicineViewModelProvider, (prev, next) {
      if (next.actionStatus == MedicineActionStatus.idle &&
          prev?.medicines != next.medicines) {
        refresh();
      }
    });

    return _fetchStats();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }

  Future<DashboardStats> _fetchStats() async {
    final getStats = ref.watch(getDashboardStatsUseCaseProvider);
    final result = await getStats(const NoParams());
    return result.fold(
      (failure) => throw Exception(failure.message),
      (stats) => stats,
    );
  }
}
final dashboardViewModelProvider =
    AsyncNotifierProvider<DashboardViewModel, DashboardStats>(
  DashboardViewModel.new,
);
