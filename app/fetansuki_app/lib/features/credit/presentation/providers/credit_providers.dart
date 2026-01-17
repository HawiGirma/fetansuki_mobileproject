import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/core/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fetansuki_app/features/credit/presentation/providers/credit_update_notifier.dart';
import 'package:fetansuki_app/features/credit/data/datasources/credit_mock_data_source.dart';
import 'package:fetansuki_app/features/credit/data/datasources/credit_remote_data_source.dart';
import 'package:fetansuki_app/features/credit/data/repositories/credit_repository_impl.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_data.dart';
import 'package:fetansuki_app/features/credit/domain/repositories/credit_repository.dart';

// Data Sources
final creditMockDataSourceProvider = Provider<CreditMockDataSource>((ref) {
  return CreditMockDataSource();
});

final creditRemoteDataSourceProvider = Provider<CreditRemoteDataSource>((ref) {
  return CreditRemoteDataSource(
    firestore: FirebaseFirestore.instance,
    firebaseAuth: FirebaseAuth.instance,
  );
});

// Repository
final creditRepositoryProvider = Provider<CreditRepository>((ref) {
  final useMock = AppConstants.useMockData;
  final mockDataSource = ref.watch(creditMockDataSourceProvider);
  final remoteDataSource = ref.watch(creditRemoteDataSourceProvider);

  return CreditRepositoryImpl(
    dataSource: useMock ? mockDataSource : remoteDataSource,
  );
});

// Data Provider
final creditDataProvider = FutureProvider<CreditData>((ref) async {
  final repository = ref.watch(creditRepositoryProvider);
  final result = await repository.getCreditData();
  
  return result.fold(
    (failure) {
      print('CREDIT ERROR: ${failure.message}');
      return throw Exception(failure.message);
    },
    (data) => data,
  );
});
final creditUpdateProvider = StateNotifierProvider<CreditUpdateNotifier, CreditUpdateState>((ref) {
  final repository = ref.watch(creditRepositoryProvider);
  return CreditUpdateNotifier(repository);
});
