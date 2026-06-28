import 'package:equatable/equatable.dart';

/// Lightweight medicine result from POS search.
/// Carries only fields needed to add to cart.
class MedicineSearchResult extends Equatable {
  const MedicineSearchResult({
    required this.medicineId,
    required this.tradeName,
    required this.genericName,
    required this.manufacturer,
    required this.strength,
    required this.form,
    required this.category,
    required this.salePrice,
    required this.isControlled,
    required this.availableBatches,
  });

  final String medicineId;
  final String tradeName;
  final String genericName;
  final String manufacturer;
  final String strength;
  final String form;
  final String category;
  final double salePrice;
  final bool isControlled;
  final List<BatchStock> availableBatches;   // FIFO sorted

  int get totalQtyAvailable =>
      availableBatches.fold(0, (s, b) => s + b.qtyAvailable);

  bool get isInStock => totalQtyAvailable > 0;

  /// First FIFO batch with available stock
  BatchStock? get primaryBatch =>
      availableBatches.where((b) => b.qtyAvailable > 0).isNotEmpty
          ? availableBatches.firstWhere((b) => b.qtyAvailable > 0)
          : null;

  @override
  List<Object?> get props => [medicineId, tradeName];
}

class BatchStock extends Equatable {
  const BatchStock({
    required this.batchId,
    required this.batchNo,
    required this.expiryDate,
    required this.qtyAvailable,
    required this.salePrice,
  });
  final String batchId;
  final String batchNo;
  final DateTime expiryDate;
  final int qtyAvailable;
  final double salePrice;
  @override List<Object?> get props => [batchId, qtyAvailable];
}