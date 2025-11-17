import 'package:flutter/foundation.dart';
import 'backend_api.dart';

class ApiHealthCheck {
  ApiHealthCheck({BackendApi? api}) : _api = api ?? BackendApi();

  final BackendApi _api;

  Future<bool> healthCheck() async {
    try {
      debugPrint('🔍 Starting API health check...');
      final response = await _api.get('/api/chat/test');
      debugPrint('✅ API health check passed: $response');
      return true;
    } catch (e) {
      debugPrint('❌ API health check failed: $e');
      return false;
    }
  }
}

