import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase implements UseCase<List<CustomerEntity>, GetCustomersParams> {
  const GetCustomersUseCase(this._repo);
  final CustomerRepository _repo;
  @override
  Future<Either<Failure, List<CustomerEntity>>> call(GetCustomersParams p) =>
      _repo.getCustomers(search: p.search);
}

class AddCustomerUseCase implements UseCase<CustomerEntity, CustomerParams> {
  const AddCustomerUseCase(this._repo);
  final CustomerRepository _repo;
  @override
  Future<Either<Failure, CustomerEntity>> call(CustomerParams p) async {
    if (p.name.trim().isEmpty)
      return const Left(ValidationFailure('Name is required.'));
    if (p.phone.trim().isEmpty)
      return const Left(ValidationFailure('Phone is required.'));
    final c = CustomerEntity(id: '', name: p.name.trim(),
        phone: p.phone.trim(), email: p.email, address: p.address,
        cnic: p.cnic, createdAt: DateTime.now());
    return _repo.addCustomer(c);
  }
}

class UpdateCustomerUseCase implements UseCase<CustomerEntity, CustomerEntity> {
  const UpdateCustomerUseCase(this._repo);
  final CustomerRepository _repo;
  @override
  Future<Either<Failure, CustomerEntity>> call(CustomerEntity c) =>
      _repo.updateCustomer(c);
}

class DeleteCustomerUseCase implements UseCase<void, String> {
  const DeleteCustomerUseCase(this._repo);
  final CustomerRepository _repo;
  @override
  Future<Either<Failure, void>> call(String id) => _repo.deleteCustomer(id);
}

class SearchCustomerByPhoneUseCase
    implements UseCase<CustomerEntity?, String> {
  const SearchCustomerByPhoneUseCase(this._repo);
  final CustomerRepository _repo;
  @override
  Future<Either<Failure, CustomerEntity?>> call(String phone) =>
      _repo.getCustomerByPhone(phone);
}

class GetCustomersParams extends Equatable {
  const GetCustomersParams({this.search});
  final String? search;
  @override List<Object?> get props => [search];
}

class CustomerParams extends Equatable {
  const CustomerParams({required this.name, required this.phone,
      this.email, this.address, this.cnic});
  final String name, phone;
  final String? email, address, cnic;
  @override List<Object?> get props => [name, phone];
}
class WatchCustomersUseCase {
  const WatchCustomersUseCase(this._repo);
  final CustomerRepository _repo;


  Stream<Either<Failure, List<CustomerEntity>>> call() =>
      _repo.watchCustomers();
}