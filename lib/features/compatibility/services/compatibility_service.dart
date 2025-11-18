import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/backend_api.dart';
import '../../../services/daily_limits_service.dart';
import '../../../services/monetization/monetization_service.dart';
import '../../../features/paywall/upgrade_screen.dart';

/// Compatibility Service - Uses Backend API
class CompatibilityService {
  CompatibilityService({
    BackendApi? api,
    DailyLimitsService? dailyLimits,
    MonetizationService? monetization,
  })  : _api = api ?? BackendApi(),
        _dailyLimits = dailyLimits ?? DailyLimitsService(),
        _monetization = monetization ?? MonetizationService.instance;

  final BackendApi _api;
  final DailyLimitsService _dailyLimits;
  final MonetizationService _monetization;

  /// Generate compatibility analysis (1 free per day)
  /// Returns all required sections: emotional harmony, sexual chemistry, communication flow, life path alignment, conflict resolution, long-term advice
  Future<Map<String, String>?> generateCompatibility({
    required String firstSign,
    required String secondSign,
    required String language,
    Map<String, dynamic>? userContext,
    BuildContext? context,
  }) async {
    // Check daily limit
    final canUse = await _dailyLimits.canUseFeature('compatibility');
    if (!canUse && !_monetization.isPremium) {
      if (context != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen()),
        );
      }
      return null;
    }

    try {
      final response = await _api.post('/api/compatibility/analyze', 
        body: {
          'sign1': firstSign.toLowerCase(),
          'sign2': secondSign.toLowerCase(),
        },
        language: language,
      );

      final analysis = response['analysis'] as String?;
      if (analysis == null || analysis.isEmpty) {
        throw Exception('Empty response from backend');
      }

      // Parse analysis into sections
      final sections = <String, String>{
        'summary': analysis,
        'love': analysis,
        'family': analysis,
        'career': analysis,
        'strengths': analysis,
        'challenges': analysis,
        'communication': analysis,
        'longTerm': analysis,
      };

      // Record usage
      await _dailyLimits.recordFeatureUse('compatibility');

      return sections;
    } catch (e) {
      debugPrint('CompatibilityService: Error - $e');
      throw Exception(language == 'tr'
          ? 'Uyumluluk analizi üretilemiyor: $e'
          : 'Cannot generate compatibility analysis: $e');
    }
  }
}
