import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Core Services
import '../core/network/network_info.dart';
import '../core/network/api_client.dart';


// Firebase
final firebaseCoreProvider = Provider<FirebaseApp>((ref) {
  throw UnimplementedError('FirebaseApp must be initialized in main.dart');
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
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
  final String firebaseProjectId;
  final bool isDebugMode;

  const AppConfig({
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
        firebaseProjectId: 'fetansuki-dev',
        isDebugMode: true,
      );
    case Environment.staging:
      return const AppConfig(
        firebaseProjectId: 'fetansuki-staging',
        isDebugMode: false,
      );
    case Environment.production:
      return const AppConfig(
        firebaseProjectId: 'fetansuki-app',
        isDebugMode: false,
      );
  }
});
