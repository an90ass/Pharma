import 'package:equatable/equatable.dart';

class MedicineRecommendation extends Equatable {
  const MedicineRecommendation({
    required this.medicineId,
    required this.tradeName,
    required this.genericName,
    required this.category,
    required this.salePrice,
    required this.type,
    required this.score,
    this.reason,
  });

  final String medicineId;
  final String tradeName;
  final String genericName;
  final String category;
  final double salePrice;
  final RecommendationType type;
  final double score;       // 0.0–1.0 relevance score
  final String? reason;     // "Bought together 23 times"

  @override
  List<Object?> get props => [medicineId, type, score];
}

enum RecommendationType {
  frequentlyBoughtTogether('Frequently bought together'),
  substitute('Possible substitute'),
  reorderSuggestion('Suggested reorder');

  const RecommendationType(this.label);
  final String label;
}