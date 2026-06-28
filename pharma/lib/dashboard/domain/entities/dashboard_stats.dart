import 'package:equatable/equatable.dart';

/// Aggregated dashboard statistics entity.
/// Pure Dart — no Firebase, no Flutter imports.
class DashboardStats extends Equatable {
  const DashboardStats({
    required this.totalMedicines,
    required this.totalCustomers,
    required this.totalSuppliers,
    required this.lowStockCount,
    required this.expiringCount,
    required this.todaySalesAmount,
    required this.todaySalesCount,
    required this.monthlySalesAmount,
    required this.monthlySalesCount,
    required this.recentActivities,
    required this.fetchedAt,
  });

  final int totalMedicines;
  final int totalCustomers;
  final int totalSuppliers;
  final int lowStockCount;
  final int expiringCount;
  final double todaySalesAmount;
  final int todaySalesCount;
  final double monthlySalesAmount;
  final int monthlySalesCount;
  final List<RecentActivity> recentActivities;
  final DateTime fetchedAt;

  bool get hasAlerts => lowStockCount > 0 || expiringCount > 0;
  int get totalAlerts => lowStockCount + expiringCount;
  double get avgTodaySale =>
      todaySalesCount == 0 ? 0 : todaySalesAmount / todaySalesCount;

  factory DashboardStats.empty() => DashboardStats(
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

  DashboardStats copyWith({
    int? totalMedicines,
    int? totalCustomers,
    int? totalSuppliers,
    int? lowStockCount,
    int? expiringCount,
    double? todaySalesAmount,
    int? todaySalesCount,
    double? monthlySalesAmount,
    int? monthlySalesCount,
    List<RecentActivity>? recentActivities,
    DateTime? fetchedAt,
  }) {
    return DashboardStats(
      totalMedicines: totalMedicines ?? this.totalMedicines,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalSuppliers: totalSuppliers ?? this.totalSuppliers,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      expiringCount: expiringCount ?? this.expiringCount,
      todaySalesAmount: todaySalesAmount ?? this.todaySalesAmount,
      todaySalesCount: todaySalesCount ?? this.todaySalesCount,
      monthlySalesAmount: monthlySalesAmount ?? this.monthlySalesAmount,
      monthlySalesCount: monthlySalesCount ?? this.monthlySalesCount,
      recentActivities: recentActivities ?? this.recentActivities,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  List<Object?> get props => [
        totalMedicines, totalCustomers, totalSuppliers,
        lowStockCount, expiringCount, todaySalesAmount,
        todaySalesCount, monthlySalesAmount, monthlySalesCount,
        recentActivities, fetchedAt,
      ];
}

class RecentActivity extends Equatable {
  const RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.performedBy,
    required this.timestamp,
    this.amount,
  });

  final String id;
  final ActivityType type;
  final String description;
  final String performedBy;
  final DateTime timestamp;
  final double? amount;

  @override
  List<Object?> get props =>
      [id, type, description, performedBy, timestamp, amount];
}

enum ActivityType {
  sale, purchase, stockAdjustment, newMedicine,
  newCustomer, prescriptionAdded, lowStockAlert, expiryAlert;

  String get displayLabel => switch (this) {
        ActivityType.sale => 'Sale',
        ActivityType.purchase => 'Purchase',
        ActivityType.stockAdjustment => 'Stock Adjustment',
        ActivityType.newMedicine => 'New Medicine',
        ActivityType.newCustomer => 'New Customer',
        ActivityType.prescriptionAdded => 'Prescription',
        ActivityType.lowStockAlert => 'Low Stock',
        ActivityType.expiryAlert => 'Expiry Alert',
      };
}
