// ══════════════════════════════════════════════════════════════════════════════
// HOW TO WIRE DARK MODE INTO main.dart AND MaterialApp
// ══════════════════════════════════════════════════════════════════════════════
//
// STEP 1 — pubspec.yaml: add shared_preferences
// ─────────────────────────────────────────────────────────────────────────────
//   dependencies:
//     shared_preferences: ^2.2.3
//
// STEP 2 — main.dart: resolve SharedPreferences before runApp()
// ─────────────────────────────────────────────────────────────────────────────
//   import 'package:flutter/material.dart';
//   import 'package:flutter_riverpod/flutter_riverpod.dart';
//   import 'package:shared_preferences/shared_preferences.dart';
//   import 'features/settings/presentation/providers/theme_providers.dart';
//
//   void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     final prefs = await SharedPreferences.getInstance();
//
//     runApp(
//       ProviderScope(
//         overrides: [
//           sharedPreferencesProvider.overrideWithValue(prefs),
//         ],
//         child: const PharmacyApp(),
//       ),
//     );
//   }
//
// STEP 3 — MaterialApp: watch themeViewModelProvider
// ─────────────────────────────────────────────────────────────────────────────
//   import 'core/theme/app_theme.dart';
//   import 'features/settings/presentation/viewmodels/theme_viewmodel.dart';
//
//   class PharmacyApp extends ConsumerWidget {
//     const PharmacyApp({super.key});
//
//     @override
//     Widget build(BuildContext context, WidgetRef ref) {
//       final themeMode = ref.watch(themeViewModelProvider);
//
//       return MaterialApp.router(
//         title: 'PharmaCare',
//         theme:     AppTheme.light,
//         darkTheme: AppTheme.dark,
//         themeMode: themeMode.toFlutterThemeMode(),
//         routerConfig: appRouter,
//       );
//     }
//   }
//
// STEP 4 — Add ThemeModeSelector to your Settings screen
// ─────────────────────────────────────────────────────────────────────────────
//   import 'features/settings/presentation/widgets/theme_mode_selector.dart';
//
//   // Inside SettingsScreen body:
//   const ThemeModeSelector(),
//
// STEP 5 — Optional: status bar icon color follows theme
// ─────────────────────────────────────────────────────────────────────────────
//   // AppBarTheme in AppTheme.light/dark already sets foregroundColor,
//   // which Flutter uses to auto-adjust system status bar brightness
//   // on most platforms. No extra code needed.