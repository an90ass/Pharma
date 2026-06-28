import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_entity.dart';
import '../entities/invoice_entity.dart';
import '../repositories/sales_repository.dart';

/// Validates cart and persists the invoice + deducts stock atomically.
class CreateInvoiceUseCase
    implements UseCase<InvoiceEntity, CreateInvoiceParams> {
  const CreateInvoiceUseCase(this._repo);
  final SalesRepository _repo;

  @override
  Future<Either<Failure, InvoiceEntity>> call(
      CreateInvoiceParams p) async {
    // ── Domain validation ──────────────────────────────────────────────
    if (p.cart.isEmpty) {
      return const Left(ValidationFailure('Cart is empty.'));
    }
    if (p.payments.isEmpty) {
      return const Left(ValidationFailure('At least one payment method is required.'));
    }
    final totalPaid = p.payments.fold(0.0, (s, e) => s + e.amount);
    if (totalPaid < p.cart.grandTotal - 0.01) {
      return Left(ValidationFailure(
          'Payment amount (Rs ${totalPaid.toStringAsFixed(0)}) '
          'is less than total (Rs ${p.cart.grandTotal.toStringAsFixed(0)}).'));
    }
    if (p.soldBy.trim().isEmpty) {
      return const Left(ValidationFailure('Sold-by user ID is required.'));
    }
    // Controlled drug check
    for (final item in p.cart.items) {
      if (p.requirePrescriptionForControlled &&
          p.cart.prescriptionId == null) {
        return Left(ValidationFailure(
            'Prescription required for controlled drug: ${item.tradeName}.'));
      }
    }
    return _repo.createInvoice(
      cart: p.cart,
      payments: p.payments,
      soldBy: p.soldBy,
      branchId: p.branchId,
    );
  }
}

class CreateInvoiceParams extends Equatable {
  const CreateInvoiceParams({
    required this.cart,
    required this.payments,
    required this.soldBy,
    this.branchId,
    this.requirePrescriptionForControlled = false,
  });

  final CartEntity cart;
  final List<PaymentEntry> payments;
  final String soldBy;
  final String? branchId;
  final bool requirePrescriptionForControlled;

  @override
  List<Object?> get props => [cart, payments, soldBy];
}