import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../../services/monetization/monetization_service.dart';

/// Universal Usage Limiter for freemium features
/// 
/// Provides 3 free uses per feature per day.
/// After 3 uses, shows premium dialog.
/// 
/// Feature keys (constants):
/// - dream_interpretation
/// - tarot_reading
/// - coffee_fortune
/// - zodiac_ai_query
/// - home_energy_insights
/// - daily_horoscope
/// - welcome_message (optional, can be exempted if desired)
class UsageLimiter {
  UsageLimiter({
    SharedPreferences? prefs,
    MonetizationService? monetizationService,
  })  : _prefsFuture = prefs != null
            ? Future.value(prefs)
            : SharedPreferences.getInstance(),
        _monetizationService = monetizationService;

  final Future<SharedPreferences> _prefsFuture;
  final MonetizationService? _monetizationService;

  static const int _freeUsesPerDay = 3;

  /// Feature keys constants
  static const String featureDreamInterpretation = 'dream_interpretation';
  static const String featureCoffeeFortune = 'coffee_fortune';
  static const String featureTarotReading = 'tarot_reading';
  static const String featureDailyHoroscope = 'daily_horoscope';
  static const String featureZodiacAiQuery = 'zodiac_ai_query';
  static const String featureHomeEnergyInsights = 'home_energy_insights';
  static const String featureWelcomeMessage = 'welcome_message'; // Optional
  static const String _storageKey = 'feature_usage';

  // Feature key constants
  static const String dreamInterpretation = 'dream_interpretation';
  static const String tarotReading = 'tarot_reading';
  static const String coffeeFortune = 'coffee_fortune';
  static const String zodiacAiQuery = 'zodiac_ai_query';
  static const String homeEnergyInsights = 'home_energy_insights';
  static const String dailyHoroscope = 'daily_horoscope';
  static const String welcomeMessage = 'welcome_message';

  /// Get date key for today (YYYY-MM-DD)
  String _todayKey() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  /// Check if user can use a feature
  /// 
  /// Returns true if:
  /// - User has premium subscription
  /// - User hasn't exceeded 3 free uses today
  /// - In debug mode (for testing)
  Future<bool> canUseFeature(String featureKey) async {
    // Check if premium user
    final monetization = _monetizationService ?? MonetizationService.instance;
    if (monetization.isPremium) {
      return true;
    }

    // Debug mode bypass - allow unlimited uses in debug/profile builds
    if (kDebugMode) {
      debugPrint('UsageLimiter: Debug mode - allowing unlimited usage for testing');
      return true;
    }

    // Dev bypass (legacy support)
    if (AppConfig.kIsDevPreview) {
      // Allow unlimited in dev mode
      return true;
    }

    // Check daily usage
    final prefs = await _prefsFuture;
    final todayKey = _todayKey();
    final usageKey = 'usage_$featureKey';
    final usageData = prefs.getString(usageKey);
    
    if (usageData == null) {
      // No usage recorded
      return true;
    }

    try {
      final Map<String, dynamic> usage = jsonDecode(usageData);
      final lastDate = usage['date'] as String?;
      final count = usage['count'] as int? ?? 0;

      if (lastDate != todayKey) {
        // Different day, reset
        return true;
      }

      return count < _freeUsesPerDay;
    } catch (e) {
      debugPrint('UsageLimiter: Error parsing usage data: $e');
      return true; // Fail open
    }
  }

  /// Register feature usage
  /// 
  /// Increments daily usage counter for the feature
  Future<void> recordUsage(String featureKey) async {
    final monetization = _monetizationService ?? MonetizationService.instance;
    if (monetization.isPremium) {
      // Premium users don't need to track usage
      return;
    }

    final prefs = await _prefsFuture;
    final todayKey = _todayKey();
    final usageKey = 'usage_$featureKey';
    final usageData = prefs.getString(usageKey);
    
    int count = 0;
    String? lastDate;

    if (usageData != null) {
      try {
        final Map<String, dynamic> usage = jsonDecode(usageData);
        lastDate = usage['date'] as String?;
        count = usage['count'] as int? ?? 0;
      } catch (e) {
        debugPrint('UsageLimiter: Error parsing usage data: $e');
      }
    }

    if (lastDate != todayKey) {
      // New day, reset count
      count = 1;
    } else {
      // Same day, increment
      count++;
    }

    await prefs.setString(
      usageKey,
      jsonEncode({
        'date': todayKey,
        'count': count,
      }),
    );
  }

  /// Get remaining free uses for today
  /// 
  /// Returns 3 - currentCount
  Future<int> getRemainingUses(String featureKey) async {
    final monetization = _monetizationService ?? MonetizationService.instance;
    if (monetization.isPremium) {
      return -1; // Unlimited for premium
    }

    final prefs = await _prefsFuture;
    final todayKey = _todayKey();
    final usageKey = 'usage_$featureKey';
    final usageData = prefs.getString(usageKey);

    if (usageData == null) {
      return _freeUsesPerDay;
    }

    try {
      final Map<String, dynamic> usage = jsonDecode(usageData);
      final lastDate = usage['date'] as String?;
      final count = usage['count'] as int? ?? 0;

      if (lastDate != todayKey) {
        return _freeUsesPerDay;
      }

      final remaining = _freeUsesPerDay - count;
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      debugPrint('UsageLimiter: Error parsing usage data: $e');
      return _freeUsesPerDay;
    }
  }

  /// Reset all usage counters (for testing or admin)
  Future<void> resetUsage(String? featureKey) async {
    final prefs = await _prefsFuture;
    
    if (featureKey != null) {
      await prefs.remove('usage_$featureKey');
    } else {
      // Reset all feature usage
      final featureKeys = [
        dreamInterpretation,
        tarotReading,
        coffeeFortune,
        zodiacAiQuery,
        homeEnergyInsights,
        dailyHoroscope,
        welcomeMessage,
      ];
      
      for (final key in featureKeys) {
        await prefs.remove('usage_$key');
      }
    }
  }
}

