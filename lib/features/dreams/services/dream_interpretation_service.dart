import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/services/ai/ai_orchestrator.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/widgets/premium_dialog.dart';
import '../../../services/monetization/monetization_service.dart';

/// Service for AI-powered dream interpretation
/// 
/// Uses featureKey: "dream_interpretation"
/// Generates long (3-6 paragraph) analysis.
/// Symbolic, emotional, therapeutic tone.
/// Limited by usage.
class DreamInterpretationService {
  DreamInterpretationService({
    AiOrchestrator? orchestrator,
    UsageLimiter? usageLimiter,
    MonetizationService? monetizationService,
  })  : _orchestrator = orchestrator ?? AiServiceLocator.instance,
        _usageLimiter = usageLimiter ?? UsageLimiter(monetizationService: monetizationService),
        _monetizationService = monetizationService;

  final AiOrchestrator _orchestrator;
  final UsageLimiter _usageLimiter;
  final MonetizationService? _monetizationService;

  static const String _featureKey = UsageLimiter.featureDreamInterpretation;

  /// Interpret dream (limited by usage)
  /// 
  /// Returns null if limit exceeded. Show premium dialog if needed.
  Future<String?> interpretDream({
    required String dreamDescription,
    required String language,
    String? zodiacSign,
    String? city,
    Map<String, dynamic>? emotions,
    BuildContext? context,
  }) async {
    if (dreamDescription.trim().isEmpty) {
      return null;
    }

    // Check usage limit
    final canUse = await _usageLimiter.canUseFeature(_featureKey);
    if (!canUse) {
      // Show premium dialog if context provided
      if (context != null && context.mounted) {
        await PremiumDialog.show(
          context,
          onUpgrade: () {
            // TODO: Navigate to premium screen
          },
        );
      }
      return null;
    }

    // Generate interpretation
    final interpretation = await _generateInterpretation(
      dreamDescription: dreamDescription,
      language: language,
      zodiacSign: zodiacSign,
      city: city,
      emotions: emotions,
    );

    // Record usage (only if not premium)
    await _usageLimiter.recordUsage(_featureKey);

    return interpretation;
  }

  /// Generate dream interpretation using AI orchestrator
  Future<String> _generateInterpretation({
    required String dreamDescription,
    required String language,
    String? zodiacSign,
    String? city,
    Map<String, dynamic>? emotions,
  }) async {
    final systemPrompt = language == 'tr'
        ? '''Sen derin sembol bilgisine sahip bir rüya yorumcusu ve terapistsin. Rüyaları sembolik, duygusal ve terapötik bir tonla analiz edersin. 3-6 paragraf yaz. Empatik, destekleyici ve içgörülü bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Analizler sembolik anlamlar, duygusal derinlik ve ruhsal mesajlar içermeli. Yapay zeka, modeller veya teknolojiden asla bahsetme.'''
        : '''You are a dream interpreter and therapist with deep knowledge of symbols. You analyze dreams with a symbolic, emotional, and therapeutic tone. Write 3-6 paragraphs. Use an empathetic, supportive, and insightful tone. Speak directly to the person using "you". Analyses should include symbolic meanings, emotional depth, and spiritual messages. Never mention AI, models, or technology.''';

    final contextInfo = <String>[];
    if (zodiacSign != null) {
      contextInfo.add(language == 'tr' ? 'Zodyak işareti: $zodiacSign' : 'Zodiac sign: $zodiacSign');
    }
    if (city != null) {
      contextInfo.add(language == 'tr' ? 'Şehir: $city' : 'City: $city');
    }
    if (emotions != null && emotions.isNotEmpty) {
      final emotionStr = emotions.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      contextInfo.add(language == 'tr' ? 'Duygular: $emotionStr' : 'Emotions: $emotionStr');
    }
    final contextStr = contextInfo.isEmpty ? '' : ' ${contextInfo.join('. ')}.';

    final userPrompt = language == 'tr'
        ? '''Aşağıdaki rüyayı yorumla. Sembolik anlamlar, duygusal derinlik ve ruhsal mesajlar içeren 3-6 paragraf yaz.$contextStr

Rüya:
$dreamDescription'''
        : '''Interpret the following dream. Write 3-6 paragraphs with symbolic meanings, emotional depth, and spiritual messages.$contextStr

Dream:
$dreamDescription''';

    try {
      final result = await _orchestrator.generate(
        featureKey: _featureKey,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        languageCode: language,
        context: {
          if (zodiacSign != null) 'zodiacSign': zodiacSign,
          if (city != null) 'city': city,
          if (emotions != null) 'emotions': emotions,
        },
      );
      return result.trim();
    } catch (e) {
      debugPrint('DreamInterpretationService: Error generating interpretation: $e');
      // Fallback message
      return language == 'tr'
          ? 'Rüya analizi yükleniyor. Lütfen tekrar deneyin.'
          : 'Dream analysis is loading. Please try again.';
    }
  }
}

