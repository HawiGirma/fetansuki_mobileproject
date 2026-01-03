import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:fetansuki_app/app.dart';
import 'package:fetansuki_app/di/providers.dart';
import 'package:fetansuki_app/firebase_options.dart';
import 'package:fetansuki_app/core/utils/helpers.dart';

/// A simple provider observer that logs all changes in providers for production debugging.
final class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    Helpers.printLog('Provider ${context.provider.name ?? context.provider.runtimeType} updated to: $newValue');
  }

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    Helpers.printLog('Provider ${context.provider.name ?? context.provider.runtimeType} added with: $value');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Helpers.printLog('Provider ${context.provider.name ?? context.provider.runtimeType} failed with error: $error');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase core services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Local Storage
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Injecting the initialized SharedPreferences into the provider tree
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      observers: [
        AppProviderObserver(),
      ],
      child: const FetansukiApp(),
    ),
  );
}
