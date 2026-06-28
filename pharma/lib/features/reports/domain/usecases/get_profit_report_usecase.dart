import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profit_report_entity.dart';
import '../repositories/reports_repository.dart';

class GetProfitReportUseCase
    implements UseCase<ProfitReportEntity, ProfitReportParams> {
  const GetProfitReportUseCase(this._repo);
  final ReportsRepository _repo;

  @override
  Future<Either<Failure, ProfitReportEntity>> call(ProfitReportParams p) =>
      _repo.getProfitReport(from: p.from, to: p.to);
}

class ProfitReportParams extends Equatable {
  const ProfitReportParams({required this.from, required this.to});
  final DateTime from;
  final DateTime to;
  @override List<Object> get props => [from, to];
}