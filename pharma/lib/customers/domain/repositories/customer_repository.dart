import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({String? search});
  Stream<Either<Failure, List<CustomerEntity>>> watchCustomers();
  Future<Either<Failure, CustomerEntity>> addCustomer(CustomerEntity c);
  Future<Either<Failure, CustomerEntity>> updateCustomer(CustomerEntity c);
  Future<Either<Failure, void>> deleteCustomer(String id);
  Future<Either<Failure, CustomerEntity?>> getCustomerByPhone(String phone);
}