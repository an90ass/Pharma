import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/medicine_recommendation.dart';

class RecommendationDataSource {
  const RecommendationDataSource(this._fs);
  final FirebaseFirestore _fs;

  // ── Frequently bought together ─────────────────────────────────────────────
  Future<List<MedicineRecommendation>> getFrequentlyBoughtTogether(
      String medicineId, int limit) async {
    try {
      // Query invoices containing this medicine
      final snap = await _fs.collection('invoices')
          .where('status', whereIn: ['paid', 'credit'])
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get();

      // Co-occurrence map: medicineId → count
      final Map<String, int> coOccurrence = {};

      for (final doc in snap.docs) {
        final items = doc.data()['items'] as List<dynamic>? ?? [];
        final ids = items
            .map((i) => (i as Map<String, dynamic>)['medicineId'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        if (!ids.contains(medicineId)) continue;

        for (final id in ids) {
          if (id == medicineId) continue;
          coOccurrence[id] = (coOccurrence[id] ?? 0) + 1;
        }
      }

      if (coOccurrence.isEmpty) return [];

      final sorted = coOccurrence.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topIds = sorted.take(limit).map((e) => e.key).toList();
      final maxCount = sorted.first.value;

      // Fetch medicine details
      final results = <MedicineRecommendation>[];
      for (final id in topIds) {
        try {
          final med = await _fs.collection('medicines').doc(id).get();
          if (!med.exists) continue;
          final d = med.data()!;
          final count = coOccurrence[id] ?? 1;
          results.add(MedicineRecommendation(
            medicineId:  id,
            tradeName:   d['tradeName']   as String? ?? '',
            genericName: d['genericName'] as String? ?? '',
            category:    d['category']    as String? ?? '',
            salePrice:   (d['salePrice']  as num?)?.toDouble() ?? 0,
            type:        RecommendationType.frequentlyBoughtTogether,
            score:       count / maxCount,
            reason:      'Bought together $count time${count == 1 ? '' : 's'}',
          ));
        } catch (_) { continue; }
      }
      return results;
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── Substitutes ────────────────────────────────────────────────────────────
  Future<List<MedicineRecommendation>> getSubstitutes(
      String medicineId, int limit) async {
    try {
      final doc = await _fs.collection('medicines').doc(medicineId).get();
      if (!doc.exists) return [];

      final substitutes = List<String>.from(
          doc.data()?['substitutes'] as List? ?? []);

      if (substitutes.isEmpty) {
        // Fallback: same genericName, different tradeName
        final generic = doc.data()?['genericName'] as String? ?? '';
        if (generic.isNotEmpty) {
          final snap = await _fs.collection('medicines')
              .where('genericName', isEqualTo: generic)
              .where('isActive', isEqualTo: true)
              .limit(limit + 1)
              .get();
          return snap.docs
              .where((d) => d.id != medicineId)
              .take(limit)
              .map((d) {
                final data = d.data();
                return MedicineRecommendation(
                  medicineId:  d.id,
                  tradeName:   data['tradeName']   as String? ?? '',
                  genericName: data['genericName'] as String? ?? '',
                  category:    data['category']    as String? ?? '',
                  salePrice:   (data['salePrice']  as num?)?.toDouble() ?? 0,
                  type:        RecommendationType.substitute,
                  score:       0.8,
                  reason:      'Same generic: $generic',
                );
              }).toList();
        }
        return [];
      }

      final results = <MedicineRecommendation>[];
      for (final id in substitutes.take(limit)) {
        try {
          final med = await _fs.collection('medicines').doc(id).get();
          if (!med.exists) continue;
          final d = med.data()!;
          results.add(MedicineRecommendation(
            medicineId:  id,
            tradeName:   d['tradeName']   as String? ?? '',
            genericName: d['genericName'] as String? ?? '',
            category:    d['category']    as String? ?? '',
            salePrice:   (d['salePrice']  as num?)?.toDouble() ?? 0,
            type:        RecommendationType.substitute,
            score:       0.9,
            reason:      'Approved substitute',
          ));
        } catch (_) { continue; }
      }
      return results;
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── Reorder suggestions ────────────────────────────────────────────────────
  Future<List<MedicineRecommendation>> getReorderSuggestions(int limit) async {
    try {
      final snap = await _fs.collection('medicines')
          .where('isActive', isEqualTo: true)
          .where('isLowStock', isEqualTo: true)
          .orderBy('tradeName')
          .limit(limit)
          .get();

      return snap.docs.map((doc) {
        final d = doc.data();
        return MedicineRecommendation(
          medicineId:  doc.id,
          tradeName:   d['tradeName']   as String? ?? '',
          genericName: d['genericName'] as String? ?? '',
          category:    d['category']    as String? ?? '',
          salePrice:   (d['salePrice']  as num?)?.toDouble() ?? 0,
          type:        RecommendationType.reorderSuggestion,
          score:       1.0,
          reason:      'Stock below reorder level',
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }
}