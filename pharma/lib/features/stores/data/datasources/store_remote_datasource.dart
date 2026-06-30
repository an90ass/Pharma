import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/store_model.dart';

class StoreRemoteDataSource {
  const StoreRemoteDataSource(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> get _col =>
      _fs.collection('stores');

  Future<List<StoreModel>> getStores() async {
    try {
      final snap = await _col.where('isActive', isEqualTo: true)
          .orderBy('createdAt').get();
      return snap.docs.map(StoreModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Stream<List<StoreModel>> watchStores() =>
      _col.where('isActive', isEqualTo: true).orderBy('createdAt')
          .snapshots()
          .map((s) => s.docs.map(StoreModel.fromFirestore).toList())
          .handleError((e) => throw ServerException(e.toString()));

  Future<StoreModel> addStore(StoreModel model) async {
    try {
      final ref = _col.doc();
      await ref.set(model.toFirestore(isNew: true));
      final doc = await ref.get();
      return StoreModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<StoreModel> updateStore(StoreModel model) async {
    try {
      await _col.doc(model.id).update(model.toFirestore());
      final doc = await _col.doc(model.id).get();
      return StoreModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> deactivateStore(String id) async {
    try {
      await _col.doc(id).update({'isActive': false,
          'updatedAt': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }
}