import 'package:flutter/foundation.dart';

import '../../config/app_secrets.dart';
import 'ai_client_base.dart';

/// Microsoft Copilot client implementation
/// 
/// Placeholder implementation - API endpoint to be determined
/// API Key from .env: COPILOT_API_KEY
class CopilotClient implements AiClientBase {
  CopilotClient({String? apiKey}) : _apiKey = apiKey ?? AppSecrets.copilotApiKey;

  final String? _apiKey;

  @override
  String get name => 'copilot';

  @override
  Future<String?> generateText({
    required String systemPrompt,
    required String userPrompt,
    String? languageCode,
    Map<String, dynamic>? context,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('CopilotClient: API key not configured');
      return null;
    }

    // TODO: Implement Microsoft Copilot API integration when available
    // For now, this is a placeholder that returns null
    debugPrint('CopilotClient: Not yet implemented');
    return null;
  }
}
