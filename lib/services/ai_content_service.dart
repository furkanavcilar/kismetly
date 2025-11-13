import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_secrets.dart';
import '../models/daily_ai_insights.dart';

class AiContentService {
  AiContentService({http.Client? client, SharedPreferences? preferences})
      : _client = client ?? http.Client(),
        _prefsFuture = preferences != null
            ? Future.value(preferences)
            : SharedPreferences.getInstance();

  final http.Client _client;
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

    DailyAiInsights? insight;
    final apiKey = AppSecrets.openAiApiKey;
    final dailySeed = _dailySeed(
      sunSign: sunSign,
      risingSign: risingSign,
      locale: locale,
      dayKey: dayKey,
      variant: forceRefresh ? DateTime.now().microsecondsSinceEpoch : null,
    );

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        insight = await _fetchFromOpenAi(
          apiKey: apiKey,
          sunSign: sunSign,
          risingSign: risingSign,
          locale: locale,
          seed: dailySeed,
        );
      } catch (e) {
        debugPrint('AI service fallback: $e');
      }
    }

    insight ??= _generateFallback(
      sunSign: sunSign,
      risingSign: risingSign,
      locale: locale,
      seed: dailySeed,
    );

    await prefs.setString(cacheKey, jsonEncode(insight.toJson()));
    return insight;
  }

  Future<Map<String, String>> fetchCompatibility({
    required String firstSign,
    required String secondSign,
    required Locale locale,
    bool forceRefresh = false,
  }) async {
    final today = DateTime.now();
    final dayKey = _dayStamp(today);
    final prefs = await _prefsFuture;

    final cacheKey =
        'ai_compat_${locale.languageCode}_${firstSign}_${secondSign}_$dayKey';
    final cached = prefs.getString(cacheKey);
    if (cached != null && !forceRefresh) {
      try {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (_) {}
    }

    Map<String, String>? response;
    final apiKey = AppSecrets.openAiApiKey;
    final compatSeed = _compatibilitySeed(
      firstSign: firstSign,
      secondSign: secondSign,
      locale: locale,
      dayKey: dayKey,
      variant: forceRefresh ? DateTime.now().microsecondsSinceEpoch : null,
    );

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        response = await _fetchCompatibilityFromOpenAi(
          apiKey: apiKey,
          firstSign: firstSign,
          secondSign: secondSign,
          locale: locale,
          seed: compatSeed,
        );
      } catch (e) {
        debugPrint('Compatibility fallback: $e');
      }
    }

    response ??= _generateCompatibilityFallback(
      firstSign: firstSign,
      secondSign: secondSign,
      locale: locale,
      seed: compatSeed,
    );

    await prefs.setString(cacheKey, jsonEncode(response));
    return response;
  }

  Future<DailyAiInsights> _fetchFromOpenAi({
    required String apiKey,
    required String sunSign,
    required String risingSign,
    required Locale locale,
    required int seed,
  }) async {
    final prompt = _dailyPrompt(
      sunSign: sunSign,
      risingSign: risingSign,
      locale: locale,
      seed: seed,
    );

    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'temperature': 1.05,
        'messages': [
          {
            'role': 'system',
            'content': locale.languageCode == 'tr'
                ? 'Sen duygusal zekası yüksek, modern Türkçe konuşan kozmik bir arkadaşsın.'
                : 'You are a poetic cosmic guide who speaks with warmth and emotional intelligence.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('OpenAI error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final content = decoded['choices']?[0]?['message']?['content'];
    if (content is! String) {
      throw const FormatException('Unexpected OpenAI response');
    }
    final parsed = jsonDecode(content);
    return DailyAiInsights.fromJson(parsed);
  }

  Future<Map<String, String>> _fetchCompatibilityFromOpenAi({
    required String apiKey,
    required String firstSign,
    required String secondSign,
    required Locale locale,
    required int seed,
  }) async {
    final prompt = _compatibilityPrompt(
      firstSign: firstSign,
      secondSign: secondSign,
      locale: locale,
      seed: seed,
    );

    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'temperature': 1.1,
        'messages': [
          {
            'role': 'system',
            'content': locale.languageCode == 'tr'
                ? 'Türkçe konuşan empatik bir astroloji rehberisin.'
                : 'You are an empathic astrology storyteller.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('OpenAI error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final content = decoded['choices']?[0]?['message']?['content'];
    if (content is! String) {
      throw const FormatException('Unexpected OpenAI response');
    }
    final parsed = jsonDecode(content);
    return parsed
        .map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  // Fallback builder
  DailyAiInsights _generateFallback({
    required String sunSign,
    required String risingSign,
    required Locale locale,
    required int seed,
  }) {
    final summary = locale.languageCode == 'tr'
        ? '$sunSign ve $risingSign enerjisi bugün sezgisel bir uyumda. Kalbine güven, ritmini koru.'
        : 'Your $sunSign and $risingSign alignment hums with quiet intuition. Trust your rhythm.';
    return DailyAiInsights(
      summary: summary,
      energyFocus: {
        'love':
            locale.languageCode == 'tr' ? 'Nazik diyalog' : 'Gentle dialogue',
        'career':
            locale.languageCode == 'tr' ? 'Planlı ilerleme' : 'Steady progress',
        'spiritual': locale.languageCode == 'tr'
            ? 'Sessiz farkındalık'
            : 'Silent awareness',
        'social': locale.languageCode == 'tr'
            ? 'Samimi bağlantılar'
            : 'Warm connections',
      },
      cosmicGuide: locale.languageCode == 'tr'
          ? '$sunSign için evrenin mesajı: dengede kal, iç sesini duy.'
          : 'The universe whispers to your $sunSign: stay balanced, listen within.',
      sections: {
        'love': '...',
        'career': '...',
        'spiritual': '...',
        'social': '...',
      },
      generatedAt: DateTime.now(),
    );
  }

  Map<String, String> _generateCompatibilityFallback({
    required String firstSign,
    required String secondSign,
    required Locale locale,
    required int seed,
  }) {
    final summary = locale.languageCode == 'tr'
        ? '$firstSign ve $secondSign arasında yumuşak bir enerji akışı var.'
        : '$firstSign and $secondSign share a gentle, harmonic flow.';
    return {
      'summary': summary,
      'love': locale.languageCode == 'tr'
          ? 'Aşkta anlayış ve sabır bugün size rehberlik edecek.'
          : 'In love, patience and empathy guide your bond.',
      'family': locale.languageCode == 'tr'
          ? 'Aile içinde karşılıklı destek enerjisi öne çıkıyor.'
          : 'Family ties are nurtured through mutual support.',
      'career': locale.languageCode == 'tr'
          ? 'İş ortamında net iletişim ve ortak hedefler önemli.'
          : 'Clear communication drives collaboration at work.',
    };
  }

  String _dailyPrompt({
    required String sunSign,
    required String risingSign,
    required Locale locale,
    required int seed,
  }) {
    if (locale.languageCode == 'tr') {
      return '''JSON döndür: {"summary":string,"energyFocus":{love,career,spiritual,social},"cosmicGuide":string,"sections":{love,career,spiritual,social}}.
Güneş burcu: $sunSign, yükselen: $risingSign. Her bölümde uygulanabilir öneriler ver. Türkçe yanıtla.''';
    }
    return '''Return JSON: {"summary":string,"energyFocus":{love,career,spiritual,social},"cosmicGuide":string,"sections":{love,career,spiritual,social}}.
Sun sign: $sunSign, rising: $risingSign. Provide actionable daily advice. Respond in English.''';
  }

  String _compatibilityPrompt({
    required String firstSign,
    required String secondSign,
    required Locale locale,
    required int seed,
  }) {
    if (locale.languageCode == 'tr') {
      return '''JSON döndür: {"summary":string,"love":string,"family":string,"career":string}.
Burçlar: $firstSign ve $secondSign. Uyumlu, empatik ve şiirsel anlatımla 2-3 cümlelik özetler oluştur. Türkçe yanıt ver.''';
    }
    return '''Return JSON: {"summary":string,"love":string,"family":string,"career":string}.
Signs: $firstSign and $secondSign. Use empathic and poetic tone with 2-3 sentence summaries. Respond in English.''';
  }
}
