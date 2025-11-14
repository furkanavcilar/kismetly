import 'package:flutter/foundation.dart';

import 'ai_client_base.dart';
import 'gemini_client.dart';
import 'chatgpt_client.dart';
import 'copilot_client.dart';
import 'claude_client.dart';
import 'deepseek_client.dart';

/// Multi-provider AI orchestrator with automatic fallback
/// 
/// Tries providers in priority order:
/// 1. Gemini
/// 2. ChatGPT (OpenAI)
/// 3. Microsoft Copilot
/// 4. Claude (Anthropic)
/// 5. DeepSeek
/// 
/// Returns graceful fallback message if all providers fail.
class AiOrchestrator {
  /// Create orchestrator with list of enabled providers
  /// 
  /// Providers should be in priority order (Gemini first, then ChatGPT, etc.)
  AiOrchestrator(this._clients);

  final List<AiClientBase> _clients;

  /// Generate text with automatic provider fallback
  /// 
  /// Tries each provider in order until one succeeds.
  /// Returns localized fallback message if all fail.
  Future<String> generate({
    required String featureKey, // e.g. "welcome", "dream", "coffee", "tarot"
    required String userPrompt,
    required String systemPrompt,
    String languageCode = 'tr',
    Map<String, dynamic>? context,
  }) async {
    for (final client in _clients) {
      try {
        final result = await client.generateText(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
          languageCode: languageCode,
          context: {
            ...?context,
            'featureKey': featureKey,
            'provider': client.name,
          },
        );

        if (result != null && result.trim().isNotEmpty) {
          debugPrint('AiOrchestrator: Success with ${client.name}');
          return result.trim();
        }
      } catch (e) {
        // Swallow error and try next provider
        debugPrint('AiOrchestrator: ${client.name} failed - $e');
        continue;
      }
    }

    // Final fallback – short, localized friendly message
    debugPrint('AiOrchestrator: All providers failed, using fallback');
    return languageCode == 'tr'
        ? 'Şu anda kozmik kanallara tam olarak bağlanamıyorum. Lütfen kısa bir süre sonra tekrar dene.'
        : 'I cannot fully connect to the cosmic channels right now. Please try again in a moment.';
  }
}

/// Factory/service locator for creating and accessing AiOrchestrator
/// 
/// Creates orchestrator with all enabled providers in priority order.
class AiServiceLocator {
  static AiOrchestrator? _instance;

  /// Get singleton instance of AiOrchestrator
  static AiOrchestrator get instance {
    _instance ??= _createOrchestrator();
    return _instance!;
  }

  /// Create orchestrator with all enabled providers
  static AiOrchestrator _createOrchestrator() {
    final clients = <AiClientBase>[
      // Priority order: Gemini → ChatGPT → Copilot → Claude → DeepSeek
      GeminiClient(),
      ChatGPTClient(),
      CopilotClient(),
      ClaudeClient(),
      DeepSeekClient(),
    ];

    return AiOrchestrator(clients);
  }

  /// Reset instance (useful for testing)
  static void reset() {
    _instance = null;
  }
}
