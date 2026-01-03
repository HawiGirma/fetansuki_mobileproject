import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/auth/presentation/pages/login_page.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_state.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // We use a ValueNotifier to notify GoRouter when auth state changes.
  final authStateNotifier = ValueNotifier<AuthStatus>(AuthStatus.initial);

  ref.listen<AuthState>(
    authNotifierProvider,
    (_, next) {
      authStateNotifier.value = next.status;
    },
  );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggingIn = state.uri.path == '/login';
      final isLoggedIn = authState.status == AuthStatus.authenticated;

      if (authState.status == AuthStatus.loading) {
        return null; // Or a loading route
      }

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Dashboard (Protected)')),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
});