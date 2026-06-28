import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_entity.dart';
import '../entities/invoice_entity.dart';
import '../entities/medicine_search_result.dart';

/// Abstract contract for all sales operations.
abstract class SalesRepository {

  // ── Medicine search (POS) ──────────────────────────────────────────────
  /// Searches medicines by name, generic, or barcode.
  /// Returns results with available batch info for FIFO cart assignment.
  Future<Either<Failure, List<MedicineSearchResult>>> searchMedicines(
      String query);

  /// Fetch a single medicine by barcode for instant scan-to-cart.
  Future<Either<Failure, MedicineSearchResult>> getMedicineByBarcode(
      String barcode);

  // ── Invoice creation ───────────────────────────────────────────────────
  /// Persists the invoice, deducts stock from batches, credits loyalty.
  /// Runs as a Firestore batch/transaction for atomicity.
  Future<Either<Failure, InvoiceEntity>> createInvoice({
    required CartEntity cart,
    required List<PaymentEntry> payments,
    required String soldBy,
    String? branchId,
  });

  // ── Sales history ──────────────────────────────────────────────────────
  /// Paginated invoice summaries, newest first.
  Future<Either<Failure, List<InvoiceSummary>>> getInvoiceSummaries({
    DateTime? from,
    DateTime? to,
    int limit = 30,
    String? lastInvoiceId,    // for pagination
  });

  /// Realtime stream for today's invoices — used in dashboard/POS.
  Stream<Either<Failure, List<InvoiceSummary>>> watchTodayInvoices();

  /// Full invoice with all items and payment details.
  Future<Either<Failure, InvoiceEntity>> getInvoiceById(String id);

  /// Search invoices by customer phone or invoice number.
  Future<Either<Failure, List<InvoiceSummary>>> searchInvoices(String query);

  // ── Returns ────────────────────────────────────────────────────────────
  Future<Either<Failure, InvoiceEntity>> returnInvoice({
    required String invoiceId,
    required String processedBy,
    String? reason,
  });
}