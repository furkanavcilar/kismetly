import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow with timeout
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn()
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              debugPrint('Google Sign-In timeout');
              throw TimeoutException('Google giriş zaman aşımına uğradı', const Duration(seconds: 60));
            },
          );

      if (googleUser == null) {
        // User canceled the sign-in
        debugPrint('Google Sign-In: User canceled');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('Google authentication timeout');
              throw TimeoutException('Google kimlik doğrulama zaman aşımına uğradı', const Duration(seconds: 30));
            },
          );

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (credential.accessToken == null && credential.idToken == null) {
        debugPrint('Google Sign-In: Invalid credential - missing tokens');
        throw Exception('Google giriş bilgileri geçersiz');
      }

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('Firebase sign-in timeout');
              throw TimeoutException('Firebase giriş zaman aşımına uğradı', const Duration(seconds: 30));
            },
          );

      // Save user data to Firestore (non-blocking - don't fail if this fails)
      if (userCredential.user != null) {
        _saveUserToFirestore(userCredential.user!).catchError((e) {
          debugPrint('Firestore save failed (non-critical): $e');
          // Don't throw - this is optional
        });
      }

      return userCredential;
    } on TimeoutException catch (e) {
      debugPrint('Google Sign-In timeout error: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}

