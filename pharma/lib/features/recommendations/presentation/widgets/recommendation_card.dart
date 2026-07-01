import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/medicine_recommendation.dart';

/// Horizontal carousel card shown in CartScreen / Dashboard.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.rec,
    required this.onAdd,
    this.width = 190,
  });

  final MedicineRecommendation rec;
  final VoidCallback onAdd;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(rec.type);

    return Material(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(rec.type.label,
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
            const SizedBox(height: 8),
            Text(rec.tradeName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(rec.genericName,
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (rec.reason != null) ...[
              const SizedBox(height: 6),
              Text(rec.reason!,
                  style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0)
                              .format(rec.salePrice),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: color),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rec.type == RecommendationType.reorderSuggestion
                              ? 'Reorder'
                              : '',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: color,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: onAdd,
                    tooltip: 'Add to cart',
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForType(RecommendationType t) {
    switch (t) {
      case RecommendationType.frequentlyBoughtTogether:
        return const Color(0xFF1565C0);
      case RecommendationType.substitute:
        return const Color(0xFF7B1FA2);
      case RecommendationType.reorderSuggestion:
        return const Color(0xFFF57C00);
    }
  }
}

/// Horizontal carousel container.
class RecommendationCarousel extends StatelessWidget {
  const RecommendationCarousel({
    super.key,
    required this.title,
    required this.recs,
    required this.onAdd,
    this.description,
  });

  final String title;
  final List<MedicineRecommendation> recs;
  final void Function(MedicineRecommendation) onAdd;
  final String? description;

  @override
  Widget build(BuildContext context) {
    // Always show header + description. If there are no recommendations,
    // show a small message so user knows why the carousel is not visible.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 6),
              Text(
                description ??
                    'Smart suggestions: Products that are typically purchased with current items, alternatives, or recommendations for reordering.',
                style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (recs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text('No recommendations available',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
          )
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => RecommendationCard(rec: recs[i], onAdd: () => onAdd(recs[i])),
            ),
          ),
      ],
    );
  }
}