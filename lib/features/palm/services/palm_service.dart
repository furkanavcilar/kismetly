import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/ai_engine/ai_orchestrator.dart';
import '../../../services/daily_limits_service.dart';
import '../../../services/monetization/monetization_service.dart';
import '../../../features/paywall/upgrade_screen.dart';

/// Palm Reading Service - Uses new AI Engine with Vision AI
class PalmService {
  PalmService({
    AIOrchestrator? orchestrator,
    DailyLimitsService? dailyLimits,
    MonetizationService? monetization,
  })  : _orchestrator = orchestrator ?? AIOrchestrator(),
        _dailyLimits = dailyLimits ?? DailyLimitsService(),
        _monetization = monetization ?? MonetizationService.instance;

  final AIOrchestrator _orchestrator;
  final DailyLimitsService _dailyLimits;
  final MonetizationService _monetization;

  /// Generate palm reading from image (1 free per day)
  /// Returns 6+ paragraphs as specified
  Future<String?> generatePalmReading({
    required List<String> imageBase64,
    required String language,
    required String handType, // 'left' or 'right'
    Map<String, dynamic>? userContext,
    BuildContext? context,
  }) async {
    if (imageBase64.isEmpty) {
      return null;
    }

    // Check daily limit
    final canUse = await _dailyLimits.canUseFeature('palm');
    if (!canUse && !_monetization.isPremium) {
      if (context != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen()),
        );
      }
      return null;
    }

    try {
      final result = await _orchestrator.generatePalmReading(
        imageBase64: imageBase64,
        language: language,
        handType: handType,
        userContext: userContext,
      );

      // Record usage
      await _dailyLimits.recordFeatureUse('palm');

      return result;
    } catch (e) {
      debugPrint('PalmService: Error - $e');
      return language == 'tr'
          ? 'El falı okuması üretilemiyor. Lütfen tekrar deneyin.'
          : 'Cannot generate palm reading. Please try again.';
    }
  }
}

