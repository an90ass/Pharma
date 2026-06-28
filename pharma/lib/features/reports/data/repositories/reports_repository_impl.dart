import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/inventory_report_entity.dart';
import '../../domain/entities/profit_report_entity.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/entities/top_medicine_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

/// Implements [ReportsRepository].
/// Maps datasource exceptions to typed [Failure]s.
class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._remote);
  final ReportsRemoteDataSource _remote;

  Either<Failure, T> _handle<T>(Object e) {
    if (e is ServerException)  return Left(ServerFailure(e.message));
    if (e is NetworkException) return const Left(NetworkFailure());
    return Left(UnexpectedFailure(e.toString()));
  }

  @override
  Future<Either<Failure, SalesReportEntity>> getDailySalesReport(
      DateTime date) async {
    try {
      final from = DateTime(date.year, date.month, date.day);
      final to   = from.add(const Duration(
          hours: 23, minutes: 59, seconds: 59));
      return Right(await _remote.getSalesReport(
          from, to, ReportPeriod.daily));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, SalesReportEntity>> getWeeklySalesReport(
      DateTime weekStart) async {
    try {
      final from = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final to   = from.add(const Duration(
          days: 6, hours: 23, minutes: 59, seconds: 59));
      return Right(await _remote.getSalesReport(
          from, to, ReportPeriod.weekly));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, SalesReportEntity>> getMonthlySalesReport(
      int year, int month) async {
    try {
      final from = DateTime(year, month, 1);
      final to   = DateTime(year, month + 1, 1)
          .subtract(const Duration(seconds: 1));
      return Right(await _remote.getSalesReport(
          from, to, ReportPeriod.monthly));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, SalesReportEntity>> getCustomRangeReport(
      DateTime from, DateTime to) async {
    try {
      return Right(await _remote.getSalesReport(
          from, to, ReportPeriod.custom));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, List<TopMedicineEntity>>> getTopSellingMedicines({
    required DateTime from,
    required DateTime to,
    int limit = 10,
  }) async {
    try {
      return Right(await _remote.getTopSellingMedicines(from, to, limit));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, ProfitReportEntity>> getProfitReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      return Right(await _remote.getProfitReport(from, to));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, InventoryReportEntity>> getInventoryReport() async {
    try {
      return Right(await _remote.getInventoryReport());
    } catch (e) { return _handle(e); }
  }
}