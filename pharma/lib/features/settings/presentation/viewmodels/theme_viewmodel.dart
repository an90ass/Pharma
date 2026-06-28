import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/usecases/get_theme_mode_usecase.dart';
import '../../domain/usecases/set_theme_mode_usecase.dart';
import '../../domain/usecases/watch_theme_mode_usecase.dart';
import '../providers/theme_providers.dart';

/// Holds the app's current [AppThemeMode] and exposes it directly as state
/// (no extra wrapper class needed — the enum IS the state).
///
/// MaterialApp watches this provider to set `themeMode`:
/// ```dart
/// themeMode: ref.watch(themeViewModelProvider).toFlutterThemeMode(),
/// ```
class ThemeViewModel extends Notifier<AppThemeMode> {
  late GetThemeModeUseCase _get;
  late SetThemeModeUseCase _set;
  late WatchThemeModeUseCase _watch;

  @override
  AppThemeMode build() {
    _get   = ref.read(getThemeModeUseCaseProvider);
    _set   = ref.read(setThemeModeUseCaseProvider);
    _watch = ref.read(watchThemeModeUseCaseProvider);

    // Subscribe to live updates (e.g. theme changed from another screen,
    // or restored from storage on first read).
    final subscription = _watch(const NoParams()).listen((either) {
      either.fold(
        (_) {},                       // ignore cache errors — keep current state
        (mode) => state = mode,
      );
    });

    // Cancel the subscription when this provider is disposed.
    ref.onDispose(subscription.cancel);

    // Initial synchronous fallback while the stream's first value
    // (emitted on the next microtask) arrives.
    return AppThemeMode.system;
  }

  /// Called when the user taps Light / Dark / System in settings.
  Future<void> setThemeMode(AppThemeMode mode) async {
    // Optimistic update — feels instant, no loading spinner needed.
    state = mode;
    final result = await _set(SetThemeModeParams(mode));
    result.fold(
      (_) {
        // Persist failed (rare — disk error). Re-sync from storage
        // so the UI doesn't show a state that wasn't actually saved.
        _resync();
      },
      (_) {}, // success — state already updated optimistically
    );
  }

  Future<void> _resync() async {
    final result = await _get(const NoParams());
    result.fold((_) {}, (mode) => state = mode);
  }
}

final themeViewModelProvider =
    NotifierProvider<ThemeViewModel, AppThemeMode>(ThemeViewModel.new);

// ── Mapping helper ────────────────────────────────────────────────────────────

/// Converts the domain [AppThemeMode] to Flutter's [ThemeMode] enum,
/// which is what `MaterialApp.themeMode` actually expects.
extension AppThemeModeMapper on AppThemeMode {
  ThemeMode toFlutterThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}