import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/builders/excel_report_builder.dart';
import '../../data/repositories/export_repository_impl.dart';
import '../../domain/repositories/export_repository.dart';
import '../../domain/usecases/export_usecases.dart';

final excelBuilderProvider = Provider<ExcelReportBuilder>((_) => ExcelReportBuilder());
final exportRepositoryProvider = Provider<ExportRepository>(
    (ref) => ExportRepositoryImpl(ref.read(excelBuilderProvider)));
final exportSalesUseCaseProvider =
    Provider((ref) => ExportSalesReportUseCase(ref.read(exportRepositoryProvider)));
final exportInventoryUseCaseProvider =
    Provider((ref) => ExportInventoryReportUseCase(ref.read(exportRepositoryProvider)));
final exportTopMedsUseCaseProvider =
    Provider((ref) => ExportTopMedicinesUseCase(ref.read(exportRepositoryProvider)));