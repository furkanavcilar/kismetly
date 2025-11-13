import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        await createUser(uid);
        return null;
      }
      return doc.data();
    } catch (e) {
      debugPrint('getUserData error: $e');
      return null;
    }
  }

  Future<void> createUser(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'isPremium': false,
        'credits': 0,
        'premiumUntil': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'email': user.email,
        'displayName': user.displayName,
      });
    } catch (e) {
      debugPrint('createUser error: $e');
    }
  }

  Future<void> updateUserPremium(
    String uid, {
    required bool isPremium,
    DateTime? premiumUntil,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isPremium': isPremium,
        'premiumUntil': premiumUntil != null ? Timestamp.fromDate(premiumUntil) : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('updateUserPremium error: $e');
    }
  }

  Future<void> updateUserCredits(String uid, int credits) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'credits': credits,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('updateUserCredits error: $e');
    }
  }
}


