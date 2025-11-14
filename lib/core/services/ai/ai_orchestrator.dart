import 'dart:math';
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
  final Random _random = Random.secure();

  /// Generate a unique seed for AI requests
  /// 
  /// Combines timestamp, random value, and context to ensure uniqueness
  int _generateSeed({
    required String featureKey,
    required DateTime date,
    Map<String, dynamic>? context,
  }) {
    final timestamp = date.millisecondsSinceEpoch;
    final randomValue = _random.nextInt(1000000);
    final contextHash = context != null ? context.toString().hashCode : 0;
    return (timestamp ^ randomValue ^ contextHash) & 0x7FFFFFFF;
  }

  /// Generate text with automatic provider fallback
  /// 
  /// Tries each provider in order until one succeeds.
  /// Includes seed and uniqueness instructions in prompts.
  /// Returns localized fallback message if all providers fail.
  Future<String> generate({
    required String featureKey, // e.g. "welcome", "dream", "coffee", "tarot"
    required String userPrompt,
    required String systemPrompt,
    String languageCode = 'tr',
    DateTime? date,
    Map<String, dynamic>? context,
    int? explicitSeed,
    int maxRetries = 3,
  }) async {
    final seed = explicitSeed ?? _generateSeed(
      featureKey: featureKey,
      date: date ?? DateTime.now(),
      context: context,
    );

    // Enhanced system prompt with uniqueness instructions
    final enhancedSystemPrompt = '''$systemPrompt

ÖNEMLİ KURALLAR (IMPORTANT RULES):
- Her yanıt benzersiz ve tekrar etmeyen olmalı (Each response must be unique and non-repetitive)
- Aynı bağlam için bile farklı cümle yapıları kullan (Use different sentence structures even for the same context)
- Kopyala-yapıştır dil kullanma (No copy-paste language)
- Seed: $seed - Bu seed'i kullanarak yanıtını varyasyonlarla oluştur (Use this seed to create variations in your response)
- Tarih/Saat: ${date ?? DateTime.now()} - Bu zaman bilgisini içer (Include this time information)
- En az 3-6 paragraf yaz, her paragrafta en az 3-4 cümle olsun (Write at least 3-6 paragraphs, each with at least 3-4 sentences)
''';

    // Enhanced user prompt with uniqueness enforcement
    final enhancedUserPrompt = '''$userPrompt

LÜTFEN ŞUNLARI YAP (PLEASE DO):
- Bu isteğe özel, benzersiz bir yanıt üret (Generate a unique response specific to this request)
- Daha önce kullandığın ifadeleri tekrar etme (Don't repeat expressions you've used before)
- Her cümleyi farklı bir açıdan yaz (Write each sentence from a different angle)
- Seed: $seed kullanarak içeriği çeşitlendir (Diversify content using seed: $seed)
''';

    int attempt = 0;
    while (attempt < maxRetries) {
      for (final client in _clients) {
        try {
          final result = await client.generateText(
            systemPrompt: enhancedSystemPrompt,
            userPrompt: enhancedUserPrompt,
            languageCode: languageCode,
            context: {
              ...?context,
              'featureKey': featureKey,
              'provider': client.name,
              'seed': seed,
              'timestamp': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
              'attempt': attempt,
            },
          ).timeout(
            Duration(seconds: 30),
            onTimeout: () {
              debugPrint('AiOrchestrator: ${client.name} timed out');
              return null;
            },
          );

          if (result != null && result.trim().isNotEmpty) {
            debugPrint('AiOrchestrator: Success with ${client.name} on attempt ${attempt + 1}');
            return result.trim();
          }
        } catch (e) {
          // Swallow error and try next provider
          debugPrint('AiOrchestrator: ${client.name} failed on attempt ${attempt + 1} - $e');
          continue;
        }
      }

      // If all providers failed, wait before retry with exponential backoff
      attempt++;
      if (attempt < maxRetries) {
        final delayMs = 1000 * pow(2, attempt - 1).toInt();
        debugPrint('AiOrchestrator: All providers failed, retrying in ${delayMs}ms...');
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    // Final fallback – short, localized friendly message (NOT static astrology text)
    debugPrint('AiOrchestrator: All providers failed after $maxRetries attempts');
    return languageCode == 'tr'
        ? 'Şu anda yorum üretirken bir sorun oluştu, lütfen tekrar dene.'
        : 'We couldn\'t generate your reading right now, please try again.';
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
