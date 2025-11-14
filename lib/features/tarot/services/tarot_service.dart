import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/ai_engine/ai_orchestrator.dart';
import '../../../services/daily_limits_service.dart';
import '../../../services/monetization/monetization_service.dart';
import '../../../features/paywall/upgrade_screen.dart';

/// Tarot Reading Service - Uses new AI Engine
class TarotService {
  TarotService({
    AIOrchestrator? orchestrator,
    DailyLimitsService? dailyLimits,
    MonetizationService? monetization,
  })  : _orchestrator = orchestrator ?? AIOrchestrator(),
        _dailyLimits = dailyLimits ?? DailyLimitsService(),
        _monetization = monetization ?? MonetizationService.instance;

  final AIOrchestrator _orchestrator;
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
      final result = await _orchestrator.generateTarotReading(
        cardNames: cardNames,
        language: language,
        spreadType: spreadType,
        userContext: userContext,
      );

      // Record usage
      await _dailyLimits.recordFeatureUse('tarot');

      return result;
    } catch (e) {
      debugPrint('TarotService: Error - $e');
      return language == 'tr'
          ? 'Tarot okuması üretilemiyor. Lütfen tekrar deneyin.'
          : 'Cannot generate tarot reading. Please try again.';
    }
  }
}

