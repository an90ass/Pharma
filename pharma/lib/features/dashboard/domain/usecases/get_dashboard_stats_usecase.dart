import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase implements UseCase<DashboardStats, NoParams> {
  const GetDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams _) {
    return _repository.getDashboardStats();
  }
}
class WatchDashboardStatsUseCase
    implements StreamUseCase<DashboardStats, NoParams> {
  const WatchDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Stream<Either<Failure, DashboardStats>> call(NoParams _) {
    return _repository.watchDashboardStats();
  }
}

class GetLowStockCountUseCase implements UseCase<int, NoParams> {
  const GetLowStockCountUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams _) {
    return _repository.getLowStockCount();
  }
}


class GetExpiringCountUseCase implements UseCase<int, ExpiringCountParams> {
  const GetExpiringCountUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, int>> call(ExpiringCountParams params) {
    return _repository.getExpiringCount(withinDays: params.withinDays);
  }
}

class ExpiringCountParams extends Equatable {
  const ExpiringCountParams({this.withinDays = 30});
  final int withinDays;

  @override
  List<Object> get props => [withinDays];
}
