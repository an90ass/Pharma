import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/usecases/get_sales_history_usecase.dart';
import '../providers/sales_providers.dart';
import '../viewmodels/sales_history_viewmodel.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
    this.fromCheckout = false,
  });
  final String invoiceId;
  final bool fromCheckout;

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState
    extends ConsumerState<InvoiceDetailScreen> {
  InvoiceEntity? _invoice;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    setState(() { _loading = true; _error = null; });
    final uc     = ref.read(getInvoiceByIdUseCaseProvider);
    final result = await uc(InvoiceIdParams(widget.invoiceId));
    result.fold(
      (f) => setState(() { _error = f.message; _loading = false; }),
      (inv) => setState(() { _invoice = inv; _loading = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.fromCheckout
            ? IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
              )
            : const BackButton(),
        title: Text(
          _invoice?.invoiceNo ?? 'Invoice',
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded,
                color: Color(0xFF1565C0)),
            tooltip: 'Print receipt',
            onPressed: _invoice == null ? null : _printReceipt,
          ),
          if (_invoice?.status == InvoiceStatus.paid)
            IconButton(
              icon: const Icon(Icons.undo_rounded,
                  color: Color(0xFFE53935)),
              tooltip: 'Return invoice',
              onPressed: () => _confirmReturn(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _loadInvoice)
              : _InvoiceBody(invoice: _invoice!),
    );
  }

  void _printReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sending to printer…'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmReturn(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Return invoice?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text(
          'This will mark the invoice as returned. '
          'Stock will need to be manually adjusted.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(salesHistoryViewModelProvider.notifier)
                  .returnInvoice(
                    widget.invoiceId, 'current_user_id')
                  .then((ok) {
                if (ok) _loadInvoice();
              });
            },
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }
}

class _InvoiceBody extends StatelessWidget {
  const _InvoiceBody({required this.invoice});
  final InvoiceEntity invoice;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);
    final statusColor = switch (invoice.status) {
      InvoiceStatus.paid     => const Color(0xFF2E7D32),
      InvoiceStatus.credit   => const Color(0xFFFF9800),
      InvoiceStatus.returned => const Color(0xFFE53935),
      InvoiceStatus.void_    => const Color(0xFF9E9E9E),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Success banner (from checkout) ────────────────────────────
        _SuccessBanner(invoice: invoice, fmt: fmt,
            statusColor: statusColor),
        const SizedBox(height: 16),

        // ── Customer & meta ───────────────────────────────────────────
        _InfoCard(children: [
          _MetaRow('Invoice no', invoice.invoiceNo),
          _MetaRow('Date',
              DateFormat('d MMM yyyy · h:mm a').format(invoice.createdAt)),
          _MetaRow('Customer',
              invoice.customerName ?? 'Walk-in customer'),
          if (invoice.customerPhone != null)
            _MetaRow('Phone', invoice.customerPhone!),
          if (invoice.prescriptionId != null)
            _MetaRow('Rx ID', invoice.prescriptionId!),
          _MetaRow('Status', invoice.status.label,
              valueColor: statusColor),
        ]),
        const SizedBox(height: 12),

        // ── Items ─────────────────────────────────────────────────────
        _SectionLabel('Items (${invoice.items.length})'),
        const SizedBox(height: 8),
        _InfoCard(
          children: invoice.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.tradeName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(
                            '${item.genericName} · Batch ${item.batchNo}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF888888)),
                          ),
                          Text(
                            'Exp: ${DateFormat('MMM yyyy').format(item.expiryDate)}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFBBBBBB)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${fmt.format(item.unitPrice)} × ${item.qty}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF888888)),
                        ),
                        Text(
                          fmt.format(item.lineTotal),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1565C0)),
                        ),
                      ],
                    ),
                  ],
                ),
                if (item.discountPct > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Discount: ${item.discountPct.toStringAsFixed(0)}%  '
                      '(- ${fmt.format(item.discountAmount)})',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2E7D32)),
                    ),
                  ),
                if (invoice.items.last != item)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Divider(height: 1),
                  ),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),

        // ── Payment breakdown ─────────────────────────────────────────
        _SectionLabel('Payment'),
        const SizedBox(height: 8),
        _InfoCard(children: [
          _MetaRow('Subtotal', fmt.format(invoice.subtotal)),
          if (invoice.totalDiscount > 0)
            _MetaRow('Discount',
                '- ${fmt.format(invoice.totalDiscount)}',
                valueColor: const Color(0xFF2E7D32)),
          if (invoice.totalTax > 0)
            _MetaRow('Tax', '+ ${fmt.format(invoice.totalTax)}'),
          const Divider(height: 16),
          _MetaRow('Grand total', fmt.format(invoice.grandTotal),
              bold: true, valueColor: const Color(0xFF1565C0)),
          const SizedBox(height: 8),
          ...invoice.payments.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _MetaRow(p.method.label, fmt.format(p.amount)),
              )),
          if (invoice.changeAmount > 0)
            _MetaRow('Change returned',
                fmt.format(invoice.changeAmount),
                valueColor: const Color(0xFF2E7D32)),
          if (invoice.loyaltyPointsEarned > 0)
            _MetaRow('Loyalty earned',
                '${invoice.loyaltyPointsEarned} pts',
                valueColor: const Color(0xFF7B1FA2)),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner(
      {required this.invoice,
      required this.fmt,
      required this.statusColor});
  final InvoiceEntity invoice;
  final NumberFormat fmt;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 36),
          const SizedBox(height: 8),
          Text(
            invoice.status == InvoiceStatus.paid
                ? 'Sale Complete!'
                : invoice.status.label,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            fmt.format(invoice.grandTotal),
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            '${invoice.items.length} item${invoice.items.length != 1 ? 's' : ''} · '
            '${invoice.customerName ?? 'Walk-in'}',
            style: const TextStyle(
                fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.black.withOpacity(0.06), width: 0.8),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E)));
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.label, this.value,
      {this.bold = false,
      this.valueColor = const Color(0xFF1A1A2E)});
  final String label;
  final String value;
  final bool bold;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF888888))),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: valueColor)),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 40, color: Color(0xFFE53935)),
              const SizedBox(height: 12),
              Text(error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF888888))),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0)),
              ),
            ],
          ),
        ),
      );
}