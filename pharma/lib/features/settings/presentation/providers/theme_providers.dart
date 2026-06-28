import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/theme_local_datasource.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/get_theme_mode_usecase.dart';
import '../../domain/usecases/set_theme_mode_usecase.dart';
import '../../domain/usecases/watch_theme_mode_usecase.dart';


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() '
    'with a resolved SharedPreferences instance.',
  );
});

// ── Data layer ────────────────────────────────────────────────────────────────
final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
  return ThemeLocalDataSourceImpl(ref.read(sharedPreferencesProvider));
});

// ── Repository ────────────────────────────────────────────────────────────────
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepositoryImpl(ref.read(themeLocalDataSourceProvider));
});

// ── Use cases ─────────────────────────────────────────────────────────────────
final getThemeModeUseCaseProvider = Provider<GetThemeModeUseCase>((ref) {
  return GetThemeModeUseCase(ref.read(themeRepositoryProvider));
});

final setThemeModeUseCaseProvider = Provider<SetThemeModeUseCase>((ref) {
  return SetThemeModeUseCase(ref.read(themeRepositoryProvider));
});

final watchThemeModeUseCaseProvider = Provider<WatchThemeModeUseCase>((ref) {
  return WatchThemeModeUseCase(ref.read(themeRepositoryProvider));
});