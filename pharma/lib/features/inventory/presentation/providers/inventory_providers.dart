import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/inventory_remote_datasource.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';
import '../../domain/usecases/get_expiring_medicines_usecase.dart';
import '../../domain/usecases/get_low_stock_medicines_usecase.dart';
import '../../domain/usecases/purchase_order_usecases.dart';
import '../../domain/usecases/receive_stock_usecase.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────
final firestoreProvider = Provider<FirebaseFirestore>(
    (_) => FirebaseFirestore.instance);

// ── Data layer ────────────────────────────────────────────────────────────────
final inventoryRemoteDataSourceProvider =
    Provider<InventoryRemoteDataSource>((ref) =>
        InventoryRemoteDataSourceImpl(ref.read(firestoreProvider)));

// ── Repository ────────────────────────────────────────────────────────────────
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) =>
    InventoryRepositoryImpl(ref.read(inventoryRemoteDataSourceProvider)));

// ── Use cases ─────────────────────────────────────────────────────────────────
final receiveStockUseCaseProvider = Provider<ReceiveStockUseCase>((ref) =>
    ReceiveStockUseCase(ref.read(inventoryRepositoryProvider)));

final adjustStockUseCaseProvider = Provider<AdjustStockUseCase>((ref) =>
    AdjustStockUseCase(ref.read(inventoryRepositoryProvider)));

final getLowStockUseCaseProvider =
    Provider<GetLowStockMedicinesUseCase>((ref) =>
        GetLowStockMedicinesUseCase(ref.read(inventoryRepositoryProvider)));

final watchLowStockUseCaseProvider =
    Provider<WatchLowStockMedicinesUseCase>((ref) =>
        WatchLowStockMedicinesUseCase(ref.read(inventoryRepositoryProvider)));

final getExpiringUseCaseProvider =
    Provider<GetExpiringMedicinesUseCase>((ref) =>
        GetExpiringMedicinesUseCase(ref.read(inventoryRepositoryProvider)));

final watchExpiringUseCaseProvider =
    Provider<WatchExpiringMedicinesUseCase>((ref) =>
        WatchExpiringMedicinesUseCase(ref.read(inventoryRepositoryProvider)));

final getPurchaseOrdersUseCaseProvider =
    Provider<GetPurchaseOrdersUseCase>((ref) =>
        GetPurchaseOrdersUseCase(ref.read(inventoryRepositoryProvider)));

final createPurchaseOrderUseCaseProvider =
    Provider<CreatePurchaseOrderUseCase>((ref) =>
        CreatePurchaseOrderUseCase(ref.read(inventoryRepositoryProvider)));

final receivePurchaseOrderUseCaseProvider =
    Provider<ReceivePurchaseOrderUseCase>((ref) =>
        ReceivePurchaseOrderUseCase(ref.read(inventoryRepositoryProvider)));

final cancelPurchaseOrderUseCaseProvider =
    Provider<CancelPurchaseOrderUseCase>((ref) =>
        CancelPurchaseOrderUseCase(ref.read(inventoryRepositoryProvider)));