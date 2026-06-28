import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {

  Future<Either<Failure, DashboardStats>> getDashboardStats();

  Stream<Either<Failure, DashboardStats>> watchDashboardStats();

  Future<Either<Failure, int>> getLowStockCount();

  Future<Either<Failure, int>> getExpiringCount({int withinDays = 30});
}
