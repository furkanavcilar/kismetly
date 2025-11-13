import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_secrets.dart';

class OpenAIProvider {
  OpenAIProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> generate({
    required String systemPrompt,
    required String userPrompt,
    required String language,
    int? seed,
    double temperature = 0.95,
    int maxRetries = 3,
  }) async {
    final apiKey = AppSecrets.openAiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
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
              return content.trim();
            }
          }
        }

        // If we get here, the response was not successful
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
        }
        attempt++;
      } catch (e) {
        debugPrint('OpenAI attempt ${attempt + 1} failed: $e');
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
    final apiKey = AppSecrets.openAiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
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
            return content.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('OpenAI image generation failed: $e');
    }

    return null;
  }
}

