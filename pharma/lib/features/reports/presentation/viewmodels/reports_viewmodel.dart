import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/inventory_report_entity.dart';
import '../../domain/entities/profit_report_entity.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../../domain/entities/top_medicine_entity.dart';
import '../../domain/usecases/get_inventory_report_usecase.dart';
import '../../domain/usecases/get_profit_report_usecase.dart';
import '../../domain/usecases/get_sales_report_usecase.dart';
import '../../domain/usecases/get_top_medicines_usecase.dart';
import '../providers/reports_providers.dart';

// ── Report tabs ───────────────────────────────────────────────────────────────

enum ReportTab { daily, weekly, monthly, topMedicines, profit, inventory }

enum ReportStatus { idle, loading, success, error }

// ── State ─────────────────────────────────────────────────────────────────────

class ReportsState {
  const ReportsState({
    this.selectedTab        = ReportTab.daily,
    this.status             = ReportStatus.idle,
    this.errorMessage,
    this.salesReport,
    this.topMedicines       = const [],
    this.profitReport,
    this.inventoryReport,
    this.selectedDate,
    this.selectedMonth,
    this.selectedYear,
    this.customFrom,
    this.customTo,
  });

  final ReportTab    selectedTab;
  final ReportStatus status;
  final String?      errorMessage;
  final SalesReportEntity?      salesReport;
  final List<TopMedicineEntity> topMedicines;
  final ProfitReportEntity?      profitReport;
  final InventoryReportEntity?   inventoryReport;
  final DateTime? selectedDate;
  final int?      selectedMonth;
  final int?      selectedYear;
  final DateTime? customFrom;
  final DateTime? customTo;

  bool get isLoading => status == ReportStatus.loading;

