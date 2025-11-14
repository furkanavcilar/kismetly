import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/ai_engine/ai_orchestrator.dart';
import '../../../services/daily_limits_service.dart';
import '../../../services/monetization/monetization_service.dart';
import '../../../core/widgets/premium_dialog.dart';
import '../../../features/paywall/upgrade_screen.dart';

/// Dream Interpretation Service - Uses new AI Engine
class DreamService {
  DreamService({
    AIOrchestrator? orchestrator,
    DailyLimitsService? dailyLimits,
    MonetizationService? monetization,
  })  : _orchestrator = orchestrator ?? AIOrchestrator(),
        _dailyLimits = dailyLimits ?? DailyLimitsService(),
        _monetization = monetization ?? MonetizationService.instance;

  final AIOrchestrator _orchestrator;
  final DailyLimitsService _dailyLimits;
  final MonetizationService _monetization;

  /// Interpret dream (1 free per day)
  Future<String?> interpretDream({
    required String dreamText,
    required String language,
    Map<String, dynamic>? userContext,
    BuildContext? context,
  }) async {
    if (dreamText.trim().isEmpty) {
      return null;
    }

    // Check daily limit
    final canUse = await _dailyLimits.canUseFeature('dream');
    if (!canUse && !_monetization.isPremium) {
      if (context != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen()),
        );
      }
      return null;
    }

    try {
      final result = await _orchestrator.generateDreamInterpretation(
        dreamText: dreamText,
        language: language,
        userContext: userContext,
      );

      // Record usage
      await _dailyLimits.recordFeatureUse('dream');

      return result;
    } catch (e) {
      debugPrint('DreamService: Error - $e');
      return language == 'tr'
          ? 'Rüya analizi üretilemiyor. Lütfen tekrar deneyin.'
          : 'Cannot generate dream analysis. Please try again.';
    }
  }
}

