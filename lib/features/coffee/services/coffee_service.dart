import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/ai_engine/ai_orchestrator.dart';
import '../../../services/daily_limits_service.dart';
import '../../../services/monetization/monetization_service.dart';
import '../../../features/paywall/upgrade_screen.dart';

/// Coffee Fortune Service - Uses new AI Engine with Vision AI
class CoffeeService {
  CoffeeService({
    AIOrchestrator? orchestrator,
    DailyLimitsService? dailyLimits,
    MonetizationService? monetization,
  })  : _orchestrator = orchestrator ?? AIOrchestrator(),
        _dailyLimits = dailyLimits ?? DailyLimitsService(),
        _monetization = monetization ?? MonetizationService.instance;

  final AIOrchestrator _orchestrator;
  final DailyLimitsService _dailyLimits;
  final MonetizationService _monetization;

  /// Generate coffee reading from image (1 free per day)
  /// Returns 5-8 paragraphs as specified
  Future<String?> generateCoffeeReading({
    required List<String> imageBase64,
    required String language,
    Map<String, dynamic>? userContext,
    BuildContext? context,
  }) async {
    if (imageBase64.isEmpty) {
      return null;
    }

    // Check daily limit
    final canUse = await _dailyLimits.canUseFeature('coffee');
    if (!canUse && !_monetization.isPremium) {
      if (context != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen()),
        );
      }
      return null;
    }

    try {
      final result = await _orchestrator.generateCoffeeReading(
        imageBase64: imageBase64,
        language: language,
        userContext: userContext,
      );

      // Record usage
      await _dailyLimits.recordFeatureUse('coffee');

      return result;
    } catch (e) {
      debugPrint('CoffeeService: Error - $e');
      return language == 'tr'
          ? 'Kahve falı okuması üretilemiyor. Lütfen tekrar deneyin.'
          : 'Cannot generate coffee reading. Please try again.';
    }
  }
}

