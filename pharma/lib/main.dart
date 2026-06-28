import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma/features/settings/presentation/providers/theme_providers.dart';
import 'package:pharma/features/settings/presentation/viewmodels/theme_viewmodel.dart';
import 'package:pharma/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on PlatformException catch (e, stack) {
    debugPrint('Firebase initialization PlatformException: $e');
    debugPrintStack(stackTrace: stack);
    if (e.code == 'channel-error') {
      debugPrint(
        'CRITICAL: Platform channel connection failed. '
        'This is usually resolved by running "flutter clean", "flutter pub get", and rebuilding the app.',
      );
    }
    rethrow;
  } catch (e, stack) {
    debugPrint('Failed to initialize Firebase: $e');
    debugPrintStack(stackTrace: stack);
    rethrow;
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const PharmacyApp(),
    ),
  );
}

class PharmacyApp extends ConsumerWidget {
  const PharmacyApp({super.key});

  @override

  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeViewModelProvider);

    return MaterialApp.router(
      title:        'Pharma',
      debugShowCheckedModeBanner: false,
      theme:        AppTheme.light,
      darkTheme:    AppTheme.dark,
      themeMode:    themeMode.toFlutterThemeMode(),
      routerConfig: router,
    );
  }
}