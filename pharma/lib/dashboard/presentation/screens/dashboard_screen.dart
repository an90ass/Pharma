import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/activity_tile.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/stat_card.dart';

/// Admin dashboard screen — entry point after login.
///
/// Uses [AsyncValue.when] for automatic loading / error / data handling.
/// Pull-to-refresh and a refresh icon button trigger [DashboardViewModel.refresh].
///
/// Zero business logic — all data fetching is in [DashboardViewModel].
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _buildAppBar(context, ref, statsAsync),
      body: statsAsync.when(
        loading: () => const _DashboardShimmer(),
        error: (error, _) => _DashboardError(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref
              .read(dashboardViewModelProvider.notifier)
              .refresh(),
        ),
        data: (stats) => RefreshIndicator(
          color: const Color(0xFF1565C0),
          onRefresh: () =>
              ref.read(dashboardViewModelProvider.notifier).refresh(),
          child: _DashboardContent(stats: stats),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, AsyncValue statsAsync) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FC),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.local_pharmacy_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Pharma',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
      actions: [
        // Refresh button
        IconButton(
          onPressed:(){
            statsAsync.isLoading
              ? null
              : () => ref
                  .read(dashboardViewModelProvider.notifier)
                  .refresh();
print("Dashboard State: ${statsAsync.runtimeType}");
    if (statsAsync.hasError) {
      print("Error details: ${statsAsync.error}");
    }
          } ,
          icon: statsAsync.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF1565C0),
                ),
          tooltip: 'Refresh dashboard',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}


class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.stats});

  final dynamic stats; // DashboardStats

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        // Header
        DashboardHeader(
          userName: 'Admin',
          totalAlerts: stats.totalAlerts,
          onAlertTap: () => context.go('/notifications'),
        ),
        const SizedBox(height: 24),

        // ── Alert banner ─────────────────────────────────────────────────
        if (stats.hasAlerts) ...[
          _AlertBanner(
            lowStockCount: stats.lowStockCount,
            expiringCount: stats.expiringCount,
          ),
          const SizedBox(height: 20),
        ],

        // ── Today's sales highlight ──────────────────────────────────────
        _TodaysSalesCard(stats: stats),
        const SizedBox(height: 20),

        // ── KPI grid — row 1 ─────────────────────────────────────────────
        _SectionLabel(label: 'Inventory overview'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: [
            StatCard(
              label: 'Total medicines',
              value: stats.totalMedicines,
              icon: Icons.medication_rounded,
              color: const Color(0xFF1565C0),
            ),
            StatCard(
              label: 'Total customers',
              value: stats.totalCustomers,
              icon: Icons.people_rounded,
              color: const Color(0xFF00897B),
            ),
            StatCard(
              label: 'Suppliers',
              value: stats.totalSuppliers,
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFF7B1FA2),
            ),
            StatCard(
              label: 'Monthly sales',
              value: stats.monthlySalesAmount,
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF2E7D32),
              isCurrency: true,
              subtitle: '${stats.monthlySalesCount} invoices',
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Alert cards row ───────────────────────────────────────────────
        _SectionLabel(label: 'Alerts'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Low stock',
                value: stats.lowStockCount,
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFF44336),
                isAlert: stats.lowStockCount > 0,
                subtitle: 'below reorder level',
                onTap: () => context.go('/inventory'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Expiring soon',
                value: stats.expiringCount,
                icon: Icons.hourglass_bottom_rounded,
                color: const Color(0xFFFF5722),
                isAlert: stats.expiringCount > 0,
                subtitle: 'within 30 days',
                onTap: () => context.go('/inventory'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Quick actions ─────────────────────────────────────────────────
        _SectionLabel(label: 'Quick actions'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.85,
          children: [
            QuickActionButton(
              label: 'New sale',
              icon: Icons.point_of_sale_rounded,
              color: const Color(0xFF1565C0),
              onTap: () => context.go('/pos'),
            ),
            QuickActionButton(
              label: 'Add medicine',
              icon: Icons.medication_rounded,
              color: const Color(0xFF2E7D32),
              onTap: () => context.go('/medicines/add'),
            ),
            QuickActionButton(
              label: 'Purchase order',
              icon: Icons.shopping_cart_rounded,
              color: const Color(0xFF7B1FA2),
              onTap: () => context.go('/inventory/orders/new'),
            ),
            QuickActionButton(
              label: 'Add customer',
              icon: Icons.person_add_rounded,
              color: const Color(0xFF00897B),
              onTap: () => context.go('/customers/add'),
            ),
            QuickActionButton(
              label: 'Inventory',
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFFE65100),
              onTap: () => context.go('/inventory'),
            ),
            QuickActionButton(
              label: 'Reports',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF0277BD),
              onTap: () => context.go('/reports'),
            ),
            QuickActionButton(
              label: 'Suppliers',
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFF6A1B9A),
              onTap: () => context.go('/suppliers'),
            ),
            QuickActionButton(
              label: 'Settings',
              icon: Icons.settings_rounded,
              color: const Color(0xFF37474F),
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Recent activity ───────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel(label: 'Recent activity'),
            TextButton(
              onPressed: () => context.go('/sales'),
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.06),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: stats.recentActivities.isEmpty
              ? const _EmptyActivity()
              : Column(
                  children: [
                    for (int i = 0;
                        i < stats.recentActivities.length;
                        i++) ...[
                      ActivityTile(
                          activity: stats.recentActivities[i]),
                      if (i < stats.recentActivities.length - 1)
                        Divider(
                          height: 1,
                          color: Colors.black.withOpacity(0.06),
                        ),
                    ],
                  ],
                ),
        ),

        // Last updated
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Last updated: ${_formatTime(stats.fetchedAt)}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime t) {
    return DateFormat('h:mm a').format(t);
  }
}

// ── Sub-components ─────────────────────────────────────────────────────────────

class _TodaysSalesCard extends StatelessWidget {
  const _TodaysSalesCard({required this.stats});
  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s sales',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatter.format(stats.todaySalesAmount),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricPill(
                label: '${stats.todaySalesCount} invoices',
                icon: Icons.receipt_long_rounded,
              ),
              const SizedBox(width: 10),
              _MetricPill(
                label: 'Avg ${formatter.format(stats.avgTodaySale)}',
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner(
      {required this.lowStockCount, required this.expiringCount});
  final int lowStockCount;
  final int expiringCount;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (lowStockCount > 0) parts.add('$lowStockCount low-stock items');
    if (expiringCount > 0) parts.add('$expiringCount expiring soon');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFFFB74D).withOpacity(0.6), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded,
              color: Color(0xFFF57C00), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Attention needed: ${parts.join(' · ')}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE65100),
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/notifications'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 28),
            ),
            child: const Text(
              'View',
              style: TextStyle(fontSize: 12, color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
        letterSpacing: -0.2,
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 32, color: Color(0xFFCCCCCC)),
            SizedBox(height: 8),
            Text(
              'No recent activity',
              style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading shimmer ────────────────────────────────────────────────────────────

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ShimmerBox(width: double.infinity, height: 60),
        const SizedBox(height: 20),
        _ShimmerBox(width: double.infinity, height: 130),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: List.generate(4, (_) =>
              _ShimmerBox(width: double.infinity, height: 100)),
        ),
        const SizedBox(height: 20),
        _ShimmerBox(width: double.infinity, height: 200),
      ],
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({required this.width, required this.height});
  final double width;
  final double height;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_anim.value * 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFE53935),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load dashboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
