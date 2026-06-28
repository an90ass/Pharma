import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_entity.dart';
import '../entities/invoice_entity.dart';
import '../entities/medicine_search_result.dart';
import '../repositories/sales_repository.dart';

/// Orchestrates the full POS sale:
/// 1. Validates stock availability for every cart item
/// 2. Calls CreateInvoice to persist + deduct stock
///
/// This is the primary use case called on "Checkout" button press.
class ProcessSaleUseCase
    implements UseCase<InvoiceEntity, ProcessSaleParams> {
  const ProcessSaleUseCase(this._repo);
  final SalesRepository _repo;

  @override
  Future<Either<Failure, InvoiceEntity>> call(
      ProcessSaleParams p) async {
    if (p.cart.isEmpty) {
      return const Left(ValidationFailure('Cannot process an empty cart.'));
    }
    if (p.payments.isEmpty) {
      return const Left(
          ValidationFailure('Select at least one payment method.'));
    }

    // Stock availability check before hitting Firestore
    for (final item in p.cart.items) {
      if (item.qty <= 0) {
        return Left(ValidationFailure(
            'Quantity for ${item.tradeName} must be at least 1.'));
      }
    }

    final totalPaid = p.payments.fold(0.0, (s, e) => s + e.amount);
    if (totalPaid < p.cart.grandTotal - 0.01) {
      return Left(ValidationFailure(
          'Insufficient payment. '
          'Due: \$ ${p.cart.grandTotal.toStringAsFixed(0)}, '
          'Paid: \$ ${totalPaid.toStringAsFixed(0)}.'));
    }

    return _repo.createInvoice(
      cart: p.cart,
      payments: p.payments,
      soldBy: p.soldBy,
      branchId: p.branchId,
    );
  }
}

class ProcessSaleParams extends Equatable {
  const ProcessSaleParams({
    required this.cart,
    required this.payments,
    required this.soldBy,
    this.branchId,
  });
  final CartEntity cart;
  final List<PaymentEntry> payments;
  final String soldBy;
  final String? branchId;

  @override
  List<Object?> get props => [cart, payments, soldBy];
}

/// Return / refund an existing invoice.
class ReturnInvoiceUseCase
    implements UseCase<InvoiceEntity, ReturnInvoiceParams> {
  const ReturnInvoiceUseCase(this._repo);
  final SalesRepository _repo;

  @override
  Future<Either<Failure, InvoiceEntity>> call(ReturnInvoiceParams p) {
    if (p.invoiceId.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('Invoice ID is required.')));
    }
    return _repo.returnInvoice(
      invoiceId: p.invoiceId,
      processedBy: p.processedBy,
      reason: p.reason,
    );
  }
}

class ReturnInvoiceParams extends Equatable {
  const ReturnInvoiceParams({
    required this.invoiceId,
    required this.processedBy,
    this.reason,
  });
  final String invoiceId;
  final String processedBy;
  final String? reason;
  @override
  List<Object?> get props => [invoiceId, processedBy];
}