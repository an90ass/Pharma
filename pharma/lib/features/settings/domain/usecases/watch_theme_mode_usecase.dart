import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/theme_repository.dart';

/// Real-time stream of the theme mode.
/// Lets MaterialApp rebuild instantly when the preference changes,
/// even if changed from a different part of the widget tree.
class WatchThemeModeUseCase
    implements StreamUseCase<AppThemeMode, NoParams> {
  const WatchThemeModeUseCase(this._repo);
  final ThemeRepository _repo;

  @override
  Stream<Either<Failure, AppThemeMode>> call(NoParams _) =>
      _repo.watchThemeMode();
}