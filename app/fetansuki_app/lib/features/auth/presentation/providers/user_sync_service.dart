import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/di/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// a provider that listens to Firebase Auth state changes and syncs the user to Firestore.
final userSyncProvider = Provider<void>((ref) {
  final authChanges = ref.watch(firebaseAuthProvider).authStateChanges();
  final firestore = FirebaseFirestore.instance;

  authChanges.listen((User? user) async {
    if (user != null) {
      try {
        await firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName ?? 'User',
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('Automatically synced user ${user.uid} to Firestore');
      } catch (e) {
        print('Automatic sync to Firestore failed: $e');
      }
    }
  });
});
