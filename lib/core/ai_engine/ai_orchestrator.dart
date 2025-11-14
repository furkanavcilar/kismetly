import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_router.dart';
import 'ai_constants.dart';
import 'ai_seed.dart';
import 'prompts/horoscope_prompt.dart';
import 'prompts/zodiac_prompt.dart';
import 'prompts/tarot_prompt.dart';
import 'prompts/dream_prompt.dart';
import 'prompts/palm_prompt.dart';
import 'prompts/coffee_prompt.dart';
import 'prompts/greeting_prompt.dart';
import 'prompts/compatibility_prompt.dart';

/// Global AI Orchestrator - Main entry point for all AI generation
/// 
/// Handles:
/// - Prompt building
/// - Seed generation for uniqueness
/// - Caching
/// - Context management
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

    final seed = AISeed.generateDaily(
      base: '$sign|$language',
      date: date,
      userContext: userContext,
    );

    final prompt = HoroscopePrompt.signDaily(
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
      temperature: AIConstants.defaultTemperature,
      maxTokens: AIConstants.horoscopeMaxTokens,
    );

    // Cache the result
    final prefs = await _prefsFuture;
    await prefs.setString(cacheKey, result);

    return result;
  }

  /// Generate zodiac sign details (all 9 sections)
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
          final json = jsonDecode(cached) as Map<String, dynamic>;
          return json.map((k, v) => MapEntry(k, v.toString()));
        } catch (_) {}
      }
    }

    final seed = AISeed.generate(
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
      temperature: AIConstants.lowVariationTemperature,
      maxTokens: AIConstants.zodiacMaxTokens,
    );

    // Parse result into sections
    final sections = _parseZodiacDetails(result, language);

    // Cache for 12 hours
    final prefs = await _prefsFuture;
    await prefs.setString(cacheKey, jsonEncode(sections));

    return sections;
  }

  /// Generate dream interpretation
  Future<String> generateDreamInterpretation({
    required String dreamText,
    required String language,
    Map<String, dynamic>? userContext,
  }) async {
    final seed = AISeed.generateUnique(
      base: '$dreamText|$language',
      date: DateTime.now(),
      userContext: userContext,
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
      temperature: AIConstants.defaultTemperature,
      maxTokens: AIConstants.extendedMaxTokens,
    );
  }

  /// Generate palm reading from image
  Future<String> generatePalmReading({
    required List<String> imageBase64,
    required String language,
    required String handType, // 'left' or 'right'
    Map<String, dynamic>? userContext,
  }) async {
    final seed = AISeed.generateUnique(
      base: '$handType|$language',
      date: DateTime.now(),
      userContext: userContext,
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
      temperature: AIConstants.defaultTemperature,
      maxTokens: AIConstants.extendedMaxTokens,
    );
  }

  /// Generate coffee fortune reading from image
  Future<String> generateCoffeeReading({
    required List<String> imageBase64,
    required String language,
    Map<String, dynamic>? userContext,
  }) async {
    final seed = AISeed.generateUnique(
      base: 'coffee|$language',
      date: DateTime.now(),
      userContext: userContext,
    );

    final prompt = CoffeePrompt.build(
      language: language,
      userContext: userContext,
    );

    return await _router.generateWithImage(
      systemPrompt: prompt.systemPrompt,
      userPrompt: prompt.userPrompt,
      imageBase64: imageBase64,
      language: language,
      seed: seed,
      temperature: AIConstants.defaultTemperature,
      maxTokens: AIConstants.extendedMaxTokens,
    );
  }

  /// Generate tarot reading interpretation
  Future<String> generateTarotReading({
    required List<String> cardNames,
    required String language,
    required String spreadType,
    Map<String, dynamic>? userContext,
  }) async {
    final seed = AISeed.generateUnique(
      base: '${cardNames.join(',')}|$language',
      date: DateTime.now(),
      userContext: userContext,
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
      temperature: AIConstants.defaultTemperature,
      maxTokens: AIConstants.tarotMaxTokens,
    );
  }

  /// Generate compatibility analysis
  Future<Map<String, String>> generateCompatibility({
    required String firstSign,
    required String secondSign,
    required String language,
    Map<String, dynamic>? userContext,
  }) async {
    final seed = AISeed.generate(
      base: '$firstSign|$secondSign|$language',
      date: DateTime.now(),
      userContext: userContext,
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
      temperature: AIConstants.highVariationTemperature,
      maxTokens: AIConstants.compatibilityMaxTokens,
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
    final seed = AISeed.generateDaily(
      base: '$sunSign|$risingSign|$language',
      date: date,
      userContext: userContext,
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
      temperature: AIConstants.defaultTemperature,
      maxTokens: AIConstants.defaultMaxTokens,
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

    // Simple parsing - distribute paragraphs into sections
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
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonStr = text.substring(jsonStart, jsonEnd + 1);
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (e) {
      debugPrint('Compatibility JSON parsing failed: $e');
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

