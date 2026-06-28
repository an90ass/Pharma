import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/customer_datasource.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/usecases/customer_usecases.dart';

/// Single source of truth for firestoreProvider.
final firestoreProvider =
Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final customerDataSourceProvider = Provider(
        (ref) => CustomerRemoteDataSource(ref.read(firestoreProvider)));

final customerRepositoryProvider = Provider<CustomerRepository>(
        (ref) => CustomerRepositoryImpl(ref.read(customerDataSourceProvider)));

final getCustomersUseCaseProvider =
Provider((ref) => GetCustomersUseCase(ref.read(customerRepositoryProvider)));




final addCustomerUseCaseProvider =
Provider((ref) => AddCustomerUseCase(ref.read(customerRepositoryProvider)));

final updateCustomerUseCaseProvider =
Provider((ref) => UpdateCustomerUseCase(ref.read(customerRepositoryProvider)));

final deleteCustomerUseCaseProvider =
Provider((ref) => DeleteCustomerUseCase(ref.read(customerRepositoryProvider)));

final searchCustomerByPhoneProvider =
Provider((ref) => SearchCustomerByPhoneUseCase(
    ref.read(customerRepositoryProvider)));


    final watchCustomersUseCaseProvider = Provider(
  (ref) => WatchCustomersUseCase(ref.read(customerRepositoryProvider)),
);


