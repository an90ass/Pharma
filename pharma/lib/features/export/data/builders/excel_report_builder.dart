import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

/// Builds .xlsx files from report data.
class ExcelReportBuilder {
  final _fmt = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);

  // ── Sales report ─────────────────────────────────────────────────────────
  Uint8List buildSalesReport(dynamic report) {
    final excel = Excel.createExcel();
    final sheet = excel['Sales Report'];

    // Header row
    _headerRow(sheet, ['Date/Period', 'Revenue (Rs)', 'Invoices', 'Profit (Rs)']);

    // Data rows
    for (final dp in report.dailyBreakdown) {
      sheet.appendRow([
        TextCellValue(dp.label),
        DoubleCellValue(dp.revenue),
        IntCellValue(dp.invoiceCount),
        DoubleCellValue(dp.profit),
      ]);
    }

    // Summary row
    sheet.appendRow([]);
    sheet.appendRow([
      TextCellValue('TOTAL'),
      DoubleCellValue(report.totalRevenue),
      IntCellValue(report.totalInvoices),
      DoubleCellValue(report.grossProfit),
    ]);

    // Summary sheet
    final sum = excel['Summary'];
    _headerRow(sum, ['Metric', 'Value']);
    sum.appendRow([TextCellValue('Total revenue'),   TextCellValue(_fmt.format(report.totalRevenue))]);
    sum.appendRow([TextCellValue('Gross profit'),    TextCellValue(_fmt.format(report.grossProfit))]);
    sum.appendRow([TextCellValue('Profit margin'),   TextCellValue('${report.profitMarginPct.toStringAsFixed(1)}%')]);
    sum.appendRow([TextCellValue('Total invoices'),  TextCellValue('${report.totalInvoices}')]);
    sum.appendRow([TextCellValue('Total items sold'),TextCellValue('${report.totalItemsSold}')]);
    sum.appendRow([TextCellValue('Total discount'),  TextCellValue(_fmt.format(report.totalDiscount))]);

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  // ── Top medicines ─────────────────────────────────────────────────────────
  Uint8List buildTopMedicines(List<dynamic> medicines) {
    final excel = Excel.createExcel();
    final sheet = excel['Top Medicines'];

    _headerRow(sheet, [
      'Rank', 'Trade name', 'Generic name', 'Category',
      'Qty sold', 'Revenue (Rs)', 'Profit (Rs)', 'Margin %',
    ]);

    for (final m in medicines) {
      sheet.appendRow([
        IntCellValue(m.rank),
        TextCellValue(m.tradeName),
        TextCellValue(m.genericName),
        TextCellValue(m.category),
        IntCellValue(m.totalQtySold),
        DoubleCellValue(m.totalRevenue),
        DoubleCellValue(m.totalProfit),
        DoubleCellValue(m.profitMargin),
      ]);
    }

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  // ── Inventory report ──────────────────────────────────────────────────────
  Uint8List buildInventoryReport(dynamic report) {
    final excel = Excel.createExcel();

    // Low stock sheet
    final ls = excel['Low Stock'];
    _headerRow(ls, ['Medicine', 'Current qty', 'Reorder level', 'Reorder qty']);
    for (final item in report.lowStockItems) {
      ls.appendRow([
        TextCellValue(item.tradeName),
        IntCellValue(item.currentQty),
        IntCellValue(item.reorderLevel),
        IntCellValue(item.reorderQty),
      ]);
    }

    // Expiring sheet
    final exp = excel['Expiring Soon'];
    _headerRow(exp, ['Medicine', 'Batch', 'Qty', 'Expiry date', 'Days left', 'Stock value']);
    for (final item in report.expiringItems) {
      exp.appendRow([
        TextCellValue(item.tradeName),
        TextCellValue(item.batchNo),
        IntCellValue(item.qtyAvailable),
        TextCellValue(DateFormat('d MMM yyyy').format(item.expiryDate)),
        IntCellValue(item.daysLeft),
        DoubleCellValue(item.stockValue),
      ]);
    }

    excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  void _headerRow(Sheet sheet, List<String> headers) {
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
  }
}

// ignore: avoid_classes_with_only_static_members
class DateFormat {
  DateFormat(this.pattern);
  final String pattern;
  String format(DateTime date) {
    // Simple formatting — replace with intl.DateFormat in your project
    return '${date.day}/${date.month}/${date.year}';
  }
}