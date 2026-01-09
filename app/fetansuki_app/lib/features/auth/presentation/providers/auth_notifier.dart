import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:fetansuki_app/features/auth/data/models/user_model.dart';
import 'package:fetansuki_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:fetansuki_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fetansuki_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:fetansuki_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_state.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_providers.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final AuthRepository _authRepository;
  late final AuthLocalDataSource _localDataSource;

  @override
  AuthState build() {
    _loginUseCase = ref.watch(loginUseCaseProvider);
    _registerUseCase = ref.watch(registerUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _localDataSource = ref.watch(authLocalDataSourceProvider);
    
    // Trigger initial check
    Future.microtask(() => checkAuthStatus());
    
    return const AuthState();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      // TEMPORARY: Simulate successful login for UI testing
      await Future.delayed(const Duration(seconds: 1));
      const mockUser = UserModel(
        id: '1',
        email: 'mock@example.com',
        name: 'Mock User',
      );
      
      // Persist mock user
      await _localDataSource.cacheUser(mockUser);
      
      state = state.copyWith(status: AuthStatus.authenticated, user: mockUser);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      // TEMPORARY: Simulate successful registration for UI testing
      await Future.delayed(const Duration(seconds: 1));
      final mockUser = UserModel(
        id: '2',
        email: email,
        name: name,
      );

      // Persist mock user
      await _localDataSource.cacheUser(mockUser);

      state = state.copyWith(status: AuthStatus.authenticated, user: mockUser);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _logoutUseCase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated, user: null),
    );
  }
}