import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';
import 'monetization/monetization_service.dart';

/// Daily Free Limits Service
/// 
/// Tracks daily usage in Firestore: users/{uid}/daily_usage/{yyyy-MM-dd}
/// 
/// Limits:
/// - Dream → 1/day
/// - Tarot → 1/day
/// - Palm → 1/day
/// - Coffee → 1/day
/// - Compatibility → 1/day
class DailyLimitsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MonetizationService _monetizationService = MonetizationService.instance;

  /// Get date key in format yyyy-MM-dd
  String _getDateKey(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  /// Check if user can use a feature (1 free per day)
  Future<bool> canUseFeature(String featureName) async {
    final user = _auth.currentUser;
    
    // Premium users have unlimited access
    if (_monetizationService.isPremium) {
      return true;
    }
    
    // Dev bypass
    if (AppConfig.shouldBypassLimits(user?.email)) {
      debugPrint('Dev mode: bypassing daily limit for $featureName');
      return true;
    }
    
    if (user == null) {
      // Guest users - check local storage or allow first use
      return true;
    }

    try {
      final todayKey = _getDateKey(DateTime.now());
      final usageDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_usage')
          .doc(todayKey)
          .get();

      if (!usageDoc.exists) {
        return true; // No usage today
      }

      final data = usageDoc.data();
      if (data == null) {
        return true;
      }

      final used = data[featureName] as bool? ?? false;
      return !used; // Can use if not used today
    } catch (e) {
      debugPrint('Error checking daily limit: $e');
      return true; // Fail open
    }
  }

  /// Record feature usage
  Future<void> recordFeatureUse(String featureName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Premium users don't need tracking
    if (_monetizationService.isPremium) {
      return;
    }

    try {
      final todayKey = _getDateKey(DateTime.now());
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_usage')
          .doc(todayKey)
          .set({
        featureName: true,
        'date': todayKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error recording feature use: $e');
    }
  }

  /// Get remaining free uses for today
  Future<Map<String, bool>> getTodayLimits() async {
    final user = _auth.currentUser;
    
    // Premium users have unlimited
    if (_monetizationService.isPremium) {
      return {
        'dream': true,
        'tarot': true,
        'palm': true,
        'coffee': true,
        'compatibility': true,
      };
    }
    
    if (user == null) {
      return {
        'dream': true,
        'tarot': true,
        'palm': true,
        'coffee': true,
        'compatibility': true,
      };
    }

    try {
      final todayKey = _getDateKey(DateTime.now());
      final usageDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_usage')
          .doc(todayKey)
          .get();

      if (!usageDoc.exists) {
        return {
          'dream': true,
          'tarot': true,
          'palm': true,
          'coffee': true,
          'compatibility': true,
        };
      }

      final data = usageDoc.data();
      if (data == null) {
        return {
          'dream': true,
          'tarot': true,
          'palm': true,
          'coffee': true,
          'compatibility': true,
        };
      }

      return {
        'dream': !(data['dream'] as bool? ?? false),
        'tarot': !(data['tarot'] as bool? ?? false),
        'palm': !(data['palm'] as bool? ?? false),
        'coffee': !(data['coffee'] as bool? ?? false),
        'compatibility': !(data['compatibility'] as bool? ?? false),
      };
    } catch (e) {
      debugPrint('Error getting daily limits: $e');
      return {
        'dream': true,
        'tarot': true,
        'palm': true,
        'coffee': true,
        'compatibility': true,
      };
    }
  }
}
