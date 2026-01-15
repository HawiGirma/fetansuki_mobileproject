import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/di/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// a provider that listens to Firebase Auth state changes and syncs the user to Supabase.
final userSyncProvider = Provider<void>((ref) {
  final authChanges = ref.watch(firebaseAuthProvider).authStateChanges();
  final supabase = ref.watch(supabaseClientProvider);

  authChanges.listen((User? user) async {
    if (user != null) {
      try {
        await supabase.from('users').upsert({
          'id': user.uid,
          'email': user.email,
          'name': user.displayName ?? 'User',
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
        print('Automatically synced user ${user.uid} to Supabase');
      } catch (e) {
        print('Automatic sync failed: $e');
      }
    }
  });
});
