import 'package:flutter/foundation.dart';

import '../../../services/backend_api.dart';

/// Horoscope Service - Uses Backend API
class HoroscopeService {
  HoroscopeService({BackendApi? api}) : _api = api ?? BackendApi();

  final BackendApi _api;

  /// Get daily horoscope for a sign
  Future<String> getDailyHoroscope({
    required String sign,
    required String language,
    required DateTime date,
    Map<String, dynamic>? userContext,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _api.post('/api/horoscope/generate', 
        body: {
          'sign': sign.toLowerCase(),
          'timeframe': 'daily',
        },
        language: language,
      );

      final horoscope = response['horoscope'] as String?;
      if (horoscope == null || horoscope.isEmpty) {
        throw Exception('Empty response from backend');
      }

      return horoscope;
    } catch (e) {
      debugPrint('HoroscopeService: Error - $e');
      throw Exception(language == 'tr'
          ? 'Şu anda burç yorumu üretilemiyor: $e'
          : 'Cannot generate horoscope right now: $e');
    }
  }
}

