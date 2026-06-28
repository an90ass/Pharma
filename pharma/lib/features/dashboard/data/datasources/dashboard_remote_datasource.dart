import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboardStats();
  Stream<DashboardModel> watchDashboardStats();
  Future<int> getLowStockCount();
  Future<int> getExpiringCount({int withinDays = 30});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference get _medicines => _firestore.collection('medicines');
  CollectionReference get _customers => _firestore.collection('customers');
  CollectionReference get _suppliers => _firestore.collection('suppliers');
  CollectionReference get _invoices  => _firestore.collection('invoices');
  CollectionReference get _batches   => _firestore.collection('batches');

  @override
  Future<DashboardModel> getDashboardStats() async {
    try {
      final now             = DateTime.now();
      final todayStart      = DateTime(now.year, now.month, now.day);
      final monthStart      = DateTime(now.year, now.month, 1);
      final expiryThreshold = now.add(const Duration(days: 30));

      final results = await Future.wait([
        _medicines.where('isActive', isEqualTo: true).get(),
        _customers.get(),
        _suppliers.where('isActive', isEqualTo: true).get(),
        _medicines
            .where('isActive',   isEqualTo: true)
            .where('isLowStock', isEqualTo: true)
            .get(),
        _batches
            .where('expiryDate',
            isLessThanOrEqualTo: Timestamp.fromDate(expiryThreshold))
            .get(),
        _invoices
            .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
            .get(),
        _invoices
            .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
            .get(),
      ]);

      final medicinesSnap = results[0] as QuerySnapshot;
      final customersSnap = results[1] as QuerySnapshot;
      final suppliersSnap = results[2] as QuerySnapshot;
      final lowStockSnap  = results[3] as QuerySnapshot;
      final expiringSnap  = results[4] as QuerySnapshot;
      final todaySnap     = results[5] as QuerySnapshot;
      final monthlySnap   = results[6] as QuerySnapshot;

      // Filter in Dart — no compound index needed
      final expiringCount = expiringSnap.docs.where((doc) {
        final d       = doc.data() as Map<String, dynamic>;
        final status  = d['status']      as String?    ?? '';
        final expDate = (d['expiryDate'] as Timestamp?)?.toDate();
        return status == 'active' && expDate != null && expDate.isAfter(now);
      }).length;

      double todaySales = 0;
      int    todayCount = 0;
      for (final doc in todaySnap.docs) {
        final d      = doc.data() as Map<String, dynamic>;
        final status = d['status'] as String? ?? '';
        if (status == 'paid' || status == 'credit') {
          todaySales += (d['grandTotal'] as num?)?.toDouble() ?? 0;
          todayCount++;
        }
      }

      double monthlySales = 0;
      int    monthlyCount = 0;
      for (final doc in monthlySnap.docs) {
        final d      = doc.data() as Map<String, dynamic>;
        final status = d['status'] as String? ?? '';
        if (status == 'paid' || status == 'credit') {
          monthlySales += (d['grandTotal'] as num?)?.toDouble() ?? 0;
          monthlyCount++;
        }
      }

      return DashboardModel(
        totalMedicines: medicinesSnap.docs.length,
        totalCustomers: customersSnap.docs.length,
        totalSuppliers: suppliersSnap.docs.length,
        lowStockCount: lowStockSnap.docs.length,
        expiringCount: expiringCount,
        todaySalesAmount: todaySales,
        todaySalesCount: todayCount,
        monthlySalesAmount: monthlySales,
        monthlySalesCount: monthlyCount,
        recentActivities: const [],
        fetchedAt: now,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<DashboardModel> watchDashboardStats() {
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => getDashboardStats());
  }

  @override
  Future<int> getLowStockCount() async {
    try {
      final snap = await _medicines
          .where('isActive',   isEqualTo: true)
          .where('isLowStock', isEqualTo: true)
          .get();
      return snap.docs.length;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error');
    }
  }

  @override
  Future<int> getExpiringCount({int withinDays = 30}) async {
    try {
      final now       = DateTime.now();
      final threshold = now.add(Duration(days: withinDays));
      final snap = await _batches
          .where('expiryDate',
          isLessThanOrEqualTo: Timestamp.fromDate(threshold))
          .get();
      return snap.docs.where((doc) {
        final d       = doc.data() as Map<String, dynamic>;
        final status  = d['status']      as String?    ?? '';
        final expDate = (d['expiryDate'] as Timestamp?)?.toDate();
        return status == 'active' && expDate != null && expDate.isAfter(now);
      }).length;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error');
    }
  }
}