import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/auth/presentation/pages/login_page.dart';
import 'package:fetansuki_app/features/auth/presentation/pages/register_page.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:fetansuki_app/features/auth/presentation/providers/auth_state.dart';
import 'package:fetansuki_app/features/dashboard/presentation/pages/home_page.dart';
import 'package:fetansuki_app/features/stock/presentation/pages/stock_page.dart';
import 'package:fetansuki_app/features/credit/presentation/pages/credit_page.dart';
import 'package:fetansuki_app/features/settings/presentation/pages/settings_page.dart';
import 'package:fetansuki_app/features/main_nav/presentation/pages/main_nav_page.dart';

import 'package:fetansuki_app/features/splash/presentation/pages/splash_page.dart';

// Navigator Keys for maintaining state
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authStateNotifier = ValueNotifier<AuthStatus>(AuthStatus.initial);

  ref.listen<AuthState>(
    authNotifierProvider,
    (_, next) {
      authStateNotifier.value = next.status;
    },
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      
      final isSplash = state.uri.path == '/splash';
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';

      if (authState.status == AuthStatus.loading) {
        return null;
      }

      // If on splash, let the splash timer handle navigation
      if (isSplash) {
        return null;
      }

      // If not logged in and not on a public page, redirect to login
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
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stock',
                builder: (context, state) => const StockPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/credit',
                builder: (context, state) => const CreditPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
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