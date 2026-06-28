import 'package:equatable/equatable.dart';

/// Detailed profit & loss breakdown.
class ProfitReportEntity extends Equatable {
  const ProfitReportEntity({
    required this.from,
    required this.to,
    required this.totalRevenue,
    required this.totalCogs,
    required this.grossProfit,
    required this.totalDiscount,
    required this.netProfit,
    required this.profitMarginPct,
    required this.monthlyTrend,
    required this.categoryBreakdown,
  });

  final DateTime from;
  final DateTime to;
  final double totalRevenue;
  final double totalCogs;        // cost of goods sold
  final double grossProfit;
  final double totalDiscount;
  final double netProfit;
  final double profitMarginPct;
  final List<ProfitDataPoint>    monthlyTrend;
  final List<CategoryProfit>     categoryBreakdown;

  @override
  List<Object?> get props => [from, to, netProfit];
}

class ProfitDataPoint extends Equatable {
  const ProfitDataPoint({
    required this.label,
    required this.revenue,
    required this.cost,
    required this.profit,
  });
  final String label;
  final double revenue;
  final double cost;
  final double profit;
  @override List<Object?> get props => [label, profit];
}

class CategoryProfit extends Equatable {
  const CategoryProfit({
    required this.category,
    required this.revenue,
    required this.profit,
    required this.percentage,
  });
  final String category;
  final double revenue;
  final double profit;
  final double percentage;
  @override List<Object?> get props => [category, profit];
}