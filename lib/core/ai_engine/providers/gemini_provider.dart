import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../config/app_secrets.dart';

/// Gemini Provider for text and vision AI
class GeminiProvider {
  Future<String?> generate({
    required String systemPrompt,
    required String userPrompt,
    required String language,
    int? seed,
    double temperature = 0.95,
    int maxTokens = 8192,
    int maxRetries = 3,
  }) async {
    final apiKey = AppSecrets.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('GeminiProvider: API key not configured');
      return null;
    }

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: temperature,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: maxTokens,
          ),
          systemInstruction: Content.system(systemPrompt),
        );

        final response = await model.generateContent([
          Content.text(userPrompt),
        ]).timeout(const Duration(seconds: 30));

        final text = response.text;
        if (text != null && text.trim().isNotEmpty) {
          debugPrint('GeminiProvider: Success on attempt ${attempt + 1}');
          return text.trim();
        }

        attempt++;
        if (attempt < maxRetries) {
          final delayMs = 1000 * (attempt + 1);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      } catch (e) {
        debugPrint('GeminiProvider: Attempt ${attempt + 1} failed: $e');
        if (attempt < maxRetries - 1) {
          final delayMs = 1000 * (attempt + 1);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
        attempt++;
      }
    }

    return null;
  }

  Future<String?> generateWithImage({
    required String systemPrompt,
    required String userPrompt,
    required List<String> imageBase64,
    required String language,
    int? seed,
    double temperature = 0.95,
    int maxTokens = 8192,
  }) async {
    final apiKey = AppSecrets.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('GeminiProvider: API key not configured');
      return null;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: temperature,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: maxTokens,
        ),
        systemInstruction: Content.system(systemPrompt),
      );

      final imageParts = imageBase64.map((img) {
        final bytes = base64Decode(img);
        return DataPart('image/jpeg', bytes);
      }).toList();

      final response = await model.generateContent([
        Content.multi([
          TextPart(userPrompt),
          ...imageParts,
        ]),
      ]).timeout(const Duration(seconds: 60));

      final text = response.text;
      if (text != null && text.trim().isNotEmpty) {
        debugPrint('GeminiProvider: Vision success');
        return text.trim();
      }
    } catch (e) {
      debugPrint('GeminiProvider: Vision generation failed: $e');
    }

    return null;
  }
}

