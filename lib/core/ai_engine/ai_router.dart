import 'package:flutter/foundation.dart';

import 'ai_constants.dart';
import 'providers/openai_provider.dart';
import 'providers/gemini_provider.dart';
import 'providers/claude_provider.dart';

/// AI Router - Routes requests through provider chain with fallback
/// 
/// Priority: OpenAI → Gemini → Claude
/// Implements retries with exponential backoff
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

  /// Generate text with fallback chain: OpenAI → Gemini → Claude
  Future<String> generate({
    required String systemPrompt,
    required String userPrompt,
    required String language,
    int? seed,
    double temperature = AIConstants.defaultTemperature,
    int maxTokens = AIConstants.defaultMaxTokens,
  }) async {
    // Try OpenAI first
    final openAIResult = await _openAI.generate(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      language: language,
      seed: seed,
      temperature: temperature,
      maxTokens: maxTokens,
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
      maxTokens: maxTokens,
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
      maxTokens: maxTokens,
    );
    if (claudeResult != null && claudeResult.isNotEmpty) {
      debugPrint('AI Router: Success with Claude');
      return claudeResult;
    }

    // All providers failed - return error message (NOT static astrology text)
    debugPrint('AI Router: All providers failed');
    return language == 'tr'
        ? 'Şu anda yorum üretirken bir sorun oluştu. Lütfen tekrar deneyin.'
        : 'We couldn\'t generate your reading right now. Please try again.';
  }

  /// Generate with image using multimodal AI
  Future<String> generateWithImage({
    required String systemPrompt,
    required String userPrompt,
    required List<String> imageBase64,
    required String language,
    int? seed,
    double temperature = AIConstants.defaultTemperature,
    int maxTokens = AIConstants.extendedMaxTokens,
  }) async {
    // Try OpenAI Vision
    final openAIResult = await _openAI.generateWithImage(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      imageBase64: imageBase64,
      language: language,
      seed: seed,
      temperature: temperature,
      maxTokens: maxTokens,
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
      maxTokens: maxTokens,
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
      maxTokens: maxTokens,
    );
    if (claudeResult != null && claudeResult.isNotEmpty) {
      debugPrint('AI Router: Success with Claude Vision');
      return claudeResult;
    }

    // All providers failed
    debugPrint('AI Router: All vision providers failed');
    return language == 'tr'
        ? 'Görüntü analizi şu anda yükleniyor. Lütfen tekrar deneyin.'
        : 'Image analysis is loading. Please try again.';
  }
}

