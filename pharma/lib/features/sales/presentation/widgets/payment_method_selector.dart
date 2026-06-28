import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/invoice_entity.dart';

class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({
    super.key,
    required this.grandTotal,
    required this.selectedPayments,
    required this.onPaymentChanged,
  });
  final double grandTotal;
  final List<PaymentEntry> selectedPayments;
  final void Function(PaymentMethod method, double amount) onPaymentChanged;

  @override
  State<PaymentMethodSelector> createState() =>
      _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  final Map<PaymentMethod, TextEditingController> _ctrls = {};

  @override
  void initState() {
    super.initState();
    for (final m in PaymentMethod.values) {
      final existing = widget.selectedPayments
          .firstWhere((p) => p.method == m,
              orElse: () => PaymentEntry(method: m, amount: 0))
          .amount;
      _ctrls[m] = TextEditingController(
          text: existing > 0 ? existing.toStringAsFixed(0) : '');
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPaid = widget.selectedPayments
        .fold(0.0, (s, p) => s + p.amount);
    final change = totalPaid - widget.grandTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick fill button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            TextButton(
              onPressed: () {
                _ctrls[PaymentMethod.cash]?.text =
                    widget.grandTotal.toStringAsFixed(0);
                widget.onPaymentChanged(
                    PaymentMethod.cash, widget.grandTotal);
              },
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1565C0),
                  padding: EdgeInsets.zero),
              child: const Text('Exact cash', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Method rows
        ...PaymentMethod.values.map((method) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _MethodIcon(method: method),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    child: Text(method.label,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrls[method],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'))
                      ],
                      onChanged: (v) {
                        final amt = double.tryParse(v) ?? 0;
                        widget.onPaymentChanged(method, amt);
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: Color(0xFFCCCCCC)),
                        prefixText: '\$ ',
                        prefixStyle: const TextStyle(
                            fontSize: 13, color: Color(0xFF888888)),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE0E0E0))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8E8E8))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF1565C0), width: 1.5)),
                      ),
                    ),
                  ),
                ],
              ),
            )),

        const SizedBox(height: 8),
        const Divider(),
        // Totals
        _TotalRow(
            label: 'Total paid',
            value: totalPaid,
            bold: false,
            color: const Color(0xFF1565C0)),
        const SizedBox(height: 4),
        _TotalRow(
            label: change >= 0 ? 'Change' : 'Remaining',
            value: change.abs(),
            bold: true,
            color: change >= 0
                ? const Color(0xFF2E7D32)
                : const Color(0xFFE53935)),
      ],
    );
  }
}

class _MethodIcon extends StatelessWidget {
  const _MethodIcon({required this.method});
  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final icon = switch (method) {
      PaymentMethod.cash         => Icons.money_rounded,
      PaymentMethod.card         => Icons.credit_card_rounded,
      PaymentMethod.jazzCash     => Icons.phone_android_rounded,
      PaymentMethod.easypaisa    => Icons.phone_android_rounded,
      PaymentMethod.bankTransfer => Icons.account_balance_rounded,
      PaymentMethod.storeCredit  => Icons.store_rounded,
    };
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF1565C0)),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(
      {required this.label,
      required this.value,
      required this.bold,
      required this.color});
  final String label;
  final double value;
  final bool bold;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF555555),
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(
          '\$ ${value.toStringAsFixed(0)}',
          style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color),
        ),
      ],
    );
  }
}