import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_report_entity.dart';
import '../repositories/reports_repository.dart';

class GetInventoryReportUseCase
    implements UseCase<InventoryReportEntity, NoParams> {
  const GetInventoryReportUseCase(this._repo);
  final ReportsRepository _repo;

  @override
  Future<Either<Failure, InventoryReportEntity>> call(NoParams _) =>
      _repo.getInventoryReport();
}