import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/export_repository.dart';
import '../builders/excel_report_builder.dart';

class ExportRepositoryImpl implements ExportRepository {
  const ExportRepositoryImpl(this._excel);
  final ExcelReportBuilder _excel;

  Either<Failure, T> _h<T>(Object e) =>
      Left(UnexpectedFailure(e.toString()));

  @override
  Future<Either<Failure, Uint8List>> exportSalesReport(
      dynamic report, ExportFormat format) async {
    try {
      if (format == ExportFormat.excel) {
        return Right(_excel.buildSalesReport(report));
      }
      // PDF handled by Step 9's InvoicePdfGenerator
      return const Left(ValidationFailure('Use PDF service for PDF export.'));
    } catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, Uint8List>> exportInventoryReport(
      dynamic report, ExportFormat format) async {
    try {
      if (format == ExportFormat.excel) {
        return Right(_excel.buildInventoryReport(report));
      }
      return const Left(ValidationFailure('Use PDF service for PDF export.'));
    } catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, Uint8List>> exportTopMedicines(
      List<dynamic> medicines, ExportFormat format) async {
    try {
      if (format == ExportFormat.excel) {
        return Right(_excel.buildTopMedicines(medicines));
      }
      return const Left(ValidationFailure('Use PDF service for PDF export.'));
    } catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, void>> shareExport(
      Uint8List bytes, String fileName, ExportFormat format) async {
    try {
      final dir  = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path,
            mimeType: format == ExportFormat.excel
                ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                : 'application/pdf')],
        subject: fileName,
      );
      return const Right(null);
    } catch (e) { return _h(e); }
  }
}