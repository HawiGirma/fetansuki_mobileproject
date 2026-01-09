import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/core/utils/constants.dart';
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
  return CreditRemoteDataSource();
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
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});
