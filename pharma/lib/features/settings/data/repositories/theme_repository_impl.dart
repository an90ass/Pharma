import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  const ThemeRepositoryImpl(this._local);
  final ThemeLocalDataSource _local;

  @override
  Future<Either<Failure, AppThemeMode>> getThemeMode() async {
    try {
      final key = await _local.getThemeMode();
      return Right(AppThemeMode.fromStorageKey(key));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(AppThemeMode mode) async {
    try {
      await _local.setThemeMode(mode.storageKey);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, AppThemeMode>> watchThemeMode() {
    return _local
        .watchThemeMode()
        .map<Either<Failure, AppThemeMode>>(
          (key) => Right(AppThemeMode.fromStorageKey(key)),
        )
        .handleError((e) {
      throw e is CacheException
          ? CacheFailure(e.message)
          : UnexpectedFailure(e.toString());
    });
  }
}