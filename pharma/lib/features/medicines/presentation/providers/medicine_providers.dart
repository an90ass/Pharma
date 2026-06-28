import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/medicine_remote_datasource.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../../domain/usecases/delete_medicine_usecase.dart';
import '../../domain/usecases/get_medicines_usecase.dart';
import '../../domain/usecases/update_medicine_usecase.dart';

// ── Infrastructure ──────────────────────────────────────────────────────────

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

// ── Data layer ──────────────────────────────────────────────────────────────

final medicineRemoteDataSourceProvider =
    Provider<MedicineRemoteDataSource>((ref) {
  return MedicineRemoteDataSourceImpl(ref.read(firestoreProvider));
});

// ── Repository ──────────────────────────────────────────────────────────────

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepositoryImpl(ref.read(medicineRemoteDataSourceProvider));
});

// ── Use cases ───────────────────────────────────────────────────────────────

final getMedicinesUseCaseProvider = Provider<GetMedicinesUseCase>((ref) {
  return GetMedicinesUseCase(ref.read(medicineRepositoryProvider));
});

final watchMedicinesUseCaseProvider = Provider<WatchMedicinesUseCase>((ref) {
  return WatchMedicinesUseCase(ref.read(medicineRepositoryProvider));
});

final searchMedicinesUseCaseProvider = Provider<SearchMedicinesUseCase>((ref) {
  return SearchMedicinesUseCase(ref.read(medicineRepositoryProvider));
});

final filterMedicinesUseCaseProvider = Provider<FilterMedicinesUseCase>((ref) {
  return FilterMedicinesUseCase(ref.read(medicineRepositoryProvider));
});

final addMedicineUseCaseProvider = Provider<AddMedicineUseCase>((ref) {
  return AddMedicineUseCase(ref.read(medicineRepositoryProvider));
});

final updateMedicineUseCaseProvider = Provider<UpdateMedicineUseCase>((ref) {
  return UpdateMedicineUseCase(ref.read(medicineRepositoryProvider));
});

final deleteMedicineUseCaseProvider = Provider<DeleteMedicineUseCase>((ref) {
  return DeleteMedicineUseCase(ref.read(medicineRepositoryProvider));
});