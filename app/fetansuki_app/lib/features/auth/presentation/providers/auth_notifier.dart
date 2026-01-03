import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:fetansuki_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fetansuki_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_state.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_providers.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _loginUseCase = ref.watch(loginUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    
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
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _loginUseCase(email, password);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
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