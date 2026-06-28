import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_theme_mode.dart';

/// Abstract contract for reading/writing the user's theme preference.
///
/// Implemented by the data layer using SharedPreferences — no Firestore
/// involved, since theme preference is a per-device setting.
abstract class ThemeRepository {
  /// Returns the currently saved theme mode.
  /// Returns [AppThemeMode.system] if no preference has been saved yet.
  Future<Either<Failure, AppThemeMode>> getThemeMode();

  /// Persists the user's chosen theme mode.
  Future<Either<Failure, void>> setThemeMode(AppThemeMode mode);

  /// Emits the current theme mode immediately, then again whenever
  /// it changes (e.g. updated from a different screen).
  Stream<Either<Failure, AppThemeMode>> watchThemeMode();
}