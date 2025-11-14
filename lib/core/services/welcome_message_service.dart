import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ai/ai_client.dart';
import '../../services/ai_engine/prompts/greeting_prompt.dart';

/// Service for generating daily AI greeting messages
/// 
/// Generates personal greeting with:
/// - username
/// - zodiac sign
/// - date/time
/// - city (if exists)
/// 
/// Cache per day (date-based keys)
class WelcomeMessageService {
  WelcomeMessageService({
    AiClient? aiClient,
    SharedPreferences? prefs,
  })  : _aiClient = aiClient ?? AiClient(),
        _prefsFuture = prefs != null
            ? Future.value(prefs)
            : SharedPreferences.getInstance();

  final AiClient _aiClient;
  final Future<SharedPreferences> _prefsFuture;

  /// Get date stamp for today (YYYY-MM-DD)
  String _dayStamp(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  /// Generate or retrieve cached greeting message
  /// 
  /// Cached per day based on username, zodiac sign, and city
  Future<String> getWelcomeMessage({
    required String username,
    required String? zodiacSign,
    required DateTime date,
    required String language,
    String? city,
    bool forceRefresh = false,
  }) async {
    final today = date;
    final dayKey = _dayStamp(today);
    final prefs = await _prefsFuture;

    // Create cache key based on username, zodiac, city, and date
    final cacheKey = 'welcome_${username}_${zodiacSign ?? 'unknown'}_${city ?? 'nocity'}_${language}_$dayKey';

    // Check cache if not forcing refresh
    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        debugPrint('WelcomeMessageService: Using cached greeting');
        return cached;
      }
    }

    // Generate new greeting
    final greeting = await _generateGreeting(
      username: username,
      zodiacSign: zodiacSign,
      date: today,
      language: language,
      city: city,
    );

    // Cache the result
    await prefs.setString(cacheKey, greeting);

    return greeting;
  }

  /// Generate greeting using AI
  Future<String> _generateGreeting({
    required String username,
    required String? zodiacSign,
    required DateTime date,
    required String language,
    String? city,
  }) async {
    final dateStr = language == 'tr'
        ? '${date.day} ${_monthNameTr(date.month)} ${date.year}'
        : '${date.month}/${date.day}/${date.year}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final systemPrompt = language == 'tr'
        ? '''Sen sıcak, dostane ve kişisel bir kozmik rehbersin. Günlük karşılama mesajları yazarsın. Empatik, mistik ve destekleyici bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Mesajlar benzersiz ve kişisel olmalı. Yapay zeka, modeller veya teknolojiden asla bahsetme.'''
        : '''You are a warm, friendly, and personal cosmic guide. You write daily greeting messages. Use an empathetic, mystical, and supportive tone. Speak directly to the person using "you". Messages must be unique and personal. Never mention AI, models, or technology.''';

    final userContext = <String, dynamic>{
      'name': username,
      'zodiac': zodiacSign ?? 'unknown',
      if (city != null) 'city': city,
    };

    final userPrompt = language == 'tr'
        ? '''$username için bugünün ($dateStr, saat $timeStr) karşılama mesajını yaz. ${zodiacSign != null ? 'Zodyak işareti: $zodiacSign. ' : ''}${city != null ? 'Şehir: $city. ' : ''}Mesaj 2-3 cümle olmalı, kişisel ve sıcak olmalı. Mistik bir ton kullan.'''
        : '''Write today's ($dateStr at $timeStr) greeting message for $username. ${zodiacSign != null ? 'Zodiac sign: $zodiacSign. ' : ''}${city != null ? 'City: $city. ' : ''}Message should be 2-3 sentences, personal and warm. Use a mystical tone.''';

    try {
      final result = await _aiClient.generate(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        language: language,
        seed: _generateSeed(username, zodiacSign, city, date),
        temperature: 0.9,
      );
      return result.trim();
    } catch (e) {
      debugPrint('WelcomeMessageService: Error generating greeting: $e');
      // Fallback message
      return language == 'tr'
          ? 'Merhaba $username! Bugünün kozmik enerjileri seninle birlikte. 🌟'
          : 'Hello $username! Today\'s cosmic energies are with you. 🌟';
    }
  }

  int _generateSeed(String username, String? zodiac, String? city, DateTime date) {
    final combined = '$username|${zodiac ?? ''}|${city ?? ''}|${_dayStamp(date)}';
    return combined.hashCode;
  }

  String _monthNameTr(int month) {
    const names = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return names[month - 1];
  }
}

