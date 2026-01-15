import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fetansuki_app/app.dart';
import 'package:fetansuki_app/di/providers.dart';
import 'package:fetansuki_app/firebase_options.dart';
import 'package:fetansuki_app/core/utils/helpers.dart';

/// A simple provider observer that logs all changes in providers for production debugging.
final class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    Helpers.printLog('Provider ${provider.name ?? provider.runtimeType} updated to: $newValue');
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    Helpers.printLog('Provider ${provider.name ?? provider.runtimeType} added with: $value');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    Helpers.printLog('Provider ${provider.name ?? provider.runtimeType} failed with error: $error');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase core services
    final firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Local Storage
    final sharedPreferences = await SharedPreferences.getInstance();

    // Load Environment Variables
    await dotenv.load(fileName: "assets/.env");

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    runApp(
      ProviderScope(
        overrides: [
          // Injecting the initialized dependencies into the provider tree
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          firebaseCoreProvider.overrideWithValue(firebaseApp),
          supabaseClientProvider.overrideWithValue(Supabase.instance.client),
        ],
        observers: [
          AppProviderObserver(),
        ],
        child: const FetansukiApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Handle initialization errors
    Helpers.printLog('Failed to initialize app: $e');
    Helpers.printLog('Stack trace: $stackTrace');
    
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to initialize the app: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => main(), // Retry initialization
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
