import 'package:equatable/equatable.dart';

/// Aggregated sales figures for a given time range.
class SalesReportEntity extends Equatable {
  const SalesReportEntity({
    required this.from,
    required this.to,
    required this.period,
    required this.totalRevenue,
    required this.totalCost,
    required this.grossProfit,
    required this.totalInvoices,
    required this.totalItemsSold,
    required this.totalDiscount,
    required this.totalTax,
    required this.dailyBreakdown,
    required this.paymentBreakdown,
  });

  final DateTime from;
  final DateTime to;
  final ReportPeriod period;
  final double totalRevenue;
  final double totalCost;
  final double grossProfit;
  final int    totalInvoices;
  final int    totalItemsSold;
  final double totalDiscount;
  final double totalTax;

  /// Revenue per day/week/month — used for line/bar chart.
  final List<SalesDataPoint> dailyBreakdown;

  /// Revenue split by payment method — used for pie chart.
  final List<PaymentBreakdown> paymentBreakdown;

  double get profitMarginPct =>
      totalRevenue == 0 ? 0 : (grossProfit / totalRevenue) * 100;

  double get avgInvoiceValue =>
      totalInvoices == 0 ? 0 : totalRevenue / totalInvoices;

  @override
  List<Object?> get props => [from, to, period, totalRevenue];
}

class SalesDataPoint extends Equatable {
  const SalesDataPoint({
    required this.label,
    required this.date,
    required this.revenue,
    required this.invoiceCount,
    this.profit = 0,
  });
  final String   label;        // "Mon", "Jan", "Week 1"
  final DateTime date;
  final double   revenue;
  final int      invoiceCount;
  final double   profit;
  @override List<Object?> get props => [date, revenue];
}

class PaymentBreakdown extends Equatable {
  const PaymentBreakdown({
    required this.method,
    required this.amount,
    required this.percentage,
  });
  final String method;
  final double amount;
  final double percentage;
  @override List<Object?> get props => [method, amount];
}

enum ReportPeriod { daily, weekly, monthly, custom }