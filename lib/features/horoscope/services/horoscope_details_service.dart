import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/ai/ai_orchestrator.dart';

/// Service for horoscope detail sections
/// 
/// Uses featureKey: "zodiac_ai_query"
/// AI request per section:
/// - General Traits
/// - Strengths
/// - Challenges
/// - Love & Relationships
/// - Career & Money
/// - Emotional Landscape
/// - Spiritual Journey
/// 
/// Cache 10 mins per section.
/// Allow manual refresh.
class HoroscopeDetailsService {
  HoroscopeDetailsService({
    AiOrchestrator? orchestrator,
    SharedPreferences? prefs,
  })  : _orchestrator = orchestrator ?? AiServiceLocator.instance,
        _prefsFuture = prefs != null
            ? Future.value(prefs)
            : SharedPreferences.getInstance();

  final AiOrchestrator _orchestrator;
  final Future<SharedPreferences> _prefsFuture;

  static const String _featureKey = 'zodiac_ai_query';
  static const int _cacheMinutes = 10;

  /// Available sections
  static const List<String> sections = [
    'general_traits',
    'strengths',
    'challenges',
    'love_relationships',
    'career_money',
    'emotional_landscape',
    'spiritual_journey',
  ];

  /// Section labels (localized)
  static Map<String, String> getSectionLabels(String language) {
    if (language == 'tr') {
      return {
        'general_traits': 'Genel Özellikler',
        'strengths': 'Güçlü Yönler',
        'challenges': 'Zorluklar',
        'love_relationships': 'Aşk & İlişkiler',
        'career_money': 'Kariyer & Para',
        'emotional_landscape': 'Duygusal Manzara',
        'spiritual_journey': 'Ruhsal Yolculuk',
      };
    } else {
      return {
        'general_traits': 'General Traits',
        'strengths': 'Strengths',
        'challenges': 'Challenges',
        'love_relationships': 'Love & Relationships',
        'career_money': 'Career & Money',
        'emotional_landscape': 'Emotional Landscape',
        'spiritual_journey': 'Spiritual Journey',
      };
    }
  }

  /// Get section content (cached 10 mins)
  Future<String> getSectionContent({
    required String sign,
    required String section,
    required String language,
    bool forceRefresh = false,
  }) async {
    final prefs = await _prefsFuture;
    final cacheKey = 'horoscope_detail_${sign}_${section}_$language';

    // Check cache if not forcing refresh
    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          final Map<String, dynamic> data = jsonDecode(cached);
          final timestamp = data['timestamp'] as int?;
          final content = data['content'] as String?;
          
          if (timestamp != null && content != null) {
            final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final now = DateTime.now();
            final diff = now.difference(cachedTime);
            
            if (diff.inMinutes < _cacheMinutes) {
              debugPrint('HoroscopeDetailsService: Using cached section $section');
              return content;
            }
          }
        } catch (e) {
          debugPrint('HoroscopeDetailsService: Error parsing cached section: $e');
        }
      }
    }

    // Generate new content
    final content = await _generateSectionContent(
      sign: sign,
      section: section,
      language: language,
    );

    // Cache with timestamp
    await prefs.setString(
      cacheKey,
      jsonEncode({
        'content': content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    return content;
  }

  /// Get all sections
  Future<Map<String, String>> getAllSections({
    required String sign,
    required String language,
    bool forceRefresh = false,
  }) async {
    final results = <String, String>{};
    
    for (final section in sections) {
      results[section] = await getSectionContent(
        sign: sign,
        section: section,
        language: language,
        forceRefresh: forceRefresh,
      );
    }
    
    return results;
  }

  /// Generate section content using AI orchestrator
  Future<String> _generateSectionContent({
    required String sign,
    required String section,
    required String language,
  }) async {
    final sectionLabels = getSectionLabels(language);
    final sectionLabel = sectionLabels[section] ?? section;

    final systemPrompt = language == 'tr'
        ? '''Sen profesyonel bir astrolog ve kozmik rehbersin. Burç detayları için derin analizler yazarsın. 2-3 paragraf yaz. Empatik, mistik ve destekleyici bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Analizler benzersiz ve kişisel olmalı. Yapay zeka, modeller veya teknolojiden asla bahsetme.'''
        : '''You are a professional astrologer and cosmic guide. You write deep analyses for zodiac details. Write 2-3 paragraphs. Use an empathetic, mystical, and supportive tone. Speak directly to the person using "you". Analyses must be unique and personal. Never mention AI, models, or technology.''';

    final sectionPrompts = language == 'tr'
        ? {
            'general_traits': 'Genel özellikler ve karakteristikler',
            'strengths': 'Güçlü yönler ve yetenekler',
            'challenges': 'Zorluklar ve gelişim alanları',
            'love_relationships': 'Aşk ve ilişkiler hakkında içgörüler',
            'career_money': 'Kariyer ve para konularında rehberlik',
            'emotional_landscape': 'Duygusal dünya ve içsel deneyimler',
            'spiritual_journey': 'Ruhsal gelişim ve kozmik bağlantılar',
          }
        : {
            'general_traits': 'General traits and characteristics',
            'strengths': 'Strengths and talents',
            'challenges': 'Challenges and areas for growth',
            'love_relationships': 'Insights about love and relationships',
            'career_money': 'Guidance on career and money matters',
            'emotional_landscape': 'Emotional world and inner experiences',
            'spiritual_journey': 'Spiritual growth and cosmic connections',
          };

    final sectionPrompt = sectionPrompts[section] ?? section;

    final userPrompt = language == 'tr'
        ? '''$sign burcu için "$sectionLabel" bölümü yaz. $sectionPrompt. 2-3 paragraf yaz.'''
        : '''Write the "$sectionLabel" section for $sign sign. $sectionPrompt. Write 2-3 paragraphs.''';

    try {
      // Generate unique seed for this sign + section combination
      final signHash = sign.hashCode;
      final sectionHash = section.hashCode;
      final seed = (signHash ^ sectionHash ^ DateTime.now().millisecondsSinceEpoch) & 0x7FFFFFFF;
      
      final result = await _orchestrator.generate(
        featureKey: _featureKey,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        languageCode: language,
        date: DateTime.now(),
        explicitSeed: seed,
        context: {
          'sign': sign,
          'section': section,
          'sectionLabel': sectionLabel,
        },
      );
      return result.trim();
    } catch (e) {
      debugPrint('HoroscopeDetailsService: Error generating section: $e');
      // Fallback content (error message, not static text)
      return language == 'tr'
          ? '$sign burcu için $sectionLabel bölümü üretilemiyor. Lütfen tekrar deneyin.'
          : 'Cannot generate $sectionLabel section for $sign sign. Please try again.';
    }
  }
}


