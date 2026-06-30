import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id, required super.name, required super.address,
    required super.phone, required super.isMain, required super.isActive,
    required super.createdAt, super.email, super.licenseNo, super.ntn,
  });

  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StoreModel(
      id:        doc.id,
      name:      d['name']      as String? ?? '',
      address:   d['address']   as String? ?? '',
      phone:     d['phone']     as String? ?? '',
      isMain:    d['isMain']    as bool? ?? false,
      isActive:  d['isActive']  as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      email:     d['email']     as String?,
      licenseNo: d['licenseNo'] as String?,
      ntn:       d['ntn']       as String?,
    );
  }

  Map<String, dynamic> toFirestore({bool isNew = false}) => {
    'name': name, 'address': address, 'phone': phone,
    'isMain': isMain, 'isActive': isActive,
    if (email != null) 'email': email,
    if (licenseNo != null) 'licenseNo': licenseNo,
    if (ntn != null) 'ntn': ntn,
    if (isNew) 'createdAt': FieldValue.serverTimestamp()
    else 'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}