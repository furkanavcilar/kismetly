import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/backend_api.dart';
import '../../../services/daily_limits_service.dart';
import '../../../services/monetization/monetization_service.dart';
import '../../../features/paywall/upgrade_screen.dart';

/// Dream Interpretation Service - Uses Backend API
class DreamService {
  DreamService({
    BackendApi? api,
    DailyLimitsService? dailyLimits,
    MonetizationService? monetization,
  })  : _api = api ?? BackendApi(),
        _dailyLimits = dailyLimits ?? DailyLimitsService(),
        _monetization = monetization ?? MonetizationService.instance;

  final BackendApi _api;
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
      final response = await _api.post('/api/dreams/interpret', 
        body: {
          'description': dreamText,
          'mood': userContext?['mood'],
          'date': DateTime.now().toIso8601String(),
        },
        language: language,
      );

      final interpretation = response['interpretation'] as String?;
      if (interpretation == null || interpretation.isEmpty) {
        throw Exception('Empty response from backend');
      }

      // Record usage
      await _dailyLimits.recordFeatureUse('dream');

      return interpretation;
    } catch (e) {
      debugPrint('DreamService: Error - $e');
      throw Exception(language == 'tr'
          ? 'Rüya analizi üretilemiyor: $e'
          : 'Cannot generate dream analysis: $e');
    }
  }
}

