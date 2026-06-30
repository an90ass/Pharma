import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  const StoreEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isMain,
    required this.isActive,
    required this.createdAt,
    this.email,
    this.licenseNo,
    this.ntn,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isMain;
  final bool isActive;
  final DateTime createdAt;
  final String? email;
  final String? licenseNo;
  final String? ntn;

  StoreEntity copyWith({
    String? name, String? address, String? phone,
    bool? isMain, bool? isActive,
    String? email, String? licenseNo, String? ntn,
  }) =>
      StoreEntity(
        id: id, name: name ?? this.name,
        address: address ?? this.address, phone: phone ?? this.phone,
        isMain: isMain ?? this.isMain, isActive: isActive ?? this.isActive,
        createdAt: createdAt, email: email ?? this.email,
        licenseNo: licenseNo ?? this.licenseNo, ntn: ntn ?? this.ntn,
      );

  @override
  List<Object?> get props => [id, name, isMain, isActive];
}