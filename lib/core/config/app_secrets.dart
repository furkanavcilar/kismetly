import 'dart:io';

class AppSecrets {
  static String? get openAiApiKey {
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
}
