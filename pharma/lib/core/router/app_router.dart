import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharma/features/inventory/presentation/screens/create_purchase_order_screen.dart';
import 'package:pharma/features/inventory/presentation/screens/purchase_orders_screen.dart';
import 'package:pharma/features/reports/presentation/screens/reports_screen.dart' show ReportsScreen;
import 'package:pharma/features/settings/presentation/screens/settings_screen.dart';
import 'package:pharma/features/stores/presentation/screens/store_management_screen.dart';
import 'package:pharma/features/suppliers/presentation/screens/supplier_list_screen.dart';

import '../../features/customers/presentation/screens/add_customer_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/medicines/presentation/screens/add_medicine_screen.dart';
import '../../features/medicines/presentation/screens/medicine_list_screen.dart';
import '../../features/sales/presentation/screens/cart_screen.dart';
import '../../features/sales/presentation/screens/invoice_detail_screen.dart';
import '../../features/sales/presentation/screens/pos_screen.dart';
import '../../features/sales/presentation/screens/sales_history_screen.dart';


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
  GoRoute(
        path: '/customers',
        builder: (_, __) => const CustomerListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, __) => const AddCustomerScreen(),
          ),

  
        ],
      ),
       GoRoute(
        path: '/pos',
        builder: (_, __) => const POSScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: '/sales',
        builder: (_, __) => const SalesHistoryScreen(),
      ),
      GoRoute(
        path: '/invoices/:id',
        builder: (_, state) =>
            InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
      ),
 GoRoute(
        path: '/inventory',
        builder: (_, __) => const InventoryScreen(),
        routes: [
          GoRoute(
            path: 'receive',
            builder: (_, __) => Scaffold(
              appBar: AppBar(
                title: const Text('Receive Stock'),
                backgroundColor: const Color(0xFFF7F8FC),
                elevation: 0,
              ),
              body: const Center(child: Text('Receive Stock Screen')),
            ),
          ),
          GoRoute(
            path: 'adjust',
            builder: (_, __) => Scaffold(
              appBar: AppBar(
                title: const Text('Adjust Stock'),
                backgroundColor: const Color(0xFFF7F8FC),
                elevation: 0,
              ),
              body: const Center(child: Text('Adjust Stock Screen')),
            ),
          ),
          GoRoute(
            path: 'orders',
            builder: (_, __) => const PurchaseOrdersScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const CreatePurchaseOrderScreen(),
              ),
            ],
          ),
        ],
      ),
          GoRoute(
        path: '/suppliers',
        builder: (_, __) => const SupplierListScreen(),
      ),
  GoRoute(
        path: '/reports',
        builder: (_, __) => const ReportsScreen(),
      ),
            GoRoute(
        path: '/stores',
        builder: (_, __) => const StoreManagementScreen(),
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