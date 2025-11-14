import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_secrets.dart';
import 'ai_client_base.dart';

/// DeepSeek AI client implementation
/// 
/// Uses DeepSeek REST API
/// API Key from .env: DEEPSEEK_API_KEY
class DeepSeekClient implements AiClientBase {
  DeepSeekClient({
    String? apiKey,
    http.Client? client,
  })  : _apiKey = apiKey ?? AppSecrets.deepSeekApiKey,
        _client = client ?? http.Client();

  final String? _apiKey;
  final http.Client _client;

  @override
  String get name => 'deepseek';

  @override
  Future<String?> generateText({
    required String systemPrompt,
    required String userPrompt,
    String? languageCode,
    Map<String, dynamic>? context,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('DeepSeekClient: API key not configured');
      return null;
    }

    try {
      final response = await _client.post(
        Uri.parse('https://api.deepseek.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.9,
          'max_tokens': 4096,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            debugPrint('DeepSeekClient: Success');
            return content.trim();
          }
        }
      }

      debugPrint('DeepSeekClient: HTTP ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('DeepSeekClient: Error - $e');
      return null;
    }
  }
}

