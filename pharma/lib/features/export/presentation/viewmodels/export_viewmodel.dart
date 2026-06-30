import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/export_repository.dart';
import '../../domain/usecases/export_usecases.dart';
import '../providers/export_providers.dart';

enum ExportStatus { idle, exporting, done, error }

class ExportState {
  const ExportState({this.status = ExportStatus.idle, this.errorMessage});
  final ExportStatus status;
  final String? errorMessage;
  bool get isExporting => status == ExportStatus.exporting;
  ExportState copyWith({ExportStatus? status, String? errorMessage}) =>
      ExportState(status: status ?? this.status,
                  errorMessage: errorMessage ?? this.errorMessage);
}

class ExportViewModel extends Notifier<ExportState> {
  @override ExportState build() => const ExportState();

  Future<void> exportSalesReport(dynamic report, ExportFormat format) async {
    state = state.copyWith(status: ExportStatus.exporting);
    final uc     = ref.read(exportSalesUseCaseProvider);
    final repo   = ref.read(exportRepositoryProvider);
    final result = await uc(ExportParams(data: report, format: format));
    await result.fold(
      (f) async => state = state.copyWith(
          status: ExportStatus.error, errorMessage: f.message),
      (bytes) async {
        final fileName = 'sales_report_${DateTime.now().millisecondsSinceEpoch}'
            '.${format == ExportFormat.excel ? 'xlsx' : 'pdf'}';
        await repo.shareExport(bytes, fileName, format);
        state = state.copyWith(status: ExportStatus.done);
      },
    );
  }

  Future<void> exportInventoryReport(dynamic report, ExportFormat format) async {
    state = state.copyWith(status: ExportStatus.exporting);
    final uc   = ref.read(exportInventoryUseCaseProvider);
    final repo = ref.read(exportRepositoryProvider);
    final result = await uc(ExportParams(data: report, format: format));
    await result.fold(
      (f) async => state = state.copyWith(
          status: ExportStatus.error, errorMessage: f.message),
      (bytes) async {
        await repo.shareExport(bytes, 'inventory_report.xlsx', format);
        state = state.copyWith(status: ExportStatus.done);
      },
    );
  }
}

final exportViewModelProvider =
    NotifierProvider<ExportViewModel, ExportState>(ExportViewModel.new);