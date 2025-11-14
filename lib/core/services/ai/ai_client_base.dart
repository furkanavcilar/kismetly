/// Base interface for all AI providers
/// 
/// All AI clients must implement this interface to ensure
/// consistent API across providers and enable automatic fallback.
abstract class AiClientBase {
  /// Provider name (e.g. "gemini", "chatgpt", "copilot", "claude", "deepseek")
  String get name;

  /// Generate text using the AI provider
  /// 
  /// Returns null on any error (network, HTTP >=400, parsing, timeout).
  /// The orchestrator will handle fallback to the next provider.
  /// 
  /// [systemPrompt] - System instructions that define tone, structure, style
  /// [userPrompt] - The actual user request/query
  /// [languageCode] - Language code (e.g. "tr", "en")
  /// [context] - Additional context (zodiac sign, feature, date, etc.)
  Future<String?> generateText({
    required String systemPrompt,
    required String userPrompt,
    String? languageCode,
    Map<String, dynamic>? context,
  });
}
