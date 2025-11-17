import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/config/backend_config.dart';

class BackendApi {
  BackendApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl != null && baseUrl.isNotEmpty) {
      return baseUrl;
    }
    // Fallback for Android emulator
    return 'http://10.0.2.2:3000';
  }

  String _buildUrl(String endpoint) {
    final base = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = _buildUrl(endpoint);
    final uri = Uri.parse(url);
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    final bodyJson = body != null ? jsonEncode(body) : null;
    
    print('➡️ Request to: $url');
    print('📤 Method: $method');
    if (bodyJson != null) {
      print('📤 Body: $bodyJson');
    }

    try {
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: requestHeaders).timeout(
            const Duration(seconds: 10),
          );
          break;
        case 'POST':
          response = await _client.post(uri, headers: requestHeaders, body: bodyJson).timeout(
            const Duration(seconds: 10),
          );
          break;
        case 'PUT':
          response = await _client.put(uri, headers: requestHeaders, body: bodyJson).timeout(
            const Duration(seconds: 10),
          );
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: requestHeaders).timeout(
            const Duration(seconds: 10),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('⬅️ Response: ${response.statusCode}');
      print('⬅️ Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else {
        throw Exception('API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Request error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) {
    return _request(method: 'GET', endpoint: endpoint, headers: headers);
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) {
    return _request(method: 'POST', endpoint: endpoint, body: body, headers: headers);
  }

  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) {
    return _request(method: 'PUT', endpoint: endpoint, body: body, headers: headers);
  }

  Future<Map<String, dynamic>> delete(String endpoint, {Map<String, String>? headers}) {
    return _request(method: 'DELETE', endpoint: endpoint, headers: headers);
  }
}

