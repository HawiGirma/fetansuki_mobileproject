import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/di/providers.dart';
import 'package:fetansuki_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:fetansuki_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fetansuki_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fetansuki_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fetansuki_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:fetansuki_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fetansuki_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_state.dart';

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// Notifier
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});