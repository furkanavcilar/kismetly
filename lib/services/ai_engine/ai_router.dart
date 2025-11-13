import 'package:flutter/foundation.dart';

import 'ai_providers/openai_provider.dart';
import 'ai_providers/gemini_provider.dart';
import 'ai_providers/claude_provider.dart';

enum AIProviderType { openai, gemini, claude, local }

class AIRouter {
  AIRouter({
    OpenAIProvider? openAI,
    GeminiProvider? gemini,
    ClaudeProvider? claude,
  })  : _openAI = openAI ?? OpenAIProvider(),
        _gemini = gemini ?? GeminiProvider(),
        _claude = claude ?? ClaudeProvider();

  final OpenAIProvider _openAI;
  final GeminiProvider _gemini;
  final ClaudeProvider _claude;

  /// Generate text with fallback chain: OpenAI → Gemini → Claude → local
  Future<String> generate({
    required String systemPrompt,
    required String userPrompt,
    required String language,
    int? seed,
    double temperature = 0.95,
    String? fallbackText,
  }) async {
    // Try OpenAI first
    final openAIResult = await _openAI.generate(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      language: language,
      seed: seed,
      temperature: temperature,
    );
    if (openAIResult != null && openAIResult.isNotEmpty) {
      debugPrint('AI Router: Success with OpenAI');
      return openAIResult;
    }

    // Try Gemini
    final geminiResult = await _gemini.generate(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      language: language,
      seed: seed,
      temperature: temperature,
    );
    if (geminiResult != null && geminiResult.isNotEmpty) {
      debugPrint('AI Router: Success with Gemini');
      return geminiResult;
    }

    // Try Claude
    final claudeResult = await _claude.generate(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      language: language,
      seed: seed,
      temperature: temperature,
    );
    if (claudeResult != null && claudeResult.isNotEmpty) {
      debugPrint('AI Router: Success with Claude');
      return claudeResult;
    }

    // Fallback to local/static text
    debugPrint('AI Router: All providers failed, using fallback');
    return fallbackText ??
        (language == 'tr'
            ? 'Kozmik enerjiler şu anda yükleniyor. Lütfen tekrar deneyin.'
            : 'Cosmic energies are loading. Please try again.');
  }

  /// Generate with image using multimodal AI
  Future<String> generateWithImage({
    required String systemPrompt,
    required String userPrompt,
    required List<String> imageBase64,
    required String language,
    int? seed,
    double temperature = 0.95,
    String? fallbackText,
  }) async {
    // Try OpenAI Vision
    final openAIResult = await _openAI.generateWithImage(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      imageBase64: imageBase64,
      language: language,
      seed: seed,
      temperature: temperature,
    );
    if (openAIResult != null && openAIResult.isNotEmpty) {
      debugPrint('AI Router: Success with OpenAI Vision');
      return openAIResult;
    }

    // Try Gemini Vision
    final geminiResult = await _gemini.generateWithImage(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      imageBase64: imageBase64,
      language: language,
      seed: seed,
      temperature: temperature,
    );
    if (geminiResult != null && geminiResult.isNotEmpty) {
      debugPrint('AI Router: Success with Gemini Vision');
      return geminiResult;
    }

    // Try Claude Vision
    final claudeResult = await _claude.generateWithImage(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      imageBase64: imageBase64,
      language: language,
      seed: seed,
      temperature: temperature,
    );
    if (claudeResult != null && claudeResult.isNotEmpty) {
      debugPrint('AI Router: Success with Claude Vision');
      return claudeResult;
    }

    // Fallback
    debugPrint('AI Router: All vision providers failed, using fallback');
    return fallbackText ??
        (language == 'tr'
            ? 'Görüntü analizi şu anda yükleniyor. Lütfen tekrar deneyin.'
            : 'Image analysis is loading. Please try again.');
  }
}

