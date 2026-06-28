import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    this.email,
    this.address,
    this.cnic,
    this.loyaltyPoints = 0,
    this.totalPurchases = 0,
    this.isActive = true,
  });

  final String   id;
  final String   name;
  final String   phone;
  final DateTime createdAt;
  final String?  email;
  final String?  address;
  final String?  cnic;
  final int      loyaltyPoints;
  final double   totalPurchases;
  final bool     isActive;

  CustomerEntity copyWith({
    String? name, String? phone, String? email, String? address,
    String? cnic, int? loyaltyPoints, double? totalPurchases, bool? isActive,
  }) => CustomerEntity(
    id: id, name: name ?? this.name, phone: phone ?? this.phone,
    createdAt: createdAt, email: email ?? this.email,
    address: address ?? this.address, cnic: cnic ?? this.cnic,
    loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    totalPurchases: totalPurchases ?? this.totalPurchases,
    isActive: isActive ?? this.isActive,
  );

  @override List<Object?> get props => [id, name, phone];
}