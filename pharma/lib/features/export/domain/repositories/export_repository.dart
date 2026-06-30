import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

enum ExportFormat { pdf, excel }

abstract class ExportRepository {
  Future<Either<Failure, Uint8List>> exportSalesReport(
      dynamic report, ExportFormat format);
  Future<Either<Failure, Uint8List>> exportInventoryReport(
      dynamic report, ExportFormat format);
  Future<Either<Failure, Uint8List>> exportTopMedicines(
      List<dynamic> medicines, ExportFormat format);
  Future<Either<Failure, void>> shareExport(
      Uint8List bytes, String fileName, ExportFormat format);
}