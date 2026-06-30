import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/medicine_recommendation.dart';

/// Horizontal carousel card shown in CartScreen / Dashboard.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key, required this.rec, required this.onAdd,
  });
  final MedicineRecommendation rec;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final color = switch (rec.type) {
      RecommendationType.frequentlyBoughtTogether => const Color(0xFF1565C0),
      RecommendationType.substitute               => const Color(0xFF7B1FA2),
      RecommendationType.reorderSuggestion        => const Color(0xFFFF9800),
    };

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.8),
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
                    fontSize: 9, fontWeight: FontWeight.w600, color: color)),
          ),
          const SizedBox(height: 8),
          Text(rec.tradeName,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(rec.genericName,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (rec.reason != null) ...[
            const SizedBox(height: 4),
            Text(rec.reason!,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0)
                    .format(rec.salePrice),
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0)),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 26, height: 26,
                  decoration: const BoxDecoration(
                      color: Color(0xFF1565C0), shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horizontal carousel container.
class RecommendationCarousel extends StatelessWidget {
  const RecommendationCarousel({
    super.key, required this.title, required this.recs, required this.onAdd,
  });
  final String title;
  final List<MedicineRecommendation> recs;
  final void Function(MedicineRecommendation) onAdd;

  @override
  Widget build(BuildContext context) {
    if (recs.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => RecommendationCard(
              rec: recs[i], onAdd: () => onAdd(recs[i])),
          ),
        ),
      ],
    );
  }
}