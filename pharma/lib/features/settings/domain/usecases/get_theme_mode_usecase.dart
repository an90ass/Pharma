import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/theme_repository.dart';

/// One-time fetch of the saved theme mode.
/// Used at app startup before the first frame is built.
class GetThemeModeUseCase implements UseCase<AppThemeMode, NoParams> {
  const GetThemeModeUseCase(this._repo);
  final ThemeRepository _repo;

  @override
  Future<Either<Failure, AppThemeMode>> call(NoParams _) =>
      _repo.getThemeMode();
}