import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_theme_mode.dart';

abstract class ThemeLocalDataSource {

  Future<String?> getThemeMode();

  Future<void> setThemeMode(String storageKey);

  Stream<String> watchThemeMode();
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  ThemeLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeModeKey = 'theme_mode';

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  @override
  Future<String?> getThemeMode() async {
    try {
      return _prefs.getString(_kThemeModeKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> setThemeMode(String storageKey) async {
    try {
      await _prefs.setString(_kThemeModeKey, storageKey);

      _controller.add(storageKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Stream<String> watchThemeMode() async* {
    try {

      final current = _prefs.getString(_kThemeModeKey) ??
          AppThemeMode.system.storageKey;
      yield current;
      yield* _controller.stream;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}