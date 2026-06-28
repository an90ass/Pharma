import 'package:equatable/equatable.dart';

/// Inventory snapshot for reporting.
class InventoryReportEntity extends Equatable {
  const InventoryReportEntity({
    required this.generatedAt,
    required this.totalMedicines,
    required this.totalBatches,
    required this.totalStockValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.expiringCount,
    required this.expiredCount,
    required this.categoryBreakdown,
    required this.lowStockItems,
    required this.expiringItems,
    required this.stockValueByCategory,
  });

  final DateTime generatedAt;
  final int    totalMedicines;
  final int    totalBatches;
  final double totalStockValue;
  final int    lowStockCount;
  final int    outOfStockCount;
  final int    expiringCount;
  final int    expiredCount;
  final List<CategoryStock>     categoryBreakdown;
  final List<LowStockItem>      lowStockItems;
  final List<ExpiringItem>      expiringItems;
  final List<StockValueCategory> stockValueByCategory;

  @override List<Object?> get props => [generatedAt, totalStockValue];
}

class CategoryStock extends Equatable {
  const CategoryStock({
    required this.category,
    required this.count,
    required this.totalQty,
    required this.stockValue,
  });
  final String category;
  final int    count;
  final int    totalQty;
  final double stockValue;
  @override List<Object?> get props => [category, count];
}

class LowStockItem extends Equatable {
  const LowStockItem({
    required this.medicineId,
    required this.tradeName,
    required this.currentQty,
    required this.reorderLevel,
    required this.reorderQty,
  });
  final String medicineId;
  final String tradeName;
  final int    currentQty;
  final int    reorderLevel;
  final int    reorderQty;
  @override List<Object?> get props => [medicineId, currentQty];
}

class ExpiringItem extends Equatable {
  const ExpiringItem({
    required this.medicineId,
    required this.tradeName,
    required this.batchNo,
    required this.qtyAvailable,
    required this.expiryDate,
    required this.daysLeft,
    required this.stockValue,
  });
  final String   medicineId;
  final String   tradeName;
  final String   batchNo;
  final int      qtyAvailable;
  final DateTime expiryDate;
  final int      daysLeft;
  final double   stockValue;
  @override List<Object?> get props => [medicineId, batchNo, expiryDate];
}

class StockValueCategory extends Equatable {
  const StockValueCategory({
    required this.category,
    required this.value,
    required this.percentage,
  });
  final String category;
  final double value;
  final double percentage;
  @override List<Object?> get props => [category, value];
}