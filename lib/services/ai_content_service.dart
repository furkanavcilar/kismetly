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
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    
    // Ensure all required sections exist
    final result = <String, String>{
      'summary': parsed['summary']?.toString() ?? '',
      'love': parsed['love']?.toString() ?? '',
      'family': parsed['family']?.toString() ?? '',
      'career': parsed['career']?.toString() ?? '',
      'strengths': parsed['strengths']?.toString() ?? '',
      'challenges': parsed['challenges']?.toString() ?? '',
      'communication': parsed['communication']?.toString() ?? '',
      'longTerm': parsed['longTerm']?.toString() ?? '',
    };
    
    return result;
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
    // Fallback should be minimal - AI service should handle most cases
    final loadingMsg = locale.languageCode == 'tr'
        ? 'Uyumluluk analizi yükleniyor...'
        : 'Loading compatibility analysis...';
    return {
      'summary': loadingMsg,
      'love': loadingMsg,
      'family': loadingMsg,
      'career': loadingMsg,
      'strengths': loadingMsg,
      'challenges': loadingMsg,
      'communication': loadingMsg,
      'longTerm': loadingMsg,
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
      return '''Sen deneyimli bir astroloji ve ilişki danışmanısın. $firstSign ve $secondSign burçlarının uyumluluğunu derinlemesine analiz et. JSON formatında döndür: {"summary":string,"love":string,"family":string,"career":string,"strengths":string,"challenges":string,"communication":string,"longTerm":string}. 

Her bölüm için 3-4 paragraf yaz. Her bölüm detaylı, özgün ve bu özel burç çiftine özgü olmalı. Aynı metni kopyalama - her burç çifti için tamamen farklı içerik üret.

- summary: Genel uyum özeti (3-4 paragraf)
- love: Aşk ve romantik ilişkiler (3-4 paragraf)
- family: Aile ve yakın ilişkiler (3-4 paragraf)
- career: İş ve kariyer uyumu (3-4 paragraf)
- strengths: Bu çiftin güçlü yönleri ve uyumlu alanları (3-4 paragraf)
- challenges: Zorluklar ve dikkat edilmesi gerekenler (3-4 paragraf)
- communication: İletişim önerileri ve nasıl daha iyi anlaşabilecekleri (3-4 paragraf)
- longTerm: Uzun vadeli potansiyel ve ilişki geleceği (3-4 paragraf)

Kişisel, empatik, şiirsel ve derinden insani bir ton kullan. Yapay zeka, modeller veya teknolojiden asla bahsetme. Kişiye doğrudan "sen" diye hitap et. Her burç çifti için benzersiz, tekrar etmeyen içerik üret. Türkçe yanıt ver.''';
    }
    return '''You are an experienced astrology and relationship counselor. Analyze the compatibility between $firstSign and $secondSign signs in depth. Return in JSON format: {"summary":string,"love":string,"family":string,"career":string,"strengths":string,"challenges":string,"communication":string,"longTerm":string}.

Write 3-4 paragraphs for each section. Each section must be detailed, unique, and specific to this particular sign pair. Do not copy the same text - generate completely different content for each sign pair.

- summary: Overall compatibility summary (3-4 paragraphs)
- love: Love and romantic relationships (3-4 paragraphs)
- family: Family and close relationships (3-4 paragraphs)
- career: Work and career compatibility (3-4 paragraphs)
- strengths: This pair's strengths and harmonious areas (3-4 paragraphs)
- challenges: Challenges and areas to be mindful of (3-4 paragraphs)
- communication: Communication tips and how they can better understand each other (3-4 paragraphs)
- longTerm: Long-term potential and relationship future (3-4 paragraphs)

Use a personal, empathetic, poetic, and deeply human tone. Never mention AI, models, or technology. Speak directly to the person using "you". Generate unique, non-repetitive content for each sign pair. Respond in English.''';
  }

  /// Fetch daily horoscope for a specific zodiac sign
  Future<String> fetchDailyHoroscope({
    required String sign,
    required Locale locale,
    required DateTime date,
    bool forceRefresh = false,
  }) async {
    final dayKey = _dayStamp(date);
    final prefs = await _prefsFuture;
    final cacheKey = 'horoscope_${locale.languageCode}_${sign}_$dayKey';
    
    // Only use cache if not forcing refresh
    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
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
                'content': _horoscopeSystemPrompt(locale.languageCode),
              },
              {
                'role': 'user',
                'content': locale.languageCode == 'tr'
                    ? 'Sen sıcak, empatik bir astrologsun. $sign burcu için bugünün (${date.day}/${date.month}/${date.year}) horoskopunu yaz. Bu horoskop SADECE $sign burcu için özel olmalı - diğer burçlardan tamamen farklı olmalı. 4-6 uzun paragraf yaz. Her paragraf en az 3-4 cümle içermeli. Aşk, kariyer, ruhsal gelişim ve sosyal bağlantılar hakkında özel içgörüler ver. Tarihi ve burç özelliklerini kullanarak benzersiz, tekrar etmeyen içerik oluştur. Kişiye doğrudan "sen" diye hitap et. Yapay zeka, modeller veya teknolojiden asla bahsetme. Dilini, cümle yapını değiştir ve tekrarlayan ifadelerden kaçın. Bu horoskop $sign burcu için bugün özel olmalı ve diğer tüm burçlardan farklı olmalı.'
                    : 'You are a warm, empathetic astrologer. Write today\'s (${date.day}/${date.month}/${date.year}) horoscope for the $sign sign. This horoscope must be SPECIFIC to the $sign sign only - completely different from all other signs. Write 4-6 long paragraphs. Each paragraph should contain at least 3-4 sentences. Provide specific insights about love, career, spiritual growth, and social connections. Use the date and sign characteristics to create unique, non-repetitive content. Speak directly to the person using "you". Never mention AI, models, or technology. Vary your language, sentence structure, and avoid repetitive phrases. This horoscope must be special for the $sign sign today and different from all other signs.',
              },
            ],
            'temperature': 0.95, // Higher temperature for more variation
            'seed': date.day * 100 + date.month + date.year % 100 + sign.hashCode % 1000, // Add sign hash for uniqueness
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
                'content': locale.languageCode == 'tr'
                    ? 'Sen deneyimli bir astrologsun. $sign burcu hakkında detaylı, zengin ve kişisel bir açıklama yaz. Şu bölümleri içermeli: Genel Özellikler (3-4 paragraf, bu burcun temel karakteristiklerini anlat - $sign burcuna özgü, diğer burçlardan farklı), Güçlü Yönler (3-4 paragraf, bu burcun güçlü yanlarını detaylandır - $sign burcuna özel güçler), Zorluklar (3-4 paragraf, bu burcun zayıf yönlerini ve gelişim alanlarını açıkla - $sign burcuna özgü zorluklar), Aşk & İlişkiler (3-4 paragraf, bu burcun aşk hayatındaki yaklaşımını ve ilişki dinamiklerini anlat - $sign burcuna özel aşk tarzı), Kariyer & Para (3-4 paragraf, bu burcun iş hayatı ve finansal yaklaşımını detaylandır - $sign burcuna özel kariyer yolu), Duygusal Manzara (3-4 paragraf, bu burcun duygusal dünyasını ve içsel yolculuğunu anlat - $sign burcuna özel duygusal özellikler), Ruhsal Yolculuk (3-4 paragraf, bu burcun ruhsal gelişim yolunu ve manevi arayışını açıkla - $sign burcuna özel ruhsal yol). Her bölümü $sign burcuna özgü, benzersiz ve detaylı yaz. Her burç için farklı cümle yapıları, farklı örnekler ve farklı odak noktaları kullan. Yapay zeka, modeller veya teknolojiden asla bahsetme. Kişiye doğrudan "sen" diye hitap et. Her burç için tamamen farklı içerik üret - aynı metni kopyalama. $sign burcu diğer tüm burçlardan farklıdır, bu farklılığı her bölümde vurgula.'
                    : 'You are an experienced astrologer. Write a detailed, rich, and personal description about the $sign zodiac sign. Include these sections: General Traits (3-4 paragraphs describing the core characteristics of this sign - specific to $sign, different from other signs), Strengths (3-4 paragraphs detailing the strong points of this sign - $sign-specific strengths), Challenges (3-4 paragraphs explaining the weaknesses and growth areas of this sign - $sign-specific challenges), Love & Relationships (3-4 paragraphs describing this sign\'s approach to love and relationship dynamics - $sign-specific love style), Career & Money (3-4 paragraphs detailing this sign\'s work life and financial approach - $sign-specific career path), Emotional Landscape (3-4 paragraphs describing this sign\'s emotional world and inner journey - $sign-specific emotional traits), Spiritual Path (3-4 paragraphs explaining this sign\'s spiritual development path and spiritual quest - $sign-specific spiritual journey). Write each section uniquely and specifically for the $sign sign. Use different sentence structures, different examples, and different focus points for each sign. Never mention AI, models, or technology. Speak directly to the person using "you". Generate completely different content for each sign - do not copy the same text. The $sign sign is different from all other signs, emphasize this difference in every section.',
              },
            ],
            'temperature': 0.85, // Higher temperature for more variation between signs
            'seed': _hashString('$sign|${locale.languageCode}'), // Unique seed per sign
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
      'love': '',
      'career': '',
      'emotional': '',
      'spiritual': '', // New section: Ruhsal Yolculuk / Spiritual Path
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
    final loveKeywords = language == 'tr'
        ? ['aşk', 'ilişkiler', 'love']
        : ['love', 'relationships'];
    final careerKeywords = language == 'tr'
        ? ['kariyer', 'para', 'career', 'money']
        : ['career', 'money'];
    final emotionalKeywords = language == 'tr'
        ? ['duygusal', 'emotional']
        : ['emotional', 'landscape'];
    final spiritualKeywords = language == 'tr'
        ? ['ruhsal', 'spiritual', 'spiritüel', 'manevi']
        : ['spiritual', 'path', 'journey'];
    final themeKeywords = language == 'tr'
        ? ['tema', 'yılın', 'ayın', 'themes']
        : ['themes', 'year', 'monthly'];

    // Simple parsing - in production, use more sophisticated parsing
    for (final key in sections.keys) {
      final keywords = key == 'traits' ? traitKeywords
          : key == 'strengths' ? strengthKeywords
          : key == 'challenges' ? challengeKeywords
          : key == 'love' ? loveKeywords
          : key == 'career' ? careerKeywords
          : key == 'emotional' ? emotionalKeywords
          : key == 'spiritual' ? spiritualKeywords
          : themeKeywords;
      
      for (final keyword in keywords) {
        final index = lower.indexOf(keyword);
        if (index != -1) {
          // Extract text after keyword until next section or end
          final start = index + keyword.length;
          // Find next section marker
          int end = text.length;
          for (final otherKey in sections.keys) {
            if (otherKey == key) continue;
            final otherKeywords = otherKey == 'traits' ? traitKeywords
                : otherKey == 'strengths' ? strengthKeywords
                : otherKey == 'challenges' ? challengeKeywords
                : otherKey == 'love' ? loveKeywords
                : otherKey == 'career' ? careerKeywords
                : otherKey == 'emotional' ? emotionalKeywords
                : otherKey == 'spiritual' ? spiritualKeywords
                : themeKeywords;
            for (final otherKeyword in otherKeywords) {
              final otherIndex = lower.indexOf(otherKeyword, start);
              if (otherIndex != -1 && otherIndex < end) {
                end = otherIndex;
              }
            }
          }
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
    // Fallback should be minimal and sign-specific - avoid generic text
    // In production, this should rarely be used as AI service should handle it
    final signHash = sign.hashCode % 12; // Simple variation per sign
    if (language == 'tr') {
      return {
        'traits': '$sign burcu hakkında detaylı bilgi yükleniyor. Lütfen internet bağlantınızı kontrol edin.',
        'strengths': 'Güçlü yönler analiz ediliyor...',
        'challenges': 'Zorluklar değerlendiriliyor...',
        'love': 'Aşk ve ilişkiler bölümü hazırlanıyor...',
        'career': 'Kariyer ve para bölümü hazırlanıyor...',
        'emotional': 'Duygusal manzara analiz ediliyor...',
        'spiritual': 'Ruhsal yolculuk bölümü hazırlanıyor...',
        'themes': 'Yıllık temalar değerlendiriliyor...',
      };
    }
    return {
      'traits': 'Loading detailed information about the $sign sign. Please check your internet connection.',
      'strengths': 'Analyzing strengths...',
      'challenges': 'Evaluating challenges...',
      'love': 'Preparing love and relationships section...',
      'career': 'Preparing career and money section...',
      'emotional': 'Analyzing emotional landscape...',
      'spiritual': 'Preparing spiritual path section...',
      'themes': 'Evaluating yearly themes...',
    };
  }
}
