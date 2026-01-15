import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:fetansuki_app/core/utils/constants.dart';
import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(String name, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  GoogleSignIn? _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw ServerException('Login failed: No user returned');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: user.displayName ?? 'User',
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw ServerException('Registration failed: No user returned');
      }

      // Update display name
      await user.updateDisplayName(name);
      await user.reload();

      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: name,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Lazy initialize GoogleSignIn only when needed
      _googleSignIn ??= GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: kIsWeb ? AppConstants.googleWebClientId : null,
      );

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        throw ServerException('Google sign-in cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw ServerException('Google sign-in failed: No user returned');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        if (_googleSignIn != null) _googleSignIn!.signOut(),
      ]);
    } catch (e) {
      throw ServerException('Sign out failed: ${e.toString()}');
    }
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UnauthorizedException('No user found with this email');
      case 'wrong-password':
        return UnauthorizedException('Wrong password');
      case 'email-already-in-use':
        return ServerException('Email already in use');
      case 'weak-password':
        return ServerException('Password is too weak');
      case 'invalid-email':
        return ServerException('Invalid email address');
      case 'user-disabled':
        return UnauthorizedException('This account has been disabled');
      case 'too-many-requests':
        return ServerException('Too many requests. Please try again later');
      case 'operation-not-allowed':
        return ServerException('Operation not allowed');
      case 'invalid-credential':
        return UnauthorizedException('Invalid credentials');
      default:
        return ServerException(e.message ?? 'Authentication failed');
    }
  }
}