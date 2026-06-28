import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/reports_remote_datasource.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/get_inventory_report_usecase.dart';
import '../../domain/usecases/get_profit_report_usecase.dart';
import '../../domain/usecases/get_sales_report_usecase.dart';
import '../../domain/usecases/get_top_medicines_usecase.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────
final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

// ── Data layer ────────────────────────────────────────────────────────────────
final reportsRemoteDataSourceProvider =
    Provider<ReportsRemoteDataSource>((ref) =>
        ReportsRemoteDataSourceImpl(ref.read(firestoreProvider)));

// ── Repository ────────────────────────────────────────────────────────────────
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) =>
    ReportsRepositoryImpl(ref.read(reportsRemoteDataSourceProvider)));

// ── Use cases ─────────────────────────────────────────────────────────────────
final getDailySalesReportUseCaseProvider =
    Provider<GetDailySalesReportUseCase>((ref) =>
        GetDailySalesReportUseCase(ref.read(reportsRepositoryProvider)));

final getWeeklySalesReportUseCaseProvider =
    Provider<GetWeeklySalesReportUseCase>((ref) =>
        GetWeeklySalesReportUseCase(ref.read(reportsRepositoryProvider)));

final getMonthlySalesReportUseCaseProvider =
    Provider<GetMonthlySalesReportUseCase>((ref) =>
        GetMonthlySalesReportUseCase(ref.read(reportsRepositoryProvider)));

final getCustomRangeReportUseCaseProvider =
    Provider<GetCustomRangeReportUseCase>((ref) =>
        GetCustomRangeReportUseCase(ref.read(reportsRepositoryProvider)));

final getTopSellingMedicinesUseCaseProvider =
    Provider<GetTopSellingMedicinesUseCase>((ref) =>
        GetTopSellingMedicinesUseCase(ref.read(reportsRepositoryProvider)));

final getProfitReportUseCaseProvider =
    Provider<GetProfitReportUseCase>((ref) =>
        GetProfitReportUseCase(ref.read(reportsRepositoryProvider)));

final getInventoryReportUseCaseProvider =
    Provider<GetInventoryReportUseCase>((ref) =>
        GetInventoryReportUseCase(ref.read(reportsRepositoryProvider)));