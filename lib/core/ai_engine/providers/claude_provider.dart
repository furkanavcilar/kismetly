import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_secrets.dart';

/// Claude Provider for text and vision AI
class ClaudeProvider {
  ClaudeProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> generate({
    required String systemPrompt,
    required String userPrompt,
    required String language,
    int? seed,
    double temperature = 0.95,
    int maxTokens = 8192,
    int maxRetries = 3,
  }) async {
    final apiKey = AppSecrets.claudeApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('ClaudeProvider: API key not configured');
      return null;
    }

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response = await _client.post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'claude-3-haiku-20240307',
            'max_tokens': maxTokens,
            'temperature': temperature,
            'system': systemPrompt,
            'messages': [
              {'role': 'user', 'content': userPrompt}
            ],
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final content = data['content'] as List<dynamic>?;
          if (content != null && content.isNotEmpty) {
            final text = content.first['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              debugPrint('ClaudeProvider: Success on attempt ${attempt + 1}');
              return text.trim();
            }
          }
        }

        if (attempt < maxRetries - 1) {
          final delayMs = 1000 * (attempt + 1);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
        attempt++;
      } catch (e) {
        debugPrint('ClaudeProvider: Attempt ${attempt + 1} failed: $e');
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
    final apiKey = AppSecrets.claudeApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('ClaudeProvider: API key not configured');
      return null;
    }

    try {
      final imageContent = imageBase64.map((img) => {
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': 'image/jpeg',
              'data': img,
            }
          }).toList();

      final response = await _client.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'claude-3-haiku-20240307',
          'max_tokens': maxTokens,
          'temperature': temperature,
          'system': systemPrompt,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': userPrompt},
                ...imageContent,
              ]
            }
          ],
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>?;
        if (content != null && content.isNotEmpty) {
          final text = content.first['text'] as String?;
          if (text != null && text.trim().isNotEmpty) {
            debugPrint('ClaudeProvider: Vision success');
            return text.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('ClaudeProvider: Vision generation failed: $e');
    }

    return null;
  }
}

