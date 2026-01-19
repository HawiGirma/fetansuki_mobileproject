import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/core/utils/constants.dart';
import 'package:fetansuki_app/features/stock/data/datasources/stock_mock_data_source.dart';
import 'package:fetansuki_app/features/stock/data/datasources/stock_remote_data_source.dart';
import 'package:fetansuki_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fetansuki_app/features/stock/domain/repositories/stock_repository.dart';
import 'package:fetansuki_app/features/stock/presentation/providers/stock_creation_notifier.dart';
import 'package:fetansuki_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Data Sources
final stockMockDataSourceProvider = Provider<StockMockDataSource>((ref) {
  return StockMockDataSource();
});

final stockRemoteDataSourceProvider = Provider<StockRemoteDataSource>((ref) {
  final firestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  
  return StockRemoteDataSource(
    firestore: firestore,
    firebaseAuth: firebaseAuth,
  );
});

// Repository
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  // Use the global constant directly for now, or we could make a provider for it if we needed dynamic switching again.
  // Since the requirement is to use AppConstants.useMockData:
  final useMock = AppConstants.useMockData;
  final mockDataSource = ref.watch(stockMockDataSourceProvider);
  final remoteDataSource = ref.watch(stockRemoteDataSourceProvider);

  return StockRepositoryImpl(
    dataSource: useMock ? mockDataSource : remoteDataSource,
  );
});

// Data Provider
final stockDataProvider = FutureProvider<StockData>((ref) async {
  final repository = ref.watch(stockRepositoryProvider);
  final result = await repository.getStockData();
  
  return result.fold(
    (failure) {
      print('STOCK ERROR: ${failure.message}');
      return throw Exception(failure.message);
    },
    (data) => data,
  );
});

// Stock Creation Provider
final stockCreationProvider = StateNotifierProvider<StockCreationNotifier, StockCreationState>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return StockCreationNotifier(repository, notificationRepository);
});

