import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/customer_model.dart';

class CustomerRemoteDataSource {
  const CustomerRemoteDataSource(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> get _col =>
      _fs.collection('customers');

  Future<List<CustomerModel>> getCustomers({String? search}) async {
    try {
      Query<Map<String, dynamic>> q =
          _col.where('isActive', isEqualTo: true);
      if (search != null && search.isNotEmpty) {
        q = q.where('searchTokens',
            arrayContains: search.toLowerCase());
      }
      final snap = await q.orderBy('name').limit(100).get();
      return snap.docs.map(CustomerModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Stream<List<CustomerModel>> watchCustomers() =>
      _col.where('isActive', isEqualTo: true)
          .orderBy('name').limit(100).snapshots()
          .map((s) => s.docs.map(CustomerModel.fromFirestore).toList());

  Future<CustomerModel> addCustomer(CustomerModel m) async {
    try {
      final ref = _col.doc();
      await ref.set(m.toFirestore(isNew: true));
      return CustomerModel.fromFirestore(await ref.get());
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<CustomerModel> updateCustomer(CustomerModel m) async {
    try {
      await _col.doc(m.id).update(m.toFirestore());
      return CustomerModel.fromFirestore(await _col.doc(m.id).get());
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _col.doc(id).update({'isActive': false,
          'updatedAt': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    try {
      final snap = await _col.where('phone', isEqualTo: phone)
          .where('isActive', isEqualTo: true).limit(1).get();
      if (snap.docs.isEmpty) return null;
      return CustomerModel.fromFirestore(snap.docs.first);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }
}