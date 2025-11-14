import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_secrets.dart';

/// OpenAI Provider for text and vision AI
class OpenAIProvider {
  OpenAIProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Generate text using OpenAI
  Future<String?> generate({
    required String systemPrompt,
    required String userPrompt,
    required String language,
    int? seed,
    double temperature = 0.95,
    int maxTokens = 4096,
    int maxRetries = 3,
  }) async {
    final apiKey = AppSecrets.openAiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('OpenAIProvider: API key not configured');
      return null;
    }

    int attempt = 0;
    while (attempt < maxRetries) {
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
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
            'temperature': temperature,
            'max_tokens': maxTokens,
            if (seed != null) 'seed': seed,
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final message = choices.first['message'] as Map<String, dynamic>?;
            final content = message?['content'] as String?;
            if (content != null && content.trim().isNotEmpty) {
              debugPrint('OpenAIProvider: Success on attempt ${attempt + 1}');
              return content.trim();
            }
          }
        }

        // If we get here, the response was not successful
        if (attempt < maxRetries - 1) {
          final delayMs = 1000 * (attempt + 1);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
        attempt++;
      } catch (e) {
        debugPrint('OpenAIProvider: Attempt ${attempt + 1} failed: $e');
        if (attempt < maxRetries - 1) {
          final delayMs = 1000 * (attempt + 1);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
        attempt++;
      }
    }

    return null;
  }

  /// Generate with image using OpenAI Vision
  Future<String?> generateWithImage({
    required String systemPrompt,
    required String userPrompt,
    required List<String> imageBase64,
    required String language,
    int? seed,
    double temperature = 0.95,
    int maxTokens = 4096,
  }) async {
    final apiKey = AppSecrets.openAiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('OpenAIProvider: API key not configured');
      return null;
    }

    try {
      final content = <Map<String, dynamic>>[
        {'type': 'text', 'text': userPrompt},
        ...imageBase64.map((img) => {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$img'}
            }),
      ];

      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': content},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
          if (seed != null) 'seed': seed,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            debugPrint('OpenAIProvider: Vision success');
            return content.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('OpenAIProvider: Vision generation failed: $e');
    }

    return null;
  }
}

