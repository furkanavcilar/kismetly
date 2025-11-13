import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_router.dart';
import 'prompts/horoscope_prompt.dart';
import 'prompts/zodiac_prompt.dart';
import 'prompts/dream_prompt.dart';
import 'prompts/palm_prompt.dart';
import 'prompts/tarot_prompt.dart';
import 'prompts/coffee_reading_prompt.dart';
import 'prompts/greeting_prompt.dart';
import 'prompts/compatibility_prompt.dart';

class AIOrchestrator {
  AIOrchestrator({
    AIRouter? router,
    SharedPreferences? prefs,
  })  : _router = router ?? AIRouter(),
        _prefsFuture = prefs != null
            ? Future.value(prefs)
            : SharedPreferences.getInstance();

  final AIRouter _router;
  final Future<SharedPreferences> _prefsFuture;

  /// Generate a random seed based on date, sign, and user context
  int _generateSeed({
    required String base,
    required DateTime date,
    int? variant,
  }) {
    final dateStr = '${date.year}-${date.month}-${date.day}';
    final combined = '$base|$dateStr${variant != null ? '|$variant' : ''}';
    return combined.hashCode;
  }

  /// Generate daily horoscope for a specific sign
  Future<String> generateHoroscope({
    required String sign,
    required String language,
    required DateTime date,
    Map<String, dynamic>? userContext,
    bool forceRefresh = false,
  }) async {
    final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final cacheKey = 'horoscope_${language}_${sign}_$dayKey';
    
    if (!forceRefresh) {
      final prefs = await _prefsFuture;
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    final seed = _generateSeed(
      base: '$sign|$language',
      date: date,
      variant: forceRefresh ? DateTime.now().microsecondsSinceEpoch : null,
    );

    final prompt = HoroscopePrompt.build(
      sign: sign,
      date: date,
      language: language,
      userContext: userContext,
    );

    final result = await _router.generate(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      language: language,
      seed: seed,
      temperature: 0.95,
    );

    // Cache the result
    final prefs = await _prefsFuture;
    await prefs.setString(cacheKey, result);

    return result;
  }

  /// Generate zodiac sign details
  Future<Map<String, String>> generateZodiacDetails({
    required String sign,
    required String language,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'zodiac_details_${language}_$sign';
    
    if (!forceRefresh) {
      final prefs = await _prefsFuture;
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          final decoded = _prefsFuture.then((p) => p.getString(cacheKey))
              .then((s) => s != null ? Map<String, dynamic>.from(
                  Map.fromEntries(s.split('|').map((e) {
                    final parts = e.split(':');
                    return MapEntry(parts[0], parts.sublist(1).join(':'));
                  })))) : null);
          // Simplified caching - in production use JSON
          // For now, always regenerate
        } catch (_) {}
      }
    }

    final seed = _generateSeed(
      base: '$sign|$language',
      date: DateTime.now(),
    );

    final prompt = ZodiacPrompt.build(
      sign: sign,
      language: language,
    );

    final result = await _router.generate(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      language: language,
      seed: seed,
      temperature: 0.85,
    );

    // Parse result into sections
    final sections = _parseZodiacDetails(result, language);

    // Cache for 12 hours
    final prefs = await _prefsFuture;
    await prefs.setString(cacheKey, _serializeSections(sections));

