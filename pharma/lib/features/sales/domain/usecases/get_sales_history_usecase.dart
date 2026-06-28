import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice_entity.dart';
import '../repositories/sales_repository.dart';

/// Paginated sales history with optional date filter.
class GetSalesHistoryUseCase
    implements UseCase<List<InvoiceSummary>, SalesHistoryParams> {
  const GetSalesHistoryUseCase(this._repo);
  final SalesRepository _repo;

  @override
  Future<Either<Failure, List<InvoiceSummary>>> call(
      SalesHistoryParams p) {
    return _repo.getInvoiceSummaries(
      from: p.from,
      to: p.to,
      limit: p.limit,
      lastInvoiceId: p.lastInvoiceId,
    );
  }
}

class SalesHistoryParams extends Equatable {
  const SalesHistoryParams({
    this.from,
    this.to,
    this.limit = 30,
    this.lastInvoiceId,
  });
  final DateTime? from;
  final DateTime? to;
  final int limit;
  final String? lastInvoiceId;
  @override
  List<Object?> get props => [from, to, limit, lastInvoiceId];
}

/// Full invoice detail by ID.
class GetInvoiceByIdUseCase
    implements UseCase<InvoiceEntity, InvoiceIdParams> {
  const GetInvoiceByIdUseCase(this._repo);
  final SalesRepository _repo;

  @override
  Future<Either<Failure, InvoiceEntity>> call(InvoiceIdParams p) {
    if (p.id.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('Invoice ID required.')));
    }
    return _repo.getInvoiceById(p.id);
  }
}

/// Search invoices by customer phone or invoice number.
class SearchInvoicesUseCase
    implements UseCase<List<InvoiceSummary>, SearchInvoiceParams> {
  const SearchInvoicesUseCase(this._repo);
  final SalesRepository _repo;

  @override
  Future<Either<Failure, List<InvoiceSummary>>> call(
      SearchInvoiceParams p) {
    final q = p.query.trim();
    if (q.isEmpty) return Future.value(const Right([]));
    return _repo.searchInvoices(q);
  }
}

class InvoiceIdParams extends Equatable {
  const InvoiceIdParams(this.id);
  final String id;
  @override List<Object> get props => [id];
}

class SearchInvoiceParams extends Equatable {
  const SearchInvoiceParams(this.query);
  final String query;
  @override List<Object> get props => [query];
}