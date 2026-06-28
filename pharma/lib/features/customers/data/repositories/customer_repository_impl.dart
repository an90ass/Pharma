import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl(this._ds);
  final CustomerRemoteDataSource _ds;

  Either<Failure, T> _h<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    return Left(UnexpectedFailure(e.toString()));
  }

  CustomerModel _m(CustomerEntity e) => CustomerModel(
      id: e.id, name: e.name, phone: e.phone, createdAt: e.createdAt,
      email: e.email, address: e.address, cnic: e.cnic,
      loyaltyPoints: e.loyaltyPoints, totalPurchases: e.totalPurchases,
      isActive: e.isActive);

  @override Future<Either<Failure, List<CustomerEntity>>> getCustomers({String? search}) async {
    try { return Right(await _ds.getCustomers(search: search)); } catch (e) { return _h(e); }
  }
  @override Stream<Either<Failure, List<CustomerEntity>>> watchCustomers() =>
      _ds.watchCustomers()
         .map<Either<Failure, List<CustomerEntity>>>(Right.new)
         .handleError((e) => _h<List<CustomerEntity>>(e));
  @override Future<Either<Failure, CustomerEntity>> addCustomer(CustomerEntity c) async {
    try { return Right(await _ds.addCustomer(_m(c))); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, CustomerEntity>> updateCustomer(CustomerEntity c) async {
    try { return Right(await _ds.updateCustomer(_m(c))); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> deleteCustomer(String id) async {
    try { await _ds.deleteCustomer(id); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, CustomerEntity?>> getCustomerByPhone(String phone) async {
    try { return Right(await _ds.getCustomerByPhone(phone)); } catch (e) { return _h(e); }
  }
}