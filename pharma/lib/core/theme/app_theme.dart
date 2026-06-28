import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand colors (shared across light & dark) ───────────────────────────
  static const _primary   = Color(0xFF1565C0);
  static const _secondary = Color(0xFF2E7D32);
  static const _error     = Color(0xFFE53935);
  static const _warning   = Color(0xFFFF9800);

  // ── Light theme ──────────────────────────────────────────────────────────
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary:        _primary,
      onPrimary:      Colors.white,
      secondary:      _secondary,
      onSecondary:    Colors.white,
      error:          _error,
      onError:        Colors.white,
      surface:        Colors.white,
      onSurface:      Color(0xFF1A1A2E),
      surfaceVariant: Color(0xFFF7F8FC),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme:  scheme,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F8FC),
        foregroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.black.withOpacity(0.06), width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withOpacity(0.06),
        thickness: 1,
      ),
    );
  }

  // ── Dark theme ───────────────────────────────────────────────────────────
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary:        Color(0xFF64B5F6),   // lighter blue for contrast
      onPrimary:      Color(0xFF0D2438),
      secondary:      Color(0xFF81C784),
      onSecondary:    Color(0xFF0D2412),
      error:          Color(0xFFEF9A9A),
      onError:        Color(0xFF3A0E0E),
      surface:        Color(0xFF1E1E26),
      onSurface:      Color(0xFFE8E8ED),
      surfaceVariant: Color(0xFF151519),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme:  scheme,
      scaffoldBackgroundColor: const Color(0xFF121216),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121216),
        foregroundColor: Color(0xFFE8E8ED),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E26),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF26262E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
      ),
    );
  }

  /// Shared color constants for use outside ThemeData
  /// (e.g. status badges that need a fixed semantic color
  /// regardless of theme).
  static const warning = _warning;
  static const success = _secondary;
  static const danger  = _error;
}