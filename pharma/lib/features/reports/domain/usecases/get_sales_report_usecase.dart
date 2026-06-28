import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sales_report_entity.dart';
import '../repositories/reports_repository.dart';

class GetDailySalesReportUseCase
    implements UseCase<SalesReportEntity, DailyReportParams> {
  const GetDailySalesReportUseCase(this._repo);
  final ReportsRepository _repo;

  @override
  Future<Either<Failure, SalesReportEntity>> call(DailyReportParams p) =>
      _repo.getDailySalesReport(p.date);
}

class GetWeeklySalesReportUseCase
    implements UseCase<SalesReportEntity, WeeklyReportParams> {
  const GetWeeklySalesReportUseCase(this._repo);
  final ReportsRepository _repo;

  @override
  Future<Either<Failure, SalesReportEntity>> call(WeeklyReportParams p) =>
      _repo.getWeeklySalesReport(p.weekStart);
}

class GetMonthlySalesReportUseCase
    implements UseCase<SalesReportEntity, MonthlyReportParams> {
  const GetMonthlySalesReportUseCase(this._repo);
  final ReportsRepository _repo;

  @override
  Future<Either<Failure, SalesReportEntity>> call(MonthlyReportParams p) =>
      _repo.getMonthlySalesReport(p.year, p.month);
}

class GetCustomRangeReportUseCase
    implements UseCase<SalesReportEntity, CustomRangeParams> {
  const GetCustomRangeReportUseCase(this._repo);
  final ReportsRepository _repo;

  @override
  Future<Either<Failure, SalesReportEntity>> call(CustomRangeParams p) async {
    if (p.to.isBefore(p.from)) {
      return const Left(
          ValidationFailure('End date must be after start date.'));
    }
    if (p.to.difference(p.from).inDays > 365) {
      return const Left(
          ValidationFailure('Date range cannot exceed 1 year.'));
    }
    return _repo.getCustomRangeReport(p.from, p.to);
  }
}

// ── Params ────────────────────────────────────────────────────────────────────

class DailyReportParams extends Equatable {
  const DailyReportParams(this.date);
  final DateTime date;
  @override List<Object> get props => [date];
}

class WeeklyReportParams extends Equatable {
  const WeeklyReportParams(this.weekStart);
  final DateTime weekStart;
  @override List<Object> get props => [weekStart];
}

class MonthlyReportParams extends Equatable {
  const MonthlyReportParams({required this.year, required this.month});
  final int year;
  final int month;
  @override List<Object> get props => [year, month];
}

class CustomRangeParams extends Equatable {
  const CustomRangeParams({required this.from, required this.to});
  final DateTime from;
  final DateTime to;
  @override List<Object> get props => [from, to];
}