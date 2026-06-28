import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier_entity.dart';

class SupplierModel extends SupplierEntity {
  const SupplierModel({
    required super.id, required super.name, required super.phone,
    required super.createdAt, super.email, super.address, super.ntn,
    super.contactPerson, super.totalOrders, super.totalAmount, super.isActive,
  });

  factory SupplierModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SupplierModel(
      id:            doc.id,
      name:          d['name']          as String? ?? '',
      phone:         d['phone']         as String? ?? '',
      createdAt:     (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      email:         d['email']         as String?,
      address:       d['address']       as String?,
      ntn:           d['ntn']           as String?,
      contactPerson: d['contactPerson'] as String?,
      totalOrders:   (d['totalOrders']  as num?)?.toInt()    ?? 0,
      totalAmount:   (d['totalAmount']  as num?)?.toDouble() ?? 0,
      isActive:      d['isActive']      as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore({bool isNew = false}) => {
    'name': name, 'phone': phone, 'email': email, 'address': address,
    'ntn': ntn, 'contactPerson': contactPerson, 'totalOrders': totalOrders,
    'totalAmount': totalAmount, 'isActive': isActive,
    if (isNew) 'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}