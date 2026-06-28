import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/supplier_model.dart';

class SupplierRemoteDataSource {
  const SupplierRemoteDataSource(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> get _col =>
      _fs.collection('suppliers');

  Future<List<SupplierModel>> getSuppliers({String? search}) async {
    try {
      var q = _col.where('isActive', isEqualTo: true).orderBy('name');
      final snap = await q.limit(100).get();
      final list = snap.docs.map(SupplierModel.fromFirestore).toList();
      if (search != null && search.isNotEmpty) {
        final lower = search.toLowerCase();
        return list.where((s) =>
            s.name.toLowerCase().contains(lower) ||
            s.phone.contains(search)).toList();
      }
      return list;
    } on FirebaseException catch (e) { throw ServerException(e.message); }
  }

  Stream<List<SupplierModel>> watchSuppliers() =>
      _col.where('isActive', isEqualTo: true).orderBy('name').snapshots()
          .map((s) => s.docs.map(SupplierModel.fromFirestore).toList());

  Future<SupplierModel> addSupplier(SupplierModel m) async {
    try {
      final ref = _col.doc();
      await ref.set(m.toFirestore(isNew: true));
      return SupplierModel.fromFirestore(await ref.get());
    } on FirebaseException catch (e) { throw ServerException(e.message); }
  }

  Future<SupplierModel> updateSupplier(SupplierModel m) async {
    try {
      await _col.doc(m.id).update(m.toFirestore());
      return SupplierModel.fromFirestore(await _col.doc(m.id).get());
    } on FirebaseException catch (e) { throw ServerException(e.message); }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _col.doc(id).update({'isActive': false,
          'updatedAt': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) { throw ServerException(e.message); }
  }
}