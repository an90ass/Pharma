import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/medicine_search_result.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_datasource.dart';

class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl(this._remote);
  final SalesRemoteDataSource _remote;

  Either<Failure, T> _handle<T>(Object e) {
    if (e is ServerException)           return Left(ServerFailure(e.message));
    if (e is NetworkException)          return const Left(NetworkFailure());
    if (e is NotFoundException)         return const Left(NotFoundFailure());
    if (e is InsufficientStockException)
      return Left(InsufficientStockFailure(e.medicineName));
    return Left(UnexpectedFailure(e.toString()));
  }

  @override
  Future<Either<Failure, List<MedicineSearchResult>>> searchMedicines(
      String query) async {
    try { return Right(await _remote.searchMedicines(query)); }
    catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, MedicineSearchResult>> getMedicineByBarcode(
      String barcode) async {
    try { return Right(await _remote.getMedicineByBarcode(barcode)); }
    catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, InvoiceEntity>> createInvoice({
    required CartEntity cart,
    required List<PaymentEntry> payments,
    required String soldBy,
    String? branchId,
  }) async {
    try {
      return Right(await _remote.createInvoice(
        cart: cart, payments: payments,
        soldBy: soldBy, branchId: branchId,
      ));
    } catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, List<InvoiceSummary>>> getInvoiceSummaries({
    DateTime? from, DateTime? to, int limit = 30, String? lastInvoiceId,
  }) async {
    try {
      return Right(await _remote.getInvoiceSummaries(
        from: from, to: to, limit: limit, lastInvoiceId: lastInvoiceId,
      ));
    } catch (e) { return _handle(e); }
  }

  @override
  Stream<Either<Failure, List<InvoiceSummary>>> watchTodayInvoices() =>
      _remote.watchTodayInvoices()
          .map<Either<Failure, List<InvoiceSummary>>>(Right.new)
          .handleError((e) => _handle<List<InvoiceSummary>>(e));

  @override
  Future<Either<Failure, InvoiceEntity>> getInvoiceById(String id) async {
    try { return Right(await _remote.getInvoiceById(id)); }
    catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, List<InvoiceSummary>>> searchInvoices(
      String query) async {
    try { return Right(await _remote.searchInvoices(query)); }
    catch (e) { return _handle(e); }
  }

  @override
  Future<Either<Failure, InvoiceEntity>> returnInvoice({
    required String invoiceId,
    required String processedBy,
    String? reason,
  }) async {
    try {
      return Right(await _remote.returnInvoice(
        invoiceId: invoiceId,
        processedBy: processedBy,
        reason: reason,
      ));
    } catch (e) { return _handle(e); }
  }
}