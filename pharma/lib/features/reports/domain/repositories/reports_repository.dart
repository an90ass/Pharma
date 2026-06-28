import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/inventory_report_entity.dart';
import '../entities/profit_report_entity.dart';
import '../entities/sales_report_entity.dart';
import '../entities/top_medicine_entity.dart';

/// Abstract contract for all report data operations.
abstract class ReportsRepository {

  // ── Sales reports ──────────────────────────────────────────────────────
  Future<Either<Failure, SalesReportEntity>> getDailySalesReport(DateTime date);

  Future<Either<Failure, SalesReportEntity>> getWeeklySalesReport(
      DateTime weekStart);

  Future<Either<Failure, SalesReportEntity>> getMonthlySalesReport(
      int year, int month);

  Future<Either<Failure, SalesReportEntity>> getCustomRangeReport(
      DateTime from, DateTime to);

  // ── Top medicines ──────────────────────────────────────────────────────
  Future<Either<Failure, List<TopMedicineEntity>>> getTopSellingMedicines({
    required DateTime from,
    required DateTime to,
    int limit = 10,
  });

  // ── Profit report ──────────────────────────────────────────────────────
  Future<Either<Failure, ProfitReportEntity>> getProfitReport({
    required DateTime from,
    required DateTime to,
  });

  // ── Inventory report ───────────────────────────────────────────────────
  Future<Either<Failure, InventoryReportEntity>> getInventoryReport();
}