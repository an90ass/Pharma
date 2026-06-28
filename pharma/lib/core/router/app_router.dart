import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharma/features/settings/presentation/screens/settings_screen.dart';

import '../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/medicines/presentation/screens/add_medicine_screen.dart';
import '../../features/medicines/presentation/screens/medicine_list_screen.dart';


final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
    GoRoute(
        path: '/',
        builder: (_, __) => const DashboardScreen(),
      ),
  GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
    GoRoute(
        path: '/medicines',
        builder: (_, __) => const MedicineListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, __) => const AddMedicineScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) => Scaffold(
              appBar: AppBar(
                title: const Text('Edit Medicine'),
                backgroundColor: const Color(0xFFF7F8FC),
                elevation: 0,
              ),
              body: Center(
                child: Text(
                  'Edit Medicine: ${state.pathParameters['id']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),

    ],

      errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 44, color: Color(0xFFE53935)),
            const SizedBox(height: 12),
            const Text('Page not found',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => GoRouter.of(context).go('/'),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0)),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});