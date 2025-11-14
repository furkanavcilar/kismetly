import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  static String? get openAiApiKey {
    // Try flutter_dotenv first
    final dotenvKey = dotenv.env['OPENAI_API_KEY'];
    if (dotenvKey != null && dotenvKey.isNotEmpty) {
      return dotenvKey;
    }
    
    // Fallback to environment variables
    const envKey = String.fromEnvironment('KISMETLY_OPENAI_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    final runtimeKey = Platform.environment['KISMETLY_OPENAI_KEY'];
    if (runtimeKey != null && runtimeKey.isNotEmpty) {
      return runtimeKey;
    }
    return null;
  }

  static String? get geminiApiKey {
    // Try flutter_dotenv first
    final dotenvKey = dotenv.env['GEMINI_API_KEY'];
    if (dotenvKey != null && dotenvKey.isNotEmpty) {
      return dotenvKey;
    }
    
    // Fallback to environment variables
    const envKey = String.fromEnvironment('KISMETLY_GEMINI_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    final runtimeKey = Platform.environment['KISMETLY_GEMINI_KEY'];
    if (runtimeKey != null && runtimeKey.isNotEmpty) {
      return runtimeKey;
    }
    return null;
  }

  static String? get claudeApiKey {
    // Try flutter_dotenv first
    final dotenvKey = dotenv.env['ANTHROPIC_API_KEY'];
    if (dotenvKey != null && dotenvKey.isNotEmpty) {
      return dotenvKey;
    }
    
    // Fallback to environment variables
    const envKey = String.fromEnvironment('KISMETLY_CLAUDE_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    final runtimeKey = Platform.environment['KISMETLY_CLAUDE_KEY'];
    if (runtimeKey != null && runtimeKey.isNotEmpty) {
      return runtimeKey;
    }
    return null;
  }

  static String? get copilotApiKey {
    // Try flutter_dotenv first
    final dotenvKey = dotenv.env['COPILOT_API_KEY'];
    if (dotenvKey != null && dotenvKey.isNotEmpty) {
      return dotenvKey;
    }
    
    // Fallback to environment variables
    const envKey = String.fromEnvironment('KISMETLY_COPILOT_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    final runtimeKey = Platform.environment['KISMETLY_COPILOT_KEY'];
    if (runtimeKey != null && runtimeKey.isNotEmpty) {
      return runtimeKey;
    }
    return null;
  }
}
