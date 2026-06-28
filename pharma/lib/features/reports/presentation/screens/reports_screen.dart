import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/reports_viewmodel.dart';
import 'tabs/daily_sales_tab.dart';
import 'tabs/weekly_sales_tab.dart';
import 'tabs/monthly_sales_tab.dart';
import 'tabs/top_medicines_tab.dart';
import 'tabs/profit_report_tab.dart';
import 'tabs/inventory_report_tab.dart';

/// Main Reports & Analytics screen.
///
/// 6 tabs: Daily · Weekly · Monthly · Top Medicines · Profit · Inventory
/// Each tab is its own widget for readability — see screens/tabs/.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    (ReportTab.daily,        'Daily',   Icons.today_rounded),
    (ReportTab.weekly,       'Weekly',  Icons.calendar_view_week_rounded),
    (ReportTab.monthly,      'Monthly', Icons.calendar_month_rounded),
    (ReportTab.topMedicines, 'Top Items', Icons.star_rounded),
    (ReportTab.profit,       'Profit',  Icons.trending_up_rounded),
    (ReportTab.inventory,    'Inventory', Icons.inventory_2_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final tab = _tabs[_tabController.index].$1;
      ref.read(reportsViewModelProvider.notifier).switchTab(tab);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Reports & Analytics',
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF1565C0)),
            onPressed: state.isLoading
                ? null
                : () => ref
                    .read(reportsViewModelProvider.notifier)
                    .loadReport(state.selectedTab),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF1565C0),
          labelColor: const Color(0xFF1565C0),
          unselectedLabelColor: const Color(0xFF888888),
          labelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600),
          tabs: _tabs
              .map((t) => Tab(
                    icon: Icon(t.$3, size: 18),
                    text: t.$2,
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DailySalesTab(),
          WeeklySalesTab(),
          MonthlySalesTab(),
          TopMedicinesTab(),
          ProfitReportTab(),
          InventoryReportTab(),
        ],
      ),
    );
  }
}