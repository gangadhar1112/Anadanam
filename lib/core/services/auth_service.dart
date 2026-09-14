import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firestore_service.dart';
import 'notification_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  AuthService(this._ref);

  // ============================================================
  // AUTH STATE
  // ============================================================

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  bool get isAdmin => currentUser?.email == 'gangadharg1112@gmail.com';

  // ============================================================
  // EMAIL SIGN IN
  // ============================================================

  Future<UserCredential?> signInWithEmail(
      String email,
      String password,
      ) async {
    try {
      final UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await syncUserProfile(
          credential.user!,
        );
      }

      return credential;
    } catch (e) {
      print('Email Sign In Error: $e');
      rethrow;
    }
  }

  // ============================================================
  // EMAIL SIGN UP
  // ============================================================

  Future<UserCredential?> signUpWithEmail(
      String email,
      String password,
      String name,
      ) async {
    try {
      final UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(
          name,
        );

        await syncUserProfile(
          credential.user!,
        );
      }

      return credential;
    } catch (e) {
      print('Email Sign Up Error: $e');
      rethrow;
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset Password Error: $e');
      rethrow;
    }
  }
 
  // ============================================================
  // FACEBOOK SIGN IN
  // ============================================================

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;

        if (accessToken == null) {
          throw Exception('Facebook access token is missing');
        }

        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );

        if (userCredential.user != null) {
          await syncUserProfile(
            userCredential.user!,
          );
        }

        return userCredential;
      } else if (result.status == LoginStatus.cancelled) {
        print('Facebook login cancelled by user');
        return null;
      } else {
        final errorMsg = result.message ?? 'Status: ${result.status}';
        print('Facebook login failed: $errorMsg');
        throw Exception('Facebook login failed: $errorMsg');
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Facebook login: ${e.code} - ${e.message}');
      throw Exception('Firebase Auth (${e.code}): ${e.message ?? 'Invalid credential'}');
    } catch (e) {
      print('Facebook Sign In Error: $e');
      rethrow;
    }
  }

  // ============================================================
  // SYNC USER PROFILE
  // ============================================================

  Future<void> syncUserProfile(
      User user,
      ) async {
    try {
      final DocumentReference userRef =
      _firestore.collection('users').doc(user.uid);

      final DocumentSnapshot userDoc =
      await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'displayName':
          user.displayName ?? 'User',
          'photoUrl': user.photoURL,
          'isGuest': user.isAnonymous,
        });
      } else {
        await userRef.update({
          if (user.displayName != null)
            'displayName': user.displayName,

          if (user.photoURL != null)
            'photoUrl': user.photoURL,

          if (user.email != null)
            'email': user.email,

          'isGuest': user.isAnonymous,
        });
      }

      // --------------------------------------------------------
      // Save FCM token
      // --------------------------------------------------------

      try {
        final String? token =
        await FirebaseMessaging.instance.getToken();

        if (token != null) {
          await _ref
              .read(notificationServiceProvider)
              .updateToken(
            user.uid,
            token,
          );
        }
      } catch (e) {
        print(
          'Unable to save FCM token: $e',
        );
      }
    } catch (e) {
      print(
        'Error syncing user profile: $e',
      );
      rethrow;
    }
  }

  // ============================================================
  // ANONYMOUS SIGN IN
  // ============================================================

  Future<UserCredential?> signInAnonymously() async {
    try {
      final UserCredential credential =
      await _auth.signInAnonymously();

      if (credential.user != null) {
        await syncUserProfile(
          credential.user!,
        );
      }

      return credential;
    } catch (e) {
      print(
        'Anonymous Sign In Error: $e',
      );

      return null;
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print(
        'Facebook logout error: $e',
      );
    }

    await _auth.signOut();
    
    // Stop notification listener
    _ref.read(notificationServiceProvider).stopListening();
  }
}