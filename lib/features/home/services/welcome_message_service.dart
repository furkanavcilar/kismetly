import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/ai/ai_orchestrator.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../services/monetization/monetization_service.dart';

/// Service for generating daily AI greeting messages
/// 
/// Uses featureKey: "welcome_message"
/// Generates 1-2 paragraphs of warm Turkish greeting
/// Context: userName, zodiacSign, date, time, maybe city
/// Cache per day in SharedPreferences
class WelcomeMessageService {
  WelcomeMessageService({
    AiOrchestrator? orchestrator,
    UsageLimiter? usageLimiter,
    SharedPreferences? prefs,
    MonetizationService? monetizationService,
  })  : _orchestrator = orchestrator ?? AiServiceLocator.instance,
        _usageLimiter = usageLimiter ?? UsageLimiter(monetizationService: monetizationService),
        _prefsFuture = prefs != null
            ? Future.value(prefs)
            : SharedPreferences.getInstance();

  final AiOrchestrator _orchestrator;
  final UsageLimiter _usageLimiter;
  final Future<SharedPreferences> _prefsFuture;

  static const String _featureKey = UsageLimiter.featureWelcomeMessage;

  /// Get date stamp for today (YYYY-MM-DD)
  String _dayStamp(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  /// Generate or retrieve cached greeting message
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

    // Create cache key
    final cacheKey = 'welcome_${username}_${zodiacSign ?? 'unknown'}_${city ?? 'nocity'}_${language}_$dayKey';

    // Check cache if not forcing refresh
    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        debugPrint('WelcomeMessageService: Using cached greeting');
        return cached;
      }
    }

    // Generate new greeting using orchestrator
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

  /// Generate greeting using AI orchestrator
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

    final contextInfo = <String>[];
    if (zodiacSign != null) {
      contextInfo.add(language == 'tr' ? 'Zodyak işareti: $zodiacSign' : 'Zodiac sign: $zodiacSign');
    }
    if (city != null) {
      contextInfo.add(language == 'tr' ? 'Şehir: $city' : 'City: $city');
    }

    final userPrompt = language == 'tr'
        ? '''$username için bugünün ($dateStr, saat $timeStr) karşılama mesajını yaz. ${zodiacSign != null ? 'Zodyak işareti: $zodiacSign. ' : ''}${city != null ? 'Şehir: $city. ' : ''}Mesaj 1-2 paragraf olmalı, kişisel ve sıcak olmalı. Mistik bir ton kullan.'''
        : '''Write today's ($dateStr at $timeStr) greeting message for $username. ${zodiacSign != null ? 'Zodiac sign: $zodiacSign. ' : ''}${city != null ? 'City: $city. ' : ''}Message should be 1-2 paragraphs, personal and warm. Use a mystical tone.''';

    try {
      final result = await _orchestrator.generate(
        featureKey: _featureKey,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        languageCode: language,
        context: {
          'username': username,
          if (zodiacSign != null) 'zodiacSign': zodiacSign,
          if (city != null) 'city': city,
          'date': dateStr,
          'time': timeStr,
        },
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
