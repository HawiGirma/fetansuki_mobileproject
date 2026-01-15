import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core Services
import '../core/network/network_info.dart';
import '../core/network/api_client.dart';

// Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  throw UnimplementedError('SupabaseClient must be provided in main.dart');
});

// Firebase
final firebaseCoreProvider = Provider<FirebaseApp>((ref) {
  throw UnimplementedError('FirebaseApp must be initialized in main.dart');
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// External Services
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be provided in main.dart');
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.sendTimeout = const Duration(seconds: 30);
  
  // Add logging in debug mode
  if (!const bool.fromEnvironment('dart.vm.product')) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          print(object);
        },
      ),
    );
  }
  
  return dio;
});

final internetConnectionCheckerProvider = Provider<InternetConnectionChecker>((ref) {
  return InternetConnectionChecker.createInstance();
});

// Core Dependencies
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(internetConnectionCheckerProvider));
});

// API Client (using existing ApiClient from core/network)
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio: dio);
});

// Environment Configuration
class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String supabaseFunctionsUrl;
  final String firebaseProjectId;
  final bool isDebugMode;

  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.supabaseFunctionsUrl,
    required this.firebaseProjectId,
    required this.isDebugMode,
  });
}

enum Environment { development, staging, production }

final environmentProvider = Provider<Environment>((ref) {
  // This should be determined at runtime based on environment variables or build configuration
  return Environment.development; // Default to development
});

final appConfigProvider = Provider<AppConfig>((ref) {
  final environment = ref.watch(environmentProvider);
  
  switch (environment) {
    case Environment.development:
      return const AppConfig(
        supabaseUrl: 'https://xxxx-dev.supabase.co',
        supabaseAnonKey: 'your-dev-anon-key',
        supabaseFunctionsUrl: 'https://xxxx-dev.supabase.co/functions/v1',
        firebaseProjectId: 'fetansuki-dev',
        isDebugMode: true,
      );
    case Environment.staging:
      return const AppConfig(
        supabaseUrl: 'https://xxxx-staging.supabase.co',
        supabaseAnonKey: 'your-staging-anon-key',
        supabaseFunctionsUrl: 'https://xxxx-staging.supabase.co/functions/v1',
        firebaseProjectId: 'fetansuki-staging',
        isDebugMode: false,
      );
    case Environment.production:
      return const AppConfig(
        supabaseUrl: 'https://xxxx.supabase.co',
        supabaseAnonKey: 'your-prod-anon-key',
        supabaseFunctionsUrl: 'https://xxxx.supabase.co/functions/v1',
        firebaseProjectId: 'fetansuki-app',
        isDebugMode: false,
      );
  }
});
