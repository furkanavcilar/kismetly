import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_secrets.dart';
import 'ai_client_base.dart';

/// Claude (Anthropic) client implementation
/// 
/// Uses Anthropic REST API
/// API Key from .env: ANTHROPIC_API_KEY
class ClaudeClient implements AiClientBase {
  ClaudeClient({
    String? apiKey,
    http.Client? client,
  })  : _apiKey = apiKey ?? AppSecrets.claudeApiKey,
        _client = client ?? http.Client();

  final String? _apiKey;
  final http.Client _client;

  @override
  String get name => 'claude';

  @override
  Future<String?> generateText({
    required String systemPrompt,
    required String userPrompt,
    String? languageCode,
    Map<String, dynamic>? context,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('ClaudeClient: API key not configured');
      return null;
    }

    try {
      final response = await _client.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'x-api-key': _apiKey!,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 8192,
          'temperature': 0.9,
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
            debugPrint('ClaudeClient: Success');
            return text.trim();
          }
        }
      }

      debugPrint('ClaudeClient: HTTP ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('ClaudeClient: Error - $e');
      return null;
    }
  }
}
