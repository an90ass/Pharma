import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medicine_entity.dart';

/// Data-layer model: extends [MedicineEntity] and adds
/// Firestore serialization (fromFirestore / toFirestore).
///
/// Rule: only the data layer ever uses MedicineModel directly.
/// Domain and presentation layers work with MedicineEntity.
class MedicineModel extends MedicineEntity {
  const MedicineModel({
    required super.id,
    required super.tradeName,
    required super.genericName,
    required super.manufacturer,
    required super.category,
    required super.form,
    required super.strength,
    required super.packSize,
    required super.unit,
    required super.salePrice,
    required super.purchasePrice,
    required super.mrp,
    required super.reorderLevel,
    required super.reorderQty,
    required super.isControlled,
    required super.isActive,
    required super.createdAt,
    super.barcode,
    super.supplierId,
    super.taxCode,
    super.substitutes,
    super.updatedAt,
    super.description,
  });

  // ── fromFirestore ────────────────────────────────────────────────────
  factory MedicineModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MedicineModel(
      id: doc.id,
      tradeName: d['tradeName'] as String? ?? '',
      genericName: d['genericName'] as String? ?? '',
      manufacturer: d['manufacturer'] as String? ?? '',
      category: MedicineCategory.fromString(d['category'] as String?),
      form: MedicineForm.fromString(d['form'] as String?),
      strength: d['strength'] as String? ?? '',
      packSize: (d['packSize'] as num?)?.toInt() ?? 1,
      unit: d['unit'] as String? ?? 'strip',
      salePrice: (d['salePrice'] as num?)?.toDouble() ?? 0,
      purchasePrice: (d['purchasePrice'] as num?)?.toDouble() ?? 0,
      mrp: (d['mrp'] as num?)?.toDouble() ?? 0,
      reorderLevel: (d['reorderLevel'] as num?)?.toInt() ?? 10,
      reorderQty: (d['reorderQty'] as num?)?.toInt() ?? 50,
      isControlled: d['isControlled'] as bool? ?? false,
      isActive: d['isActive'] as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      barcode: d['barcode'] as String?,
      supplierId: d['supplierId'] as String?,
      taxCode: d['taxCode'] as String?,
      substitutes: List<String>.from(d['substitutes'] as List? ?? []),
      description: d['description'] as String?,
    );
  }

  // ── toFirestore ──────────────────────────────────────────────────────
  /// Used for both create and update.
  /// Pass [isNew: true] on create to set createdAt via serverTimestamp.
  Map<String, dynamic> toFirestore({bool isNew = false}) {
    return {
      'tradeName': tradeName,
      'genericName': genericName,
      // searchIndex: lowercase tokens for client-side search fallback
      'searchTokens': _buildSearchTokens(),
      'manufacturer': manufacturer,
      'category': category.name,
      'form': form.name,
      'strength': strength,
      'packSize': packSize,
      'unit': unit,
      'salePrice': salePrice,
      'purchasePrice': purchasePrice,
      'mrp': mrp,
      'reorderLevel': reorderLevel,
      'reorderQty': reorderQty,
      'isControlled': isControlled,
      'isActive': isActive,
      if (barcode != null) 'barcode': barcode,
      if (supplierId != null) 'supplierId': supplierId,
      if (taxCode != null) 'taxCode': taxCode,
      if (description != null) 'description': description,
      'substitutes': substitutes,
      'isLowStock': false,   // updated by Cloud Function on each sale
      if (isNew)
        'createdAt': FieldValue.serverTimestamp()
      else
        'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Build prefix tokens for Firestore "array-contains" search
  List<String> _buildSearchTokens() {
    final tokens = <String>{};
    for (final word in [tradeName, genericName, manufacturer]) {
      final lower = word.toLowerCase();
      for (int i = 1; i <= lower.length; i++) {
        tokens.add(lower.substring(0, i));
      }
    }
    if (barcode != null) tokens.add(barcode!);
    return tokens.toList();
  }
}