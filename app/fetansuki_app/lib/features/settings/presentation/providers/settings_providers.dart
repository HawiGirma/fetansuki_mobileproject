import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/di/providers.dart';
import 'package:fetansuki_app/core/utils/constants.dart';
import 'package:fetansuki_app/features/settings/data/datasources/settings_mock_data_source.dart';
import 'package:fetansuki_app/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:fetansuki_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fetansuki_app/features/settings/domain/entities/settings_data.dart';
import 'package:fetansuki_app/features/settings/domain/repositories/settings_repository.dart';

// Data Sources
final settingsMockDataSourceProvider = Provider<SettingsMockDataSource>((ref) {
  return SettingsMockDataSource();
});

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final useMock = AppConstants.useMockData;
  final mockDataSource = ref.watch(settingsMockDataSourceProvider);
  final remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);

  return SettingsRepositoryImpl(
    dataSource: useMock ? mockDataSource : remoteDataSource,
  );
});

// Data Provider
final settingsDataProvider = FutureProvider<SettingsData>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  final result = await repository.getSettingsData();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});
