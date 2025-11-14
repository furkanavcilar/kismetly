import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ai/ai_client.dart';

/// Service for daily horoscope with multiple paragraphs
/// 
/// Generates multi-paragraph text for:
/// - general
/// - love
/// - career
/// - spiritual
/// 
/// Daily cached per sign.
class DailyHoroscopeService {
  DailyHoroscopeService({
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

  /// Daily horoscope structure
  class DailyHoroscope {
    final String general;
    final String love;
    final String career;
    final String spiritual;

    DailyHoroscope({
      required this.general,
      required this.love,
      required this.career,
      required this.spiritual,
    });

    Map<String, dynamic> toJson() {
      return {
        'general': general,
        'love': love,
        'career': career,
        'spiritual': spiritual,
      };
    }

    static DailyHoroscope fromJson(Map<String, dynamic> json) {
      return DailyHoroscope(
        general: json['general'] as String? ?? '',
        love: json['love'] as String? ?? '',
        career: json['career'] as String? ?? '',
        spiritual: json['spiritual'] as String? ?? '',
      );
    }
  }

  /// Get daily horoscope (cached per day)
  Future<DailyHoroscope> getHoroscope({
    required String sign,
    required DateTime date,
    required String language,
    String? risingSign,
    bool forceRefresh = false,
  }) async {
    final today = date;
    final dayKey = _dayStamp(today);
    final prefs = await _prefsFuture;

    // Create cache key
    final cacheKey = 'daily_horoscope_${sign}_${risingSign ?? 'none'}_${language}_$dayKey';

    // Check cache if not forcing refresh
    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          final json = jsonDecode(cached) as Map<String, dynamic>;
          debugPrint('DailyHoroscopeService: Using cached horoscope');
          return DailyHoroscope.fromJson(json);
        } catch (e) {
          debugPrint('DailyHoroscopeService: Error parsing cached horoscope: $e');
        }
      }
    }

    // Generate new horoscope
    final horoscope = await _generateHoroscope(
      sign: sign,
      date: today,
      language: language,
      risingSign: risingSign,
    );

    // Cache the result
    await prefs.setString(cacheKey, jsonEncode(horoscope.toJson()));

    return horoscope;
  }

  /// Generate horoscope using AI
  Future<DailyHoroscope> _generateHoroscope({
    required String sign,
    required DateTime date,
    required String language,
    String? risingSign,
  }) async {
    final systemPrompt = language == 'tr'
        ? '''Sen profesyonel bir astrolog ve kozmik rehbersin. Günlük burç yorumları yazarsın. Her bölüm için 2-3 paragraf yaz. Empatik, mistik ve destekleyici bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Yorumlar benzersiz ve kişisel olmalı. Yapay zeka, modeller veya teknolojiden asla bahsetme.'''
        : '''You are a professional astrologer and cosmic guide. You write daily horoscopes. Write 2-3 paragraphs per section. Use an empathetic, mystical, and supportive tone. Speak directly to the person using "you". Horoscopes must be unique and personal. Never mention AI, models, or technology.''';

    final dateStr = '${date.day}/${date.month}/${date.year}';
    final risingText = risingSign != null ? ' ve $risingSign yükselen burcu' : '';
    
    final userPrompt = language == 'tr'
        ? '''$sign burcu$risingText için bugünün ($dateStr) günlük burç yorumunu yaz:

Genel: 2-3 paragraf
Aşk: 2-3 paragraf
Kariyer: 2-3 paragraf
Ruhsal: 2-3 paragraf

Her bölümü ayrı başlıklarla yaz.'''
        : '''Write today's ($dateStr) daily horoscope for $sign sign$risingText:

General: 2-3 paragraphs
Love: 2-3 paragraphs
Career: 2-3 paragraphs
Spiritual: 2-3 paragraphs

Write each section with separate headers.''';

    try {
      final result = await _aiClient.generate(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        language: language,
        seed: _generateSeed(sign, risingSign, date),
        temperature: 0.9,
      );

      return _parseHoroscope(result, language);
    } catch (e) {
      debugPrint('DailyHoroscopeService: Error generating horoscope: $e');
      // Fallback horoscope
      return _getFallbackHoroscope(language);
    }
  }

  DailyHoroscope _parseHoroscope(String text, String language) {
    // Parse horoscope sections
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    final Map<String, StringBuffer> sections = {
      'general': StringBuffer(),
      'love': StringBuffer(),
      'career': StringBuffer(),
      'spiritual': StringBuffer(),
    };

    String? currentSection;
    
    for (final line in lines) {
      final lower = line.toLowerCase();
      
      if (lower.contains('genel') || lower.contains('general')) {
        currentSection = 'general';
        continue;
      } else if (lower.contains('aşk') || lower.contains('love')) {
        currentSection = 'love';
        continue;
      } else if (lower.contains('kariyer') || lower.contains('career')) {
        currentSection = 'career';
        continue;
      } else if (lower.contains('ruhsal') || lower.contains('spiritual')) {
        currentSection = 'spiritual';
        continue;
      }

      if (currentSection != null && sections.containsKey(currentSection)) {
        if (sections[currentSection]!.isNotEmpty) {
          sections[currentSection]!.write(' ');
        }
        sections[currentSection]!.write(line);
      }
    }

    return DailyHoroscope(
      general: sections['general']!.isEmpty 
          ? (language == 'tr' ? 'Bugün genel enerjiler dengeli ve uyumlu.' : 'Today\'s general energies are balanced and harmonious.') 
          : sections['general']!.toString().trim(),
      love: sections['love']!.isEmpty 
          ? (language == 'tr' ? 'Aşk alanında yeni fırsatlar var.' : 'New opportunities in love.') 
          : sections['love']!.toString().trim(),
      career: sections['career']!.isEmpty 
          ? (language == 'tr' ? 'Kariyer alanında ilerleme görünüyor.' : 'Progress is visible in career.') 
          : sections['career']!.toString().trim(),
      spiritual: sections['spiritual']!.isEmpty 
          ? (language == 'tr' ? 'Ruhsal gelişim için uygun zaman.' : 'Good time for spiritual growth.') 
          : sections['spiritual']!.toString().trim(),
    );
  }

  DailyHoroscope _getFallbackHoroscope(String language) {
    if (language == 'tr') {
      return DailyHoroscope(
        general: 'Bugün genel enerjiler dengeli ve uyumlu. Kozmik döngüler seni destekliyor.',
        love: 'Aşk alanında yeni fırsatlar var. Bağlantılarını güçlendirme zamanı.',
        career: 'Kariyer alanında ilerleme görünüyor. Yeni projeler için uygun bir gün.',
        spiritual: 'Ruhsal gelişim için uygun zaman. İç sesini dinlemeye odaklan.',
      );
    } else {
      return DailyHoroscope(
        general: 'Today\'s general energies are balanced and harmonious. Cosmic cycles support you.',
        love: 'New opportunities in love. Time to strengthen connections.',
        career: 'Progress is visible in career. A good day for new projects.',
        spiritual: 'Good time for spiritual growth. Focus on listening to your inner voice.',
      );
    }
  }

  int _generateSeed(String sign, String? risingSign, DateTime date) {
    final combined = '$sign|${risingSign ?? ''}|${_dayStamp(date)}';
    return combined.hashCode;
  }
}

