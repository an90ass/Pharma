import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medicine_search_result.dart';
import '../repositories/sales_repository.dart';

/// Search medicines by name/generic/barcode from POS screen.
class SearchMedicineUseCase
    implements UseCase<List<MedicineSearchResult>, SearchMedicineParams> {
  const SearchMedicineUseCase(this._repo);
  final SalesRepository _repo;

  @override
  Future<Either<Failure, List<MedicineSearchResult>>> call(
      SearchMedicineParams p) async {
    final q = p.query.trim();
    if (q.isEmpty) return const Right([]);
    if (q.length < 2) {
      return const Left(
          ValidationFailure('Enter at least 2 characters to search.'));
    }
    return _repo.searchMedicines(q);
  }
}

class SearchMedicineParams extends Equatable {
  const SearchMedicineParams(this.query);
  final String query;
  @override
  List<Object> get props => [query];
}

/// Barcode scan — instant single result.
class GetMedicineByBarcodeUseCase
    implements UseCase<MedicineSearchResult, BarcodeParams> {
  const GetMedicineByBarcodeUseCase(this._repo);
  final SalesRepository _repo;

  @override
  Future<Either<Failure, MedicineSearchResult>> call(BarcodeParams p) {
    if (p.barcode.trim().isEmpty) {
      return Future.value(
          const Left(ValidationFailure('Barcode cannot be empty.')));
    }
    return _repo.getMedicineByBarcode(p.barcode.trim());
  }
}

class BarcodeParams extends Equatable {
  const BarcodeParams(this.barcode);
  final String barcode;
  @override
  List<Object> get props => [barcode];
}