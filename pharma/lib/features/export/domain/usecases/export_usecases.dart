import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/export_repository.dart';

class ExportSalesReportUseCase implements UseCase<Uint8List, ExportParams> {
  const ExportSalesReportUseCase(this._repo);
  final ExportRepository _repo;
  @override
  Future<Either<Failure, Uint8List>> call(ExportParams p) =>
      _repo.exportSalesReport(p.data, p.format);
}

class ExportInventoryReportUseCase implements UseCase<Uint8List, ExportParams> {
  const ExportInventoryReportUseCase(this._repo);
  final ExportRepository _repo;
  @override
  Future<Either<Failure, Uint8List>> call(ExportParams p) =>
      _repo.exportInventoryReport(p.data, p.format);
}

class ExportTopMedicinesUseCase implements UseCase<Uint8List, ExportListParams> {
  const ExportTopMedicinesUseCase(this._repo);
  final ExportRepository _repo;
  @override
  Future<Either<Failure, Uint8List>> call(ExportListParams p) =>
      _repo.exportTopMedicines(p.data, p.format);
}

class ExportParams extends Equatable {
  const ExportParams({required this.data, required this.format});
  final dynamic data;
  final ExportFormat format;
  @override List<Object?> get props => [format];
}

class ExportListParams extends Equatable {
  const ExportListParams({required this.data, required this.format});
  final List<dynamic> data;
  final ExportFormat format;
  @override List<Object?> get props => [format];
}