import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/config/app_secrets.dart';

class GeminiProvider {
  Future<String?> generate({
    required String systemPrompt,
    required String userPrompt,
    required String language,
    int? seed,
    double temperature = 0.95,
    int maxRetries = 3,
  }) async {
    final apiKey = AppSecrets.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
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
            maxOutputTokens: 8192,
          ),
          systemInstruction: Content.system(systemPrompt),
        );

        final response = await model.generateContent([
          Content.text(userPrompt),
        ]).timeout(const Duration(seconds: 30));

        final text = response.text;
        if (text != null && text.trim().isNotEmpty) {
          return text.trim();
        }

        attempt++;
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
        }
      } catch (e) {
        debugPrint('Gemini attempt ${attempt + 1} failed: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
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
  }) async {
    final apiKey = AppSecrets.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
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
          maxOutputTokens: 8192,
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
        return text.trim();
      }
    } catch (e) {
      debugPrint('Gemini image generation failed: $e');
    }

    return null;
  }
}

