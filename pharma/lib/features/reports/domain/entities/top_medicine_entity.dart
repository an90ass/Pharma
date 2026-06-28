import 'package:equatable/equatable.dart';

/// A medicine ranked by sales performance.
class TopMedicineEntity extends Equatable {
  const TopMedicineEntity({
    required this.rank,
    required this.medicineId,
    required this.tradeName,
    required this.genericName,
    required this.category,
    required this.totalQtySold,
    required this.totalRevenue,
    required this.totalProfit,
    required this.invoiceCount,
    this.profitMargin = 0,
  });

  final int    rank;
  final String medicineId;
  final String tradeName;
  final String genericName;
  final String category;
  final int    totalQtySold;
  final double totalRevenue;
  final double totalProfit;
  final int    invoiceCount;
  final double profitMargin;

  @override
  List<Object?> get props => [medicineId, rank, totalRevenue];
}