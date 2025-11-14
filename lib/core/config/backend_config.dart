import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Backend configuration service
/// Loads BACKEND_URL from .env file
class BackendConfig {
  static String get baseUrl {
    // Try to get from .env file
    final envUrl = dotenv.env['BACKEND_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Fallback for Android emulator
    return 'http://10.0.2.2:3000';
  }
  
  /// Get full API endpoint URL
  static String apiUrl(String endpoint) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }
}

