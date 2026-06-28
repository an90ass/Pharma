import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/inventory_report_entity.dart';
import '../../domain/entities/profit_report_entity.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/entities/top_medicine_entity.dart';

abstract class ReportsRemoteDataSource {
  Future<SalesReportEntity> getSalesReport(DateTime from, DateTime to,
      ReportPeriod period);
  Future<List<TopMedicineEntity>> getTopSellingMedicines(
      DateTime from, DateTime to, int limit);
  Future<ProfitReportEntity> getProfitReport(DateTime from, DateTime to);
  Future<InventoryReportEntity> getInventoryReport();
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  const ReportsRemoteDataSourceImpl(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> get _invoices =>
      _fs.collection('invoices');
  CollectionReference<Map<String, dynamic>> get _medicines =>
      _fs.collection('medicines');
  CollectionReference<Map<String, dynamic>> get _batches =>
      _fs.collection('batches');

  // ── SALES REPORT ─────────────────────────────────────────────────────────

  @override
  Future<SalesReportEntity> getSalesReport(
      DateTime from, DateTime to, ReportPeriod period) async {
    try {
      final snap = await _invoices
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(to))
          .where('status', whereIn: ['paid', 'credit'])
          .orderBy('createdAt')
          .get();

      double totalRevenue  = 0;
      double totalCost     = 0;
      double totalDiscount = 0;
      double totalTax      = 0;
      int    totalItems    = 0;

      // Payment method totals
      final Map<String, double> paymentTotals = {};

      // Daily buckets for chart
      final Map<String, _DayBucket> dayBuckets = {};

      for (final doc in snap.docs) {
        final d = doc.data();
        final revenue  = (d['grandTotal']          as num?)?.toDouble() ?? 0;
        final discount = (d['itemDiscountAmount']   as num?)?.toDouble() ?? 0
            + ((d['globalDiscountAmount'] as num?)?.toDouble() ?? 0);
        final tax      = (d['totalTax']             as num?)?.toDouble() ?? 0;
        final items    = (d['items'] as List<dynamic>?)?.length ?? 0;
        final dateTs   = d['createdAt'] as Timestamp?;
        final date     = dateTs?.toDate() ?? DateTime.now();

        totalRevenue  += revenue;
        totalDiscount += discount;
        totalTax      += tax;
        totalItems    += items;

        // Cost from invoice items (purchasePrice × qty denormalized)
        final rawItems = d['items'] as List<dynamic>? ?? [];
        for (final item in rawItems) {
          final m = item as Map<String, dynamic>;
          // purchasePrice may not be on invoice; default to 70% of unit price
          final purchase = (m['purchasePrice'] as num?)?.toDouble()
              ?? ((m['unitPrice'] as num?)?.toDouble() ?? 0) * 0.70;
          final qty = (m['qty'] as num?)?.toInt() ?? 0;
          totalCost += purchase * qty;
        }

        // Payment breakdown
        final payments = d['payments'] as List<dynamic>? ?? [];
        for (final p in payments) {
          final pm  = p as Map<String, dynamic>;
          final m   = pm['method'] as String? ?? 'cash';
          final amt = (pm['amount'] as num?)?.toDouble() ?? 0;
          paymentTotals[m] = (paymentTotals[m] ?? 0) + amt;
        }

        // Daily bucket
        final label = _bucketLabel(date, period);
        dayBuckets[label] ??= _DayBucket(label: label, date: date);
        dayBuckets[label]!.revenue += revenue;
        dayBuckets[label]!.count  += 1;
      }

      final sortedBuckets = dayBuckets.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final dailyBreakdown = sortedBuckets
          .map((b) => SalesDataPoint(
                label:        b.label,
                date:         b.date,
                revenue:      b.revenue,
                invoiceCount: b.count,
              ))
          .toList();

      final payTotal = paymentTotals.values.fold(0.0, (s, v) => s + v);
      final payBreakdown = paymentTotals.entries
          .map((e) => PaymentBreakdown(
                method:     e.key,
                amount:     e.value,
                percentage: payTotal == 0 ? 0 : (e.value / payTotal) * 100,
              ))
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      return SalesReportEntity(
        from:             from,
        to:               to,
        period:           period,
        totalRevenue:     totalRevenue,
        totalCost:        totalCost,
        grossProfit:      totalRevenue - totalCost,
        totalInvoices:    snap.docs.length,
        totalItemsSold:   totalItems,
        totalDiscount:    totalDiscount,
        totalTax:         totalTax,
        dailyBreakdown:   dailyBreakdown,
        paymentBreakdown: payBreakdown,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── TOP MEDICINES ────────────────────────────────────────────────────────

  @override
  Future<List<TopMedicineEntity>> getTopSellingMedicines(
      DateTime from, DateTime to, int limit) async {
    try {
      final snap = await _invoices
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(to))
          .where('status', whereIn: ['paid', 'credit'])
          .get();

      // Aggregate by medicineId
      final Map<String, _MedAgg> agg = {};

      for (final doc in snap.docs) {
        final items = doc.data()['items'] as List<dynamic>? ?? [];
        for (final item in items) {
          final m   = item as Map<String, dynamic>;
          final id  = m['medicineId'] as String? ?? '';
          final qty = (m['qty'] as num?)?.toInt() ?? 0;
          final price   = (m['unitPrice']    as num?)?.toDouble() ?? 0;
          final purchase = (m['purchasePrice'] as num?)?.toDouble()
              ?? price * 0.70;
          final lineTotal = (m['lineTotal'] as num?)?.toDouble()
              ?? price * qty;

          agg[id] ??= _MedAgg(
            medicineId:  id,
            tradeName:   m['tradeName']   as String? ?? '',
            genericName: m['genericName'] as String? ?? '',
            category:    m['category']    as String? ?? 'OTC',
          );
          agg[id]!.qty     += qty;
          agg[id]!.revenue += lineTotal;
          agg[id]!.cost    += purchase * qty;
          agg[id]!.invoices += 1;
        }
      }

      final sorted = agg.values.toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));

      return sorted.take(limit).toList().asMap().entries.map((e) {
        final a = e.value;
        final profit = a.revenue - a.cost;
        return TopMedicineEntity(
          rank:         e.key + 1,
          medicineId:   a.medicineId,
          tradeName:    a.tradeName,
          genericName:  a.genericName,
          category:     a.category,
          totalQtySold: a.qty,
          totalRevenue: a.revenue,
          totalProfit:  profit,
          invoiceCount: a.invoices,
          profitMargin: a.revenue == 0 ? 0 : (profit / a.revenue) * 100,
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── PROFIT REPORT ────────────────────────────────────────────────────────

  @override
  Future<ProfitReportEntity> getProfitReport(
      DateTime from, DateTime to) async {
    try {
      final snap = await _invoices
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(to))
          .where('status', whereIn: ['paid', 'credit'])
          .orderBy('createdAt')
          .get();

      double revenue  = 0;
      double cogs     = 0;
      double discount = 0;
      final Map<String, _MonthBucket> months    = {};
      final Map<String, _CatProfit>   catProfit = {};

      for (final doc in snap.docs) {
        final d   = doc.data();
        final rev = (d['grandTotal'] as num?)?.toDouble() ?? 0;
        final disc = ((d['itemDiscountAmount'] as num?)?.toDouble() ?? 0)
            + ((d['globalDiscountAmount'] as num?)?.toDouble() ?? 0);

        revenue  += rev;
        discount += disc;

        final dateTs = d['createdAt'] as Timestamp?;
        final date   = dateTs?.toDate() ?? DateTime.now();
        final mLabel = '${date.year}-${date.month.toString().padLeft(2, '0')}';

        months[mLabel] ??= _MonthBucket(label: mLabel);

        final items = d['items'] as List<dynamic>? ?? [];
        for (final item in items) {
          final m       = item as Map<String, dynamic>;
          final price   = (m['unitPrice']    as num?)?.toDouble() ?? 0;
          final purchase = (m['purchasePrice'] as num?)?.toDouble()
              ?? price * 0.70;
          final qty      = (m['qty'] as num?)?.toInt() ?? 0;
          final lineCost = purchase * qty;
          final lineRev  = (m['lineTotal'] as num?)?.toDouble() ?? price * qty;
          final cat      = m['category'] as String? ?? 'OTC';

          cogs                  += lineCost;
          months[mLabel]!.rev   += lineRev;
          months[mLabel]!.cost  += lineCost;

          catProfit[cat] ??= _CatProfit(category: cat);
          catProfit[cat]!.rev    += lineRev;
          catProfit[cat]!.profit += lineRev - lineCost;
        }
      }

      final gross = revenue - cogs;
      final sortedMonths = months.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));

      final monthlyTrend = sortedMonths.map((m) => ProfitDataPoint(
            label:   m.label,
            revenue: m.rev,
            cost:    m.cost,
            profit:  m.rev - m.cost,
          )).toList();

      final catTotal = catProfit.values
          .fold(0.0, (s, c) => s + c.profit);
      final catBreakdown = catProfit.values.map((c) => CategoryProfit(
            category:   c.category,
            revenue:    c.rev,
            profit:     c.profit,
            percentage: catTotal == 0 ? 0 : (c.profit / catTotal) * 100,
          )).toList()
        ..sort((a, b) => b.profit.compareTo(a.profit));

      return ProfitReportEntity(
        from:              from,
        to:                to,
        totalRevenue:      revenue,
        totalCogs:         cogs,
        grossProfit:       gross,
        totalDiscount:     discount,
        netProfit:         gross,
        profitMarginPct:   revenue == 0 ? 0 : (gross / revenue) * 100,
        monthlyTrend:      monthlyTrend,
        categoryBreakdown: catBreakdown,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── INVENTORY REPORT ─────────────────────────────────────────────────────

  @override
  Future<InventoryReportEntity> getInventoryReport() async {
    try {
      final now = DateTime.now();
      final expiry30 = now.add(const Duration(days: 30));

      final results = await Future.wait([
        _medicines.where('isActive', isEqualTo: true).get(),
        _batches.where('status', isEqualTo: 'active').get(),
        _batches
            .where('status', isEqualTo: 'active')
            .where('qtyAvailable', isGreaterThan: 0)
            .where('expiryDate',
                isLessThanOrEqualTo: Timestamp.fromDate(expiry30))
            .get(),
        _medicines
            .where('isActive', isEqualTo: true)
            .where('isLowStock', isEqualTo: true)
            .get(),
      ]);

      final medsSnap     = results[0] as QuerySnapshot;
      final batchesSnap  = results[1] as QuerySnapshot;
      final expiringSnap = results[2] as QuerySnapshot;
      final lowSnap      = results[3] as QuerySnapshot;

      double totalValue = 0;
      int outOfStock    = 0;
      int expired       = 0;
      final Map<String, _CatStock> catMap = {};

      for (final doc in batchesSnap.docs) {
        final d   = doc.data() as Map<String, dynamic>;
        final qty = (d['qtyAvailable'] as num?)?.toInt() ?? 0;
        final purchase = (d['purchasePrice'] as num?)?.toDouble() ?? 0;
        final expDate  = (d['expiryDate'] as Timestamp?)?.toDate();
        totalValue += qty * purchase;
        if (expDate != null && expDate.isBefore(now)) expired++;
      }

      for (final doc in medsSnap.docs) {
        final d   = doc.data() as Map<String, dynamic>;
        final cat = d['category'] as String? ?? 'OTC';
        catMap[cat] ??= _CatStock(category: cat);
        catMap[cat]!.count++;
      }

      final lowStockItems = lowSnap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return LowStockItem(
          medicineId:   doc.id,
          tradeName:    d['tradeName']    as String? ?? '',
          currentQty:   (d['qtyAvailable'] as num?)?.toInt() ?? 0,
          reorderLevel: (d['reorderLevel'] as num?)?.toInt() ?? 10,
          reorderQty:   (d['reorderQty']   as num?)?.toInt() ?? 50,
        );
      }).toList();

      final expiringItems = expiringSnap.docs.map((doc) {
        final d       = doc.data() as Map<String, dynamic>;
        final expDate = (d['expiryDate'] as Timestamp?)?.toDate()
            ?? now;
        final qty     = (d['qtyAvailable'] as num?)?.toInt() ?? 0;
        final purchase = (d['purchasePrice'] as num?)?.toDouble() ?? 0;
        return ExpiringItem(
          medicineId:   d['medicineId']  as String? ?? '',
          tradeName:    d['tradeName']   as String? ?? '',
          batchNo:      d['batchNo']     as String? ?? '',
          qtyAvailable: qty,
          expiryDate:   expDate,
          daysLeft:     expDate.difference(now).inDays,
          stockValue:   qty * purchase,
        );
      }).toList()
        ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

      final catList = catMap.values
          .map((c) => CategoryStock(
                category:   c.category,
                count:      c.count,
                totalQty:   0,
                stockValue: 0,
              ))
          .toList();

      final catValTotal = totalValue;
      final stockByCategory = catMap.entries
          .map((e) => StockValueCategory(
                category:   e.key,
                value:      0,
                percentage: 0,
              ))
          .toList();

      return InventoryReportEntity(
        generatedAt:         now,
        totalMedicines:      medsSnap.docs.length,
        totalBatches:        batchesSnap.docs.length,
        totalStockValue:     totalValue,
        lowStockCount:       lowSnap.docs.length,
        outOfStockCount:     outOfStock,
        expiringCount:       expiringSnap.docs.length,
        expiredCount:        expired,
        categoryBreakdown:   catList,
        lowStockItems:       lowStockItems,
        expiringItems:       expiringItems,
        stockValueByCategory: stockByCategory,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _bucketLabel(DateTime date, ReportPeriod period) {
    switch (period) {
      case ReportPeriod.daily:
        return '${date.hour}:00';
      case ReportPeriod.weekly:
        const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
        return days[(date.weekday - 1) % 7];
      case ReportPeriod.monthly:
        return date.day.toString();
      default:
        return '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
    }
  }
}

// ── Private aggregation helpers ───────────────────────────────────────────────
class _DayBucket    { _DayBucket({required this.label, required this.date}); final String label; final DateTime date; double revenue = 0; int count = 0; }
class _MedAgg       { _MedAgg({required this.medicineId, required this.tradeName, required this.genericName, required this.category}); final String medicineId, tradeName, genericName, category; int qty = 0, invoices = 0; double revenue = 0, cost = 0; }
class _MonthBucket  { _MonthBucket({required this.label}); final String label; double rev = 0, cost = 0; }
class _CatProfit    { _CatProfit({required this.category}); final String category; double rev = 0, profit = 0; }
class _CatStock     { _CatStock({required this.category}); final String category; int count = 0; }