import 'package:equatable/equatable.dart';

/// Core Medicine entity — pure Dart, no Firebase imports.
/// Every other layer maps to/from this class.
class MedicineEntity extends Equatable {
  const MedicineEntity({
    required this.id,
    required this.tradeName,
    required this.genericName,
    required this.manufacturer,
    required this.category,
    required this.form,
    required this.strength,
    required this.packSize,
    required this.unit,
    required this.salePrice,
    required this.purchasePrice,
    required this.mrp,
    required this.reorderLevel,
    required this.reorderQty,
    required this.isControlled,
    required this.isActive,
    required this.createdAt,
    this.barcode,
    this.supplierId,
    this.taxCode,
    this.substitutes = const [],
    this.updatedAt,
    this.description,
  });

  final String id;
  final String tradeName;
  final String genericName;
  final String manufacturer;
  final MedicineCategory category;
  final MedicineForm form;
  final String strength;       // e.g. "500mg", "250mg/5ml"
  final int packSize;          // units per pack
  final String unit;           // "strip" | "bottle" | "vial" | "box"
  final double salePrice;      // PKR
  final double purchasePrice;
  final double mrp;            // max retail price
  final int reorderLevel;      // alert threshold
  final int reorderQty;        // suggested PO qty
  final bool isControlled;     // narcotic / scheduled drug
  final bool isActive;
  final DateTime createdAt;
  final String? barcode;
  final String? supplierId;
  final String? taxCode;
  final List<String> substitutes;  // list of medicineIds
  final DateTime? updatedAt;
  final String? description;

  // ── Convenience ────────────────────────────────────────────────────────
  double get profitMargin =>
      salePrice == 0 ? 0 : ((salePrice - purchasePrice) / salePrice) * 100;

  bool get needsReorder => false; // overridden with batch data in ViewModel

  MedicineEntity copyWith({
    String? id,
    String? tradeName,
    String? genericName,
    String? manufacturer,
    MedicineCategory? category,
    MedicineForm? form,
    String? strength,
    int? packSize,
    String? unit,
    double? salePrice,
    double? purchasePrice,
    double? mrp,
    int? reorderLevel,
    int? reorderQty,
    bool? isControlled,
    bool? isActive,
    DateTime? createdAt,
    String? barcode,
    String? supplierId,
    String? taxCode,
    List<String>? substitutes,
    DateTime? updatedAt,
    String? description,
  }) {
    return MedicineEntity(
      id: id ?? this.id,
      tradeName: tradeName ?? this.tradeName,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      form: form ?? this.form,
      strength: strength ?? this.strength,
      packSize: packSize ?? this.packSize,
      unit: unit ?? this.unit,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      mrp: mrp ?? this.mrp,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      reorderQty: reorderQty ?? this.reorderQty,
      isControlled: isControlled ?? this.isControlled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      barcode: barcode ?? this.barcode,
      supplierId: supplierId ?? this.supplierId,
      taxCode: taxCode ?? this.taxCode,
      substitutes: substitutes ?? this.substitutes,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id, tradeName, genericName, manufacturer, category, form,
        strength, packSize, unit, salePrice, purchasePrice, mrp,
        reorderLevel, reorderQty, isControlled, isActive, createdAt,
        barcode, supplierId, taxCode, substitutes, updatedAt,
      ];
}

// ── Enums ──────────────────────────────────────────────────────────────────

enum MedicineCategory {
  otc('OTC'),
  prescription('Rx'),
  controlled('Controlled'),
  generic('Generic'),
  herbal('Herbal'),
  supplement('Supplement');

  const MedicineCategory(this.label);
  final String label;

  static MedicineCategory fromString(String? v) =>
      MedicineCategory.values.firstWhere(
        (e) => e.name == v || e.label == v,
        orElse: () => MedicineCategory.otc,
      );
}

enum MedicineForm {
  tablet('Tablet'),
  capsule('Capsule'),
  syrup('Syrup'),
  injection('Injection'),
  drops('Drops'),
  cream('Cream'),
  ointment('Ointment'),
  inhaler('Inhaler'),
  patch('Patch'),
  sachet('Sachet'),
  suppository('Suppository'),
  powder('Powder');

  const MedicineForm(this.label);
  final String label;

  static MedicineForm fromString(String? v) =>
      MedicineForm.values.firstWhere(
        (e) => e.name == v || e.label == v,
        orElse: () => MedicineForm.tablet,
      );
}