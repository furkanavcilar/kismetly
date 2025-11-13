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
      return '''Sen deneyimli bir astroloji ve ilişki danışmanısın. $firstSign ve $secondSign burçlarının uyumluluğunu analiz et. JSON formatında döndür: {"summary":string,"love":string,"family":string,"career":string}. Her bölüm için 2-3 paragraf yaz. Kişisel, empatik, şiirsel ve derinden insani bir ton kullan. Yapay zeka, modeller veya teknolojiden asla bahsetme. Kişiye doğrudan "sen" diye hitap et. Türkçe yanıt ver.''';
    }
    return '''You are an experienced astrology and relationship counselor. Analyze the compatibility between $firstSign and $secondSign signs. Return in JSON format: {"summary":string,"love":string,"family":string,"career":string}. Write 2-3 paragraphs for each section. Use a personal, empathetic, poetic, and deeply human tone. Never mention AI, models, or technology. Speak directly to the person using "you". Respond in English.''';
  }

  /// Fetch daily horoscope for a specific zodiac sign
  Future<String> fetchDailyHoroscope({
    required String sign,
    required Locale locale,
    required DateTime date,
  }) async {
    final dayKey = _dayStamp(date);
    final prefs = await _prefsFuture;
    final cacheKey = 'horoscope_${locale.languageCode}_${sign}_$dayKey';
    
    final cached = prefs.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final apiKey = AppSecrets.openAiApiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final response = await _client.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'messages': [
              {
                'role': 'system',
                'content': _horoscopeSystemPrompt(locale.languageCode),
              },
              {
                'role': 'user',
                'content': 'Write today\'s horoscope for $sign. Make it personal, warm, and specific to this sign. Include insights about love, career, spiritual growth, and social connections. Write as a caring astrologer speaking directly to the person. Never mention AI or technology.',
              },
            ],
            'temperature': 0.8,
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final message = choices.first['message'] as Map<String, dynamic>?;
            final content = message?['content'] as String?;
            if (content != null && content.trim().isNotEmpty) {
              final horoscope = content.trim();
              await prefs.setString(cacheKey, horoscope);
              return horoscope;
            }
          }
        }
      } catch (e) {
        debugPrint('Horoscope generation failed: $e');
      }
    }

    // Fallback
    return _getFallbackHoroscope(sign, locale.languageCode);
  }

  String _horoscopeSystemPrompt(String language) {
    if (language == 'en') {
      return '''You are a warm, intuitive astrologer with deep knowledge of zodiac signs and their daily energies. Write horoscopes that feel personal, empathetic, and deeply human. Speak directly to the person using "you". Never mention AI, models, or technology. Your tone should be supportive, mystical, and feminine-friendly. Write multiple paragraphs with specific insights about love, career, spiritual growth, and social connections.''';
    }
    return '''Sen derin burç bilgisine sahip sıcak, sezgisel bir astrologsun. Kişisel, empatik ve derinden insani horoskoplar yaz. Kişiye doğrudan "sen" diye hitap et. Yapay zeka, modeller veya teknolojiden asla bahsetme. Tonun destekleyici, mistik ve kadın dostu olsun. Aşk, kariyer, ruhsal gelişim ve sosyal bağlantılar hakkında özel içgörülerle çok paragraflı metinler yaz.''';
  }

  String _getFallbackHoroscope(String sign, String language) {
    if (language == 'tr') {
      return 'Bugün kozmik enerjiler senin lehine çalışıyor. İç sesine güven ve adımlarını cesaretle at. Aşk hayatında yeni fırsatlar belirebilir, kariyerinde ilerleme kaydedebilirsin. Ruhsal gelişim için meditasyon ve iç gözlem zamanı ayır.';
    }
    return 'Today cosmic energies are working in your favor. Trust your inner voice and take steps with courage. New opportunities may appear in love, and you may make progress in your career. Take time for meditation and inner reflection for spiritual growth.';
  }

  /// Fetch detailed information about a zodiac sign
  Future<Map<String, String>> fetchZodiacSignDetails({
    required String sign,
    required Locale locale,
  }) async {
    final prefs = await _prefsFuture;
    final cacheKey = 'zodiac_details_${locale.languageCode}_$sign';
    
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        return Map<String, String>.from(decoded);
      } catch (_) {
        // Invalid cache, continue to generate
      }
    }

    final apiKey = AppSecrets.openAiApiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final response = await _client.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'messages': [
              {
                'role': 'system',
                'content': _zodiacDetailsSystemPrompt(locale.languageCode),
              },
              {
                'role': 'user',
                'content': 'Provide detailed information about the $sign zodiac sign. Include: General Traits (Genel Özellikler), Strengths (Güçlü Yönler), Challenges (Zorluklar), and Themes for the Year (Yılın Astrolojik Temaları). Write as a knowledgeable astrologer. Each section should be at least 2-3 paragraphs. Never mention AI or technology.',
              },
            ],
            'temperature': 0.7,
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final message = choices.first['message'] as Map<String, dynamic>?;
            final content = message?['content'] as String?;
            if (content != null && content.trim().isNotEmpty) {
              final details = _parseZodiacDetails(content, locale.languageCode);
              await prefs.setString(cacheKey, jsonEncode(details));
              return details;
            }
          }
        }
      } catch (e) {
        debugPrint('Zodiac details generation failed: $e');
      }
    }

    // Fallback
    return _getFallbackZodiacDetails(sign, locale.languageCode);
  }

  String _zodiacDetailsSystemPrompt(String language) {
    if (language == 'en') {
      return '''You are a knowledgeable, warm astrologer with deep understanding of zodiac signs. Write detailed, rich descriptions that feel personal and human. Never mention AI, models, or technology. Your tone should be supportive, mystical, and feminine-friendly. Write multiple paragraphs for each section.''';
    }
    return '''Sen derin burç bilgisine sahip bilgili, sıcak bir astrologsun. Kişisel ve insani hissettiren detaylı, zengin açıklamalar yaz. Yapay zeka, modeller veya teknolojiden asla bahsetme. Tonun destekleyici, mistik ve kadın dostu olsun. Her bölüm için çok paragraflı metinler yaz.''';
  }

  Map<String, String> _parseZodiacDetails(String text, String language) {
    final sections = <String, String>{
      'traits': '',
      'strengths': '',
      'challenges': '',
      'themes': '',
    };

    // Try to parse structured response
    final lower = text.toLowerCase();
    final traitKeywords = language == 'tr' 
        ? ['genel özellikler', 'özellikler', 'traits']
        : ['general traits', 'traits'];
    final strengthKeywords = language == 'tr'
        ? ['güçlü yönler', 'güçlü', 'strengths']
        : ['strengths', 'strong'];
    final challengeKeywords = language == 'tr'
        ? ['zorluklar', 'zayıf', 'challenges']
        : ['challenges', 'weaknesses'];
    final themeKeywords = language == 'tr'
        ? ['tema', 'yılın', 'themes']
        : ['themes', 'year'];

    // Simple parsing - in production, use more sophisticated parsing
    for (final key in sections.keys) {
      final keywords = key == 'traits' ? traitKeywords
          : key == 'strengths' ? strengthKeywords
          : key == 'challenges' ? challengeKeywords
          : themeKeywords;
      
      for (final keyword in keywords) {
        final index = lower.indexOf(keyword);
        if (index != -1) {
          // Extract text after keyword
          final start = index + keyword.length;
          final end = text.length;
          sections[key] = text.substring(start, end).trim();
          break;
        }
      }
    }

    // If parsing failed, distribute text evenly
    if (sections.values.every((v) => v.isEmpty)) {
      final parts = text.split('\n\n');
      final perSection = (parts.length / sections.length).ceil();
      int partIndex = 0;
      for (final key in sections.keys) {
        final end = (partIndex + 1) * perSection;
        sections[key] = parts.sublist(partIndex, end > parts.length ? parts.length : end).join('\n\n');
        partIndex = end;
      }
    }

    return sections;
  }

  Map<String, String> _getFallbackZodiacDetails(String sign, String language) {
    if (language == 'tr') {
      return {
        'traits': '$sign burcu, kozmik enerjilerin güçlü bir temsilcisidir. Bu burç, derin duygusal bağlantılar ve sezgisel anlayışla karakterize edilir.',
        'strengths': 'Güçlü yönlerin arasında empati, yaratıcılık ve içgörü yer alır. Bu özellikler seni hayatta ileriye taşır.',
        'challenges': 'Bazen aşırı duyarlılık ve mükemmeliyetçilik zorluk yaratabilir. Kendine karşı nazik olmayı unutma.',
        'themes': 'Bu yıl, kişisel gelişim ve ruhsal derinleşme temaları öne çıkıyor. Yeni fırsatlar ve dönüşümler seni bekliyor.',
      };
    }
    return {
      'traits': 'The $sign sign is a powerful representative of cosmic energies. This sign is characterized by deep emotional connections and intuitive understanding.',
      'strengths': 'Your strengths include empathy, creativity, and insight. These qualities carry you forward in life.',
      'challenges': 'Sometimes excessive sensitivity and perfectionism can create challenges. Remember to be gentle with yourself.',
      'themes': 'This year, themes of personal growth and spiritual deepening come to the fore. New opportunities and transformations await you.',
    };
  }
}
