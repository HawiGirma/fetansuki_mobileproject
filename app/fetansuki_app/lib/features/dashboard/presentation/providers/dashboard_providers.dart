import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/dashboard/data/datasources/dashboard_mock_data_source.dart';
import 'package:fetansuki_app/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:fetansuki_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fetansuki_app/features/dashboard/domain/repositories/dashboard_repository.dart';

import 'package:fetansuki_app/core/utils/constants.dart';

// 1. Data Sources
final dashboardMockDataSourceProvider = Provider<DashboardMockDataSource>((ref) {
  return DashboardMockDataSource();
});

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(
    firestore: FirebaseFirestore.instance,
    firebaseAuth: FirebaseAuth.instance,
  );
});

// 2. Configuration Flag
final useMockDashboardProvider = NotifierProvider<UseMockDashboardNotifier, bool>(UseMockDashboardNotifier.new);

class UseMockDashboardNotifier extends Notifier<bool> {
  @override
  bool build() => AppConstants.useMockData;

  void toggle() {
    state = !state;
  }
}

// 3. Repository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final useMock = ref.watch(useMockDashboardProvider);
  final mockDataSource = ref.watch(dashboardMockDataSourceProvider);
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);

  return DashboardRepositoryImpl(
    dataSource: useMock ? mockDataSource : remoteDataSource,
  );
});

// 4. Data Provider (Controller/ViewModel)
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.getDashboardData();
  
  return result.fold(
    (failure) {
      // Print the real error to Chrome console as per user checklist
      print('DASHBOARD ERROR: ${failure.message}');
      return throw Exception(failure.message);
    },
    (data) => data,
  );
});
