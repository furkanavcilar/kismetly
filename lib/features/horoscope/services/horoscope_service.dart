import 'package:flutter/foundation.dart';

import '../../../core/ai_engine/ai_orchestrator.dart';
import '../../../services/daily_limits_service.dart';
import '../../../services/monetization/monetization_service.dart';

/// Horoscope Service - Uses new AI Engine
class HoroscopeService {
  HoroscopeService({
    AIOrchestrator? orchestrator,
    DailyLimitsService? dailyLimits,
    MonetizationService? monetization,
  })  : _orchestrator = orchestrator ?? AIOrchestrator(),
        _dailyLimits = dailyLimits ?? DailyLimitsService(),
        _monetization = monetization ?? MonetizationService.instance;

  final AIOrchestrator _orchestrator;
  final DailyLimitsService _dailyLimits;
  final MonetizationService _monetization;

  /// Get daily horoscope for a sign
  Future<String> getDailyHoroscope({
    required String sign,
    required String language,
    required DateTime date,
    Map<String, dynamic>? userContext,
    bool forceRefresh = false,
  }) async {
    try {
      return await _orchestrator.generateHoroscope(
        sign: sign,
        language: language,
        date: date,
        userContext: userContext,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('HoroscopeService: Error - $e');
      return language == 'tr'
          ? 'Şu anda burç yorumu üretilemiyor. Lütfen tekrar deneyin.'
          : 'Cannot generate horoscope right now. Please try again.';
    }
  }
}

