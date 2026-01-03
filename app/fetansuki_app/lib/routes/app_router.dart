import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/auth/presentation/pages/login_page.dart';
import 'package:fetansuki_app/features/auth/presentation/pages/register_page.dart';
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
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';

      if (authState.status == AuthStatus.loading) {
        return null; // Or a loading route
      }

      // If not logged in and not on a public page (login or register), redirect to login
      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      // If logged in and trying to access auth pages, redirect to dashboard
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
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
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
});
