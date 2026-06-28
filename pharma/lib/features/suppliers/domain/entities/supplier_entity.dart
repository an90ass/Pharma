import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  const SupplierEntity({
    required this.id, required this.name, required this.phone,
    required this.createdAt,
    this.email, this.address, this.ntn, this.contactPerson,
    this.totalOrders = 0, this.totalAmount = 0, this.isActive = true,
  });
  final String id, name, phone;
  final DateTime createdAt;
  final String? email, address, ntn, contactPerson;
  final int totalOrders;
  final double totalAmount;
  final bool isActive;

  SupplierEntity copyWith({
    String? name, String? phone, String? email, String? address,
    String? ntn, String? contactPerson, bool? isActive,
  }) => SupplierEntity(
    id: id, name: name ?? this.name, phone: phone ?? this.phone,
    createdAt: createdAt, email: email ?? this.email,
    address: address ?? this.address, ntn: ntn ?? this.ntn,
    contactPerson: contactPerson ?? this.contactPerson,
    totalOrders: totalOrders, totalAmount: totalAmount,
    isActive: isActive ?? this.isActive,
  );

  @override List<Object?> get props => [id, name, phone];
}