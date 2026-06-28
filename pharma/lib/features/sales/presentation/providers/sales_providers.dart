import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/sales_remote_datasource.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/usecases/create_invoice_usecase.dart';
import '../../domain/usecases/get_sales_history_usecase.dart';
import '../../domain/usecases/process_sale_usecase.dart';
import '../../domain/usecases/search_medicine_usecase.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final salesRemoteDataSourceProvider =
    Provider<SalesRemoteDataSource>((ref) =>
        SalesRemoteDataSourceImpl(ref.read(firestoreProvider)));

final salesRepositoryProvider = Provider<SalesRepository>((ref) =>
    SalesRepositoryImpl(ref.read(salesRemoteDataSourceProvider)));

final searchMedicineUseCaseProvider =
    Provider<SearchMedicineUseCase>((ref) =>
        SearchMedicineUseCase(ref.read(salesRepositoryProvider)));

final getMedicineByBarcodeUseCaseProvider =
    Provider<GetMedicineByBarcodeUseCase>((ref) =>
        GetMedicineByBarcodeUseCase(ref.read(salesRepositoryProvider)));

final createInvoiceUseCaseProvider =
    Provider<CreateInvoiceUseCase>((ref) =>
        CreateInvoiceUseCase(ref.read(salesRepositoryProvider)));

final processSaleUseCaseProvider =
    Provider<ProcessSaleUseCase>((ref) =>
        ProcessSaleUseCase(ref.read(salesRepositoryProvider)));

final returnInvoiceUseCaseProvider =
    Provider<ReturnInvoiceUseCase>((ref) =>
        ReturnInvoiceUseCase(ref.read(salesRepositoryProvider)));

final getSalesHistoryUseCaseProvider =
    Provider<GetSalesHistoryUseCase>((ref) =>
        GetSalesHistoryUseCase(ref.read(salesRepositoryProvider)));

final getInvoiceByIdUseCaseProvider =
    Provider<GetInvoiceByIdUseCase>((ref) =>
        GetInvoiceByIdUseCase(ref.read(salesRepositoryProvider)));

final searchInvoicesUseCaseProvider =
    Provider<SearchInvoicesUseCase>((ref) =>
        SearchInvoicesUseCase(ref.read(salesRepositoryProvider)));