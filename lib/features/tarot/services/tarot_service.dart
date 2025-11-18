import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/backend_api.dart';
import '../../../services/daily_limits_service.dart';
import '../../../services/monetization/monetization_service.dart';
import '../../../features/paywall/upgrade_screen.dart';

/// Tarot Reading Service - Uses Backend API
class TarotService {
  TarotService({
    BackendApi? api,
    DailyLimitsService? dailyLimits,
    MonetizationService? monetization,
  })  : _api = api ?? BackendApi(),
        _dailyLimits = dailyLimits ?? DailyLimitsService(),
        _monetization = monetization ?? MonetizationService.instance;

  final BackendApi _api;
  final DailyLimitsService _dailyLimits;
  final MonetizationService _monetization;

  /// Generate tarot reading (1 free per day)
  Future<String?> generateTarotReading({
    required List<String> cardNames,
    required String language,
    required String spreadType,
    Map<String, dynamic>? userContext,
    BuildContext? context,
  }) async {
    if (cardNames.isEmpty) {
      return null;
    }

    // Check daily limit
    final canUse = await _dailyLimits.canUseFeature('tarot');
    if (!canUse && !_monetization.isPremium) {
      if (context != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen()),
        );
      }
      return null;
    }

    try {
      final response = await _api.post('/api/tarot/draw', 
        body: {
          'question': userContext?['question'] ?? 'General guidance',
          'spreadType': spreadType,
        },
        language: language,
      );

      final reading = response['reading'] as String?;
      if (reading == null || reading.isEmpty) {
        throw Exception('Empty response from backend');
      }

      // Record usage
      await _dailyLimits.recordFeatureUse('tarot');

      return reading;
    } catch (e) {
      debugPrint('TarotService: Error - $e');
      throw Exception(language == 'tr'
          ? 'Tarot okuması üretilemiyor: $e'
          : 'Cannot generate tarot reading: $e');
    }
  }
}

