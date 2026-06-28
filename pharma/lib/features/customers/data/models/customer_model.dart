import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id, required super.name, required super.phone,
    required super.createdAt, super.email, super.address, super.cnic,
    super.loyaltyPoints, super.totalPurchases, super.isActive,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id:             doc.id,
      name:           d['name']           as String? ?? '',
      phone:          d['phone']          as String? ?? '',
      createdAt:      (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      email:          d['email']          as String?,
      address:        d['address']        as String?,
      cnic:           d['cnic']           as String?,
      loyaltyPoints:  (d['loyaltyPoints'] as num?)?.toInt()    ?? 0,
      totalPurchases: (d['totalPurchases'] as num?)?.toDouble() ?? 0,
      isActive:       d['isActive']       as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore({bool isNew = false}) => {
    'name': name, 'phone': phone, 'email': email,
    'address': address, 'cnic': cnic,
    'loyaltyPoints': loyaltyPoints, 'totalPurchases': totalPurchases,
    'isActive': isActive,
    if (isNew) 'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    // Search tokens for partial text search
    'searchTokens': _tokens(name) + _tokens(phone),
  };

  static List<String> _tokens(String s) {
    final tokens = <String>[];
    s = s.toLowerCase();
    for (int i = 1; i <= s.length; i++) tokens.add(s.substring(0, i));
    return tokens;
  }
}