  ReportsState copyWith({
    ReportTab?    selectedTab,
    ReportStatus? status,
    String?       errorMessage,
    SalesReportEntity?      salesReport,
    List<TopMedicineEntity>? topMedicines,
    ProfitReportEntity?      profitReport,
    InventoryReportEntity?   inventoryReport,
    DateTime? selectedDate,
    int?      selectedMonth,
    int?      selectedYear,
    DateTime? customFrom,
    DateTime? customTo,
    bool clearError = false,
  }) {
    return ReportsState(
      selectedTab:     selectedTab     ?? this.selectedTab,
      status:          status          ?? this.status,
      errorMessage:    clearError ? null : errorMessage ?? this.errorMessage,
      salesReport:     salesReport     ?? this.salesReport,
      topMedicines:    topMedicines    ?? this.topMedicines,
      profitReport:    profitReport    ?? this.profitReport,
      inventoryReport: inventoryReport ?? this.inventoryReport,
      selectedDate:    selectedDate    ?? this.selectedDate,
      selectedMonth:   selectedMonth   ?? this.selectedMonth,
      selectedYear:    selectedYear    ?? this.selectedYear,
      customFrom:      customFrom      ?? this.customFrom,
      customTo:        customTo        ?? this.customTo,
    );
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class ReportsViewModel extends Notifier<ReportsState> {
  late GetDailySalesReportUseCase    _getDaily;
  late GetWeeklySalesReportUseCase   _getWeekly;
  late GetMonthlySalesReportUseCase  _getMonthly;
  late GetCustomRangeReportUseCase   _getCustom;
  late GetTopSellingMedicinesUseCase _getTopMeds;
  late GetProfitReportUseCase        _getProfit;
  late GetInventoryReportUseCase     _getInventory;

  @override
  ReportsState build() {
    _getDaily     = ref.read(getDailySalesReportUseCaseProvider);
    _getWeekly    = ref.read(getWeeklySalesReportUseCaseProvider);
    _getMonthly   = ref.read(getMonthlySalesReportUseCaseProvider);
    _getCustom    = ref.read(getCustomRangeReportUseCaseProvider);
    _getTopMeds   = ref.read(getTopSellingMedicinesUseCaseProvider);
    _getProfit    = ref.read(getProfitReportUseCaseProvider);
    _getInventory = ref.read(getInventoryReportUseCaseProvider);

    final now = DateTime.now();
    final initial = ReportsState(
      selectedDate:  now,
      selectedMonth: now.month,
      selectedYear:  now.year,
    );
    Future.microtask(() => loadReport(ReportTab.daily, initialState: initial));
    return initial;
  }

  // ── Switch tab ───────────────────────────────────────────────────────────
  Future<void> switchTab(ReportTab tab) async {
    state = state.copyWith(selectedTab: tab, clearError: true);
    await loadReport(tab);
  }

  // ── Load report based on tab ──────────────────────────────────────────────
  Future<void> loadReport(ReportTab tab, {ReportsState? initialState}) async {
    final s = initialState ?? state;
    state = s.copyWith(status: ReportStatus.loading, clearError: true);

    switch (tab) {
      case ReportTab.daily:
        await _loadDaily(s.selectedDate ?? DateTime.now());
        break;
      case ReportTab.weekly:
        await _loadWeekly(_weekStart(s.selectedDate ?? DateTime.now()));
        break;
      case ReportTab.monthly:
        await _loadMonthly(
            s.selectedYear ?? DateTime.now().year,
            s.selectedMonth ?? DateTime.now().month);
        break;
      case ReportTab.topMedicines:
        await _loadTopMedicines();
        break;
      case ReportTab.profit:
        await _loadProfit();
        break;
      case ReportTab.inventory:
        await _loadInventory();
        break;
    }
  }

  // ── Date navigation ────────────────────────────────────────────────────────
  Future<void> goToPreviousPeriod() async {
    switch (state.selectedTab) {
      case ReportTab.daily:
        final newDate = (state.selectedDate ?? DateTime.now())
            .subtract(const Duration(days: 1));
        state = state.copyWith(selectedDate: newDate);
        await _loadDaily(newDate);
        break;
      case ReportTab.weekly:
        final newDate = (state.selectedDate ?? DateTime.now())
            .subtract(const Duration(days: 7));
        state = state.copyWith(selectedDate: newDate);
        await _loadWeekly(_weekStart(newDate));
        break;
      case ReportTab.monthly:
        var m = (state.selectedMonth ?? DateTime.now().month) - 1;
        var y = state.selectedYear ?? DateTime.now().year;
        if (m == 0) { m = 12; y -= 1; }
        state = state.copyWith(selectedMonth: m, selectedYear: y);
        await _loadMonthly(y, m);
        break;
      default:
        break;
    }
  }

  Future<void> goToNextPeriod() async {
    final now = DateTime.now();
    switch (state.selectedTab) {
      case ReportTab.daily:
        final newDate = (state.selectedDate ?? now).add(const Duration(days: 1));
        if (newDate.isAfter(now)) return;
        state = state.copyWith(selectedDate: newDate);
        await _loadDaily(newDate);
        break;
      case ReportTab.weekly:
        final newDate = (state.selectedDate ?? now).add(const Duration(days: 7));
        if (newDate.isAfter(now)) return;
        state = state.copyWith(selectedDate: newDate);
        await _loadWeekly(_weekStart(newDate));
        break;
      case ReportTab.monthly:
        var m = (state.selectedMonth ?? now.month) + 1;
        var y = state.selectedYear ?? now.year;
        if (m == 13) { m = 1; y += 1; }
        if (DateTime(y, m, 1).isAfter(now)) return;
        state = state.copyWith(selectedMonth: m, selectedYear: y);
        await _loadMonthly(y, m);
        break;
      default:
        break;
    }
  }

  // ── Individual loaders ─────────────────────────────────────────────────────

  Future<void> _loadDaily(DateTime date) async {
    final result = await _getDaily(DailyReportParams(date));
    result.fold(
      (f) => state = state.copyWith(
          status: ReportStatus.error, errorMessage: f.message),
      (r) => state = state.copyWith(
          status: ReportStatus.success, salesReport: r),
    );
  }

  Future<void> _loadWeekly(DateTime weekStart) async {
    final result = await _getWeekly(WeeklyReportParams(weekStart));
    result.fold(
      (f) => state = state.copyWith(
          status: ReportStatus.error, errorMessage: f.message),
      (r) => state = state.copyWith(
          status: ReportStatus.success, salesReport: r),
    );
  }

  Future<void> _loadMonthly(int year, int month) async {
    final result = await _getMonthly(
        MonthlyReportParams(year: year, month: month));
    result.fold(
      (f) => state = state.copyWith(
          status: ReportStatus.error, errorMessage: f.message),
      (r) => state = state.copyWith(
          status: ReportStatus.success, salesReport: r),
    );
  }

  Future<void> loadCustomRange(DateTime from, DateTime to) async {
    state = state.copyWith(
        status: ReportStatus.loading,
        customFrom: from, customTo: to,
        clearError: true);
    final result = await _getCustom(CustomRangeParams(from: from, to: to));
    result.fold(
      (f) => state = state.copyWith(
          status: ReportStatus.error, errorMessage: f.message),
      (r) => state = state.copyWith(
          status: ReportStatus.success, salesReport: r),
    );
  }

  Future<void> _loadTopMedicines() async {
    final now  = DateTime.now();
    final from = DateTime(now.year, now.month - 1, now.day);
    final result = await _getTopMeds(
        TopMedicinesParams(from: from, to: now, limit: 10));
    result.fold(
      (f) => state = state.copyWith(
          status: ReportStatus.error, errorMessage: f.message),
      (r) => state = state.copyWith(
          status: ReportStatus.success, topMedicines: r),
    );
  }

  Future<void> _loadProfit() async {
    final now  = DateTime.now();
    final from = DateTime(now.year, now.month - 5, 1); // last 6 months
    final result = await _getProfit(ProfitReportParams(from: from, to: now));
    result.fold(
      (f) => state = state.copyWith(
          status: ReportStatus.error, errorMessage: f.message),
      (r) => state = state.copyWith(
          status: ReportStatus.success, profitReport: r),
    );
  }

  Future<void> _loadInventory() async {
    final result = await _getInventory(const NoParams());
    result.fold(
      (f) => state = state.copyWith(
          status: ReportStatus.error, errorMessage: f.message),
      (r) => state = state.copyWith(
          status: ReportStatus.success, inventoryReport: r),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  DateTime _weekStart(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));
}

final reportsViewModelProvider =
    NotifierProvider<ReportsViewModel, ReportsState>(ReportsViewModel.new);