    return sections;
  }

  /// Generate dream interpretation
  Future<String> generateDreamInterpretation({
    required String dreamText,
    required String language,
    Map<String, dynamic>? userContext,
  }) async {
    final now = DateTime.now();
    // Include user context in seed for better variation
    final contextHash = userContext != null
        ? userContext.toString().hashCode
        : 0;
    final seed = _generateSeed(
      base: '$dreamText|$language|$contextHash',
      date: now,
      variant: now.microsecondsSinceEpoch,
    );

    final prompt = DreamPrompt.build(
      dreamText: dreamText,
      language: language,
      userContext: userContext,
    );

    return await _router.generate(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      language: language,
      seed: seed,
      temperature: 0.95, // Slightly higher for more variation
    );
  }

  /// Generate palm reading from image
  Future<String> generatePalmReading({
    required List<String> imageBase64,
    required String language,
    required String handType, // 'left' or 'right'
    Map<String, dynamic>? userContext,
  }) async {
    final seed = _generateSeed(
      base: '$handType|$language',
      date: DateTime.now(),
      variant: DateTime.now().microsecondsSinceEpoch,
    );

    final prompt = PalmPrompt.build(
      handType: handType,
      language: language,
      userContext: userContext,
    );

    return await _router.generateWithImage(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      imageBase64: imageBase64,
      language: language,
      seed: seed,
      temperature: 0.9,
    );
  }

  /// Generate coffee fortune reading from image
  Future<String> generateCoffeeReading({
    required List<String> imageBase64,
    required String language,
    Map<String, dynamic>? userContext,
  }) async {
    final seed = _generateSeed(
      base: 'coffee|$language',
      date: DateTime.now(),
      variant: DateTime.now().microsecondsSinceEpoch,
    );

    final prompt = CoffeeReadingPrompt.build(
      language: language,
      userContext: userContext,
    );

    return await _router.generateWithImage(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      imageBase64: imageBase64,
      language: language,
      seed: seed,
      temperature: 0.9,
    );
  }

  /// Generate tarot reading interpretation
  Future<String> generateTarotReading({
    required List<String> cardNames,
    required String language,
    required String spreadType,
    Map<String, dynamic>? userContext,
  }) async {
    final seed = _generateSeed(
      base: '${cardNames.join(',')}|$language',
      date: DateTime.now(),
      variant: DateTime.now().microsecondsSinceEpoch,
    );

    final prompt = TarotPrompt.build(
      cardNames: cardNames,
      spreadType: spreadType,
      language: language,
      userContext: userContext,
    );

    return await _router.generate(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      language: language,
      seed: seed,
      temperature: 0.9,
    );
  }

  /// Generate compatibility analysis
  Future<Map<String, String>> generateCompatibility({
    required String firstSign,
    required String secondSign,
    required String language,
    Map<String, dynamic>? userContext,
  }) async {
    final seed = _generateSeed(
      base: '$firstSign|$secondSign|$language',
      date: DateTime.now(),
    );

    final prompt = CompatibilityPrompt.build(
      firstSign: firstSign,
      secondSign: secondSign,
      language: language,
      userContext: userContext,
    );

    final result = await _router.generate(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      language: language,
      seed: seed,
      temperature: 1.1,
    );

    return _parseCompatibility(result, language);
  }

  /// Generate daily energy focus
  Future<String> generateEnergyFocus({
    required String sunSign,
    required String risingSign,
    required String language,
    required DateTime date,
    Map<String, dynamic>? userContext,
  }) async {
    final seed = _generateSeed(
      base: '$sunSign|$risingSign|$language',
      date: date,
      variant: DateTime.now().microsecondsSinceEpoch,
    );

    final prompt = GreetingPrompt.buildEnergyFocus(
      sunSign: sunSign,
      risingSign: risingSign,
      language: language,
      date: date,
      userContext: userContext,
    );

    return await _router.generate(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      language: language,
      seed: seed,
      temperature: 0.95,
    );
  }

  // Helper methods for parsing
  Map<String, String> _parseZodiacDetails(String text, String language) {
    final sections = <String, String>{
      'traits': '',
      'strengths': '',
      'challenges': '',
      'love': '',
      'career': '',
      'emotional': '',
      'spiritual': '',
      'monthly': '',
      'yearly': '',
    };

    // Simple parsing - in production use more sophisticated parsing
    final lower = text.toLowerCase();
    final keywords = language == 'tr'
        ? {
            'traits': ['genel özellikler', 'özellikler'],
            'strengths': ['güçlü yönler', 'güçlü'],
            'challenges': ['zorluklar', 'zayıf'],
            'love': ['aşk', 'ilişkiler'],
            'career': ['kariyer', 'para'],
            'emotional': ['duygusal'],
            'spiritual': ['ruhsal', 'manevi'],
            'monthly': ['aylık', 'ayın'],
            'yearly': ['yıllık', 'yılın'],
          }
        : {
            'traits': ['general traits', 'traits'],
            'strengths': ['strengths', 'strong'],
            'challenges': ['challenges', 'weaknesses'],
            'love': ['love', 'relationships'],
            'career': ['career', 'money'],
            'emotional': ['emotional'],
            'spiritual': ['spiritual'],
            'monthly': ['monthly'],
            'yearly': ['yearly'],
          };

    // Distribute text into sections (simplified)
    final paragraphs = text.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    final perSection = (paragraphs.length / sections.length).ceil();
    int index = 0;

    for (final key in sections.keys) {
      final end = (index + 1) * perSection;
      if (end <= paragraphs.length) {
        sections[key] = paragraphs.sublist(index, end).join('\n\n');
      } else if (index < paragraphs.length) {
        sections[key] = paragraphs.sublist(index).join('\n\n');
      }
      index = end;
    }

    return sections;
  }

  String _serializeSections(Map<String, String> sections) {
    return sections.entries.map((e) => '${e.key}:${e.value}').join('|');
  }

  Map<String, String> _parseCompatibility(String text, String language) {
    final sections = <String, String>{
      'summary': '',
      'love': '',
      'family': '',
      'career': '',
      'strengths': '',
      'challenges': '',
      'communication': '',
      'longTerm': '',
    };

    // Try to parse JSON first
    try {
      // Look for JSON object in the text
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonStr = text.substring(jsonStart, jsonEnd + 1);
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (e) {
      debugPrint('JSON parsing failed: $e');
    }

    // Fallback: distribute paragraphs
    final paragraphs = text.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    final perSection = (paragraphs.length / sections.length).ceil();
    int index = 0;

    for (final key in sections.keys) {
      final end = (index + 1) * perSection;
      if (end <= paragraphs.length) {
        sections[key] = paragraphs.sublist(index, end).join('\n\n');
      } else if (index < paragraphs.length) {
        sections[key] = paragraphs.sublist(index).join('\n\n');
      }
      index = end;
    }

    return sections;
  }
}

