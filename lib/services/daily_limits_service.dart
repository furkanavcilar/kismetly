import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';

class DailyLimitsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user can use a feature (1 free per day)
  Future<bool> canUseFeature(String featureName) async {
    final user = _auth.currentUser;
    
    // Dev bypass: if in dev mode and user email matches test domains, bypass limits
    if (AppConfig.shouldBypassLimits(user?.email)) {
      debugPrint('Dev mode: bypassing daily limit for $featureName');
      return true;
    }
    
    if (user == null) return true; // Guest users have limits too, but we'll track locally

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();
      
      if (data == null) return true;

      final dailyLimits = data['dailyLimits'] as Map<String, dynamic>? ?? {};
      final lastUsed = dailyLimits[featureName] as Timestamp?;

      if (lastUsed == null) return true;

      final lastUsedDate = lastUsed.toDate();
      final now = DateTime.now();
      
      // Check if last use was today
      final isSameDay = lastUsedDate.year == now.year &&
          lastUsedDate.month == now.month &&
          lastUsedDate.day == now.day;

      return !isSameDay;
    } catch (e) {
      debugPrint('Error checking daily limit: $e');
      return true; // Fail open
    }
  }

  /// Record feature usage
  Future<void> recordFeatureUse(String featureName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'dailyLimits': {
          featureName: FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error recording feature use: $e');
    }
  }

  /// Get remaining free uses for today
  Future<Map<String, bool>> getTodayLimits() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'coffee': true,
        'dream': true,
        'palm': true,
        'tarot': true,
        'compatibility': true,
      };
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();
      
      if (data == null) {
        return {
          'coffee': true,
          'dream': true,
          'palm': true,
          'tarot': true,
          'compatibility': true,
        };
      }

      final dailyLimits = data['dailyLimits'] as Map<String, dynamic>? ?? {};
      final now = DateTime.now();
      
      final limits = <String, bool>{};
      for (final feature in ['coffee', 'dream', 'palm', 'tarot', 'compatibility']) {
        final lastUsed = dailyLimits[feature] as Timestamp?;
        if (lastUsed == null) {
          limits[feature] = true;
        } else {
          final lastUsedDate = lastUsed.toDate();
          final isSameDay = lastUsedDate.year == now.year &&
              lastUsedDate.month == now.month &&
              lastUsedDate.day == now.day;
          limits[feature] = !isSameDay;
        }
      }
      
      return limits;
    } catch (e) {
      debugPrint('Error getting daily limits: $e');
      return {
        'coffee': true,
        'dream': true,
        'palm': true,
        'tarot': true,
        'compatibility': true,
      };
    }
  }
}

