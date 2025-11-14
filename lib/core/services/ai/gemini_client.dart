import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../config/app_secrets.dart';
import 'ai_client_base.dart';

/// Gemini AI client implementation
/// 
/// Uses Google's Generative AI SDK (google_generative_ai)
/// API Key from .env: GEMINI_API_KEY
class GeminiClient implements AiClientBase {
  GeminiClient({String? apiKey}) : _apiKey = apiKey ?? AppSecrets.geminiApiKey;

  final String? _apiKey;

  @override
  String get name => 'gemini';

  @override
  Future<String?> generateText({
    required String systemPrompt,
    required String userPrompt,
    String? languageCode,
    Map<String, dynamic>? context,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('GeminiClient: API key not configured');
      return null;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey!,
        generationConfig: GenerationConfig(
          temperature: 0.9,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        ),
        systemInstruction: Content.system(systemPrompt),
      );

      final response = await model.generateContent([
        Content.text(userPrompt),
      ]).timeout(const Duration(seconds: 30));

      final text = response.text;
      if (text != null && text.trim().isNotEmpty) {
        debugPrint('GeminiClient: Success');
        return text.trim();
      }

      return null;
    } catch (e) {
      debugPrint('GeminiClient: Error - $e');
      return null;
    }
  }
}
