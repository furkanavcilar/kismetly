import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../config/app_secrets.dart';
import '../../../services/ai_engine/ai_providers/openai_provider.dart';
import '../../../services/ai_engine/ai_providers/claude_provider.dart';
import '../../../services/ai_engine/ai_providers/gemini_provider.dart';

/// Centralized AI Client supporting multiple providers
/// 
/// Supports: OpenAI, Anthropic (Claude), Gemini, Copilot (placeholder)
/// Keys are loaded from .env using flutter_dotenv or environment variables
/// 
/// All AI logic should go through this client to ensure:
/// - Consistent error handling
/// - Provider fallback chain
/// - Enforced system prompts for tone/structure
/// - No duplicate AI logic
class AiClient {
  AiClient({
    OpenAIProvider? openAI,
    ClaudeProvider? claude,
    GeminiProvider? gemini,
  })  : _openAI = openAI ?? OpenAIProvider(),
        _claude = claude ?? ClaudeProvider(),
        _gemini = gemini ?? GeminiProvider();

  final OpenAIProvider _openAI;
  final ClaudeProvider _claude;
  final GeminiProvider _gemini;

  /// Generate text with fallback chain: OpenAI → Gemini → Claude → Copilot
  /// 
  /// System prompts must enforce tone, structure, and consistency.
  /// This ensures all AI-generated content maintains the same quality and style.
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
      debugPrint('AiClient: Success with OpenAI');
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
      debugPrint('AiClient: Success with Gemini');
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
      debugPrint('AiClient: Success with Claude');
      return claudeResult;
    }

    // TODO: Add Copilot provider when available
    // Try Copilot would go here

    // Fallback to provided text or default
    debugPrint('AiClient: All providers failed, using fallback');
    return fallbackText ??
        (language == 'tr'
            ? 'Kozmik enerjiler şu anda yükleniyor. Lütfen tekrar deneyin.'
            : 'Cosmic energies are loading. Please try again.');
  }

  /// Generate with image using multimodal AI
  /// 
  /// Supports vision models for image analysis (coffee reading, palmistry, etc.)
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
      debugPrint('AiClient: Success with OpenAI Vision');
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
      debugPrint('AiClient: Success with Gemini Vision');
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
      debugPrint('AiClient: Success with Claude Vision');
      return claudeResult;
    }

    // TODO: Add Copilot Vision when available

    // Fallback
    debugPrint('AiClient: All vision providers failed, using fallback');
    return fallbackText ??
        (language == 'tr'
            ? 'Görsel analiz şu anda yükleniyor. Lütfen tekrar deneyin.'
            : 'Image analysis is loading. Please try again.');
  }
}

