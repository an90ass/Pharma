import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/medicine_entity.dart';
import '../models/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<List<MedicineModel>> getMedicines();
  Stream<List<MedicineModel>> watchMedicines();
  Future<MedicineModel> getMedicineById(String id);
  Future<List<MedicineModel>> searchMedicines(String query);
  Future<List<MedicineModel>> filterMedicines({
    MedicineCategory? category,
    MedicineForm? form,
    bool? isControlled,
  });
  Future<MedicineModel> addMedicine(MedicineModel model);
  Future<MedicineModel> updateMedicine(MedicineModel model);
  Future<void> deleteMedicine(String id);
  Future<void> permanentlyDeleteMedicine(String id);
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  const MedicineRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('medicines');

  // ── GET ALL ────────────────────────────────────────────────────────────
  @override
  Future<List<MedicineModel>> getMedicines() async {
    try {
      final snap = await _col
          .where('isActive', isEqualTo: true)
          .orderBy('tradeName')
          .get();
      return snap.docs.map(MedicineModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── WATCH (real-time) ──────────────────────────────────────────────────
  @override
  Stream<List<MedicineModel>> watchMedicines() {
    return _col
        .where('isActive', isEqualTo: true)
        .orderBy('tradeName')
        .snapshots()
        .map((s) => s.docs.map(MedicineModel.fromFirestore).toList())
        .handleError((e) => throw ServerException(e.toString()));
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────
  @override
  Future<MedicineModel> getMedicineById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) throw const NotFoundException();
      return MedicineModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── SEARCH ─────────────────────────────────────────────────────────────
  // Uses Firestore array-contains on searchTokens field.
  // For production with large datasets, integrate Algolia/Typesense.
  @override
  Future<List<MedicineModel>> searchMedicines(String query) async {
    try {
      final token = query.toLowerCase().trim();
      final snap = await _col
          .where('isActive', isEqualTo: true)
          .where('searchTokens', arrayContains: token)
          .get();
      return snap.docs.map(MedicineModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── FILTER ─────────────────────────────────────────────────────────────
  @override
  Future<List<MedicineModel>> filterMedicines({
    MedicineCategory? category,
    MedicineForm? form,
    bool? isControlled,
  }) async {
    try {
      Query<Map<String, dynamic>> q =
          _col.where('isActive', isEqualTo: true);
      if (category != null) q = q.where('category', isEqualTo: category.name);
      if (form != null) q = q.where('form', isEqualTo: form.name);
      if (isControlled != null) {
        q = q.where('isControlled', isEqualTo: isControlled);
      }
      final snap = await q.orderBy('tradeName').get();
      return snap.docs.map(MedicineModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── ADD ────────────────────────────────────────────────────────────────
  @override
  Future<MedicineModel> addMedicine(MedicineModel model) async {
    try {
      final ref = _col.doc(); // auto-generate ID
      await ref.set(model.toFirestore(isNew: true));
      final doc = await ref.get();
      return MedicineModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────
  @override
  Future<MedicineModel> updateMedicine(MedicineModel model) async {
    try {
      await _col.doc(model.id).update(model.toFirestore());
      final doc = await _col.doc(model.id).get();
      return MedicineModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── SOFT DELETE ────────────────────────────────────────────────────────
  @override
  Future<void> deleteMedicine(String id) async {
    try {
      await _col.doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── HARD DELETE ────────────────────────────────────────────────────────
  @override
  Future<void> permanentlyDeleteMedicine(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }
}