import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_secrets.dart';
import 'ai_client_base.dart';

/// ChatGPT (OpenAI) client implementation
/// 
/// Uses OpenAI REST API
/// API Key from .env: OPENAI_API_KEY
class ChatGPTClient implements AiClientBase {
  ChatGPTClient({
    String? apiKey,
    http.Client? client,
  })  : _apiKey = apiKey ?? AppSecrets.openAiApiKey,
        _client = client ?? http.Client();

  final String? _apiKey;
  final http.Client _client;

  @override
  String get name => 'chatgpt';

  @override
  Future<String?> generateText({
    required String systemPrompt,
    required String userPrompt,
    String? languageCode,
    Map<String, dynamic>? context,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('ChatGPTClient: API key not configured');
      return null;
    }

    try {
      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
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
            debugPrint('ChatGPTClient: Success');
            return content.trim();
          }
        }
      }

      debugPrint('ChatGPTClient: HTTP ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('ChatGPTClient: Error - $e');
      return null;
    }
  }
}
