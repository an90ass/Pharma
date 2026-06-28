import 'package:pharma/dashboard/domain/entities/dashboard_stats.dart';

class DashboardModel extends DashboardStats {
  const DashboardModel({
    required super.totalMedicines,
    required super.totalCustomers,
    required super.totalSuppliers,
    required super.lowStockCount,
    required super.expiringCount,
    required super.todaySalesAmount,
    required super.todaySalesCount,
    required super.monthlySalesAmount,
    required super.monthlySalesCount,
    required super.recentActivities,
    required super.fetchedAt,
  });

  factory DashboardModel.empty() => DashboardModel(
    totalMedicines: 0,
    totalCustomers: 0,
    totalSuppliers: 0,
    lowStockCount: 0,
    expiringCount: 0,
    todaySalesAmount: 0,
    todaySalesCount: 0,
    monthlySalesAmount: 0,
    monthlySalesCount: 0,
    recentActivities: const [],
    fetchedAt: DateTime.now(),
  );
}