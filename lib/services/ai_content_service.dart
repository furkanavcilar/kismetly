import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_ai_insights.dart';
import 'backend_api.dart';

class AiContentService {
  AiContentService({
    BackendApi? api,
    SharedPreferences? preferences,
  })  : _api = api ?? BackendApi(),
        _prefsFuture = preferences != null
            ? Future.value(preferences)
            : SharedPreferences.getInstance();

  final BackendApi _api;
  final Future<SharedPreferences> _prefsFuture;

  String _dayStamp(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  int _hashString(String value) {
    const int fnvPrime = 16777619;
    const int offset = 2166136261;
    var hash = offset;
    for (final code in value.codeUnits) {
      hash ^= code;
      hash = (hash * fnvPrime) & 0x7fffffff;
    }
    return hash;
  }

  int _dailySeed({
    required String sunSign,
    required String risingSign,
    required Locale locale,
    required String dayKey,
    int? variant,
  }) {
    final base =
        '$dayKey|${locale.languageCode}|${sunSign.toLowerCase()}|${risingSign.toLowerCase()}';
    final salt = variant != null ? '$base|$variant' : base;
    return _hashString(salt);
  }

  int _compatibilitySeed({
    required String firstSign,
    required String secondSign,
    required Locale locale,
    required String dayKey,
    int? variant,
  }) {
    final base =
        '$dayKey|${locale.languageCode}|${firstSign.toLowerCase()}|${secondSign.toLowerCase()}';
    final salt = variant != null ? '$base|$variant' : base;
    return _hashString(salt);
  }

  Future<DailyAiInsights> fetchDailyInsights({
    required String sunSign,
    required String risingSign,
    required Locale locale,
    bool forceRefresh = false,
  }) async {
    final today = DateTime.now();
    final dayKey = _dayStamp(today);
    final prefs = await _prefsFuture;

    final cacheKey =
        'ai_insight_${locale.languageCode}_${sunSign}_${risingSign}_$dayKey';
    final cached = DailyAiInsights.tryParse(prefs.getString(cacheKey));
    if (cached != null && !forceRefresh) {
      return cached;
    }

    try {
      final response = await _api.post('/api/chat/daily-guidance', 
        body: {
          'sign': sunSign,
          'name': '',
          'focus': 'Daily insights for $sunSign with $risingSign rising',
        },
        language: locale.languageCode,
      );

      final guidance = response['guidance'] as String?;
      if (guidance == null || guidance.isEmpty) {
        throw Exception('Empty response from backend');
      }

      // Parse guidance into DailyAiInsights structure
      final insight = DailyAiInsights(
        summary: guidance,
        energyFocus: {
          'love': guidance,
          'career': guidance,
          'spiritual': guidance,
          'social': guidance,
        },
        cosmicGuide: guidance,
        sections: {
          'love': guidance,
          'career': guidance,
          'spiritual': guidance,
          'social': guidance,
        },
        generatedAt: DateTime.now(),
      );

      await prefs.setString(cacheKey, jsonEncode(insight.toJson()));
      return insight;
    } catch (e) {
      debugPrint('AiContentService: Error fetching daily insights: $e');
      throw Exception('Failed to fetch daily insights: $e');
    }
  }

  Future<Map<String, String>> fetchCompatibility({
    required String firstSign,
    required String secondSign,
    required Locale locale,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _api.post('/api/compatibility/analyze', 
        body: {
          'sign1': firstSign.toLowerCase(),
          'sign2': secondSign.toLowerCase(),
        },
        language: locale.languageCode,
      );

      final analysis = response['analysis'] as String?;
      if (analysis == null || analysis.isEmpty) {
        throw Exception('Empty response from backend');
      }

      // Parse analysis into sections
      final result = <String, String>{
        'summary': analysis,
        'love': analysis,
        'family': analysis,
        'career': analysis,
        'strengths': analysis,
        'challenges': analysis,
        'communication': analysis,
        'longTerm': analysis,
      };
      
      // Cache the result
      final today = DateTime.now();
      final dayKey = _dayStamp(today);
      final prefs = await _prefsFuture;
      final cacheKey =
          'ai_compat_${locale.languageCode}_${firstSign}_${secondSign}_$dayKey';
      await prefs.setString(cacheKey, jsonEncode(result));
      
      return result;
    } catch (e) {
      debugPrint('Compatibility generation failed: $e');
      throw Exception('Failed to fetch compatibility: $e');
    }
  }

  /// Fetch daily horoscope for a specific zodiac sign
  Future<String> fetchDailyHoroscope({
    required String sign,
    required Locale locale,
    required DateTime date,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _api.post('/api/horoscope/generate', 
        body: {
          'sign': sign.toLowerCase(),
          'timeframe': 'daily',
        },
        language: locale.languageCode,
      );

      final horoscope = response['horoscope'] as String?;
      if (horoscope == null || horoscope.isEmpty) {
        throw Exception('Empty response from backend');
      }

      return horoscope;
    } catch (e) {
      debugPrint('Horoscope generation failed: $e');
      throw Exception('Failed to fetch horoscope: $e');
    }
  }

  /// Fetch detailed information about a zodiac sign
  Future<Map<String, String>> fetchZodiacSignDetails({
    required String sign,
    required Locale locale,
    bool forceRefresh = false,
  }) async {
    try {
      // Backend doesn't have zodiac details endpoint, use horoscope as fallback
      final horoscope = await fetchDailyHoroscope(
        sign: sign,
        locale: locale,
        date: DateTime.now(),
        forceRefresh: forceRefresh,
      );
      
      return {
        'traits': horoscope,
        'strengths': horoscope,
        'challenges': horoscope,
        'love': horoscope,
        'career': horoscope,
        'emotional': horoscope,
        'spiritual': horoscope,
        'themes': horoscope,
      };
    } catch (e) {
      debugPrint('Zodiac details generation failed: $e');
      throw Exception('Failed to fetch zodiac details: $e');
    }
  }

  /// Fetch dream interpretation
  Future<String> fetchDreamInterpretation({
    required String dreamText,
    required Locale locale,
    Map<String, dynamic>? userContext,
  }) async {
    try {
      final response = await _api.post('/api/dreams/interpret', 
        body: {
          'description': dreamText,
          'mood': userContext?['mood'],
          'date': DateTime.now().toIso8601String(),
        },
        language: locale.languageCode,
      );

      final interpretation = response['interpretation'] as String?;
      if (interpretation == null || interpretation.isEmpty) {
        throw Exception('Empty response from backend');
      }

      return interpretation;
    } catch (e) {
      debugPrint('Dream interpretation failed: $e');
      throw Exception('Failed to fetch dream interpretation: $e');
    }
  }

}
