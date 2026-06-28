// medicine_viewmodel.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../../domain/usecases/delete_medicine_usecase.dart';
import '../../domain/usecases/update_medicine_usecase.dart';
import '../../domain/usecases/get_medicines_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../providers/medicine_providers.dart';

// ── State (بدون تغيير) ───────────────────────────────────────────────────────

enum MedicineActionStatus { idle, loading, success, error }

class MedicineState {
  const MedicineState({
    this.medicines = const [],
    this.filtered = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedForm,
    this.controlledOnly = false,
    this.actionStatus = MedicineActionStatus.idle,
    this.actionError,
    this.successMessage,
  });

  final List<MedicineEntity> medicines;
  final List<MedicineEntity> filtered;
  final String searchQuery;
  final MedicineCategory? selectedCategory;
  final MedicineForm? selectedForm;
  final bool controlledOnly;
  final MedicineActionStatus actionStatus;
  final String? actionError;
  final String? successMessage;

  bool get hasActiveFilters =>
      selectedCategory != null || selectedForm != null || controlledOnly;

  MedicineState copyWith({
    List<MedicineEntity>? medicines,
    List<MedicineEntity>? filtered,
    String? searchQuery,
    MedicineCategory? selectedCategory,
    bool clearCategory = false,
    MedicineForm? selectedForm,
    bool clearForm = false,
    bool? controlledOnly,
    MedicineActionStatus? actionStatus,
    String? actionError,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return MedicineState(
      medicines: medicines ?? this.medicines,
      filtered: filtered ?? this.filtered,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : selectedCategory ?? this.selectedCategory,
      selectedForm: clearForm ? null : selectedForm ?? this.selectedForm,
      controlledOnly: controlledOnly ?? this.controlledOnly,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: clearMessages ? null : actionError ?? this.actionError,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
    );
  }
}

// ── ViewModel ────────────────────────────────────────────────────────────────

class MedicineViewModel extends Notifier<MedicineState> {
  late AddMedicineUseCase _add;
  late UpdateMedicineUseCase _update;
  late DeleteMedicineUseCase _delete;
  late WatchMedicinesUseCase _watch; 

  StreamSubscription? _medicinesSub; 


@override
MedicineState build() {
  _add    = ref.watch(addMedicineUseCaseProvider);
  _update = ref.watch(updateMedicineUseCaseProvider);
  _delete = ref.watch(deleteMedicineUseCaseProvider);
  _watch  = ref.watch(watchMedicinesUseCaseProvider);

  ref.onDispose(() => _medicinesSub?.cancel());

  Future.microtask(_startWatching);

  return const MedicineState(actionStatus: MedicineActionStatus.loading);
}
void restartWatching() => _startWatching();

  // ── WATCH (real-time) ────────────────────────────────────────────────────

void _startWatching() {
  _medicinesSub?.cancel();

  _medicinesSub = _watch(const NoParams()).listen(
    (result) {
      result.fold(
        (failure) => state = state.copyWith(
          actionStatus: MedicineActionStatus.error,
          actionError: failure.message,
        ),
        (list) => state = state.copyWith(
          medicines: list,
          filtered: _applyFilters(list),
          actionStatus: MedicineActionStatus.idle,
        ),
      );
    },
    onError: (e) => state = state.copyWith(
      actionStatus: MedicineActionStatus.error,
      actionError: e.toString(),
    ),
  );
}

  // ── SEARCH ───────────────────────────────────────────────────────────────

  void onSearchChanged(String query) {
    state = state.copyWith(
      searchQuery: query,
      filtered: _applyFilters(state.medicines, query: query),
    );
  }

  // ── FILTER ───────────────────────────────────────────────────────────────

  void setCategory(MedicineCategory? cat) {
    state = state.copyWith(
      selectedCategory: cat,
      clearCategory: cat == null,
      filtered: _applyFilters(state.medicines,
          category: cat,
          form: state.selectedForm,
          controlledOnly: state.controlledOnly),
    );
  }

  void setForm(MedicineForm? form) {
    state = state.copyWith(
      selectedForm: form,
      clearForm: form == null,
      filtered: _applyFilters(state.medicines,
          category: state.selectedCategory,
          form: form,
          controlledOnly: state.controlledOnly),
    );
  }

  void toggleControlledOnly() {
    final next = !state.controlledOnly;
    state = state.copyWith(
      controlledOnly: next,
      filtered: _applyFilters(state.medicines, controlledOnly: next),
    );
  }

  void clearFilters() {
    state = state.copyWith(
      clearCategory: true,
      clearForm: true,
      controlledOnly: false,
      filtered: _applyFilters(state.medicines,
          query: state.searchQuery, controlledOnly: false),
    );
  }

  // ── ADD ──────────────────────────────────────────────────────────────────

  Future<bool> addMedicine(AddMedicineParams params) async {
    state = state.copyWith(
        actionStatus: MedicineActionStatus.loading, clearMessages: true);
    final result = await _add(params);
    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: MedicineActionStatus.error, actionError: f.message);
        return false;
      },
      (medicine) {
        state = state.copyWith(
          actionStatus: MedicineActionStatus.success,
          successMessage: '"${medicine.tradeName}" added successfully.',
        );
        return true;
      },
    );
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────

  Future<bool> updateMedicine(UpdateMedicineParams params) async {
    state = state.copyWith(
        actionStatus: MedicineActionStatus.loading, clearMessages: true);
    final result = await _update(params);
    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: MedicineActionStatus.error, actionError: f.message);
        return false;
      },
      (updated) {
        state = state.copyWith(
          actionStatus: MedicineActionStatus.success,
          successMessage: '"${updated.tradeName}" updated successfully.',
        );
        return true;
      },
    );
  }

  // ── DELETE ───────────────────────────────────────────────────────────────

  Future<bool> deleteMedicine(String id, String tradeName) async {
    state = state.copyWith(
        actionStatus: MedicineActionStatus.loading, clearMessages: true);
    final result = await _delete(DeleteMedicineParams(id));
    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: MedicineActionStatus.error, actionError: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          actionStatus: MedicineActionStatus.success,
          successMessage: '"$tradeName" deleted.',
        );
        return true;
      },
    );
  }

  void clearActionMessages() {
    state = state.copyWith(
        clearMessages: true, actionStatus: MedicineActionStatus.idle);
  }

  // ── Private filter ───────────────────────────────────────────────────────

  List<MedicineEntity> _applyFilters(
    List<MedicineEntity> source, {
    String? query,
    MedicineCategory? category,
    MedicineForm? form,
    bool? controlledOnly,
  }) {
    final q   = (query ?? state.searchQuery).toLowerCase().trim();
    final cat = category ?? state.selectedCategory;
    final frm = form ?? state.selectedForm;
    final ctrl = controlledOnly ?? state.controlledOnly;

    return source.where((m) {
      if (q.isNotEmpty) {
        final match = m.tradeName.toLowerCase().contains(q) ||
            m.genericName.toLowerCase().contains(q) ||
            m.manufacturer.toLowerCase().contains(q) ||
            (m.barcode?.contains(q) ?? false);
        if (!match) return false;
      }
      if (cat != null && m.category != cat) return false;
      if (frm != null && m.form != frm) return false;
      if (ctrl && !m.isControlled) return false;
      return true;
    }).toList();
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final medicineViewModelProvider =NotifierProvider<MedicineViewModel, MedicineState>(
  MedicineViewModel.new,
);