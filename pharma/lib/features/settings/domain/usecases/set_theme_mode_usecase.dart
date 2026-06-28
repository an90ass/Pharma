import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/theme_repository.dart';

/// Persists the user's chosen theme mode.
/// Called when the user taps Light / Dark / System in settings.
class SetThemeModeUseCase implements UseCase<void, SetThemeModeParams> {
  const SetThemeModeUseCase(this._repo);
  final ThemeRepository _repo;

  @override
  Future<Either<Failure, void>> call(SetThemeModeParams p) =>
      _repo.setThemeMode(p.mode);
}

class SetThemeModeParams extends Equatable {
  const SetThemeModeParams(this.mode);
  final AppThemeMode mode;

  @override
  List<Object> get props => [mode];
}